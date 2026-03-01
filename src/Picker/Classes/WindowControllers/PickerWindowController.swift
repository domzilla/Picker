import AppKit
import Carbon.HIToolbox

/// Window controller for the floating picker window
class PickerWindowController: NSWindowController, NSWindowDelegate {
    // MARK: - Properties

    private let pickerViewController: PickerViewController

    /// Local key event monitor for arrow key nudging
    private var keyMonitor: Any?

    // MARK: - Initialization

    init() {
        self.pickerViewController = PickerViewController(mode: .defaultMode)
        self.pickerViewController.shouldUpdateView = true

        let window = NSWindow(contentViewController: self.pickerViewController)

        // Configure window appearance
        window.styleMask = [.titled, .closable]
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.title = NSLocalizedString("Picker", comment: "Window title")
        window.titleVisibility = .hidden
        window.collectionBehavior = .fullScreenNone
        window.canHide = false
        window.isExcludedFromWindowsMenu = true
        window.level = .floating

        super.init(window: window)
        window.delegate = self
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Window Lifecycle

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        ColorPicker.shared.previewDidBecomeVisible()
        self.installKeyMonitor()
    }

    // MARK: - NSWindowDelegate

    func windowWillClose(_: Notification) {
        self.removeKeyMonitor()
        ColorPicker.shared.previewDidBecomeHidden()
    }

    // MARK: - Arrow Key Nudging

    private func installKeyMonitor() {
        guard self.keyMonitor == nil else { return }

        self.keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            switch Int(event.keyCode) {
            case kVK_LeftArrow:
                ColorPicker.shared.nudgeCursor(dx: -1, dy: 0)
                return nil
            case kVK_RightArrow:
                ColorPicker.shared.nudgeCursor(dx: 1, dy: 0)
                return nil
            case kVK_UpArrow:
                ColorPicker.shared.nudgeCursor(dx: 0, dy: -1) // Quartz: y decreases upward
                return nil
            case kVK_DownArrow:
                ColorPicker.shared.nudgeCursor(dx: 0, dy: 1) // Quartz: y increases downward
                return nil
            default:
                return event
            }
        }
    }

    private func removeKeyMonitor() {
        if let monitor = self.keyMonitor {
            NSEvent.removeMonitor(monitor)
            self.keyMonitor = nil
        }
    }
}
