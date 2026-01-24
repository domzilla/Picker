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
