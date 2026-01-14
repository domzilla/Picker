import AppKit

/// Window controller for the preferences window
class PreferencesWindowController: NSWindowController {
    // MARK: - Shared Instance

    static let shared = PreferencesWindowController()

    // MARK: - Properties

    private let shortcutsViewController: ShortcutsPreferencesViewController

    // MARK: - Initialization

    private init() {
        self.shortcutsViewController = ShortcutsPreferencesViewController()

        // Create window with the shortcuts view controller as content
        let window = NSWindow(contentViewController: self.shortcutsViewController)

        // Configure window
        window.styleMask = [.titled, .closable]
        window.title = NSLocalizedString("Preferences", comment: "Preferences window title")

        // Since we only have one panel, no toolbar is needed
        // If we add more panels in the future, we can add a toolbar here

        super.init(window: window)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    override func showWindow(_ sender: Any?) {
        self.window?.center()
        self.window?.makeKeyAndOrderFront(sender)
        NSApp.activate(ignoringOtherApps: true)
    }
}
