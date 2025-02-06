import SwiftUI

struct ContentView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var logoColorIndex = 0
    @State private var searchResults: [Track] = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Logo
                LogoView(colorIndex: $logoColorIndex)
                    .padding(.top, isSearching ? 10 : 80)
                    .animation(.spring(duration: 0.9), value: isSearching)

                // Search Bar
                SearchBarView(searchText: $searchText, isSearching: $isSearching, searchResults: $searchResults)
                    .padding(.top, isSearching ? 10 : 70)
                
                if isSearching {
                    List(searchResults, id: \.id) { track in
                        NavigationLink(destination: TrackDetailView(track: track)) {
                            TrackRowView(track: track)
                        }
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(PlainListStyle())
                }
                
                Spacer()
            }
            .animation(.spring(duration: 0.5), value: isSearching)
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
