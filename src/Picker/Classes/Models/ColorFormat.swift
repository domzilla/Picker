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
            NSLocalizedString("HEX", comment: "Color format name")
        case .hexNoHash:
            NSLocalizedString("HEX (No #)", comment: "Color format name without hash")
        case .rgb:
            NSLocalizedString("RGB", comment: "Color format name")
        case .hsb:
            NSLocalizedString("HSB", comment: "Color format name")
        case .cmyk:
            NSLocalizedString("CMYK", comment: "Color format name")
        case .uiColorObjC:
            NSLocalizedString("UIColor (Objective-C)", comment: "Color format name")
        case .uiColorSwift:
            NSLocalizedString("UIColor (Swift)", comment: "Color format name")
        case .nsColorObjC:
            NSLocalizedString("NSColor (Objective-C)", comment: "Color format name")
        case .nsColorSwift:
            NSLocalizedString("NSColor (Swift)", comment: "Color format name")
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
