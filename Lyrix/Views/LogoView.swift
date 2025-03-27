import SwiftUI

struct LogoView: View {
    @Binding var colorIndex: Int
    @Binding var activeDeleteTrackId: String?
    var isSearching: Bool = false
    
    var body: some View {
        Text("Lyrix")
            .font(ThemeManager.logoFont(size: isSearching ? 
                  AnimationConstants.logoSizeSmall : 
                  AnimationConstants.logoSizeNormal))
            .foregroundColor(ThemeManager.logoColors[colorIndex])
            .onTapGesture {
                if activeDeleteTrackId != nil {
                    withAnimation(AnimationConstants.easeOut) {
                        activeDeleteTrackId = nil
                    }
                    return
                }
                
                withAnimation {
                    colorIndex = (colorIndex + 1) % ThemeManager.logoColors.count
                }
            }
    }
}
