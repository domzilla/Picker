import AppKit

extension NSScreen {
    /// Get the backing scale factor for a display by its ID
    /// - Parameter displayID: The Core Graphics display ID
    /// - Returns: The backing scale factor (defaults to 2.0 for Retina if no match found)
    static func backingScaleFactor(for displayID: CGDirectDisplayID) -> CGFloat {
        for screen in NSScreen.screens {
            if
                let screenDisplayID = screen
                    .deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID,
                screenDisplayID == displayID
            {
                return screen.backingScaleFactor
            }
        }
        // Default to 2x for Retina if no match found
        return 2.0
    }
}
