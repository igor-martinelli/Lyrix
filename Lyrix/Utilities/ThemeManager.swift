import SwiftUI

enum ThemeManager {
    static let backgroundColor = Color(.systemBackground)
    static let accentColor = Color.white
    static let secondaryColor = Color.gray
    
    // Font sizes
    static let logoFontSizeLarge: CGFloat = 60
    static let logoFontSizeSmall: CGFloat = 40
    
    // Custom fonts
    static func logoFont(size: CGFloat) -> Font {
        .custom("DMSans-normal", size: size)
    }
    
    static let headlineFont = Font.custom("DMSans-normal", size: 17)
    static let bodyFont = Font.custom("DMSans-normal", size: 16)
    
    static let searchBarCornerRadius: CGFloat = 15
    static let standardPadding: CGFloat = 15
    
    // Logo colors
    static let logoColors: [Color] = [
        .white,
        .green,
        .blue,
        .red,
        .yellow,
        .orange
    ]
} 