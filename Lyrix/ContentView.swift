import SwiftUI

struct ContentView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var showHistory = false
    @State private var currentLogoColorIndex = 0 // Track current color
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Logo
                Text("Lyrix")
                    .font(ThemeManager.logoFont(size: isSearching ? ThemeManager.logoFontSizeSmall : ThemeManager.logoFontSizeLarge))
                    .foregroundColor(ThemeManager.logoColors[currentLogoColorIndex])
                    .padding(.top, isSearching ? UIScreen.main.bounds.height * 0.01 : UIScreen.main.bounds.height * 0.1)
                    .animation(.spring(duration: 0.3), value: isSearching)
                    .onTapGesture {
                        withAnimation(.spring(duration: 0.3)) {
                            // Cycle to next color
                            currentLogoColorIndex = (currentLogoColorIndex + 1) % ThemeManager.logoColors.count
                        }
                    }
                
                // Search Bar
                SearchBarView(
                    searchText: $searchText,
                    isSearching: $isSearching
                )
                .padding(.top, isSearching ? UIScreen.main.bounds.height * 0.01 : UIScreen.main.bounds.height * 0.1)
                .onChange(of: isSearching) { _, newValue in
                    if newValue {
                        // Delay showing history
                        withAnimation(.easeInOut(duration: 0.3).delay(0.2)) {
                            showHistory = true
                        }
                    } else {
                        showHistory = false
                    }
                }
                
                if isSearching {
                    // History section
                    SearchHistoryView()
                        .opacity(showHistory ? 1 : 0)
                        .transition(.opacity)
                }
                
                Spacer()
            }
            .animation(.spring(duration: 0.3), value: isSearching)
            .background(ThemeManager.backgroundColor)
        }
        .preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
