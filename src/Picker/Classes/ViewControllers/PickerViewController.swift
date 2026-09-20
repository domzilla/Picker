import AppKit
import Combine

/// Mode for the picker view controller
enum PickerViewControllerMode {
    /// Full window mode with format selector
    case defaultMode
    /// Compact menu bar mode
    case menuMode
}

/// Main view controller for the color picker UI
@objc(PickerViewController)
class PickerViewController: NSViewController {
    // MARK: - Properties

    /// The display mode
    let mode: PickerViewControllerMode

    /// Whether the view should actively update
    var shouldUpdateView: Bool = false {
        didSet {
            if self.shouldUpdateView {
                self.updateView()
            }
        }
    }

    // MARK: - Outlets

    @IBOutlet var pickerPreviewView: PickerPreviewView!
    @IBOutlet var colorPreview: ColorView!
    @IBOutlet var rgbText: NSTextField!
    @IBOutlet var hexText: NSTextField!
    @IBOutlet var hueText: NSTextField!
    @IBOutlet var saturationText: NSTextField!
    @IBOutlet var brightnessText: NSTextField!
    @IBOutlet var xText: NSTextField!
    @IBOutlet var yText: NSTextField!

    @IBOutlet var colorHistoryButton1: ColorButton!
    @IBOutlet var colorHistoryButton2: ColorButton!
    @IBOutlet var colorHistoryButton3: ColorButton!
    @IBOutlet var colorHistoryButton4: ColorButton!
    @IBOutlet var colorHistoryButton5: ColorButton!
    @IBOutlet var colorHistoryButton6: ColorButton!

    @IBOutlet var shortcutLabel: NSTextField!
    @IBOutlet var formatButton: NSPopUpButton!

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(mode: PickerViewControllerMode) {
        self.mode = mode
        super.init(nibName: "PickerViewController", bundle: .main)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure format button based on mode
        if self.mode == .menuMode {
            self.formatButton?.isHidden = true
        } else {
            self.formatButton?.isHidden = false
            self.formatButton?.removeAllItems()
            for format in ColorFormat.allCases {
                self.formatButton?.addItem(withTitle: format.displayName)
            }
            self.formatButton?.selectItem(at: ColorPicker.shared.colorFormat.rawValue)
        }

        self.setupAccessibility()

        // Set up Combine subscriptions
        self.setupSubscriptions()

        // Initial update
        self.updateColorCopyShortcut()
        self.updateHistory()
    }

    // MARK: - Actions

    @IBAction
    func colorHistoryButtonAction(_ sender: Any) {
        guard
            let button = sender as? ColorButton,
            let color = button.color else { return }

        ColorPicker.shared.copyColor(color, toPasteboard: .general, saveToHistory: false)
    }

    @IBAction
    func formatButtonAction(_: Any) {
        guard
            let index = self.formatButton?.indexOfSelectedItem,
            let format = ColorFormat(rawValue: index) else { return }

        ColorPicker.shared.colorFormat = format
    }

    // MARK: - Private Methods

