import AppKit

/// A button that displays a color swatch
@objc(ColorButton)
class ColorButton: NSButton {
    /// The color to display
    @objc var color: NSColor? {
        didSet {
            self.updateImage()
            self.updateAccessibilityValue()
        }
    }

    // MARK: - Private Helpers

    private func updateAccessibilityValue() {
        guard let color = self.color else {
            self.setAccessibilityElement(false)
            self.setAccessibilityValue(nil)
            return
        }

        self.setAccessibilityElement(true)
        self.setAccessibilityValue(String(
            format: NSLocalizedString(
                "%1$@, hex %2$@",
                tableName: "Accessibility",
                comment: "Accessibility value for a color swatch: RGB components followed by the hex code"
            ),
            color.rgbRepresentation,
            color.hexRepresentation
        ))
    }

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
