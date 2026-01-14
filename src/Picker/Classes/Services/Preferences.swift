import AppKit
import Carbon.HIToolbox
import Combine

/// Application preferences singleton
@MainActor
final class Preferences: ObservableObject {
    /// Shared instance
    static let shared = Preferences()

    // MARK: - UserDefaults Keys

    private enum Keys {
        static let colorCopyShortcut = "PIPreferencesDefaultsColorCopyShortcutKey"
        static let pinToScreenShortcut = "PIPreferencesDefaultsPinToScreenShortcutKey"
    }

    // MARK: - Published Properties

    /// Shortcut for copying the current color
    @Published var colorCopyShortcut: Shortcut? {
        didSet {
            self.saveShortcut(self.colorCopyShortcut, forKey: Keys.colorCopyShortcut)
        }
    }

    /// Shortcut for pinning the picker to screen
    @Published var pinToScreenShortcut: Shortcut? {
        didSet {
            self.saveShortcut(self.pinToScreenShortcut, forKey: Keys.pinToScreenShortcut)
        }
    }

    // MARK: - Initialization

    private init() {
        self.colorCopyShortcut = self.loadShortcut(forKey: Keys.colorCopyShortcut)
        self.pinToScreenShortcut = self.loadShortcut(forKey: Keys.pinToScreenShortcut)
    }

    // MARK: - Defaults

    /// Register default values with UserDefaults
    static func registerDefaults() {
        let defaults = self.createDefaults()
        UserDefaults.standard.register(defaults: defaults)
    }

    /// Create default preferences dictionary
    static func createDefaults() -> [String: Any] {
        var defaults: [String: Any] = [:]

        // Try different key combinations until we find one not taken by the system
        let keyCodes = [kVK_ANSI_P, kVK_ANSI_O, kVK_ANSI_X, kVK_ANSI_Period, kVK_ANSI_Comma]

        for keyCode in keyCodes {
            let copyShortcut = Shortcut(
                keyCode: keyCode,
                modifierFlags: [.command, .shift]
            )
            let pinShortcut = Shortcut(
                keyCode: keyCode,
                modifierFlags: [.command, .shift, .option]
            )

            // Use the first available combination
            // (In a full implementation, we'd check for system conflicts)
            if let copyData = try? JSONEncoder().encode(copyShortcut),
               let pinData = try? JSONEncoder().encode(pinShortcut)
            {
                defaults[Keys.colorCopyShortcut] = copyData
                defaults[Keys.pinToScreenShortcut] = pinData
                break
            }
        }

        return defaults
    }

    // MARK: - Private Helpers

    private func loadShortcut(forKey key: String) -> Shortcut? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        return try? JSONDecoder().decode(Shortcut.self, from: data)
    }

    private func saveShortcut(_ shortcut: Shortcut?, forKey key: String) {
        if let shortcut,
           let data = try? JSONEncoder().encode(shortcut)
        {
            UserDefaults.standard.set(data, forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}