    private func setupAccessibility() {
        self.pickerPreviewView?.setAccessibilityElement(true)
        self.pickerPreviewView?.setAccessibilityRole(.image)
        self.pickerPreviewView?.setAccessibilityLabel(NSLocalizedString(
            "Magnified preview",
            tableName: "Accessibility",
            comment: "Accessibility label for the magnified screen preview"
        ))
        self.pickerPreviewView?.setAccessibilityIdentifier("PickerViewController.pickerPreviewView")

        self.colorPreview?.setAccessibilityElement(true)
        self.colorPreview?.setAccessibilityRole(.image)
        self.colorPreview?.setAccessibilityLabel(NSLocalizedString(
            "Picked color",
            tableName: "Accessibility",
            comment: "Accessibility label for the swatch showing the picked color"
        ))
        self.colorPreview?.setAccessibilityIdentifier("PickerViewController.colorPreview")

        self.colorHistoryButton1?.setAccessibilityLabel(NSLocalizedString(
            "Recent color 1",
            tableName: "Accessibility",
            comment: "Accessibility label for the first recently picked color"
        ))
        self.colorHistoryButton1?.setAccessibilityIdentifier("PickerViewController.colorHistoryButton1")

        self.colorHistoryButton2?.setAccessibilityLabel(NSLocalizedString(
            "Recent color 2",
            tableName: "Accessibility",
            comment: "Accessibility label for the second recently picked color"
        ))
        self.colorHistoryButton2?.setAccessibilityIdentifier("PickerViewController.colorHistoryButton2")

        self.colorHistoryButton3?.setAccessibilityLabel(NSLocalizedString(
            "Recent color 3",
            tableName: "Accessibility",
            comment: "Accessibility label for the third recently picked color"
        ))
        self.colorHistoryButton3?.setAccessibilityIdentifier("PickerViewController.colorHistoryButton3")

        self.colorHistoryButton4?.setAccessibilityLabel(NSLocalizedString(
            "Recent color 4",
            tableName: "Accessibility",
            comment: "Accessibility label for the fourth recently picked color"
        ))
        self.colorHistoryButton4?.setAccessibilityIdentifier("PickerViewController.colorHistoryButton4")

        self.colorHistoryButton5?.setAccessibilityLabel(NSLocalizedString(
            "Recent color 5",
            tableName: "Accessibility",
            comment: "Accessibility label for the fifth recently picked color"
        ))
        self.colorHistoryButton5?.setAccessibilityIdentifier("PickerViewController.colorHistoryButton5")

        self.colorHistoryButton6?.setAccessibilityLabel(NSLocalizedString(
            "Recent color 6",
            tableName: "Accessibility",
            comment: "Accessibility label for the sixth recently picked color"
        ))
        self.colorHistoryButton6?.setAccessibilityIdentifier("PickerViewController.colorHistoryButton6")

        self.formatButton?.setAccessibilityLabel(NSLocalizedString(
            "Color format",
            tableName: "Accessibility",
            comment: "Accessibility label for the color format selector"
        ))
        self.formatButton?.setAccessibilityIdentifier("PickerViewController.formatButton")

        self.hexText?.setAccessibilityIdentifier("PickerViewController.hexText")
        self.rgbText?.setAccessibilityIdentifier("PickerViewController.rgbText")
        self.hueText?.setAccessibilityIdentifier("PickerViewController.hueText")
        self.saturationText?.setAccessibilityIdentifier("PickerViewController.saturationText")
        self.brightnessText?.setAccessibilityIdentifier("PickerViewController.brightnessText")
        self.xText?.setAccessibilityIdentifier("PickerViewController.xText")
        self.yText?.setAccessibilityIdentifier("PickerViewController.yText")
        self.shortcutLabel?.setAccessibilityIdentifier("PickerViewController.shortcutLabel")
    }

    private func setupSubscriptions() {
        // Subscribe to color changes
        ColorPicker.shared.colorDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.updateView()
            }
            .store(in: &self.cancellables)

        // Subscribe to history changes
        ColorHistory.shared.historyDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.updateHistory()
            }
            .store(in: &self.cancellables)

        // Subscribe to shortcut changes
        Preferences.shared.$colorCopyShortcut
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateColorCopyShortcut()
            }
            .store(in: &self.cancellables)
    }

    private func updateColorCopyShortcut() {
        guard let shortcut = Preferences.shared.colorCopyShortcut else {
            self.shortcutLabel?.stringValue = ""
            return
        }

        let shortcutString = shortcut.displayString
        self.shortcutLabel?.stringValue = String(
            format: NSLocalizedString("Press %@ to copy color", comment: "Shortcut hint"),
            shortcutString
        )
    }

    private func updateView() {
        guard self.shouldUpdateView else { return }

        let picker = ColorPicker.shared
        let color = picker.color

        self.pickerPreviewView?.previewImage = picker.previewImage
        self.colorPreview?.color = color

        self.hexText?.stringValue = color.hexRepresentation
        self.rgbText?.stringValue = color.rgbRepresentation

        self.hueText?.stringValue = color.hueRepresentation
        self.saturationText?.stringValue = color.saturationRepresentation
        self.brightnessText?.stringValue = color.brightnessRepresentation

        self.xText?.stringValue = String(format: "%.0f", picker.mouseLocation.x)
        self.yText?.stringValue = String(format: "%.0f", picker.mouseLocation.y)
    }

    private func updateHistory() {
        let history = ColorHistory.shared

        self.colorHistoryButton1?.color = history.color(at: 0)
        self.colorHistoryButton2?.color = history.color(at: 1)
        self.colorHistoryButton3?.color = history.color(at: 2)
        self.colorHistoryButton4?.color = history.color(at: 3)
        self.colorHistoryButton5?.color = history.color(at: 4)
        self.colorHistoryButton6?.color = history.color(at: 5)
    }
}
