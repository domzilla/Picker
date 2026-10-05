# Picker - AGENTS.md

## Project Overview
Picker is a macOS color picker utility that lives in the menu bar. It allows users to pick colors from anywhere on screen, copy them in various formats, and maintain a history of picked colors. Global keyboard shortcuts enable quick color copying even when the app is not focused.

## Tech Stack
- **Language**: Swift
- **UI Framework**: AppKit
- **IDE**: Xcode
- **Platforms**: macOS
- **Localization**: 12 languages (`src/Picker/Resources/*.lproj`): de, en, es, fr, it, ja, ko, nl, pt, pt-BR, ru, zh-Hans, plus `Base.lproj` holding `MainMenu.xib`

## Dependencies
- **DZFoundation** (local Swift package, `~/GIT/Libraries/DZFoundation`)
- **Sparkle** (Swift package) — auto-updates

## Guides (MANDATORY)
Read `~/Agents/Guides/xcode-project-guide.md` in full before planning or editing anything.

Read these in full before touching the matching code:
- Swift style (`.swift`): `~/Agents/Style/swift-swiftui-style-guide.md`
- Accessibility (UI code, XIBs, storyboards): `~/Agents/Guides/accessibility-guide.md`

## Build Commands
```bash
# Build
xcodebuild -project src/Picker.xcodeproj -scheme "Picker" -destination "platform=macOS" build

# Clean
xcodebuild -project src/Picker.xcodeproj -scheme "Picker" clean
```

## Testing (MANDATORY)
No test targets exist in this project.

## Project-Specific Notes
### Architecture
- **Pattern**: MVC with singletons for shared services
- **Reactivity**: Existing services use Combine + `ObservableObject` (legacy); new code follows the Swift style guide (`@Observable`)
- **Hotkeys**: Custom Carbon Events wrapper (`Services/Hotkey/`)
- **Preferences**: Native AppKit window (`PreferencesWindowController`)

### Key Services (Singletons)
- `ColorPicker.shared` - Core color picking engine
- `ColorHistory.shared` - Tracks last 6 picked colors
- `Preferences.shared` - App preferences and shortcuts
- `HotkeyManager.shared` - Global hotkey registration

### Color Formats
`Models/ColorFormat.swift` (`ColorFormat` enum, grouped by `Category`) is the source of truth for supported output formats.

### XIB Files
The project uses XIB files for some views:
- XIB-backed classes declare `@objc(ClassName)` so the class names referenced in XIBs resolve
- Connect via `@IBOutlet` and `@IBAction`
