import AppKit

extension NSImage {
    // MARK: - Color Sampling

    /// Extract the center pixel color from the image
    /// - Returns: The color at the center of the image (in sRGB colorspace)
    func sampleColor() -> NSColor? {
        guard let tiffData = self.tiffRepresentation else { return nil }
        guard let bitmap = NSBitmapImageRep(data: tiffData) else { return nil }

        let centerX = bitmap.pixelsWide / 2
        let centerY = bitmap.pixelsHigh / 2

        guard let color = bitmap.colorAt(x: centerX, y: centerY) else { return nil }

        // Convert to sRGB colorspace to ensure getRed:green:blue:alpha: works
        // The captured image may be in a grayscale or other colorspace
        return color.usingColorSpace(.sRGB) ?? color
    }

    // MARK: - Factory Methods

    /// Create a solid black image of the specified size
    /// - Parameter size: The size of the image to create
    /// - Returns: A solid black image
    static func blackImage(size: NSSize) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        NSColor.black.setFill()
        NSRect(origin: .zero, size: size).fill()
        image.unlockFocus()
        return image
    }

    /// Create a padded image with black fill where the capture extends beyond the screen
    /// - Parameters:
    ///   - cgImage: The captured image (may be smaller than requested)
    ///   - capturedRect: The actual rect that was captured (clamped to screen)
    ///   - requestedRect: The original requested rect
    /// - Returns: A padded image with the captured content properly positioned
    static func paddedImage(
        cgImage: CGImage,
        capturedRect: CGRect,
        requestedRect: CGRect
    )
        -> NSImage
    {
        let size = requestedRect.size
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
            y: size.height - offsetY - capturedRect.height,
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
