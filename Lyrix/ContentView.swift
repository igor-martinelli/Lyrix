import SwiftUI

struct ContentView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var showHistory = false
    @State private var logoColorIndex = 0
    @State private var searchResults: [Track] = []
    @State private var searchHistory: [Track] = []
    @State private var selectedTrack: Track?
    @State private var navigateToDetail = false
    @State private var showSettings = false
    private let presentationManager = SlideInPresentationManager(direction: .right)

    init() {
        _searchHistory = State(initialValue: HistoryStorage.shared.loadHistory())
    }

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
                
                // Search Results
                if isSearching && !searchText.isEmpty {
                    List(searchResults, id: \.id) { track in
                        Button(action: {
                            navigateToTrack(track)
                        }) {
                            HStack {
                                TrackRowView(track: track)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(PlainListStyle())
                } else if !isSearching && !searchHistory.isEmpty {
                    Spacer()
                    HistoryGridView(
                        searchHistory: searchHistory,
                        logoColorIndex: logoColorIndex,
                        onTrackSelected: navigateToTrack,
                        onTrackDeleted: removeFromSearchHistory
                    )
                }

                Spacer()
            }
            .animation(.spring(duration: 0.5), value: isSearching)
            .background(ThemeManager.backgroundColor)
            .navigationDestination(isPresented: $navigateToDetail) {
                if let track = selectedTrack {
                    TrackDetailView(track: track)
                }
            }
            .navigationBarItems(trailing: Button(action: {
                presentSettings()
            }) {
                Image(systemName: "gearshape")
            }).foregroundColor(ThemeManager.logoColors[logoColorIndex])
        }
        .preferredColorScheme(.dark)
    }

    func navigateToTrack(_ track: Track) {
        // First trigger navigation
        selectedTrack = track
        navigateToDetail = true
        
        // Delay the history update
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {  // 0.3s delay matches the navigation transition
            addToSearchHistory(track)
        }
    }

    func addToSearchHistory(_ track: Track) {
        // Remove if track already exists to avoid duplicates
        if let existingIndex = searchHistory.firstIndex(where: { $0.id == track.id }) {
            searchHistory.remove(at: existingIndex)
        }
        
        // Add new track at the beginning (FIFO queue)
        searchHistory.insert(track, at: 0)
        
        // Keep only the most recent 8 tracks
        if searchHistory.count > 8 {
            searchHistory.removeLast()
        }
        
        // Save history after modification
        HistoryStorage.shared.saveHistory(searchHistory)
    }

    func removeFromSearchHistory(_ track: Track) {
        searchHistory.removeAll { $0.id == track.id }
        // Save history after modification
        HistoryStorage.shared.saveHistory(searchHistory)
    }

    private func presentSettings() {
        let settingsVC = SettingsViewController(searchHistory: $searchHistory)
        settingsVC.modalPresentationStyle = .custom
        settingsVC.transitioningDelegate = presentationManager
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(settingsVC, animated: true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
