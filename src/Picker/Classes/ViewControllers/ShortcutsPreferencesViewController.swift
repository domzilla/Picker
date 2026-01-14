import AppKit

/// View controller for the shortcuts preferences panel
@objc(ShortcutsPreferencesViewController)
class ShortcutsPreferencesViewController: NSViewController {
    // MARK: - Outlets

    @IBOutlet var colorCopyShortcutView: ShortcutRecorderView!
    @IBOutlet var pinToScreenShortcutView: ShortcutRecorderView!

    // MARK: - Properties

    /// Identifier for toolbar/preferences
    var viewIdentifier: String {
        "ShortcutsPreferencesViewController"
    }

    /// Label for toolbar item
    var toolbarItemLabel: String {
        NSLocalizedString("Shortcuts", comment: "Shortcuts preferences tab")
    }

    /// Image for toolbar item
    var toolbarItemImage: NSImage? {
        NSImage(named: "preferences_shortcuts")
    }

    // MARK: - Initialization

    init() {
        super.init(nibName: "ShortcutsPreferencesViewController", bundle: .main)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up color copy shortcut view
        self.colorCopyShortcutView?.shortcutValue = Preferences.shared.colorCopyShortcut
        self.colorCopyShortcutView?.shortcutValueChange = { view in
            Preferences.shared.colorCopyShortcut = view.shortcutValue
        }

        // Set up pin to screen shortcut view
        self.pinToScreenShortcutView?.shortcutValue = Preferences.shared.pinToScreenShortcut
        self.pinToScreenShortcutView?.shortcutValueChange = { view in
            Preferences.shared.pinToScreenShortcut = view.shortcutValue
        }
    }
}
