import AppKit
import Carbon.HIToolbox

/// A view for recording keyboard shortcuts
@objc(ShortcutRecorderView)
class ShortcutRecorderView: NSControl {
    // MARK: - Properties

    /// The current shortcut value
    var shortcutValue: Shortcut? {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.needsDisplay = true
            self.shortcutValueChange?(self)
        }
    }

    /// Callback when the shortcut changes
    var shortcutValueChange: ((ShortcutRecorderView) -> Void)?

    /// Whether the view is currently recording
    private(set) var isRecording: Bool = false {
        didSet {
            if oldValue != self.isRecording {
                self.updateRecordingState()
            }
        }
    }

    /// Placeholder text shown during recording
    private var placeholder: String?

    /// Whether the mouse is hovering over the clear button
    private var isHinting: Bool = false

    /// Event monitor for keyboard events during recording (nonisolated for deinit access)
    private nonisolated(unsafe) var eventMonitor: Any?

    /// Observer for window resign notifications (nonisolated for deinit access)
    private nonisolated(unsafe) var resignObserver: Any?

    // MARK: - Initialization

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }

    private func commonInit() {
        self.wantsLayer = true
    }

    deinit {
        // Clean up monitors directly (stopRecording is @MainActor, but deinit is nonisolated)
        if let monitor = self.eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
        if let observer = self.resignObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Drawing

    override var intrinsicContentSize: NSSize {
        NSSize(width: 120, height: 25)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Draw background
        let bezelPath = NSBezierPath(roundedRect: self.bounds, xRadius: 5, yRadius: 5)
        if self.isRecording {
            NSColor.controlAccentColor.withAlphaComponent(0.1).setFill()
        } else {
            NSColor.controlBackgroundColor.setFill()
        }
        bezelPath.fill()

        // Draw border
        NSColor.separatorColor.setStroke()
        bezelPath.stroke()

        // Draw text
        let title: String = if self.isRecording {
            self.placeholder ?? NSLocalizedString("Type Shortcut", comment: "")
        } else if let shortcut = self.shortcutValue {
            shortcut.displayString
        } else {
            NSLocalizedString("Record Shortcut", comment: "")
        }

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 11),
            .foregroundColor: NSColor.labelColor,
        ]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        let titleSize = attributedTitle.size()

        var titleRect = self.bounds
        if self.shortcutValue != nil, !self.isRecording {
            // Leave room for clear button
            titleRect.size.width -= 23
        }

        let titleOrigin = NSPoint(
            x: titleRect.midX - titleSize.width / 2,
            y: titleRect.midY - titleSize.height / 2
        )
        attributedTitle.draw(at: titleOrigin)

        // Draw clear button if has shortcut and not recording
        if self.shortcutValue != nil, !self.isRecording {
            let clearRect = self.clearButtonRect()
            let clearSymbol = "\u{2715}" // X symbol
            let clearAttributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 11),
                .foregroundColor: self.isHinting ? NSColor.labelColor : NSColor.secondaryLabelColor,
            ]
            let clearString = NSAttributedString(string: clearSymbol, attributes: clearAttributes)
            let clearSize = clearString.size()
            let clearOrigin = NSPoint(
                x: clearRect.midX - clearSize.width / 2,
                y: clearRect.midY - clearSize.height / 2
            )
            clearString.draw(at: clearOrigin)
        }

        // Draw escape hint when recording
        if self.isRecording {
            let escRect = self.clearButtonRect()
            let escSymbol = "\u{238B}" // Escape symbol
            let escAttributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 11),
                .foregroundColor: NSColor.secondaryLabelColor,
            ]
            let escString = NSAttributedString(string: escSymbol, attributes: escAttributes)
            let escSize = escString.size()
            let escOrigin = NSPoint(
                x: escRect.midX - escSize.width / 2,
                y: escRect.midY - escSize.height / 2
            )
            escString.draw(at: escOrigin)
        }
    }

    private func clearButtonRect() -> NSRect {
        var rect = self.bounds
        rect.origin.x = rect.maxX - 23
        rect.size.width = 23
        return rect
    }

    // MARK: - Mouse Handling

    override func mouseDown(with event: NSEvent) {
        guard self.isEnabled else {
            super.mouseDown(with: event)
            return
        }

        let location = self.convert(event.locationInWindow, from: nil)

        if self.isRecording {
            // Click on escape button cancels recording
            if self.clearButtonRect().contains(location) {
                self.stopRecording()
            }
        } else {
            if self.shortcutValue != nil, self.clearButtonRect().contains(location) {
                // Click on clear button clears the shortcut
                self.shortcutValue = nil
            } else {
                // Click anywhere else starts recording
                self.startRecording()
            }
        }
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        // Remove old tracking areas
        for area in self.trackingAreas {
            self.removeTrackingArea(area)
        }

        // Add tracking area for clear button
        if self.shortcutValue != nil, !self.isRecording {
            let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways]
            let area = NSTrackingArea(rect: self.clearButtonRect(), options: options, owner: self, userInfo: nil)
            self.addTrackingArea(area)
        }
    }

    override func mouseEntered(with event: NSEvent) {
        self.isHinting = true
        self.needsDisplay = true
    }

    override func mouseExited(with event: NSEvent) {
        self.isHinting = false
        self.needsDisplay = true
    }

    // MARK: - Recording

    func startRecording() {
        guard !self.isRecording else { return }
        self.isRecording = true
    }

    func stopRecording() {
        guard self.isRecording else { return }
        self.isRecording = false
    }

    private func updateRecordingState() {
        if self.isRecording {
            self.activateEventMonitoring(true)
            self.activateResignObserver(true)
        } else {
            self.activateEventMonitoring(false)
            self.activateResignObserver(false)
            self.placeholder = nil
        }
        self.updateTrackingAreas()
        self.invalidateIntrinsicContentSize()
        self.needsDisplay = true
    }

    private func activateEventMonitoring(_ activate: Bool) {
        if activate {
            guard self.eventMonitor == nil else { return }

            let eventMask: NSEvent.EventTypeMask = [.keyDown, .flagsChanged]
            self.eventMonitor = NSEvent.addLocalMonitorForEvents(matching: eventMask) { [weak self] event in
                guard let self else { return event }
                return self.handleKeyEvent(event)
            }
        } else {
            if let monitor = self.eventMonitor {
                NSEvent.removeMonitor(monitor)
                self.eventMonitor = nil
            }
        }
    }

    private func activateResignObserver(_ activate: Bool) {
        if activate {
            guard self.resignObserver == nil else { return }

            self.resignObserver = NotificationCenter.default.addObserver(
                forName: NSWindow.didResignKeyNotification,
                object: self.window,
                queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.stopRecording()
                }
            }
        } else {
            if let observer = self.resignObserver {
                NotificationCenter.default.removeObserver(observer)
                self.resignObserver = nil
            }
        }
    }

    private func handleKeyEvent(_ event: NSEvent) -> NSEvent? {
        let keyCode = Int(event.keyCode)
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        // Tab key passes through
        if keyCode == kVK_Tab {
            return event
        }

        // Escape without modifiers cancels recording
        if keyCode == kVK_Escape, modifiers.isEmpty {
            self.stopRecording()
            return nil
        }

        // Delete/Backspace without modifiers clears the shortcut
        if keyCode == kVK_Delete || keyCode == kVK_ForwardDelete, modifiers.isEmpty {
            self.shortcutValue = nil
            self.stopRecording()
            return nil
        }

        // Cmd+W or Cmd+Q cancel recording but pass through
        if modifiers == .command, keyCode == kVK_ANSI_W || keyCode == kVK_ANSI_Q {
            self.stopRecording()
            return event
        }

        // Check if we have a valid shortcut (key + modifiers)
        let shortcut = Shortcut(keyCode: keyCode, modifierFlags: modifiers)

        if event.type == .flagsChanged {
            // User is pressing modifier keys only - show placeholder
            if !modifiers.isEmpty {
                self.placeholder = shortcut.modifierFlagsString
                self.needsDisplay = true
            }
            return nil
        }

        // Validate the shortcut
        if shortcut.keyCodeString.isEmpty {
            // Invalid key
            NSSound.beep()
            return nil
        }

        // Valid shortcut - accept it
        self.shortcutValue = shortcut
        self.stopRecording()
        return nil
    }

    // MARK: - Accessibility

    override func isAccessibilityElement() -> Bool {
        true
    }

    override func accessibilityLabel() -> String? {
        if let shortcut = self.shortcutValue {
            return shortcut.displayString + " " + NSLocalizedString("keyboard shortcut", comment: "")
        }
        return NSLocalizedString("Empty keyboard shortcut", comment: "")
    }

    override func accessibilityRole() -> NSAccessibility.Role? {
        .button
    }

    override func accessibilityPerformPress() -> Bool {
        if !self.isRecording {
            self.startRecording()
            return true
        }
        return false
    }
}
