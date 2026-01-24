# Picker - AGENTS.md

## Project Overview
Picker is a macOS color picker utility that lives in the menu bar. It allows users to pick colors from anywhere on screen, copy them in various formats, and maintain a history of picked colors. Global keyboard shortcuts enable quick color copying even when the app is not focused.

## Tech Stack
- **Language**: Swift 6
- **UI Framework**: AppKit
- **IDE**: Xcode
- **Platforms**: macOS
- **Minimum Deployment**: macOS 14.0 (Sonoma)

## Style & Conventions (MANDATORY)
**Strictly follow** the Swift/SwiftUI style guide: `~/Agents/Style/swift-swiftui-style-guide.md`

## Localization (MANDATORY)
**Strictly follow** the localization guide: `~/Agents/Guides/localization-guide.md`
- All user-facing strings must be localized
- Follow formality rules per language
- Consistency is paramount

## Additional Guides
- Modern SwiftUI patterns: `~/Agents/Guides/swift-modern-development-guide.md`
- Swift 6 concurrency: `~/Agents/Guides/swift6-concurrency-guide.md`
- Swift 6 migration (compact): `~/Agents/Guides/swift6-migration-compact-guide.md`
- Swift 6 migration (full): `~/Agents/Guides/swift6-migration-full-guide.md`

## Logging (MANDATORY)
This project uses **DZFoundation** (`~/GIT/Libraries/DZFoundation`) for logging.

**All debug logging must use:**
- `DZLog("message")` — General debug output
- `DZErrorLog(error)` — Conditional error logging (only prints if error is non-nil)

```swift
import DZFoundation

DZLog("Starting fetch")       // 🔶 fetchData() 42: Starting fetch
DZErrorLog(error)             // ❌ MyFile.swift:45 fetchData() ERROR: Network unavailable
```

**Do NOT use:**
- `print()` for debug output
- `os.Logger` instances
- `NSLog`

Both functions are no-ops in release builds.

## API Documentation
Local Apple API documentation is available at:
`~/Agents/API Documentation/Apple/`

The `search` binary is located **inside** the documentation folder:
```bash
~/Agents/API\ Documentation/Apple/search --help  # Run once per session
~/Agents/API\ Documentation/Apple/search "view controller" --language swift
~/Agents/API\ Documentation/Apple/search "NSWindow" --type Class
```

## Xcode Project Files (CATASTROPHIC - DO NOT TOUCH)
- **NEVER edit Xcode project files** (`.xcodeproj`, `.xcworkspace`, `project.pbxproj`, `.xcsettings`, etc.)
- Editing these files will corrupt the project - this is **catastrophic and unrecoverable**
- Only the user edits project settings, build phases, schemes, and file references manually in Xcode
- If a file needs to be added to the project, **stop and tell the user** - do not attempt it yourself
- Use `xcodebuild` for building/testing only - never for project manipulation
- **Exception**: Only proceed if the user gives explicit permission for a specific edit

## Build & Format Commands
```bash
# Build
xcodebuild -scheme "Picker" -destination "platform=macOS" build

# Clean
xcodebuild -scheme "Picker" clean
```

## Code Formatting (MANDATORY)
**Always run SwiftFormat after a successful build:**
```bash
swiftformat src/Picker/Classes/
```

SwiftFormat configuration is defined in `.swiftformat` at the project root. This enforces:
- 4-space indentation
- Explicit `self.` usage
- K&R brace style
- Trailing commas in collections
- Consistent wrapping rules

**Do not commit unformatted code.**

---

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
