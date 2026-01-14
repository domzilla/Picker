import AppKit

/// A button that displays a color swatch
@objc(ColorButton)
class ColorButton: NSButton {
    /// The color to display
    @objc var color: NSColor? {
        didSet {
            self.updateImage()
        }
    }

    // MARK: - Private Helpers

    private func updateImage() {
        guard let color = self.color else {
            self.image = nil
            return
        }

        let imageSize = self.frame.size

        // Use modern image creation (replaces deprecated lockFocus/unlockFocus)
        let image = NSImage(size: imageSize, flipped: false) { rect in
            color.drawSwatch(in: rect)
            return true
        }

        self.image = image
    }
}
