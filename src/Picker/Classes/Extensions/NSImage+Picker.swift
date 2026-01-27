import AppKit

extension NSImage {
    // MARK: - Color Sampling

    /// Extract the center pixel color from the image
    /// - Returns: The color at the center of the image (in sRGB colorspace)
    func sampleColor() -> NSColor? {
        // Get CGImage directly - much faster than tiffRepresentation
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }

        let width = cgImage.width
        let height = cgImage.height
        let centerX = width / 2
        let centerY = height / 2

        // Create a 1x1 bitmap context to read single pixel
        var pixel: [UInt8] = [0, 0, 0, 0]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        guard
            let context = CGContext(
                data: &pixel,
                width: 1,
                height: 1,
                bitsPerComponent: 8,
                bytesPerRow: 4,
                space: colorSpace,
                bitmapInfo: bitmapInfo.rawValue
            ) else
        {
            return nil
        }

        // Draw just the center pixel
        context.draw(cgImage, in: CGRect(x: -centerX, y: -centerY, width: width, height: height))

        // Convert premultiplied alpha to straight alpha
        let alpha = CGFloat(pixel[3]) / 255.0
        guard alpha > 0 else {
            return NSColor(red: 0, green: 0, blue: 0, alpha: 0)
        }

        let red = CGFloat(pixel[0]) / 255.0 / alpha
        let green = CGFloat(pixel[1]) / 255.0 / alpha
        let blue = CGFloat(pixel[2]) / 255.0 / alpha

        return NSColor(
            calibratedRed: min(red, 1.0),
            green: min(green, 1.0),
            blue: min(blue, 1.0),
            alpha: alpha
        )
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
