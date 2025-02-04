import SwiftUI

struct LogoView: View {
    @Binding var isSearching: Bool
    
    var body: some View {
        Text("Lyrix")
            .font(.system(size: 60, weight: .light))
            .foregroundColor(.primary)
            .padding(.top, 100)
    }
} 