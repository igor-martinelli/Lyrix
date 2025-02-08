import SwiftUI

struct LogoView: View {
    @Binding var colorIndex: Int

    var body: some View {
        Text("Lyrix")
            .font(ThemeManager.logoFont(size: 60))
            .foregroundColor(ThemeManager.logoColors[colorIndex])
            .onTapGesture {
                withAnimation(.spring(duration: 0.3)) {
                    colorIndex = (colorIndex + 1) % ThemeManager.logoColors.count
                }
            }
    }
}
