import AppKit

/// Supported color output formats for the picker
enum ColorFormat: Int, CaseIterable, Codable {
    case hex = 0
    case hexNoHash
    case rgb
    case hsb
    case cmyk
    case uiColorObjC
    case uiColorSwift
    case nsColorObjC
    case nsColorSwift

    /// Display name for the format (used in menus)
    var displayName: String {
        switch self {
        case .hex:
            "HEX"
        case .hexNoHash:
            "HEX (No #)"
        case .rgb:
            "RGB"
        case .hsb:
            "HSB"
        case .cmyk:
            "CMYK"
        case .uiColorObjC:
            "UIColor (Objective-C)"
        case .uiColorSwift:
            "UIColor (Swift)"
        case .nsColorObjC:
            "NSColor (Objective-C)"
        case .nsColorSwift:
            "NSColor (Swift)"
        }
    }

    /// Convert a color to this format's string representation
    func string(for color: NSColor) -> String {
        switch self {
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
        case .uiColorObjC:
            color.uiColorObjCRepresentation
        case .uiColorSwift:
            color.uiColorSwiftRepresentation
        case .nsColorObjC:
            color.nsColorObjCRepresentation
        case .nsColorSwift:
            color.nsColorSwiftRepresentation
        }
    }
}

// MARK: - UserDefaults Key

extension ColorFormat {
    static let userDefaultsKey = "PIColorPickerFormat"
}
