import AppKit

/// Supported color output formats for the picker
enum ColorFormat: Int, CaseIterable, Codable {
    // MARK: - Generic (0-9)

    case hex = 0
    case hexNoHash = 1
    case rgb = 2
    case hsb = 3
    case cmyk = 4

    // MARK: - Web/CSS (10-19)

    case cssRGBA = 10
    case cssHSL = 11
    case cssHSLA = 12
    case cssHWB = 13
    case cssColor4 = 14
    case cssVariable = 15

    // MARK: - Apple Platforms (20-29)

    case swiftUIColor = 20
    case swiftUIHex = 21
    case uiColorSwift = 22
    case nsColorSwift = 23
    case cgColor = 24
    case ciColor = 25

    // MARK: - Cross-Platform (30-39)

    case flutter = 30
    case flutterRGBO = 31
    case androidKotlin = 32
    case androidXML = 33
    case unity = 34
    case godot = 35

    // MARK: - JavaScript (40-49)

    case jsObject = 40
    case jsArray = 41
    case tailwind = 42

    // MARK: - Design (50-59)

    case rawFloat = 50
    case rawInteger = 51

    // MARK: - Other (60-69)

    case javaAWT = 60
    case qtQML = 61
    case glsl = 62
    case hexInteger = 63

    // MARK: - Category

    /// Color format categories for menu organization
    enum Category: Int, CaseIterable {
        case generic
        case web
        case apple
        case crossPlatform
        case javascript
        case design
        case other

        var displayName: String {
            switch self {
            case .generic:
                NSLocalizedString("Generic", comment: "Color format category")
            case .web:
                NSLocalizedString("Web / CSS", comment: "Color format category")
            case .apple:
                NSLocalizedString("Apple Platforms", comment: "Color format category")
            case .crossPlatform:
                NSLocalizedString("Cross-Platform", comment: "Color format category")
            case .javascript:
                NSLocalizedString("JavaScript", comment: "Color format category")
            case .design:
                NSLocalizedString("Design", comment: "Color format category")
            case .other:
                NSLocalizedString("Other", comment: "Color format category")
            }
        }

        /// All formats belonging to this category, in display order
        var formats: [ColorFormat] {
            switch self {
            case .generic:
                [.hex, .hexNoHash, .rgb, .hsb, .cmyk]
            case .web:
                [.cssRGBA, .cssHSL, .cssHSLA, .cssHWB, .cssColor4, .cssVariable]
            case .apple:
                [.swiftUIColor, .swiftUIHex, .uiColorSwift, .nsColorSwift, .cgColor, .ciColor]
            case .crossPlatform:
                [.flutter, .flutterRGBO, .androidKotlin, .androidXML, .unity, .godot]
            case .javascript:
                [.jsObject, .jsArray, .tailwind]
            case .design:
                [.rawFloat, .rawInteger]
            case .other:
                [.javaAWT, .qtQML, .glsl, .hexInteger]
            }
        }
    }

    /// The category this format belongs to
    var category: Category {
        switch self {
        case .hex, .hexNoHash, .rgb, .hsb, .cmyk:
            .generic
        case .cssRGBA, .cssHSL, .cssHSLA, .cssHWB, .cssColor4, .cssVariable:
            .web
        case .swiftUIColor, .swiftUIHex, .uiColorSwift, .nsColorSwift, .cgColor, .ciColor:
            .apple
        case .flutter, .flutterRGBO, .androidKotlin, .androidXML, .unity, .godot:
            .crossPlatform
        case .jsObject, .jsArray, .tailwind:
            .javascript
        case .rawFloat, .rawInteger:
            .design
        case .javaAWT, .qtQML, .glsl, .hexInteger:
            .other
        }
    }

