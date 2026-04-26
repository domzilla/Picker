# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- "Check for Updates" no longer fails: Sparkle's feed URL and public key are now bundled correctly, and the required outgoing network entitlement is in place.

## [2.3.0] - 2026-03-01

### Added
- Arrow keys now nudge the cursor pixel by pixel inside the floating preview window.

### Fixed
- Color sampling and the crosshair now target a true center pixel instead of the gap between pixels.

## [2.2.2] - 2026-02-07

### Added
- "About Picker" menu item that opens the standard macOS About panel.
- Localization for 12 languages: English, German, French, Spanish, Italian, Dutch, Japanese, Korean, Portuguese, Brazilian Portuguese, Russian, and Simplified Chinese.
- Auto-update of the clipboard when changing color format within 30 seconds of the last copy.
- 27 new color formats organized by category (Web/CSS, Apple, Cross-Platform, JavaScript, Design, Other), including SwiftUI Color, CGColor, Flutter, Android XML, Unity C#, Tailwind CSS, GLSL vec4, and more.

### Changed
- Migrated screen capture from `CGWindowListCreateImage` to ScreenCaptureKit, with a continuous preview at up to 60 FPS and a one-shot mode for hotkey color copy.
- Reorganized the color format menu with category headers and separators.
- Bumped the minimum deployment target to macOS 26.0.

### Removed
- Removed the deprecated Objective-C color formats (`UIColor`/`NSColor` Objective-C).

### Fixed
- The cursor is no longer captured in color samples, so colors are accurate.
- Color capture now works reliably from the global hotkey context.
- Preview no longer distorts when picking colors near screen edges.
- Preview is no longer laggy in release or notarized builds.

## [2.0.1] - 2026-01-26

### Added
- "Check for Updates..." menu item powered by Sparkle.

### Changed
- App category set to Utilities.

### Fixed
- Global hotkey color copy no longer returns the wrong color (#0d0d0e) due to a coordinate conversion bug.

## [2.0.0] - 2026-01-14

### Added
- Screen capture permission request on app launch.

### Changed
- Complete migration from Objective-C to Swift 6.

## [1.1.0] - 2025-11-16

### Changed
- Updated app icon.

### Removed
- Removed the BGDataBinding dependency.

### Fixed
- Fixed a thread-safety issue in the color picker.
- Preview color and image now draw within their bounds.

## [1.0.1] - 2019-10-26

### Changed
- Changed the default color picker shortcut.

### Removed
- Removed the unused General preferences tab.

## [1.0.0] - 2019-07-17

### Added
- Initial release of Picker, a menu bar color picker.
- Preferences window with customizable settings.
- Color history of the last 6 picked colors.
- Global hotkey support that works even when the app isn't focused.
- Copy to pasteboard.
- Floating preview window at the menu position.
- Color formats: HEX, HEX without hash, RGB, HSB, CMYK, UIColor (Obj-C and Swift), and NSColor (Obj-C and Swift).

## [0.1.0] - 2019-07-06

### Added
- Initial commit with basic color picker functionality.
