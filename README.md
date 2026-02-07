# Picker

A lightweight macOS menu bar color picker with 32 formats, global hotkeys, and color history.

## Features

- **Menu Bar Integration** — Lives in your menu bar, always one click away
- **32 Color Formats** — HEX, RGB, HSB, CSS, SwiftUI, Flutter, Tailwind, and many more
- **Global Hotkeys** — Copy colors or open the picker from anywhere, even when Picker is in the background
- **Color History** — Keeps your last 6 picked colors for quick access
- **Floating Window** — Pin the picker on screen for hands-free color picking
- **Live Preview** — Magnified preview with crosshairs at up to 60 FPS
- **Auto-Update Clipboard** — Change the format after copying and the clipboard updates automatically
- **Localized** — Available in 12 languages

## Color Formats

| Category | Formats |
|---|---|
| **Generic** | HEX, HEX (no #), RGB, HSB, CMYK |
| **Web / CSS** | RGBA, HSL, HSLA, HWB, Color Level 4, CSS Variable |
| **Apple** | SwiftUI Color, SwiftUI Hex, UIColor, NSColor, CGColor, CIColor |
| **Cross-Platform** | Flutter, Flutter RGBO, Android Kotlin, Android XML, Unity C#, Godot GDScript |
| **JavaScript** | JS Object, JS Array, Tailwind CSS |
| **Design** | Float (0-1), Integer (0-255) |
| **Other** | Java AWT, Qt/QML, GLSL vec4, Hex Integer |

## Installation

Download the latest release from the [Releases](../../releases) page and move **Picker.app** to your Applications folder.

On first launch, Picker will ask for **Screen Recording** permission in System Settings > Privacy & Security.

## Keyboard Shortcuts

Picker supports two customizable global hotkeys:

| Action | Description |
|---|---|
| **Copy Color** | Copies the color under your cursor to the clipboard |
| **Pin to Screen** | Opens the floating picker window |

Configure shortcuts in **Preferences > Shortcuts**.

## Languages

English, German, French, Spanish, Italian, Dutch, Japanese, Korean, Portuguese, Brazilian Portuguese, Russian, and Simplified Chinese.

## Requirements

- macOS 26.0 or later

## Building from Source

```bash
git clone <repository-url>
cd Picker
xcodebuild -scheme "Picker" -destination "platform=macOS" build
```

Requires Xcode 16 or later with Swift 6.

## License

Copyright © 2019–2026 Dominic Rodemer. All rights reserved.
