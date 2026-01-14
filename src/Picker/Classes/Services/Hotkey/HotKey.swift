import Carbon.HIToolbox
import Foundation

/// Signature for Picker's hotkeys (ASCII for "PICK")
let hotkeySignature: FourCharCode = 0x5049_434B

/// A registered global hotkey that wraps Carbon's EventHotKeyRef
@MainActor
final class HotKey {
    /// Unique identifier for this hotkey
    let carbonID: UInt32

    /// The shortcut this hotkey represents
    let shortcut: Shortcut

    /// Action to execute when the hotkey is pressed
    var action: (() -> Void)?

    /// The Carbon hotkey reference (nonisolated for deinit access)
    private nonisolated(unsafe) var hotKeyRef: EventHotKeyRef?

    /// Counter for generating unique IDs (access serialized by MainActor)
    private nonisolated(unsafe) static var nextID: UInt32 = 0

    // MARK: - Initialization

    init?(shortcut: Shortcut) {
        HotKey.nextID += 1
        self.carbonID = HotKey.nextID
        self.shortcut = shortcut

        let hotKeyID = EventHotKeyID(signature: hotkeySignature, id: self.carbonID)

        let status = RegisterEventHotKey(
            shortcut.carbonKeyCode,
            shortcut.carbonFlags,
            hotKeyID,
            GetEventDispatcherTarget(),
            0,
            &self.hotKeyRef
        )

        guard status == noErr else {
            return nil
        }
    }

    deinit {
        if let ref = self.hotKeyRef {
            UnregisterEventHotKey(ref)
        }
    }
}
