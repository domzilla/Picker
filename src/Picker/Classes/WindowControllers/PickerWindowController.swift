import AppKit

/// Window controller for the floating picker window
class PickerWindowController: NSWindowController, NSWindowDelegate {
    // MARK: - Properties

    private let pickerViewController: PickerViewController

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
    }

    // MARK: - NSWindowDelegate

    func windowWillClose(_: Notification) {
        ColorPicker.shared.previewDidBecomeHidden()
    }
}
