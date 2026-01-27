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

    // MARK: - Format Representations

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

    /// UIColor Objective-C representation
    var uiColorObjCRepresentation: String {
        let (r, g, b, _) = self.rgbComponents
        if self.isGrayscale {
            return String(format: "[UIColor colorWithWhite:%.2f alpha:1.0]", r)
        }
        return String(format: "[UIColor colorWithRed:%.2f green:%.2f blue:%.2f alpha:1.0]", r, g, b)
    }

    /// UIColor Swift representation
    var uiColorSwiftRepresentation: String {
        let (r, g, b, _) = self.rgbComponents
        if self.isGrayscale {
            return String(format: "UIColor(white: %.2f, alpha: 1.0)", r)
        }
        return String(format: "UIColor(red: %.2f, green: %.2f, blue: %.2f, alpha: 1.0)", r, g, b)
    }

    /// NSColor Objective-C representation
    var nsColorObjCRepresentation: String {
        let (r, g, b, _) = self.rgbComponents
        if self.isGrayscale {
            return String(format: "[NSColor colorWithCalibratedWhite:%.2f alpha:1.0]", r)
        }
        return String(format: "[NSColor colorWithCalibratedRed:%.2f green:%.2f blue:%.2f alpha:1.0]", r, g, b)
    }

    /// NSColor Swift representation
    var nsColorSwiftRepresentation: String {
        let (r, g, b, _) = self.rgbComponents
        if self.isGrayscale {
            return String(format: "NSColor(calibratedWhite: %.2f, alpha: 1.0)", r)
        }
        return String(format: "NSColor(calibratedRed: %.2f, green: %.2f, blue: %.2f, alpha: 1.0)", r, g, b)
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
