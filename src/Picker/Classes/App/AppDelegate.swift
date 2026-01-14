import AppKit
import Combine
import CoreGraphics

@main
@MainActor
@objc(AppDelegate)
class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - Properties

    private var statusItem: NSStatusItem!
    private var pickerMenu: NSMenu!
    private var pickerViewController: PickerViewController!

    private var colorCopyMenuItem: NSMenuItem!
    private var availableFormatsMenuItem: NSMenuItem!
    private var availableFormatsSubmenu: NSMenu!
    private var selectedFormatMenuItem: NSMenuItem!
    private var pinToScreenItem: NSMenuItem!
    private var pickerPreferencesItem: NSMenuItem!
    private var quitMenuItem: NSMenuItem!

    private var pickerWindowController: PickerWindowController?

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Application Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon (accessory app)
        NSApp.setActivationPolicy(.accessory)

        // Register defaults
        self.registerDefaults()

        // Request screen capture permission (adds app to System Settings list)
        self.requestScreenCapturePermission()

        // Set up status bar
        self.setupStatusItem()

        // Set up menu
        self.setupMenu()

        // Start color tracking
        ColorPicker.shared.startTracking()

        // Register global hotkeys
        self.setupHotkeySubscriptions()
        self.registerGlobalHotkeys()
    }

    func applicationWillTerminate(_ notification: Notification) {
        HotkeyManager.shared.unregisterAll()
    }

    // MARK: - Setup

    /// Request screen capture permission on launch.
    /// This adds the app to System Settings > Privacy & Security > Screen Recording.
    private func requestScreenCapturePermission() {
        // CGRequestScreenCaptureAccess() triggers the permission prompt on first launch
        // and adds the app to the Screen Recording list in System Settings.
        // On subsequent launches, it simply returns the current permission state.
        _ = CGRequestScreenCaptureAccess()
    }

    private func registerDefaults() {
        var defaults: [String: Any] = [:]
        defaults.merge(Preferences.createDefaults()) { _, new in new }
        defaults.merge(ColorPicker.createDefaults()) { _, new in new }
        defaults.merge(ColorHistory.createDefaults()) { _, new in new }
        UserDefaults.standard.register(defaults: defaults)
    }

    private func setupStatusItem() {
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.statusItem.button?.image = NSImage(named: "menu_icon_dropper")
    }

    private func setupMenu() {
        self.pickerMenu = NSMenu(title: "Picker")
        self.pickerMenu.delegate = self
        self.statusItem.menu = self.pickerMenu

        // Embedded picker view
        self.pickerViewController = PickerViewController(mode: .menuMode)
        let pickerMenuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        pickerMenuItem.view = self.pickerViewController.view
        self.pickerMenu.addItem(pickerMenuItem)

        // Hidden copy color menu item (for local keyboard shortcut)
        self.colorCopyMenuItem = NSMenuItem(
            title: NSLocalizedString("Copy color", comment: "Copy color menu item"),
            action: #selector(self.copyColorMenuItemAction(_:)),
            keyEquivalent: ""
        )
        self.colorCopyMenuItem.allowsKeyEquivalentWhenHidden = true
        self.colorCopyMenuItem.isHidden = true
        self.pickerMenu.addItem(self.colorCopyMenuItem)

        self.pickerMenu.addItem(.separator())

        // Color format submenu
        self.availableFormatsMenuItem = NSMenuItem()
        self.availableFormatsMenuItem.title = NSLocalizedString("Color format", comment: "Color format menu item")
        self.availableFormatsSubmenu = NSMenu()

        for format in ColorFormat.allCases {
            let item = self.availableFormatsSubmenu.addItem(
                withTitle: format.displayName,
                action: #selector(self.formatSubmenuItemAction(_:)),
                keyEquivalent: ""
            )
            item.target = self
        }

        self.selectedFormatMenuItem = self.availableFormatsSubmenu.item(at: ColorPicker.shared.colorFormat.rawValue)
        self.selectedFormatMenuItem?.state = .on
        self.availableFormatsMenuItem.submenu = self.availableFormatsSubmenu
        self.pickerMenu.addItem(self.availableFormatsMenuItem)

        // Pin on screen
        self.pinToScreenItem = NSMenuItem(
            title: NSLocalizedString("Pin on screen...", comment: "Pin on screen menu item"),
            action: #selector(self.pickerWindowItemAction(_:)),
            keyEquivalent: ""
        )
        self.pinToScreenItem.target = self
        self.pickerMenu.addItem(self.pinToScreenItem)

        self.pickerMenu.addItem(.separator())

        // Preferences
        self.pickerPreferencesItem = NSMenuItem(
            title: NSLocalizedString("Preferences...", comment: "Preferences menu item"),
            action: #selector(self.preferencesMenuItemAction(_:)),
            keyEquivalent: ","
        )
        self.pickerPreferencesItem.keyEquivalentModifierMask = .command
        self.pickerPreferencesItem.target = self
        self.pickerMenu.addItem(self.pickerPreferencesItem)

        self.pickerMenu.addItem(.separator())

        // Quit
        self.quitMenuItem = NSMenuItem(
            title: NSLocalizedString("Quit", comment: "Quit menu item"),
            action: #selector(self.quitMenuItemAction(_:)),
            keyEquivalent: "q"
        )
        self.quitMenuItem.target = self
        self.pickerMenu.addItem(self.quitMenuItem)
    }

    private func setupHotkeySubscriptions() {
        // Subscribe to shortcut changes to re-register hotkeys
        Preferences.shared.$colorCopyShortcut
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.registerColorCopyShortcut()
            }
            .store(in: &self.cancellables)

        Preferences.shared.$pinToScreenShortcut
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.registerPinToScreenShortcut()
            }
            .store(in: &self.cancellables)
    }

    // MARK: - Actions

    @objc private func copyColorMenuItemAction(_ sender: Any) {
        ColorPicker.shared.copyColorToPasteboard()
    }

    @objc private func pickerWindowItemAction(_ sender: Any) {
        self.showPickerWindow()
    }

    @objc private func formatSubmenuItemAction(_ sender: Any) {
        guard let menuItem = sender as? NSMenuItem,
              let index = self.availableFormatsSubmenu.items.firstIndex(of: menuItem),
              let format = ColorFormat(rawValue: index)
        else { return }

        self.selectedFormatMenuItem?.state = .off
        self.selectedFormatMenuItem = menuItem
        self.selectedFormatMenuItem?.state = .on

        ColorPicker.shared.colorFormat = format
    }

    @objc private func preferencesMenuItemAction(_ sender: Any) {
        self.showPreferencesWindow()
    }

    @objc private func quitMenuItemAction(_ sender: Any) {
        NSApp.terminate(sender)
    }

    // MARK: - Hotkey Registration

    private func registerGlobalHotkeys() {
        self.registerColorCopyShortcut()
        self.registerPinToScreenShortcut()
    }

    private func unregisterGlobalHotkeys() {
        if let shortcut = Preferences.shared.colorCopyShortcut {
            HotkeyManager.shared.unregister(shortcut)
        }
        if let shortcut = Preferences.shared.pinToScreenShortcut {
            HotkeyManager.shared.unregister(shortcut)
        }
    }

    private func registerColorCopyShortcut() {
        // Unregister old shortcut if any
        if let oldShortcut = Preferences.shared.colorCopyShortcut {
            HotkeyManager.shared.unregister(oldShortcut)
        }

        guard let shortcut = Preferences.shared.colorCopyShortcut else { return }

        // Update menu item key equivalent
        self.colorCopyMenuItem?.keyEquivalent = shortcut.keyEquivalent
        self.colorCopyMenuItem?.keyEquivalentModifierMask = shortcut.modifierFlags

        // Register global hotkey
        HotkeyManager.shared.register(shortcut) { [weak self] in
            ColorPicker.shared.copyColorToPasteboard()

            // Flash status item
            self?.statusItem.button?.isHighlighted = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self?.statusItem.button?.isHighlighted = false
            }
        }
    }

    private func registerPinToScreenShortcut() {
        // Unregister old shortcut if any
        if let oldShortcut = Preferences.shared.pinToScreenShortcut {
            HotkeyManager.shared.unregister(oldShortcut)
        }

        guard let shortcut = Preferences.shared.pinToScreenShortcut else { return }

        // Update menu item key equivalent
        self.pinToScreenItem?.keyEquivalent = shortcut.keyEquivalent
        self.pinToScreenItem?.keyEquivalentModifierMask = shortcut.modifierFlags

        // Register global hotkey
        HotkeyManager.shared.register(shortcut) { [weak self] in
            self?.showPickerWindow()
        }
    }

    // MARK: - Window Management

    private func showPickerWindow() {
        if self.pickerWindowController == nil {
            self.pickerWindowController = PickerWindowController()

            // Position window below status item
            if let button = self.statusItem.button,
               let buttonWindow = button.window
            {
                let buttonRect = button.convert(button.bounds, to: nil)
                let screenRect = buttonWindow.convertToScreen(buttonRect)

                var originX = screenRect.origin.x
                let windowWidth = self.pickerWindowController!.window!.frame.width

                // Ensure window doesn't go off screen
                if let screen = NSScreen.main {
                    if originX + windowWidth + 20 > screen.frame.width {
                        originX = screenRect.origin.x - windowWidth + screenRect.width
                    }
                }

                let windowFrame = NSRect(
                    x: originX,
                    y: screenRect.origin.y - self.pickerWindowController!.window!.frame.height,
                    width: self.pickerWindowController!.window!.frame.width,
                    height: self.pickerWindowController!.window!.frame.height
                )
                self.pickerWindowController?.window?.setFrame(windowFrame, display: false)
            }
        }

        self.pickerMenu.cancelTracking()
        self.pickerWindowController?.showWindow(nil)
    }

    private func showPreferencesWindow() {
        PreferencesWindowController.shared.showWindow(nil)
    }
}

// MARK: - NSMenuDelegate

extension AppDelegate: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        self.pickerViewController.shouldUpdateView = true
        self.unregisterGlobalHotkeys()
    }

    func menuDidClose(_ menu: NSMenu) {
        self.pickerViewController.shouldUpdateView = false
        self.registerGlobalHotkeys()
    }
}
