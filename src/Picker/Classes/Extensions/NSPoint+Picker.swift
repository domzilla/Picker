import AppKit

extension NSPoint {
    /// Convert from Cocoa coordinates (bottom-left origin) to Quartz coordinates (top-left origin)
    var quartzCoordinate: NSPoint {
        let mainDisplayHeight = CGDisplayBounds(CGMainDisplayID()).height
        return NSPoint(x: self.x, y: mainDisplayHeight - self.y)
    }
}
