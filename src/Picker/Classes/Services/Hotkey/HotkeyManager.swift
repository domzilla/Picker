import Carbon.HIToolbox
import DZFoundation
import Foundation

/// Manages global hotkey registration and dispatches events
@MainActor
final class HotkeyManager {
    /// Shared instance
    static let shared = HotkeyManager()

    /// Registered hotkeys keyed by their shortcut
    private var hotKeys: [Shortcut: HotKey] = [:]

    /// Carbon event handler reference (nonisolated for deinit access)
    private nonisolated(unsafe) var eventHandlerRef: EventHandlerRef?

    // MARK: - Initialization

    private init() {
        self.installEventHandler()
    }

    deinit {
        if let ref = self.eventHandlerRef {
            RemoveEventHandler(ref)
        }
    }

    // MARK: - Public API

    /// Register a shortcut with an action
    /// - Parameters:
    ///   - shortcut: The keyboard shortcut to register
    ///   - action: The action to execute when the shortcut is pressed
    /// - Returns: true if registration succeeded
    @discardableResult
    func register(_ shortcut: Shortcut, action: @escaping () -> Void) -> Bool {
        // Unregister existing hotkey for this shortcut if any
        self.hotKeys.removeValue(forKey: shortcut)

        guard let hotKey = HotKey(shortcut: shortcut) else {
            return false
        }

        hotKey.action = action
        self.hotKeys[shortcut] = hotKey
        return true
    }

    /// Unregister a shortcut
    /// - Parameter shortcut: The shortcut to unregister
    func unregister(_ shortcut: Shortcut) {
        self.hotKeys.removeValue(forKey: shortcut)
    }

    /// Unregister all shortcuts
    func unregisterAll() {
        self.hotKeys.removeAll()
    }

    /// Check if a shortcut is registered
    /// - Parameter shortcut: The shortcut to check
    /// - Returns: true if the shortcut is registered
    func isRegistered(_ shortcut: Shortcut) -> Bool {
        self.hotKeys[shortcut] != nil
    }

    // MARK: - Event Handling

    private func installEventHandler() {
        var eventSpec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        // Store self reference for the callback
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        let status = InstallEventHandler(
            GetEventDispatcherTarget(),
            { _, event, userData -> OSStatus in
                guard
                    let userData,
                    let event else
                {
                    return noErr
                }

                let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()

                // Dispatch to main actor
                Task { @MainActor in
                    manager.handleEvent(event)
                }

                return noErr
            },
            1,
            &eventSpec,
            selfPtr,
            &self.eventHandlerRef
        )

        if status != noErr {
            DZLog("Failed to install hotkey event handler: \(status)")
        }
    }

    private func handleEvent(_ event: EventRef) {
        guard GetEventClass(event) == OSType(kEventClassKeyboard) else {
            return
        }

        var hotKeyID = EventHotKeyID()
        let status = GetEventParameter(
            event,
            UInt32(kEventParamDirectObject),
            UInt32(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            nil,
            &hotKeyID
        )

        guard status == noErr, hotKeyID.signature == hotkeySignature else {
            return
        }

        // Find and execute the matching hotkey action
        for (_, hotKey) in self.hotKeys where hotKey.carbonID == hotKeyID.id {
            hotKey.action?()
            break
        }
    }
}
