import AppKit
import Combine
import DZFoundation
import Metal
import ScreenCaptureKit

/// Manages screen capture for color picking with two modes:
/// - Streaming mode (SCStream): For continuous preview when UI is visible
/// - One-shot mode (SCScreenshotManager): For hotkey color copy when no UI visible
@MainActor
final class ScreenCapture: NSObject, ObservableObject {
    // MARK: - Published Properties

    /// Latest captured frame from the stream
    @Published private(set) var latestFrame: NSImage?

    /// Whether the stream is currently running
    @Published private(set) var isRunning: Bool = false

    // MARK: - Constants

    /// Size of the preview capture area
    nonisolated static let captureSize: CGFloat = 28

    /// Target frame rate for streaming
    private nonisolated static let targetFrameRate: Int = 60

    /// Shared CIContext with Metal GPU acceleration for efficient frame processing
    private nonisolated static let ciContext: CIContext = {
        if let device = MTLCreateSystemDefaultDevice() {
            return CIContext(mtlDevice: device)
        }
        return CIContext()
    }()

    // MARK: - Private Properties

    private var stream: SCStream?
    private var currentDisplay: SCDisplay?
    private let streamQueue = DispatchQueue(label: "net.domzilla.picker.screencapture", qos: .userInteractive)

    /// Current cursor location in display-local Quartz coordinates (accessed from stream queue)
    private nonisolated(unsafe) var cursorLocationInDisplay: NSPoint = .zero

    /// Current display bounds in Quartz coordinates (accessed from stream queue)
    private nonisolated(unsafe) var displayBounds: CGRect = .zero

    /// Scale factor of current display (accessed from stream queue)
    private nonisolated(unsafe) var displayScaleFactor: CGFloat = 2.0

    /// Cached display list to avoid repeated SCShareableContent calls (which trigger TCC checks)
    private var cachedDisplays: [SCDisplay] = []

    // MARK: - Initialization

