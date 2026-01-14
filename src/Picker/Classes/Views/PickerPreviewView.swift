import AppKit

/// A view that displays a magnified preview image with crosshairs
@objc(PickerPreviewView)
class PickerPreviewView: NSView {
    /// The preview image to display
    @objc var previewImage: NSImage? {
        didSet {
            self.needsDisplay = true
        }
    }

    // MARK: - Drawing

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let image = self.previewImage else { return }

        // Draw the preview image
        image.draw(in: self.bounds, from: .zero, operation: .sourceOver, fraction: 1.0)

        // Draw crosshairs
        let path = NSBezierPath()
        NSColor.black.set()

        let centerAdjust: CGFloat = 3.5
        let pickerRectX = self.bounds.origin.x + centerAdjust
        let pickerRectY = self.bounds.origin.y - centerAdjust

        // Horizontal line
        path.move(to: NSPoint(
            x: pickerRectX - centerAdjust,
            y: pickerRectY + self.bounds.width / 2
        ))
        path.line(to: NSPoint(
            x: pickerRectX + self.bounds.width - centerAdjust,
            y: pickerRectY + self.bounds.height / 2
        ))

        // Vertical line
        path.move(to: NSPoint(
            x: pickerRectX + self.bounds.width / 2,
            y: pickerRectY + self.bounds.height + centerAdjust
        ))
        path.line(to: NSPoint(
            x: pickerRectX + self.bounds.width / 2,
            y: pickerRectY + centerAdjust
        ))

        path.stroke()

        // Draw border
        path.move(to: self.bounds.origin)
        path.line(to: NSPoint(x: self.bounds.origin.x, y: self.bounds.maxY))
        path.line(to: NSPoint(x: self.bounds.maxX, y: self.bounds.maxY))
        path.line(to: NSPoint(x: self.bounds.maxX, y: self.bounds.origin.y))
        path.close()

        NSColor.lightGray.set()
        path.stroke()
    }
}
