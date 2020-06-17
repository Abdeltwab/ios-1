import UIKit

extension UIColor {
    
    public convenience init(hex: String) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        if (cString.count) != 6 {
            fatalError("Color string must be 6 chars long")
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    public static var rainbowColors: [UIColor] = [
        UIColor(hex: "F1F2F3"),
        UIColor(hex: "DFC3E6"),
        UIColor(hex: "CA99D7"),
        UIColor(hex: "8799E5"),
        UIColor(hex: "5168C5"),
        UIColor(hex: "55BBDF"),
        UIColor(hex: "95D0E5"),
        UIColor(hex: "BFDBD7"),
        UIColor(hex: "7FC5BC"),
        UIColor(hex: "E5F0BA"),
        UIColor(hex: "F8DAB8"),
        UIColor(hex: "F0D06C"),
        UIColor(hex: "EFBA7A"),
        UIColor(hex: "F1ACAE")
    ]
}

public extension UIColor {

    // swiftlint:disable identifier_name
    // Adjusted relative luminance
    // math based on https://www.w3.org/WAI/GL/wiki/Relative_luminance
    var luminance: CGFloat {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)

        let lowGammaCoeficient: CGFloat = 1 / 12.92
        let adjustGamma: (CGFloat) -> CGFloat = { channel in
            return pow((channel + 0.055) / 1.055, 2.4)
        }

        r = r <= 0.03928 ? r * lowGammaCoeficient : adjustGamma(r)
        g = g <= 0.03928 ? g * lowGammaCoeficient : adjustGamma(g)
        b = b <= 0.03928 ? b * lowGammaCoeficient : adjustGamma(b)

        let luma = r * 0.2126 + g * 0.7152 + b * 0.0722
        return luma
    }
    // swiftlint:enable identifier_name

    // swiftlint:disable no_ui_colors
    var foregroundColor: UIColor {
        self.luminance < 0.5 ? .white : .black
    }
    // swiftlint:enable no_ui_colors
    
    // swiftlint:disable large_tuple
    var hsb: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return (hue, saturation, brightness, alpha)
    }
    // swiftlint:enable large_tuple

    var projectColor: UIColor {
        if #available(iOS 12.0, *) {
            switch UIScreen.main.traitCollection.userInterfaceStyle {
            case .light, .unspecified:
                return self
            case .dark:
                // H (value can be 0-360)
                // S (value can be 0-100)
                // B (value can be 0-100)
                // UIColor uses values in 0...1 scale
                let (hue, saturation, brightness, alpha) = hsb
                let hueDark = hue
                let saturationDark = saturation * brightness
                let brightnessDark = 2/3 + brightness / 3
                return UIColor.init(hue: hueDark, saturation: saturationDark, brightness: brightnessDark, alpha: alpha)
            @unknown default:
                assertionFailure("New userInterface style not handled")
                return self
            }
        } else {
            return self
        }
    }
}