    override init() {
        super.init()

        // Listen for display configuration changes (monitor connect/disconnect, arrangement changes)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.screenParametersDidChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    // MARK: - Streaming API

    /// Start the capture stream on the display containing the cursor
    func start() async throws {
        guard !self.isRunning else { return }

        // Refresh display cache (this triggers TCC check, but only once at start)
        try await self.refreshDisplayCache()

        // Find the display containing the cursor
        let cursorLocation = NSEvent.mouseLocation.quartzCoordinate

        guard let display = self.display(containing: cursorLocation, from: self.cachedDisplays) else {
            return
        }

        self.currentDisplay = display

        // Store display info for frame cropping (accessed from stream queue)
        let bounds = CGRect(
            x: CGFloat(display.frame.origin.x),
            y: CGFloat(display.frame.origin.y),
            width: CGFloat(display.width),
            height: CGFloat(display.height)
        )
        self.displayBounds = bounds
        self.displayScaleFactor = NSScreen.backingScaleFactor(for: display.displayID)

        // Convert cursor to display-local coordinates
        self.cursorLocationInDisplay = NSPoint(
            x: cursorLocation.x - bounds.origin.x,
            y: cursorLocation.y - bounds.origin.y
        )

        // Create stream with content filter for the display (captures full screen)
        let filter = SCContentFilter(display: display, excludingWindows: [])
        let config = self.createStreamConfiguration(for: display)

        let stream = SCStream(filter: filter, configuration: config, delegate: self)
        try stream.addStreamOutput(self, type: .screen, sampleHandlerQueue: self.streamQueue)

        try await stream.startCapture()
        self.stream = stream
        self.isRunning = true

        DZLog("Capture stream started on display \(display.displayID)")
    }

    /// Stop the capture stream
    func stop() async {
        guard self.isRunning, let stream = self.stream else { return }

        do {
            try await stream.stopCapture()
        } catch {
            DZErrorLog(error)
        }

        self.stream = nil
        self.currentDisplay = nil
        self.isRunning = false
        self.latestFrame = nil

        DZLog("Capture stream stopped")
    }

    /// Update cursor location for frame cropping (no TCC check - just geometry!)
    /// - Parameter location: New cursor location in Quartz coordinates (top-left origin)
    func updateCursorLocation(_ location: NSPoint) async {
        // Check if cursor moved to a different display using cached display list
        if
            let newDisplay = self.display(containing: location, from: self.cachedDisplays),
            newDisplay.displayID != self.currentDisplay?.displayID
        {
            // Cursor crossed to a new display - restart stream on new display
            await self.stop()
            do {
                try await self.start()
            } catch {
                DZErrorLog(error)
            }
            return
        }

        // Update cursor location for frame cropping (no TCC check!)
        if let display = self.currentDisplay {
            let bounds = CGRect(
                x: CGFloat(display.frame.origin.x),
                y: CGFloat(display.frame.origin.y),
                width: CGFloat(display.width),
                height: CGFloat(display.height)
            )
            self.cursorLocationInDisplay = NSPoint(
                x: location.x - bounds.origin.x,
                y: location.y - bounds.origin.y
            )
        }
    }

    // MARK: - Display Change Handling

    /// Called when display configuration changes (monitor connect/disconnect, arrangement, resolution)
    @objc
    private func screenParametersDidChange(_: Notification) {
        guard self.isRunning else { return }

        DZLog("Display configuration changed, restarting stream")

        Task {
            // Restart stream to pick up new display configuration
            await self.stop()
            do {
                try await self.start()
            } catch {
                DZErrorLog(error)
            }
        }
    }

    // MARK: - One-Shot Capture

    /// Capture a single image around the given screen location (one-shot mode)
    /// Use this for hotkey color copy when no UI is visible.
    /// For continuous preview, use the streaming API instead.
    /// - Parameter location: The screen location in Quartz coordinates (origin at top-left)
    /// - Returns: An image of the area around the location
    nonisolated static func captureOnce(at location: NSPoint) async -> NSImage? {
        let halfSize = self.captureSize / 2
        let requestedRect = CGRect(
            x: location.x - halfSize,
            y: location.y - halfSize,
            width: self.captureSize,
            height: self.captureSize
        )

        // Get all screen bounds to determine valid capture area
        let screenBounds = self.combinedScreenBounds()

        // Clamp capture rect to screen bounds
        let clampedRect = requestedRect.intersection(screenBounds)

        // If completely off-screen, return a black image
        guard !clampedRect.isEmpty else {
            return .blackImage(size: NSSize(width: self.captureSize, height: self.captureSize))
        }

        let config = SCScreenshotConfiguration()
        config.showsCursor = false

        do {
            let cgImage: CGImage? = try await withCheckedThrowingContinuation { continuation in
                SCScreenshotManager.captureScreenshot(
                    rect: clampedRect,
                    configuration: config
                ) { output, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: output?.sdrImage)
                    }
                }
            }

            guard let cgImage else {
                return nil
            }

            // If the captured rect matches the requested rect, no padding needed
            if clampedRect == requestedRect {
                return NSImage(
                    cgImage: cgImage,
                    size: NSSize(width: self.captureSize, height: self.captureSize)
                )
            }

            // Need to pad the image with black where it extends beyond screen
            return .paddedImage(
                cgImage: cgImage,
                capturedRect: clampedRect,
                requestedRect: requestedRect
            )
        } catch {
            return nil
        }
    }

    // MARK: - Shared Utilities

    /// Get the combined bounds of all connected screens in Quartz coordinates
    nonisolated static func combinedScreenBounds() -> CGRect {
        var combinedBounds = CGRect.zero
        let maxDisplays: UInt32 = 16
        var displays = [CGDirectDisplayID](repeating: 0, count: Int(maxDisplays))
        var displayCount: UInt32 = 0

        CGGetActiveDisplayList(maxDisplays, &displays, &displayCount)

        for i in 0..<Int(displayCount) {
            let displayBounds = CGDisplayBounds(displays[i])
            combinedBounds = combinedBounds.union(displayBounds)
        }

        return combinedBounds
    }

    // MARK: - Private Helpers (Streaming)

    /// Refresh the cached display list from SCShareableContent
    /// This triggers a TCC check, so only called at stream start and on display config changes
    private func refreshDisplayCache() async throws {
        let content = try await SCShareableContent.excludingDesktopWindows(
            false,
            onScreenWindowsOnly: true
        )
        self.cachedDisplays = content.displays
    }

    /// Create stream configuration for capturing the full display
    private func createStreamConfiguration(for display: SCDisplay) -> SCStreamConfiguration {
        let config = SCStreamConfiguration()
        let scaleFactor = NSScreen.backingScaleFactor(for: display.displayID)

        // Capture the full display - no sourceRect means full screen
        config.width = Int(CGFloat(display.width) * scaleFactor)
        config.height = Int(CGFloat(display.height) * scaleFactor)
        config.captureResolution = .best
        config.showsCursor = false
        config.minimumFrameInterval = CMTime(value: 1, timescale: CMTimeScale(Self.targetFrameRate))
        config.queueDepth = 3
        config.pixelFormat = kCVPixelFormatType_32BGRA

        return config
    }

    /// Find the display containing the given point
    private func display(containing point: NSPoint, from displays: [SCDisplay]) -> SCDisplay? {
        for display in displays {
            let bounds = CGRect(
                x: CGFloat(display.frame.origin.x),
                y: CGFloat(display.frame.origin.y),
                width: CGFloat(display.width),
                height: CGFloat(display.height)
            )
            if bounds.contains(point) {
                return display
            }
        }
        // Fall back to main display if point is outside all displays
        return displays.first { $0.displayID == CGMainDisplayID() } ?? displays.first
    }

    /// Extract the 28×28 area around the cursor from a full-screen frame
    private nonisolated func extractPreviewImage(from sampleBuffer: CMSampleBuffer) -> NSImage? {
        guard let imageBuffer = sampleBuffer.imageBuffer else { return nil }

        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let imageWidth = ciImage.extent.width
        let imageHeight = ciImage.extent.height

        let scaleFactor = self.displayScaleFactor
        let captureSize = Self.captureSize
        let halfSize = captureSize / 2
        let scaledCaptureSize = captureSize * scaleFactor

        // Get cursor position in pixel coordinates (Quartz: top-left origin)
        let cursorPixelX = self.cursorLocationInDisplay.x * scaleFactor
        let cursorPixelY = self.cursorLocationInDisplay.y * scaleFactor

        // CIImage has origin at bottom-left, so flip Y
        let cursorCIY = imageHeight - cursorPixelY

        // Calculate the crop rect centered on cursor (in CIImage coordinates)
        let cropRect = CGRect(
            x: cursorPixelX - halfSize * scaleFactor,
            y: cursorCIY - halfSize * scaleFactor,
            width: scaledCaptureSize,
            height: scaledCaptureSize
        )

        // Clamp to image bounds
        let imageBounds = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        let clampedRect = cropRect.intersection(imageBounds)

        // If completely outside, return black
        guard !clampedRect.isEmpty else {
            return .blackImage(size: NSSize(width: captureSize, height: captureSize))
        }

        // Crop the CIImage
        let croppedCI = ciImage.cropped(to: clampedRect)

        guard let cgImage = Self.ciContext.createCGImage(croppedCI, from: croppedCI.extent) else {
            return nil
        }

        // If crop matches requested size, no padding needed
        if clampedRect.width == scaledCaptureSize, clampedRect.height == scaledCaptureSize {
            return NSImage(cgImage: cgImage, size: NSSize(width: captureSize, height: captureSize))
        }

        // Need to pad with black for edge cases
        // Convert from CIImage coords (origin bottom-left) to Quartz coords (origin top-left)
        // Quartz_Y = imageHeight - CIImage_Y - rect.height
        let quartzCropRect = CGRect(
            x: cropRect.origin.x,
            y: imageHeight - cropRect.origin.y - cropRect.height,
            width: cropRect.width,
            height: cropRect.height
        )
        let quartzClampedRect = CGRect(
            x: clampedRect.origin.x,
            y: imageHeight - clampedRect.origin.y - clampedRect.height,
            width: clampedRect.width,
            height: clampedRect.height
        )

        // Convert to logical coordinates (divide by scale factor)
        let logicalCropRect = CGRect(
            x: quartzCropRect.origin.x / scaleFactor,
            y: quartzCropRect.origin.y / scaleFactor,
            width: captureSize,
            height: captureSize
        )
        let logicalClampedRect = CGRect(
            x: quartzClampedRect.origin.x / scaleFactor,
            y: quartzClampedRect.origin.y / scaleFactor,
            width: quartzClampedRect.width / scaleFactor,
            height: quartzClampedRect.height / scaleFactor
        )

        return .paddedImage(
            cgImage: cgImage,
            capturedRect: logicalClampedRect,
            requestedRect: logicalCropRect
        )
    }
}

// MARK: - SCStreamDelegate

extension ScreenCapture: SCStreamDelegate {
    nonisolated func stream(_: SCStream, didStopWithError error: Error) {
        DZErrorLog(error)
        Task { @MainActor in
            self.isRunning = false
            self.stream = nil
        }
    }
}

// MARK: - SCStreamOutput

extension ScreenCapture: SCStreamOutput {
    nonisolated func stream(
        _: SCStream,
        didOutputSampleBuffer sampleBuffer: CMSampleBuffer,
        of type: SCStreamOutputType
    ) {
        guard type == .screen else { return }
        guard let image = self.extractPreviewImage(from: sampleBuffer) else { return }

        Task { @MainActor in
            self.latestFrame = image
        }
    }
}