    /// Display name for the format (used in menus)
    var displayName: String {
        switch self {
        // Generic
        case .hex:
            NSLocalizedString("HEX", comment: "Color format name")
        case .hexNoHash:
            NSLocalizedString("HEX (No #)", comment: "Color format name")
        case .rgb:
            NSLocalizedString("RGB", comment: "Color format name")
        case .hsb:
            NSLocalizedString("HSB", comment: "Color format name")
        case .cmyk:
            NSLocalizedString("CMYK", comment: "Color format name")
        // Web/CSS
        case .cssRGBA:
            NSLocalizedString("CSS RGBA", comment: "Color format name")
        case .cssHSL:
            NSLocalizedString("CSS HSL", comment: "Color format name")
        case .cssHSLA:
            NSLocalizedString("CSS HSLA", comment: "Color format name")
        case .cssHWB:
            NSLocalizedString("CSS HWB", comment: "Color format name")
        case .cssColor4:
            NSLocalizedString("CSS Color Level 4", comment: "Color format name")
        case .cssVariable:
            NSLocalizedString("CSS Variable", comment: "Color format name")
        // Apple Platforms
        case .swiftUIColor:
            NSLocalizedString("SwiftUI Color", comment: "Color format name")
        case .swiftUIHex:
            NSLocalizedString("SwiftUI Color (Hex)", comment: "Color format name")
        case .uiColorSwift:
            NSLocalizedString("UIColor (Swift)", comment: "Color format name")
        case .nsColorSwift:
            NSLocalizedString("NSColor (Swift)", comment: "Color format name")
        case .cgColor:
            NSLocalizedString("CGColor", comment: "Color format name")
        case .ciColor:
            NSLocalizedString("CIColor", comment: "Color format name")
        // Cross-Platform
        case .flutter:
            NSLocalizedString("Flutter Color", comment: "Color format name")
        case .flutterRGBO:
            NSLocalizedString("Flutter RGBO", comment: "Color format name")
        case .androidKotlin:
            NSLocalizedString("Android Kotlin", comment: "Color format name")
        case .androidXML:
            NSLocalizedString("Android XML", comment: "Color format name")
        case .unity:
            NSLocalizedString("Unity C#", comment: "Color format name")
        case .godot:
            NSLocalizedString("Godot GDScript", comment: "Color format name")
        // JavaScript
        case .jsObject:
            NSLocalizedString("JS Object", comment: "Color format name")
        case .jsArray:
            NSLocalizedString("JS Array", comment: "Color format name")
        case .tailwind:
            NSLocalizedString("Tailwind CSS", comment: "Color format name")
        // Design
        case .rawFloat:
            NSLocalizedString("Float (0-1)", comment: "Color format name")
        case .rawInteger:
            NSLocalizedString("Integer (0-255)", comment: "Color format name")
        // Other
        case .javaAWT:
            NSLocalizedString("Java AWT", comment: "Color format name")
        case .qtQML:
            NSLocalizedString("Qt / QML", comment: "Color format name")
        case .glsl:
            NSLocalizedString("GLSL vec4", comment: "Color format name")
        case .hexInteger:
            NSLocalizedString("Hex Integer", comment: "Color format name")
        }
    }

    /// Convert a color to this format's string representation
    func string(for color: NSColor) -> String {
        switch self {
        // Generic
        case .hex:
            color.hexRepresentation
        case .hexNoHash:
            color.hexNoHashRepresentation
        case .rgb:
            color.rgbRepresentation
        case .hsb:
            color.hsbRepresentation
        case .cmyk:
            color.cmykRepresentation
        // Web/CSS
        case .cssRGBA:
            color.cssRGBARepresentation
        case .cssHSL:
            color.cssHSLRepresentation
        case .cssHSLA:
            color.cssHSLARepresentation
        case .cssHWB:
            color.cssHWBRepresentation
        case .cssColor4:
            color.cssColor4Representation
        case .cssVariable:
            color.cssVariableRepresentation
        // Apple Platforms
        case .swiftUIColor:
            color.swiftUIColorRepresentation
        case .swiftUIHex:
            color.swiftUIHexRepresentation
        case .uiColorSwift:
            color.uiColorSwiftRepresentation
        case .nsColorSwift:
            color.nsColorSwiftRepresentation
        case .cgColor:
            color.cgColorRepresentation
        case .ciColor:
            color.ciColorRepresentation
        // Cross-Platform
        case .flutter:
            color.flutterRepresentation
        case .flutterRGBO:
            color.flutterRGBORepresentation
        case .androidKotlin:
            color.androidKotlinRepresentation
        case .androidXML:
            color.androidXMLRepresentation
        case .unity:
            color.unityRepresentation
        case .godot:
            color.godotRepresentation
        // JavaScript
        case .jsObject:
            color.jsObjectRepresentation
        case .jsArray:
            color.jsArrayRepresentation
        case .tailwind:
            color.tailwindRepresentation
        // Design
        case .rawFloat:
            color.rawFloatRepresentation
        case .rawInteger:
            color.rawIntegerRepresentation
        // Other
        case .javaAWT:
            color.javaAWTRepresentation
        case .qtQML:
            color.qtQMLRepresentation
        case .glsl:
            color.glslRepresentation
        case .hexInteger:
            color.hexIntegerRepresentation
        }
    }
}

// MARK: - UserDefaults Key

extension ColorFormat {
    static let userDefaultsKey = "PIColorPickerFormat"
}
