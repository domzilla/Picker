import AppKit
import Combine

/// Manages the history of picked colors
@MainActor
final class ColorHistory: ObservableObject {
    /// Shared instance
    static let shared = ColorHistory()

    /// Number of colors to keep in history
    static let historySize = 6

    // MARK: - UserDefaults Keys

    private enum Keys {
        static let history = "PIColorHistoryUserDefaultsHistoryKey"
    }

    // MARK: - Published Properties

    /// Publisher that emits when history changes
    let historyDidChange = PassthroughSubject<Void, Never>()

    // MARK: - Initialization

    private init() {}

    // MARK: - Defaults

    /// Register default values with UserDefaults
    static func registerDefaults() {
        let defaults = self.createDefaults()
        UserDefaults.standard.register(defaults: defaults)
    }

    /// Create default preferences dictionary
    static func createDefaults() -> [String: Any] {
        let defaultColors: [NSColor] = [
            NSColor(srgbRed: 0.93, green: 0.47, blue: 0.24, alpha: 1.0),
            NSColor(srgbRed: 0.13, green: 0.80, blue: 0.70, alpha: 1.0),
            NSColor(srgbRed: 1.00, green: 0.85, blue: 0.19, alpha: 1.0),
            NSColor(srgbRed: 0.09, green: 0.54, blue: 0.91, alpha: 1.0),
            NSColor(srgbRed: 0.95, green: 0.54, blue: 0.14, alpha: 1.0),
            NSColor(srgbRed: 0.54, green: 0.96, blue: 0.89, alpha: 1.0),
        ]

        guard let data = try? NSKeyedArchiver.archivedData(
            withRootObject: defaultColors,
            requiringSecureCoding: true
        ) else {
            return [:]
        }

        return [Keys.history: data]
    }

    // MARK: - Public API

    /// Add a color to the history
    /// - Parameter color: The color to add
    func push(_ color: NSColor) {
        var history = self.loadHistory()
        history.insert(color, at: 0)

        // Keep only the most recent colors
        if history.count > ColorHistory.historySize {
            history.removeLast()
        }

        self.saveHistory(history)
        self.historyDidChange.send()
    }

    /// Get the color at a specific index
    /// - Parameter index: The index in history (0 = most recent)
    /// - Returns: The color at that index, or nil if out of range
    func color(at index: Int) -> NSColor? {
        let history = self.loadHistory()
        guard index >= 0, index < history.count else {
            return nil
        }
        return history[index]
    }

    /// Get all colors in history
    func allColors() -> [NSColor] {
        self.loadHistory()
    }

    // MARK: - Private Helpers

    private func loadHistory() -> [NSColor] {
        guard let data = UserDefaults.standard.data(forKey: Keys.history),
              let colors = try? NSKeyedUnarchiver.unarchivedArrayOfObjects(
                  ofClass: NSColor.self,
                  from: data
              )
        else {
            return []
        }
        return colors
    }

    private func saveHistory(_ colors: [NSColor]) {
        guard let data = try? NSKeyedArchiver.archivedData(
            withRootObject: colors,
            requiringSecureCoding: true
        ) else {
            return
        }
        UserDefaults.standard.set(data, forKey: Keys.history)
    }
}
