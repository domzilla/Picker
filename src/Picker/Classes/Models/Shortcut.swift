import AppKit
import Carbon.HIToolbox

/// A keyboard shortcut represented by a key code and modifier flags
struct Shortcut: Codable, Equatable, Hashable, Sendable {
    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.keyCode)
        hasher.combine(self.modifierFlags.rawValue)
    }

    /// The virtual key code (same as NSEvent.keyCode)
    let keyCode: Int

    /// The modifier flags (Command, Option, Control, Shift)
    let modifierFlags: NSEvent.ModifierFlags

    // MARK: - Initialization

    init(keyCode: Int, modifierFlags: NSEvent.ModifierFlags) {
        self.keyCode = keyCode
        self.modifierFlags = modifierFlags.intersection(.deviceIndependentFlagsMask)
    }

    init(event: NSEvent) {
        self.keyCode = Int(event.keyCode)
        self.modifierFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
    }

    // MARK: - Carbon Compatibility

    /// Key code for Carbon APIs (RegisterEventHotKey)
    var carbonKeyCode: UInt32 {
        UInt32(self.keyCode)
    }

    /// Modifier flags for Carbon APIs
    var carbonFlags: UInt32 {
        var flags: UInt32 = 0
        if self.modifierFlags.contains(.command) { flags |= UInt32(cmdKey) }
        if self.modifierFlags.contains(.option) { flags |= UInt32(optionKey) }
        if self.modifierFlags.contains(.control) { flags |= UInt32(controlKey) }
        if self.modifierFlags.contains(.shift) { flags |= UInt32(shiftKey) }
        return flags
    }

    // MARK: - Display Strings

    /// String representation of the key (e.g., "P", "F1", "Space")
    var keyCodeString: String {
        switch self.keyCode {
        // Function keys
        case kVK_F1: "F1"
        case kVK_F2: "F2"
        case kVK_F3: "F3"
        case kVK_F4: "F4"
        case kVK_F5: "F5"
        case kVK_F6: "F6"
        case kVK_F7: "F7"
        case kVK_F8: "F8"
        case kVK_F9: "F9"
        case kVK_F10: "F10"
        case kVK_F11: "F11"
        case kVK_F12: "F12"
        case kVK_F13: "F13"
        case kVK_F14: "F14"
        case kVK_F15: "F15"
        case kVK_F16: "F16"
        case kVK_F17: "F17"
        case kVK_F18: "F18"
        case kVK_F19: "F19"
        // Special keys
        case kVK_Space: NSLocalizedString("Space", comment: "Space key name")
        case kVK_Escape: "\u{238B}" // Escape symbol
        case kVK_Delete: "\u{232B}" // Delete left symbol
        case kVK_ForwardDelete: "\u{2326}" // Delete right symbol
        case kVK_LeftArrow: "\u{2190}" // Left arrow
        case kVK_RightArrow: "\u{2192}" // Right arrow
        case kVK_UpArrow: "\u{2191}" // Up arrow
        case kVK_DownArrow: "\u{2193}" // Down arrow
        case kVK_Home: "\u{2196}" // Northwest arrow
        case kVK_End: "\u{2198}" // Southeast arrow
        case kVK_PageUp: "\u{21DE}" // Page up
        case kVK_PageDown: "\u{21DF}" // Page down
        case kVK_Tab: "\u{21E5}" // Tab right
        case kVK_Return: "\u{21A9}" // Return symbol
        case kVK_Help: "?"
        // Keypad
        case kVK_ANSI_Keypad0: "0"
        case kVK_ANSI_Keypad1: "1"
        case kVK_ANSI_Keypad2: "2"
        case kVK_ANSI_Keypad3: "3"
        case kVK_ANSI_Keypad4: "4"
        case kVK_ANSI_Keypad5: "5"
        case kVK_ANSI_Keypad6: "6"
        case kVK_ANSI_Keypad7: "7"
        case kVK_ANSI_Keypad8: "8"
        case kVK_ANSI_Keypad9: "9"
        case kVK_ANSI_KeypadDecimal: "."
        case kVK_ANSI_KeypadMultiply: "*"
        case kVK_ANSI_KeypadPlus: "+"
        case kVK_ANSI_KeypadClear: "\u{2327}" // Clear symbol
        case kVK_ANSI_KeypadDivide: "/"
        case kVK_ANSI_KeypadEnter: "\u{2305}" // Enter symbol
        case kVK_ANSI_KeypadMinus: "-"
        case kVK_ANSI_KeypadEquals: "="
        default:
            // Look up the character from the keyboard layout
            self.keyCodeStringFromKeyboardLayout()?.uppercased() ?? ""
        }
    }

    /// String representation of modifier flags (e.g., "⌘⇧")
    var modifierFlagsString: String {
        var result = ""
        // Order matches macOS menu display
        if self.modifierFlags.contains(.control) { result += "\u{2303}" } // Control
        if self.modifierFlags.contains(.option) { result += "\u{2325}" } // Option
        if self.modifierFlags.contains(.shift) { result += "\u{21E7}" } // Shift
        if self.modifierFlags.contains(.command) { result += "\u{2318}" } // Command
        return result
    }

    /// Full display string (e.g., "⌘⇧P")
    var displayString: String {
        self.modifierFlagsString + self.keyCodeString
    }

    /// Key equivalent string for NSMenuItem (lowercase)
    var keyEquivalent: String {
        switch self.keyCode {
        case kVK_F1: String(Character(UnicodeScalar(NSF1FunctionKey)!))
        case kVK_F2: String(Character(UnicodeScalar(NSF2FunctionKey)!))
        case kVK_F3: String(Character(UnicodeScalar(NSF3FunctionKey)!))
        case kVK_F4: String(Character(UnicodeScalar(NSF4FunctionKey)!))
        case kVK_F5: String(Character(UnicodeScalar(NSF5FunctionKey)!))
        case kVK_F6: String(Character(UnicodeScalar(NSF6FunctionKey)!))
        case kVK_F7: String(Character(UnicodeScalar(NSF7FunctionKey)!))
        case kVK_F8: String(Character(UnicodeScalar(NSF8FunctionKey)!))
        case kVK_F9: String(Character(UnicodeScalar(NSF9FunctionKey)!))
        case kVK_F10: String(Character(UnicodeScalar(NSF10FunctionKey)!))
        case kVK_F11: String(Character(UnicodeScalar(NSF11FunctionKey)!))
        case kVK_F12: String(Character(UnicodeScalar(NSF12FunctionKey)!))
        case kVK_Space: " "
        case kVK_Escape: "\u{001B}"
        case kVK_Delete: String(Character(UnicodeScalar(NSBackspaceCharacter)!))
        case kVK_ForwardDelete: String(Character(UnicodeScalar(NSDeleteFunctionKey)!))
        case kVK_LeftArrow: String(Character(UnicodeScalar(NSLeftArrowFunctionKey)!))
        case kVK_RightArrow: String(Character(UnicodeScalar(NSRightArrowFunctionKey)!))
        case kVK_UpArrow: String(Character(UnicodeScalar(NSUpArrowFunctionKey)!))
        case kVK_DownArrow: String(Character(UnicodeScalar(NSDownArrowFunctionKey)!))
        case kVK_Home: String(Character(UnicodeScalar(NSHomeFunctionKey)!))
        case kVK_End: String(Character(UnicodeScalar(NSEndFunctionKey)!))
        case kVK_PageUp: String(Character(UnicodeScalar(NSPageUpFunctionKey)!))
        case kVK_PageDown: String(Character(UnicodeScalar(NSPageDownFunctionKey)!))
        case kVK_Tab: "\t"
        case kVK_Return: "\r"
        default:
            self.keyCodeString.lowercased()
        }
    }

    // MARK: - Private Helpers

    private func keyCodeStringFromKeyboardLayout() -> String? {
        guard let inputSource = TISCopyCurrentASCIICapableKeyboardLayoutInputSource()?.takeRetainedValue(),
              let layoutDataRef = TISGetInputSourceProperty(inputSource, kTISPropertyUnicodeKeyLayoutData)
        else {
            return nil
        }

        let layoutData = unsafeBitCast(layoutDataRef, to: CFData.self)
        let keyboardLayout = unsafeBitCast(CFDataGetBytePtr(layoutData), to: UnsafePointer<UCKeyboardLayout>.self)

        var deadKeyState: UInt32 = 0
        var chars = [UniChar](repeating: 0, count: 4)
        var length = 0

        let status = UCKeyTranslate(
            keyboardLayout,
            UInt16(self.keyCode),
            UInt16(kUCKeyActionDisplay),
            0, // No modifiers
            UInt32(LMGetKbdType()),
            OptionBits(kUCKeyTranslateNoDeadKeysMask),
            &deadKeyState,
            chars.count,
            &length,
            &chars
        )

        guard status == noErr, length > 0 else { return nil }
        return String(utf16CodeUnits: chars, count: length)
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case keyCode
        case modifierFlags
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.keyCode = try container.decode(Int.self, forKey: .keyCode)
        let rawFlags = try container.decode(UInt.self, forKey: .modifierFlags)
        self.modifierFlags = NSEvent.ModifierFlags(rawValue: rawFlags)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.keyCode, forKey: .keyCode)
        try container.encode(self.modifierFlags.rawValue, forKey: .modifierFlags)
    }
}
