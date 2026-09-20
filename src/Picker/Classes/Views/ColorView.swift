import AppKit

/// A simple view that displays a solid color with a border
@objc(ColorView)
class ColorView: NSView {
    /// The color to display
    @objc var color: NSColor = .white {
        didSet {
            self.needsDisplay = true
            self.updateAccessibilityValue()
        }
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        self.updateAccessibilityValue()
    }

    // MARK: - Private Helpers

    private func updateAccessibilityValue() {
        self.setAccessibilityValue(String(
            format: NSLocalizedString(
                "%1$@, hex %2$@",
                tableName: "Accessibility",
                comment: "Accessibility value for a color swatch: RGB components followed by the hex code"
            ),
            self.color.rgbRepresentation,
            self.color.hexRepresentation
        ))
    }

    // MARK: - Drawing

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Fill with color
        self.color.set()
        self.bounds.fill()

        // Draw border
        let path = NSBezierPath(rect: self.bounds)
        NSColor.lightGray.set()
        path.stroke()
    }
}
