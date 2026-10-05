# Picker - AGENTS.md

## Project Overview
Picker is a macOS color picker utility that lives in the menu bar. It allows users to pick colors from anywhere on screen, copy them in various formats, and maintain a history of picked colors. Global keyboard shortcuts enable quick color copying even when the app is not focused.

## Tech Stack
- **Language**: Swift
- **UI Framework**: AppKit
- **IDE**: Xcode
- **Platforms**: macOS

## Guides (MANDATORY)
- Swift style: `~/Agents/Style/swift-swiftui-style-guide.md`
- Accessibility: `~/Agents/Guides/accessibility-guide.md`
- Xcode projects: `~/Agents/Guides/xcode-project-guide.md`

## Build Commands
```bash
# Build
xcodebuild -scheme "Picker" -destination "platform=macOS" build

# Clean
xcodebuild -scheme "Picker" clean
```

## Testing (MANDATORY)
No test targets exist in this project.

## Project-Specific Notes
### Architecture
- **Pattern**: MVC with singletons for shared services
- **Reactivity**: Combine for property observation (replacing KVO)
- **Hotkeys**: Custom Carbon Events wrapper (replacing MASShortcut)
- **Preferences**: Native AppKit window (replacing MASPreferences)

### Key Services (Singletons)
- `ColorPicker.shared` - Core color picking engine
- `ColorHistory.shared` - Tracks last 6 picked colors
- `Preferences.shared` - App preferences and shortcuts
- `HotkeyManager.shared` - Global hotkey registration

### Color Formats Supported
1. HEX (#RRGGBB)
2. HEX without hash (RRGGBB)
3. RGB (rgb(r, g, b))
4. HSB (hsb(h, s, b))
5. CMYK (cmyk(c, m, y, k))
6. UIColor Objective-C
7. UIColor Swift
8. NSColor Objective-C
9. NSColor Swift

### XIB Files
The project uses XIB files for some views. When porting:
- Keep XIB compatibility with `@objc(ClassName)` attribute
- Use `@IBOutlet` and `@IBAction` decorators
- Update class references in XIB files to match Swift class names
