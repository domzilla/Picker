import AppKit
import Combine

/// Core color picking engine that tracks the mouse and captures screen colors
@MainActor
final class ColorPicker: ObservableObject {
    /// Shared instance
    static let shared = ColorPicker()

    // MARK: - Published Properties

    /// Current mouse location in screen coordinates (origin top-left)
    @Published private(set) var mouseLocation: NSPoint = .zero

    /// Whether the picker is actively tracking
    @Published private(set) var isTracking: Bool = false

    /// Current color format for copying
    @Published var colorFormat: ColorFormat {
        didSet {
            UserDefaults.standard.set(self.colorFormat.rawValue, forKey: Keys.format)
        }
    }

    // MARK: - Publishers

    /// Emits when the color changes (mouse moved while tracking)
    let colorDidChange = PassthroughSubject<Void, Never>()

    // MARK: - UserDefaults Keys

    private enum Keys {
        static let format = "PIColorPickerUserDefaultsFormatKey"
    }

    // MARK: - Private Properties

    private var globalMonitor: Any?
    private var localMonitor: Any?

    // MARK: - Initialization

    private init() {
        // Load saved format
        let rawFormat = UserDefaults.standard.integer(forKey: Keys.format)
        self.colorFormat = ColorFormat(rawValue: rawFormat) ?? .hex

        // Set up mouse monitoring
        self.setupMouseMonitoring()
    }

    // MARK: - Defaults

    /// Register default values with UserDefaults
    static func registerDefaults() {
        let defaults = self.createDefaults()
        UserDefaults.standard.register(defaults: defaults)
    }

    /// Create default preferences dictionary
    static func createDefaults() -> [String: Any] {
        [Keys.format: ColorFormat.hex.rawValue]
    }

    // MARK: - Public API

    /// Start tracking the mouse position
    func startTracking() {
        guard !self.isTracking else { return }
        self.isTracking = true
        self.updateMouseLocation()
    }

    /// Stop tracking the mouse position
    func stopTracking() {
        self.isTracking = false
    }

    /// Get the color at the current mouse location
    var color: NSColor {
        ScreenCapture.color(at: self.mouseLocation) ?? .black
    }

    /// Get the preview image at the current mouse location
    var previewImage: NSImage? {
        ScreenCapture.previewImage(at: self.mouseLocation)
    }

    /// Copy the current color to the pasteboard
    func copyColorToPasteboard() {
        self.copyColorToPasteboard(saveToHistory: true)
    }

    /// Copy the current color to the pasteboard
    /// - Parameter saveToHistory: Whether to save the color to history
    func copyColorToPasteboard(saveToHistory: Bool) {
        self.copyColor(self.color, toPasteboard: .general, saveToHistory: saveToHistory)
    }

    /// Copy a specific color to the pasteboard
    /// - Parameters:
    ///   - color: The color to copy
    ///   - pasteboard: The pasteboard to copy to
    ///   - saveToHistory: Whether to save the color to history
    func copyColor(_ color: NSColor, toPasteboard pasteboard: NSPasteboard, saveToHistory: Bool) {
        let colorString = self.colorFormat.string(for: color)

        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(colorString, forType: .string)

        if saveToHistory {
            ColorHistory.shared.push(color)
        }
    }

    // MARK: - Private Helpers

    private func setupMouseMonitoring() {
        // Global monitor for when app is in background
        self.globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] _ in
            self?.updateMouseLocation()
        }

        // Local monitor for when app is in foreground
        self.localMonitor = NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
            self?.updateMouseLocation()
            return event
        }
    }

    private func updateMouseLocation() {
        guard self.isTracking else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            let rawLocation = NSEvent.mouseLocation

            // Convert from Cocoa coordinates (bottom-left origin) to screen coordinates (top-left origin)
            guard let screen = NSScreen.screens.first else { return }
            let screenHeight = screen.frame.height
            self.mouseLocation = NSPoint(x: rawLocation.x, y: screenHeight - rawLocation.y)

            self.colorDidChange.send()
        }
    }
}
