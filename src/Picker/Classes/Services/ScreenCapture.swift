import AppKit
import CoreGraphics

/// Utility for capturing screen content around the cursor
enum ScreenCapture {
    /// Size of the preview capture area
    private static let captureSize: CGFloat = 28

    /// Capture a preview image around the given screen location
    /// - Parameter location: The screen location (with origin at top-left)
    /// - Returns: An image of the area around the location
    static func previewImage(at location: NSPoint) -> NSImage? {
        let halfSize = self.captureSize / 2
        let imageRect = CGRect(
            x: location.x - halfSize,
            y: location.y - halfSize,
            width: self.captureSize,
            height: self.captureSize
        )

        guard let cgImage = CGWindowListCreateImage(
            imageRect,
            .optionOnScreenOnly,
            kCGNullWindowID,
            .shouldBeOpaque
        ) else {
            return nil
        }

        let image = NSImage(cgImage: cgImage, size: NSSize(width: self.captureSize, height: self.captureSize))
        return image
    }

    /// Get the color at a specific screen location
    /// - Parameter location: The screen location (with origin at top-left)
    /// - Returns: The color at that location
    static func color(at location: NSPoint) -> NSColor? {
        let imageRect = CGRect(x: location.x, y: location.y, width: 1, height: 1)

        guard let cgImage = CGWindowListCreateImage(
            imageRect,
            .optionOnScreenOnly,
            kCGNullWindowID,
            []
        ) else {
            return nil
        }

        let bitmap = NSBitmapImageRep(cgImage: cgImage)
        return bitmap.colorAt(x: 0, y: 0)
    }
}
