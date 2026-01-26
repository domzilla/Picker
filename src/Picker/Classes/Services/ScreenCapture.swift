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
        let imageRect = CGRect(
            x: location.x - halfSize,
            y: location.y - halfSize,
            width: self.captureSize,
            height: self.captureSize
        )

        let config = SCScreenshotConfiguration()
        config.showsCursor = false

        do {
            let cgImage: CGImage? = try await withCheckedThrowingContinuation { continuation in
                SCScreenshotManager.captureScreenshot(
                    rect: imageRect,
                    configuration: config
                ) { output, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        // Extract CGImage immediately to avoid Sendable issues
                        continuation.resume(returning: output?.sdrImage)
                    }
                }
            }

            guard let cgImage else {
                return nil
            }

            return NSImage(
                cgImage: cgImage,
                size: NSSize(width: self.captureSize, height: self.captureSize)
            )
        } catch {
            return nil
        }
    }
}
