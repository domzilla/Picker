import AppKit
import Combine
import DZFoundation
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

    // MARK: - Private Properties

    private var stream: SCStream?
    private var currentDisplay: SCDisplay?
    private var currentCursorLocation: NSPoint = .zero
    private let streamQueue = DispatchQueue(label: "net.domzilla.picker.screencapture", qos: .userInteractive)

    /// Padding info for edge captures (accessed from stream queue)
    private nonisolated(unsafe) var currentPaddingInfo: PaddingInfo?

    /// Information needed to pad a captured image
    private struct PaddingInfo: Sendable {
        let requestedRect: CGRect
        let clampedRect: CGRect
        let scaleFactor: CGFloat
    }

    // MARK: - Streaming API

    /// Start the capture stream on the display containing the cursor
    func start() async throws {
        guard !self.isRunning else { return }

        let content = try await SCShareableContent.excludingDesktopWindows(
            false,
            onScreenWindowsOnly: true
        )

        // Find the display containing the cursor
        let cursorLocation = NSEvent.mouseLocation.quartzCoordinate

        guard let display = self.display(containing: cursorLocation, from: content.displays) else {
            return
        }

        self.currentDisplay = display
        self.currentCursorLocation = cursorLocation

        // Create stream with content filter for the display
        let filter = SCContentFilter(display: display, excludingWindows: [])
        let config = self.createStreamConfiguration(for: cursorLocation, display: display)

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

    /// Update the capture rectangle for a new cursor location
    /// - Parameter location: New cursor location in Quartz coordinates (top-left origin)
    func updateCaptureRect(for location: NSPoint) async {
        guard self.isRunning, let stream = self.stream else { return }

        self.currentCursorLocation = location

        // Check if cursor moved to a different display
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(
                false,
                onScreenWindowsOnly: true
            )

            // Re-check running state after async operation (stop() may have been called)
            guard self.isRunning else { return }

            if
                let newDisplay = self.display(containing: location, from: content.displays),
                newDisplay.displayID != self.currentDisplay?.displayID
            {
                // Cursor crossed to a new display - restart stream
                await self.stop()
                try await self.start()
                return
            }
        } catch {
            DZErrorLog(error)
        }

        // Re-check running state before updating configuration
        guard self.isRunning, let display = self.currentDisplay else { return }

        let config = self.createStreamConfiguration(for: location, display: display)
        do {
            try await stream.updateConfiguration(config)
        } catch {
            DZErrorLog(error)
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

    /// Create stream configuration for capturing around the given location
    private func createStreamConfiguration(for location: NSPoint, display: SCDisplay) -> SCStreamConfiguration {
        let config = SCStreamConfiguration()
        let halfSize = Self.captureSize / 2

        // Calculate the source rect in display-local coordinates
        let displayBounds = CGRect(
            x: CGFloat(display.frame.origin.x),
            y: CGFloat(display.frame.origin.y),
            width: CGFloat(display.width),
            height: CGFloat(display.height)
        )

        // Convert global cursor location to display-local coordinates
        let localX = location.x - displayBounds.origin.x
        let localY = location.y - displayBounds.origin.y

        // Requested rect around cursor
        let requestedRect = CGRect(
            x: localX - halfSize,
            y: localY - halfSize,
            width: Self.captureSize,
            height: Self.captureSize
        )

        // Clamp to display bounds (in local coordinates)
        let localDisplayBounds = CGRect(
            x: 0,
            y: 0,
            width: displayBounds.width,
            height: displayBounds.height
        )
        let clampedRect = requestedRect.intersection(localDisplayBounds)

        // Use clamped rect if valid, otherwise use the full requested rect
        let sourceRect = clampedRect.isEmpty ? requestedRect : clampedRect

        // Get display scale factor for proper resolution
        let scaleFactor = NSScreen.backingScaleFactor(for: display.displayID)

        // Output size matches the clamped rect (will be padded later if needed)
        let outputWidth = Int(sourceRect.width * scaleFactor)
        let outputHeight = Int(sourceRect.height * scaleFactor)

        // Store padding info if capture is at screen edge
        if clampedRect != requestedRect, !clampedRect.isEmpty {
            self.currentPaddingInfo = PaddingInfo(
                requestedRect: requestedRect,
                clampedRect: clampedRect,
                scaleFactor: scaleFactor
            )
        } else {
            self.currentPaddingInfo = nil
        }

        config.sourceRect = sourceRect
        config.captureResolution = .best
        config.width = outputWidth
        config.height = outputHeight
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

    /// Convert a CMSampleBuffer to NSImage, applying padding if at screen edge
    private nonisolated func image(from sampleBuffer: CMSampleBuffer) -> NSImage? {
        guard let imageBuffer = sampleBuffer.imageBuffer else { return nil }

        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let context = CIContext()

        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }

        // Check if padding is needed (capture was at screen edge)
        if let paddingInfo = self.currentPaddingInfo {
            return .paddedImage(
                cgImage: cgImage,
                capturedRect: paddingInfo.clampedRect,
                requestedRect: paddingInfo.requestedRect
            )
        }

        return NSImage(
            cgImage: cgImage,
            size: NSSize(width: Self.captureSize, height: Self.captureSize)
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
        guard let image = self.image(from: sampleBuffer) else { return }

        Task { @MainActor in
            self.latestFrame = image
        }
    }
}
