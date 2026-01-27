import AppKit
import ScreenCaptureKit

/// Utility for capturing screen content around the cursor
enum ScreenCapture {
    /// Size of the preview capture area
    private static let captureSize: CGFloat = 28

    /// Capture a preview image around the given screen location
    /// - Parameter location: The screen location (with origin at top-left)
    /// - Returns: An image of the area around the location
    static func previewImage(at location: NSPoint) async -> NSImage? {
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
            return self.blackImage()
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
            return self.paddedImage(
                cgImage: cgImage,
                capturedRect: clampedRect,
                requestedRect: requestedRect
            )
        } catch {
            return nil
        }
    }

    // MARK: - Private Helpers

    /// Get the combined bounds of all connected screens in Quartz coordinates
    private static func combinedScreenBounds() -> CGRect {
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

    /// Solid black image of the standard capture size
    private static func blackImage() -> NSImage {
        let size = NSSize(width: self.captureSize, height: self.captureSize)
        let image = NSImage(size: size)
        image.lockFocus()
        NSColor.black.setFill()
        NSRect(origin: .zero, size: size).fill()
        image.unlockFocus()
        return image
    }

    /// Padded image with black fill where capture extends beyond screen
    /// - Parameters:
    ///   - cgImage: The captured image (may be smaller than requested)
    ///   - capturedRect: The actual rect that was captured (clamped to screen)
    ///   - requestedRect: The original requested rect
    /// - Returns: A padded image with the captured content properly positioned
    private static func paddedImage(
        cgImage: CGImage,
        capturedRect: CGRect,
        requestedRect: CGRect
    )
        -> NSImage
    {
        let size = NSSize(width: self.captureSize, height: self.captureSize)
        let image = NSImage(size: size)

        image.lockFocus()

        // Fill with black background
        NSColor.black.setFill()
        NSRect(origin: .zero, size: size).fill()

        // Calculate where the captured image should be drawn within the final image.
        // The offset is where the clamped rect starts relative to the requested rect.
        let offsetX = capturedRect.origin.x - requestedRect.origin.x
        let offsetY = capturedRect.origin.y - requestedRect.origin.y

        // NSImage drawing uses flipped coordinates (origin at top-left for drawing)
        // so we need to flip the Y offset
        let drawRect = NSRect(
            x: offsetX,
            y: self.captureSize - offsetY - capturedRect.height,
            width: capturedRect.width,
            height: capturedRect.height
        )

        let capturedImage = NSImage(cgImage: cgImage, size: capturedRect.size)
        capturedImage.draw(
            in: drawRect,
            from: .zero,
            operation: .sourceOver,
            fraction: 1.0
        )

        image.unlockFocus()

        return image
    }
}
