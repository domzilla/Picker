import AppKit

extension NSColor {
    // MARK: - Private Helpers

    private var rgbComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        guard let converted = self.usingColorSpace(.genericRGB) else { return nil }
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        converted.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }

    private var hexString: String? {
        guard let (r, g, b, a) = self.rgbComponents else { return nil }
        let red = String(format: "%02x", Int(r * 255))
        let green = String(format: "%02x", Int(g * 255))
        let blue = String(format: "%02x", Int(b * 255))
        let alpha = String(format: "%02x", Int(a * 255))
        return "\(red)\(green)\(blue)\(alpha)"
    }

    private var isGrayscale: Bool {
        guard let (r, g, b, _) = self.rgbComponents else { return false }
        // Use tolerance for floating point comparison
        let tolerance: CGFloat = 0.001
        return abs(r - g) < tolerance && abs(g - b) < tolerance
    }

    // MARK: - Format Representations

    /// HEX representation with hash (e.g., "#FF5733")
    var hexRepresentation: String {
        guard let hex = self.hexString else { return "#000000" }
        return "#\(String(hex.prefix(6)))"
    }

    /// HEX representation without hash (e.g., "FF5733")
    var hexNoHashRepresentation: String {
        guard let hex = self.hexString else { return "000000" }
        return String(hex.prefix(6))
    }

    /// RGB representation (e.g., "rgb(255, 87, 51)")
    var rgbRepresentation: String {
        let r = Int(self.redComponent * 255)
        let g = Int(self.greenComponent * 255)
        let b = Int(self.blueComponent * 255)
        return "rgb(\(r), \(g), \(b))"
    }

    /// HSB representation (e.g., "hsb(11, 80, 100)")
    var hsbRepresentation: String {
        let h = Int(self.hueComponent * 360)
        let s = Int(self.saturationComponent * 100)
        let b = Int(self.brightnessComponent * 100) // Fixed: was using saturation twice
        return "hsb(\(h), \(s), \(b))"
    }

    /// CMYK representation (e.g., "cmyk(0, 166, 204, 0)")
    var cmykRepresentation: String {
        let c = Int(self.cyanComponent * 255)
        let m = Int(self.magentaComponent * 255)
        let y = Int(self.yellowComponent * 255)
        let k = Int(self.blackComponent * 255)
        return "cmyk(\(c), \(m), \(y), \(k))"
    }

    /// UIColor Objective-C representation
    var uiColorObjCRepresentation: String {
        let r = self.redComponent
        let g = self.greenComponent
        let b = self.blueComponent

        if self.isGrayscale {
            return String(format: "[UIColor colorWithWhite:%.2f alpha:1.0]", r)
        }
        return String(format: "[UIColor colorWithRed:%.2f green:%.2f blue:%.2f alpha:1.0]", r, g, b)
    }

    /// UIColor Swift representation
    var uiColorSwiftRepresentation: String {
        let r = self.redComponent
        let g = self.greenComponent
        let b = self.blueComponent

        if self.isGrayscale {
            return String(format: "UIColor(white: %.2f, alpha: 1.0)", r)
        }
        return String(format: "UIColor(red: %.2f, green: %.2f, blue: %.2f, alpha: 1.0)", r, g, b)
    }

    /// NSColor Objective-C representation
    var nsColorObjCRepresentation: String {
        let r = self.redComponent
        let g = self.greenComponent
        let b = self.blueComponent

        if self.isGrayscale {
            return String(format: "[NSColor colorWithCalibratedWhite:%.2f alpha:1.0]", r)
        }
        return String(format: "[NSColor colorWithCalibratedRed:%.2f green:%.2f blue:%.2f alpha:1.0]", r, g, b)
    }

    /// NSColor Swift representation
    var nsColorSwiftRepresentation: String {
        let r = self.redComponent
        let g = self.greenComponent
        let b = self.blueComponent

        if self.isGrayscale {
            return String(format: "NSColor(calibratedWhite: %.2f, alpha: 1.0)", r)
        }
        return String(format: "NSColor(calibratedRed: %.2f, green: %.2f, blue: %.2f, alpha: 1.0)", r, g, b)
    }

    // MARK: - Display Representations

    /// Hue as degrees (e.g., "180°")
    var hueRepresentation: String {
        "\(Int(self.hueComponent * 360))°"
    }

    /// Saturation as percentage (e.g., "75%")
    var saturationRepresentation: String {
        "\(Int(self.saturationComponent * 100))%"
    }

    /// Brightness as percentage (e.g., "100%")
    var brightnessRepresentation: String {
        "\(Int(self.brightnessComponent * 100))%"
    }
}
