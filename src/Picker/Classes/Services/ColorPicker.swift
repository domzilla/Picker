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
    private var cancellables = Set<AnyCancellable>()

    /// Screen capture for continuous preview (used when UI is visible)
    private let screenCapture = ScreenCapture()

    /// Number of consumers currently showing the preview (menu, window)
    private var previewConsumerCount = 0

    // MARK: - Initialization

    private init() {
        // Load saved format
        let rawFormat = UserDefaults.standard.integer(forKey: Keys.format)
        self.colorFormat = ColorFormat(rawValue: rawFormat) ?? .hex

        // Set up mouse monitoring
        self.setupMouseMonitoring()

        // Subscribe to stream frames
        self.setupStreamSubscription()
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

    /// Called when a preview consumer (menu or window) becomes visible
    func previewDidBecomeVisible() {
        self.previewConsumerCount += 1

        // Start stream when first consumer appears
        if self.previewConsumerCount == 1 {
            Task {
                do {
                    try await self.screenCapture.start()
                } catch {
                    DZErrorLog(error)
                }
            }
        }
    }

    /// Called when a preview consumer (menu or window) is hidden
    func previewDidBecomeHidden() {
        self.previewConsumerCount = max(0, self.previewConsumerCount - 1)

        // Stop stream when last consumer disappears
        if self.previewConsumerCount == 0 {
            Task {
                await self.screenCapture.stop()
            }
        }
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
        let image: NSImage?

        // Use stream frame if available, otherwise capture once (hotkey case)
        if self.screenCapture.isRunning, let streamFrame = self.screenCapture.latestFrame {
            image = streamFrame
        } else {
            let currentLocation = NSEvent.mouseLocation.quartzCoordinate
            image = await ScreenCapture.captureOnce(at: currentLocation)
        }

        guard let image else { return }

        let currentColor = image.sampleColor() ?? .black
        self.copyColor(currentColor, toPasteboard: .general, saveToHistory: saveToHistory)
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

        let location = NSEvent.mouseLocation.quartzCoordinate
        self.mouseLocation = location

        // Update stream capture rect if running
        if self.screenCapture.isRunning {
            Task {
                await self.screenCapture.updateCaptureRect(for: location)
            }
        }
    }

    private func setupStreamSubscription() {
        // Subscribe to stream frames and update preview/color
        self.screenCapture.$latestFrame
            .compactMap(\.self)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                guard let self else { return }
                self.previewImage = image
                self.color = image.sampleColor() ?? .black
                self.colorDidChange.send()
            }
            .store(in: &self.cancellables)
    }
}
