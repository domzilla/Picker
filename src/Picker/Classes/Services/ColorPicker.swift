import AppKit
import Combine
import DZFoundation

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

    /// Cached preview image (updated asynchronously during tracking)
    @Published private(set) var previewImage: NSImage?

    /// Cached color from preview image
    @Published private(set) var color: NSColor = .black

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
    private var captureTask: Task<Void, Never>?

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
        self.captureTask?.cancel()
    }

    /// Copy the current color to the pasteboard
    func copyColorToPasteboard() {
        Task {
            await self.copyColorToPasteboardAsync(saveToHistory: true)
        }
    }

    /// Copy the current color to the pasteboard
    /// - Parameter saveToHistory: Whether to save the color to history
    func copyColorToPasteboard(saveToHistory: Bool) {
        Task {
            await self.copyColorToPasteboardAsync(saveToHistory: saveToHistory)
        }
    }

    /// Copy the current color to the pasteboard (async version)
    /// - Parameter saveToHistory: Whether to save the color to history
    private func copyColorToPasteboardAsync(saveToHistory: Bool) async {
        let currentLocation = self.currentMouseScreenLocation()

        // Capture fresh image for accurate color
        guard let image = await ScreenCapture.previewImage(at: currentLocation) else {
            DZLog("Failed to capture image")
            return
        }

        let currentColor = self.sampleColor(from: image) ?? .black
        self.copyColor(currentColor, toPasteboard: .general, saveToHistory: saveToHistory)
    }

    /// Extract the center pixel color from a preview image
    /// - Parameter image: The preview image to sample from
    /// - Returns: The color at the center of the image
    func sampleColor(from image: NSImage) -> NSColor? {
        guard
            let tiffData = image.tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiffData) else
        {
            return nil
        }

        let centerX = bitmap.pixelsWide / 2
        let centerY = bitmap.pixelsHigh / 2
        return bitmap.colorAt(x: centerX, y: centerY)
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

        self.mouseLocation = self.currentMouseScreenLocation()

        // Cancel previous capture and start new one
        self.captureTask?.cancel()
        self.captureTask = Task {
            await self.updatePreviewImage()
        }
    }

    private func updatePreviewImage() async {
        let location = self.mouseLocation

        guard let image = await ScreenCapture.previewImage(at: location) else { return }
        guard !Task.isCancelled else { return }

        // Single capture used for both preview and color
        self.previewImage = image
        self.color = self.sampleColor(from: image) ?? .black
        self.colorDidChange.send()
    }

    /// Get the current mouse position in Quartz screen coordinates (top-left origin)
    private func currentMouseScreenLocation() -> NSPoint {
        let cocoaLocation = NSEvent.mouseLocation

        // ScreenCaptureKit uses Quartz coordinates where (0,0) is at the
        // top-left of the main display. NSEvent.mouseLocation uses Cocoa coordinates
        // where (0,0) is at the bottom-left of the main display.
        // The conversion requires the main display height.
        let mainDisplayHeight = CGDisplayBounds(CGMainDisplayID()).height
        return NSPoint(x: cocoaLocation.x, y: mainDisplayHeight - cocoaLocation.y)
    }
}
