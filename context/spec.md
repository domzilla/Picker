**Technical Specification for Picker**

This document outlines the technical details and specifications for the "Picker" macOS application.

**1. Introduction and Purpose**

"Picker" is a macOS application designed for developers, designers, and anyone working with colors on their screen. Its primary purpose is to provide a user-friendly tool to pick colors from anywhere on the screen, view them in various formats, and maintain a history of recently picked colors. The application resides in the menu bar for easy access.

**2. High-Level Architecture**

The application follows a standard Model-View-Controller (MVC) architecture common in macOS development with AppKit.

*   **Model:** The data layer consists of classes that manage the application's data and business logic. This includes managing color data, color history, and user preferences.
    *   `PIColorPicker`: Manages the core color picking functionality, including tracking the mouse location and capturing the color under the cursor.
    *   `PIColorHistory`: Handles the storage and retrieval of previously picked colors.
    *   `PIPreferences`: Manages user-configurable settings, such as keyboard shortcuts.
*   **View:** The user interface elements are defined in `.xib` files and managed by their corresponding view controllers.
    *   `MainMenu.xib`: Defines the main application menu.
    *   `PIPickerViewController.xib`: Lays out the main color picker interface, including the color preview, color value text fields, and color history buttons.
    *   `PIGeneralPreferencesViewController.xib` and `PIShortcutsPreferencesViewController.xib`: Define the user interface for the application's preferences.
*   **Controller:** The controllers act as the intermediary between the Model and the View, handling user input and updating the UI.
    *   `PIAppDelegate`: The main application delegate, responsible for managing the application's lifecycle and setting up the main components.
    *   `PIPickerWindowController` and `PIPickerViewController`: Manage the main color picker window and its view, respectively. They handle user interactions and display color information.
    *   `PIPreferencesWindowController`, `PIGeneralPreferencesViewController`, and `PIShortcutsPreferencesViewController`: Manage the preferences window and its different panes.

**3. Core Functionality**

*   **Color Picking:** The application allows users to pick a color from anywhere on the screen. This is achieved by tracking the mouse cursor's position and capturing a small area of the screen around it.
*   **Color Information Display:** Once a color is picked, the application displays its value in multiple formats:
    *   HEX
    *   RGB
    *   HSB
    *   The coordinates (x, y) of the picked color are also displayed.
*   **Color History:** The application maintains a history of the last six colors that have been copied. These are displayed as clickable buttons in the main interface, allowing for quick reuse.
*   **Menu Bar Integration:** The application runs as a status bar item, providing a convenient and non-intrusive way to access the color picker.
*   **Keyboard Shortcuts:** Users can configure global keyboard shortcuts to:
    *   Copy the currently selected color to the clipboard.
    *   Pin the color picker window to the screen, keeping it on top of other windows.
*   **Color Format Selection:** Users can select the format in which the color is copied to the clipboard from a dropdown menu. Available formats include:
    *   HEX (with and without a hash)
    *   RGB
    *   HSB
    *   CMYK
    *   UIColor (for iOS/macOS development in Objective-C and Swift)
    *   NSColor (for macOS development in Objective-C and Swift)
*   **Preferences:** A dedicated preferences window allows users to customize the application's behavior, specifically the keyboard shortcuts for copying colors and pinning the window.

**4. Dependencies**

The "Picker" application utilizes the following third-party frameworks:

*   **BGFoundation:** A custom framework, likely for providing foundational utilities and extensions.
*   **MASShortcut:** Used for handling global keyboard shortcuts, allowing the user to set and record their preferred key combinations for actions within the app.
*   **MASPreferences:** A framework for creating a standardized and user-friendly preferences window.

**5. File Structure Overview**

The project is organized into logical groups:

*   `Picker/`: The main application group.
    *   `Classes/`: Contains the majority of the application's source code, further subdivided into:
        *   `WindowController/`: `PIPickerWindowController` and `PIPreferencesWindowController`.
        *   `ViewController/`: `PIPickerViewController`, `PIGeneralPreferencesViewController`, and `PIShortcutsPreferencesViewController`.
        *   `Views/`: Custom view classes like `PIPickerPreviewView`, `PIColorView`, and `PIColorButton`.
        *   `Data/`: Data model classes such as `PIColorHistory`, `PIColorPicker`, `PIPreviewImageGrabber`, and `PIPreferences`.
        *   `Categories/`: An Objective-C category on `NSColor` (`NSColor+Picker`) to add custom functionality for color format conversions.
    *   `Assets.xcassets/`: Contains the application's icon and other image assets.
    *   `Base.lproj/MainMenu.xib`: The main application menu interface definition.
    *   `Info.plist`: The application's property list file containing metadata.
*   `Extern/`: Contains references to the external project dependencies.

**6. User Interface**

*   **Main Picker View:** A compact window that displays a magnified preview of the area around the cursor, the currently selected color, color values in different formats, and a history of recently copied colors.
*   **Menu Bar Icon:** An eyedropper icon in the system menu bar provides access to the application's functionality.
*   **Preferences Window:** A standard macOS preferences window with "General" and "Shortcuts" tabs for configuration.

**7. Build and Deployment**

*   The project is configured to be built with Xcode 10.2 or later.
*   It targets macOS 10.13 and later.
*   The application is sandboxed, as indicated by the `Picker.entitlements` file, with permissions to read user-selected files.

**8. Code and Asset Details**

*   **Programming Language:** The application is written in Objective-C.
*   **Class Prefix:** The project uses the `PI` class prefix.
*   **Image Assets:** The `Assets.xcassets` folder includes the application icon in various resolutions and a template image for the menu bar icon.