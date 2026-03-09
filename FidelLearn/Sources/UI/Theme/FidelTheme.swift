import SwiftUI
import UIKit

/// Premium design system for Fidel Learn — warm, cultural, distinctive.
enum FidelTheme {
    // MARK: - Colors (warm amber/gold, cultural)

    static let accent = Color(red: 0.85, green: 0.55, blue: 0.15)
    static let accentLight = Color(red: 0.95, green: 0.75, blue: 0.35)
    static let accentDark = Color(red: 0.65, green: 0.40, blue: 0.08)

    static let streak = Color(red: 0.95, green: 0.50, blue: 0.15)
    static let success = Color(red: 0.20, green: 0.70, blue: 0.45)
    static let error = Color(red: 0.90, green: 0.30, blue: 0.25)

    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let cardShadow = Color.black.opacity(0.06)

    // MARK: - Spacing (8pt grid)

    static let spaceXS: CGFloat = 4
    static let spaceS: CGFloat = 8
    static let spaceM: CGFloat = 16
    static let spaceL: CGFloat = 24
    static let spaceXL: CGFloat = 32

    // MARK: - Corner Radius

    static let radiusS: CGFloat = 8
    static let radiusM: CGFloat = 12
    static let radiusL: CGFloat = 16
    static let radiusXL: CGFloat = 20

    // MARK: - Typography

    static let titleLarge = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold)
    static let body = Font.system(size: 16, weight: .regular)
    static let callout = Font.system(size: 15, weight: .regular)
    static let caption = Font.system(size: 13, weight: .regular)
    static let fidelLarge = Font.system(size: 56, weight: .medium)
    static let fidelMedium = Font.system(size: 44, weight: .medium)

    /// Large Fidel font using Noto Sans Ethiopic when available; falls back to system font.
    static var fidelFont: Font {
        fidelFont(size: 56)
    }

    /// Medium Fidel font for lesson cards (52pt).
    static var fidelFontCard: Font {
        fidelFont(size: 52)
    }

    private static func fidelFont(size: CGFloat) -> Font {
        let fontName = "NotoSansEthiopic-Regular"
        if UIFont(name: fontName, size: size) != nil {
            return Font.custom(fontName, size: size)
        }
        return Font.system(size: size, weight: .medium)
    }
}

// MARK: - Layout Helpers (native feel)

extension View {
    /// Square frame — `.square(56)` instead of `.frame(width: 56, height: 56)`.
    func square(_ size: CGFloat) -> some View {
        frame(width: size, height: size)
    }
}
