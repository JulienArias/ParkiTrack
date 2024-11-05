import SwiftUI

struct AppTheme {
    static let primary = Color(hex: "4A90E2")      // Bleu plus vif
    static let secondary = Color(hex: "4CD964")    // Vert plus vif
    static let accent = Color(hex: "FF9500")       // Orange plus vif
    static let warning = Color(hex: "FF3B30")      // Rouge plus vif
    static let error = Color(hex: "FF3B30")        // Rouge plus vif
    static let tremColor = Color(hex: "007AFF")    // Bleu iOS standard
    static let background = Color(hex: "F2F2F7")   // Gris iOS standard
    static let cardBackground = Color.white
    static let textPrimary = Color.black           // Texte principal
    static let textSecondary = Color.gray          // Texte secondaire
    
    static let shadowRadius: CGFloat = 4
    static let shadowY: CGFloat = 2
    static let shadowColor = Color.black.opacity(0.1)
    
    static let cornerRadius: CGFloat = 24
    static let spacing: CGFloat = 16
    static let cardPadding: CGFloat = 20
    
    static let titleStyle: Font = .title.weight(.bold)
    static let headlineStyle: Font = .headline.weight(.bold)
    static let subheadlineStyle: Font = .subheadline.weight(.semibold)
    static let bodyStyle: Font = .body.weight(.medium)
    static let captionStyle: Font = .caption.weight(.medium)
    
    static let actionButton = Color(hex: "5B9BD5")    // Bleu distinct et attractif
    static let actionButtonLight = Color(hex: "EBF3FA") // Version claire pour le fond
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 