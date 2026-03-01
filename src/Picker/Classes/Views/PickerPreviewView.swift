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

        // Draw crosshairs at the center pixel
        let crosshairPath = NSBezierPath()
        NSColor.black.set()

        let centerX = self.bounds.midX
        let centerY = self.bounds.midY

        // Horizontal line
        crosshairPath.move(to: NSPoint(x: self.bounds.minX, y: centerY))
        crosshairPath.line(to: NSPoint(x: self.bounds.maxX, y: centerY))

        // Vertical line
        crosshairPath.move(to: NSPoint(x: centerX, y: self.bounds.minY))
        crosshairPath.line(to: NSPoint(x: centerX, y: self.bounds.maxY))

        crosshairPath.stroke()

        // Draw border
        let borderPath = NSBezierPath(rect: self.bounds)
        NSColor.lightGray.set()
        borderPath.stroke()
    }
}
