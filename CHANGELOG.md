# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Localization support for 12 languages: English, German, French, Spanish, Italian, Dutch, Japanese, Korean, Portuguese, Brazilian Portuguese, Russian, and Simplified Chinese

### Changed
- Migrate screen capture from CGWindowListCreateImage to ScreenCaptureKit
- Bump minimum deployment target to macOS 26.0

### Fixed
- Fix cursor sometimes being captured in color samples, causing incorrect color values
- Fix color capture failing in global hotkey context
- Fix preview image distortion when picking colors near screen edges

## [2.0.1] - 2026-01-26

### Added
- Sparkle integration for automatic updates with "Check for Updates..." menu item

### Fixed
- Fix global hotkey color copy returning wrong color (#0d0d0e) due to incorrect coordinate conversion

### Changed
- Set app category to utilities

## [2.0.0] - 2026-01-14

### Changed
- Complete migration from Objective-C to Swift 6
- Updated project settings for modern Swift development
- Added DZFoundation dependency for logging
- Updated SwiftFormat configuration

### Added
- Screen capture permission request on app launch
- Queuestack integration for task tracking

### Removed
- Removed obsolete files from legacy codebase

## [1.1.0] - 2025-11-16

### Fixed
- Fixed thread safety issue in color picker
- Draw preview color within bounds
- Draw preview image within bounds

### Changed
- Updated app icon
- Updated nib files
- Code formatting improvements
- Refactoring for improved maintainability

### Removed
- Removed timer (no longer needed)
- Removed BGDataBinding dependency

## [1.0.1] - 2019-10-26

### Changed
- Changed default color picker shortcut
- Disabled General preferences tab (not needed)

## [1.0.0] - 2019-07-17

### Added
- Preferences window with customizable settings
- Color history (tracks last 6 picked colors)
- Global hotkey support (works when app is not focused)
- Copy to pasteboard functionality
- Floating preview window at menu position
- Multiple color format support:
  - HEX (#RRGGBB)
  - HEX without hash (RRGGBB)
  - RGB (rgb(r, g, b))
  - HSB (hsb(h, s, b))
  - CMYK (cmyk(c, m, y, k))
  - UIColor Objective-C
  - UIColor Swift
  - NSColor Objective-C
  - NSColor Swift
- Menu bar integration with NSMenuItem
- App icon
- Handle global hotkey when menu is visible

### Changed
- App activation policy for menu bar behavior

## [0.1.0] - 2019-07-06

### Added
- Initial commit with basic color picker functionality

