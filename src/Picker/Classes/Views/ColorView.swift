import AppKit

/// A simple view that displays a solid color with a border
@objc(ColorView)
class ColorView: NSView {
    /// The color to display
    @objc var color: NSColor = .white {
        didSet {
            self.needsDisplay = true
        }
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
