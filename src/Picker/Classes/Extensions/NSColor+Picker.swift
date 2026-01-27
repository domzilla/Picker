import AppKit

extension NSColor {
    // MARK: - Private Helpers

    /// Convert to genericRGB colorspace and extract components
    /// This is essential because colors may be in grayscale or other colorspaces
    private var rgbComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        guard let converted = self.usingColorSpace(.genericRGB) else {
            return (0, 0, 0, 1)
        }
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        converted.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }

    /// Convert to genericRGB colorspace and extract HSB components
    private var hsbComponents: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        guard let converted = self.usingColorSpace(.genericRGB) else {
            return (0, 0, 0, 1)
        }
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        converted.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (h, s, b, a)
    }

    /// Convert to deviceCMYK colorspace and extract components
    private var cmykComponents: (cyan: CGFloat, magenta: CGFloat, yellow: CGFloat, black: CGFloat, alpha: CGFloat) {
        guard let converted = self.usingColorSpace(.deviceCMYK) else {
            return (0, 0, 0, 1, 1)
        }
        var c: CGFloat = 0
        var m: CGFloat = 0
        var y: CGFloat = 0
        var k: CGFloat = 0
        var a: CGFloat = 0
        converted.getCyan(&c, magenta: &m, yellow: &y, black: &k, alpha: &a)
        return (c, m, y, k, a)
    }

    private var hexString: String {
        let (r, g, b, a) = self.rgbComponents
        let red = String(format: "%02x", Int(r * 255))
        let green = String(format: "%02x", Int(g * 255))
        let blue = String(format: "%02x", Int(b * 255))
        let alpha = String(format: "%02x", Int(a * 255))
        return "\(red)\(green)\(blue)\(alpha)"
    }

    private var isGrayscale: Bool {
        let (r, g, b, _) = self.rgbComponents
        // Use tolerance for floating point comparison
        let tolerance: CGFloat = 0.001
        return abs(r - g) < tolerance && abs(g - b) < tolerance
    }

    /// Convert to HSL components (different from HSB/HSV)
    private var hslComponents: (hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat) {
        let (r, g, b, a) = self.rgbComponents
        let maxC = max(r, g, b)
        let minC = min(r, g, b)
        let delta = maxC - minC

        // Lightness
        let l = (maxC + minC) / 2

        // Saturation
        let s: CGFloat = if delta == 0 {
            0
        } else {
            delta / (1 - abs(2 * l - 1))
        }

        // Hue (reuse from HSB since it's the same calculation)
        let (h, _, _, _) = self.hsbComponents

        return (h, min(s, 1), l, a)
    }

    /// HWB (Hue-Whiteness-Blackness) components
    private var hwbComponents: (hue: CGFloat, whiteness: CGFloat, blackness: CGFloat, alpha: CGFloat) {
        let (r, g, b, a) = self.rgbComponents
        let (h, _, _, _) = self.hsbComponents
        let whiteness = min(r, g, b)
        let blackness = 1 - max(r, g, b)
        return (h, whiteness, blackness, a)
    }

    // MARK: - Generic Format Representations

    /// HEX representation with hash (e.g., "#FF5733")
    var hexRepresentation: String {
        "#\(String(self.hexString.prefix(6)))"
    }

    /// HEX representation without hash (e.g., "FF5733")
    var hexNoHashRepresentation: String {
        String(self.hexString.prefix(6))
    }

    /// RGB representation (e.g., "rgb(255, 87, 51)")
    var rgbRepresentation: String {
        let (r, g, b, _) = self.rgbComponents
        return "rgb(\(Int(r * 255)), \(Int(g * 255)), \(Int(b * 255)))"
    }

    /// HSB representation (e.g., "hsb(11, 80, 100)")
    var hsbRepresentation: String {
        let (h, s, b, _) = self.hsbComponents
        return "hsb(\(Int(h * 360)), \(Int(s * 100)), \(Int(b * 100)))"
    }

    /// CMYK representation (e.g., "cmyk(0, 166, 204, 0)")
    var cmykRepresentation: String {
        let (c, m, y, k, _) = self.cmykComponents
        return "cmyk(\(Int(c * 255)), \(Int(m * 255)), \(Int(y * 255)), \(Int(k * 255)))"
    }

    /// UIColor Swift representation
    var uiColorSwiftRepresentation: String {
        let (r, g, b, _) = self.rgbComponents
        if self.isGrayscale {
            return String(format: "UIColor(white: %.2f, alpha: 1.0)", r)
        }
        return String(format: "UIColor(red: %.2f, green: %.2f, blue: %.2f, alpha: 1.0)", r, g, b)
    }

    /// NSColor Swift representation
    var nsColorSwiftRepresentation: String {
        let (r, g, b, _) = self.rgbComponents
        if self.isGrayscale {
            return String(format: "NSColor(calibratedWhite: %.2f, alpha: 1.0)", r)
        }
        return String(format: "NSColor(calibratedRed: %.2f, green: %.2f, blue: %.2f, alpha: 1.0)", r, g, b)
    }

    // MARK: - Web/CSS Format Representations

    /// CSS RGBA (e.g., "rgba(255, 87, 51, 1.0)")
    var cssRGBARepresentation: String {
        let (r, g, b, a) = self.rgbComponents
        return String(format: "rgba(%d, %d, %d, %.2g)", Int(r * 255), Int(g * 255), Int(b * 255), a)
    }

    /// CSS HSL (e.g., "hsl(11, 100%, 60%)")
    var cssHSLRepresentation: String {
        let (h, s, l, _) = self.hslComponents
        return String(format: "hsl(%d, %d%%, %d%%)", Int(h * 360), Int(s * 100), Int(l * 100))
    }

    /// CSS HSLA (e.g., "hsla(11, 100%, 60%, 1.0)")
    var cssHSLARepresentation: String {
        let (h, s, l, a) = self.hslComponents
        return String(format: "hsla(%d, %d%%, %d%%, %.2g)", Int(h * 360), Int(s * 100), Int(l * 100), a)
    }

    /// CSS HWB (e.g., "hwb(11 20% 0%)")
    var cssHWBRepresentation: String {
        let (h, w, b, _) = self.hwbComponents
        return String(format: "hwb(%d %d%% %d%%)", Int(h * 360), Int(w * 100), Int(b * 100))
    }

    /// CSS Color Level 4 (e.g., "color(srgb 1 0.34 0.2)")
    var cssColor4Representation: String {
        let (r, g, b, _) = self.rgbComponents
        return String(format: "color(srgb %.3g %.3g %.3g)", r, g, b)
    }

    /// CSS Variable (e.g., "--color: #FF5733;")
    var cssVariableRepresentation: String {
        "--color: \(self.hexRepresentation);"
    }

    // MARK: - Apple Platform Format Representations

    /// SwiftUI Color (e.g., "Color(red: 1.0, green: 0.34, blue: 0.2)")
    var swiftUIColorRepresentation: String {
        let (r, g, b, _) = self.rgbComponents
        return String(format: "Color(red: %.2f, green: %.2f, blue: %.2f)", r, g, b)
    }

    /// SwiftUI Color with hex extension (e.g., "Color(hex: 0xFF5733)")
    var swiftUIHexRepresentation: String {
        "Color(hex: 0x\(self.hexNoHashRepresentation))"
    }

    /// CGColor (e.g., "CGColor(red: 1.0, green: 0.34, blue: 0.2, alpha: 1.0)")
    var cgColorRepresentation: String {
        let (r, g, b, a) = self.rgbComponents
        return String(format: "CGColor(red: %.2f, green: %.2f, blue: %.2f, alpha: %.2f)", r, g, b, a)
    }

    /// CIColor (e.g., "CIColor(red: 1.0, green: 0.34, blue: 0.2)")
    var ciColorRepresentation: String {
        let (r, g, b, _) = self.rgbComponents
        return String(format: "CIColor(red: %.2f, green: %.2f, blue: %.2f)", r, g, b)
    }

    // MARK: - Cross-Platform Format Representations

    /// Flutter Color (e.g., "Color(0xFFFF5733)")
    var flutterRepresentation: String {
        let (r, g, b, _) = self.rgbComponents
        return String(format: "Color(0xFF%02X%02X%02X)", Int(r * 255), Int(g * 255), Int(b * 255))
    }

    /// Flutter Color.fromRGBO (e.g., "Color.fromRGBO(255, 87, 51, 1.0)")
    var flutterRGBORepresentation: String {
        let (r, g, b, a) = self.rgbComponents
        return String(format: "Color.fromRGBO(%d, %d, %d, %.2g)", Int(r * 255), Int(g * 255), Int(b * 255), a)
    }

    /// Android Kotlin (e.g., "Color(0xFFFF5733)")
    var androidKotlinRepresentation: String {
        let (r, g, b, _) = self.rgbComponents
        return String(format: "Color(0xFF%02X%02X%02X)", Int(r * 255), Int(g * 255), Int(b * 255))
    }

    /// Android XML (e.g., "#FFFF5733" - ARGB format)
    var androidXMLRepresentation: String {
        let (r, g, b, _) = self.rgbComponents
        return String(format: "#FF%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }

    /// Unity C# (e.g., "new Color(1f, 0.34f, 0.2f, 1f)")
    var unityRepresentation: String {
        let (r, g, b, a) = self.rgbComponents
        return String(format: "new Color(%.2ff, %.2ff, %.2ff, %.2ff)", r, g, b, a)
    }

    /// Godot GDScript (e.g., "Color(1.0, 0.34, 0.2, 1.0)")
    var godotRepresentation: String {
        let (r, g, b, a) = self.rgbComponents
        return String(format: "Color(%.2f, %.2f, %.2f, %.2f)", r, g, b, a)
    }

    // MARK: - JavaScript Format Representations

    /// JS Object (e.g., "{ r: 255, g: 87, b: 51 }")
    var jsObjectRepresentation: String {
        let (r, g, b, _) = self.rgbComponents
        return "{ r: \(Int(r * 255)), g: \(Int(g * 255)), b: \(Int(b * 255)) }"
    }

    /// JS Array (e.g., "[255, 87, 51]")
    var jsArrayRepresentation: String {
        let (r, g, b, _) = self.rgbComponents
        return "[\(Int(r * 255)), \(Int(g * 255)), \(Int(b * 255))]"
    }

    /// Tailwind CSS (e.g., "bg-[#FF5733]")
    var tailwindRepresentation: String {
        "bg-[\(self.hexRepresentation)]"
    }

    // MARK: - Design Format Representations

    /// Raw float values 0-1 (e.g., "1.0, 0.34, 0.2")
    var rawFloatRepresentation: String {
        let (r, g, b, _) = self.rgbComponents
        return String(format: "%.3g, %.3g, %.3g", r, g, b)
    }

    /// Raw integer values 0-255 (e.g., "255, 87, 51")
    var rawIntegerRepresentation: String {
        let (r, g, b, _) = self.rgbComponents
        return "\(Int(r * 255)), \(Int(g * 255)), \(Int(b * 255))"
    }

    // MARK: - Other Format Representations

    /// Java AWT (e.g., "new Color(255, 87, 51)")
    var javaAWTRepresentation: String {
        let (r, g, b, _) = self.rgbComponents
        return "new Color(\(Int(r * 255)), \(Int(g * 255)), \(Int(b * 255)))"
    }

    /// Qt/QML (e.g., "Qt.rgba(1.0, 0.34, 0.2, 1.0)")
    var qtQMLRepresentation: String {
        let (r, g, b, a) = self.rgbComponents
        return String(format: "Qt.rgba(%.2f, %.2f, %.2f, %.2f)", r, g, b, a)
    }

    /// GLSL vec4 (e.g., "vec4(1.0, 0.34, 0.2, 1.0)")
    var glslRepresentation: String {
        let (r, g, b, a) = self.rgbComponents
        return String(format: "vec4(%.2f, %.2f, %.2f, %.2f)", r, g, b, a)
    }

    /// Hex Integer (e.g., "0xFF5733")
    var hexIntegerRepresentation: String {
        "0x\(self.hexNoHashRepresentation)"
    }

    // MARK: - Display Representations

    /// Hue as degrees (e.g., "180°")
    var hueRepresentation: String {
        let (h, _, _, _) = self.hsbComponents
        return "\(Int(h * 360))°"
    }

    /// Saturation as percentage (e.g., "75%")
    var saturationRepresentation: String {
        let (_, s, _, _) = self.hsbComponents
        return "\(Int(s * 100))%"
    }

    /// Brightness as percentage (e.g., "100%")
    var brightnessRepresentation: String {
        let (_, _, b, _) = self.hsbComponents
        return "\(Int(b * 100))%"
    }
}
