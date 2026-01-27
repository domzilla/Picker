import AppKit
import Combine
import DZFoundation
import ScreenCaptureKit

/// Manages continuous screen capture via SCStream for smooth preview updates
@MainActor
final class CaptureStream: NSObject, ObservableObject {
    // MARK: - Published Properties

    /// Latest captured frame from the stream
    @Published private(set) var latestFrame: NSImage?

    /// Whether the stream is currently running
    @Published private(set) var isRunning: Bool = false

    // MARK: - Constants

    /// Size of the preview capture area
    private static let captureSize: CGFloat = 28

    /// Target frame rate for streaming
    private static let targetFrameRate: Int = 60

    // MARK: - Private Properties

    private var stream: SCStream?
    private var currentDisplay: SCDisplay?
    private var currentCursorLocation: NSPoint = .zero
    private let streamQueue = DispatchQueue(label: "com.picker.capturestream", qos: .userInteractive)

    // MARK: - Public API

    /// Start the capture stream on the display containing the cursor
    func start() async throws {
        guard !self.isRunning else { return }

        let content = try await SCShareableContent.excludingDesktopWindows(
            false,
            onScreenWindowsOnly: true
        )

        // Find the display containing the cursor
        let cursorLocation = self.currentMouseScreenLocation()

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

    // MARK: - Private Helpers

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
        // (SCStream will handle out-of-bounds)
        let sourceRect = clampedRect.isEmpty ? requestedRect : clampedRect

        // Get display scale factor for proper resolution
        let scaleFactor = self.backingScaleFactor(for: display.displayID)
        let outputSize = Int(Self.captureSize * scaleFactor)

        config.sourceRect = sourceRect
        config.captureResolution = .best
        config.width = outputSize
        config.height = outputSize
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

    /// Get the current mouse position in Quartz screen coordinates (top-left origin)
    private func currentMouseScreenLocation() -> NSPoint {
        let cocoaLocation = NSEvent.mouseLocation
        let mainDisplayHeight = CGDisplayBounds(CGMainDisplayID()).height
        return NSPoint(x: cocoaLocation.x, y: mainDisplayHeight - cocoaLocation.y)
    }

    /// Get the backing scale factor for a display
    private func backingScaleFactor(for displayID: CGDirectDisplayID) -> CGFloat {
        // Find matching NSScreen by display ID
        for screen in NSScreen.screens {
            if
                let screenDisplayID = screen
                    .deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID,
                screenDisplayID == displayID
            {
                return screen.backingScaleFactor
            }
        }
        // Default to 2x for Retina if no match found
        return 2.0
    }

    /// Convert a CMSampleBuffer to NSImage
    private nonisolated func image(from sampleBuffer: CMSampleBuffer) -> NSImage? {
        guard let imageBuffer = sampleBuffer.imageBuffer else { return nil }

        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let context = CIContext()

        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }

        // Use capture size constant value directly (28)
        return NSImage(
            cgImage: cgImage,
            size: NSSize(width: 28, height: 28)
        )
    }
}

// MARK: - SCStreamDelegate

extension CaptureStream: SCStreamDelegate {
    nonisolated func stream(_: SCStream, didStopWithError error: Error) {
        DZErrorLog(error)
        Task { @MainActor in
            self.isRunning = false
            self.stream = nil
        }
    }
}

// MARK: - SCStreamOutput

extension CaptureStream: SCStreamOutput {
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
