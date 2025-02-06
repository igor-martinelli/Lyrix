import SwiftUI

enum ThemeManager {
    static let backgroundColor = Color(.systemBackground)
    
    // Font sizes
    static let logoFontSizeLarge: CGFloat = 60
    static let logoFontSizeSmall: CGFloat = 40
    
    // Custom fonts
    static func logoFont(size: CGFloat) -> Font {
        .custom("DMSans-normal", size: size)
    }
    
    static let bodyFont = Font.custom("DMSans-normal", size: 16)
    
    // Search bar styling
    static let searchBarCornerRadius: CGFloat = 15
    
    // Logo colors
    static let logoColors: [Color] = [
        .white, .green, .blue, .red, .yellow, .orange
    ]
}
