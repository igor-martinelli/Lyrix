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
    @State private var historyOpacity = 1.0
    @State private var activeDeleteTrackId: String? = nil
    private let presentationManager = SlideInPresentationManager(direction: .right)

    init() {
        _searchHistory = State(initialValue: HistoryStorage.shared.loadHistory())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if activeDeleteTrackId != nil {
                            withAnimation(AnimationConstants.easeOut) {
                                activeDeleteTrackId = nil
                            }
                        }
                    }
                
                VStack(spacing: 0) {
                    // Logo
                    LogoView(colorIndex: $logoColorIndex, activeDeleteTrackId: $activeDeleteTrackId, isSearching: isSearching)
                        .padding(.top, isSearching ? 0 : 70)

                    // Search Bar
                    SearchBarView(
                        searchText: $searchText, 
                        isSearching: $isSearching, 
                        searchResults: $searchResults,
                        activeDeleteTrackId: $activeDeleteTrackId,
                        animation: AnimationConstants.standard
                    )
                    .padding(.top, isSearching ? 20 : 70)
                    
                    // Search Results or History
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
                        VStack {
                            Spacer()
                            HistoryGridView(
                                searchHistory: searchHistory,
                                logoColorIndex: logoColorIndex,
                                activeDeleteTrackId: $activeDeleteTrackId,
                                onTrackSelected: navigateToTrack,
                                onTrackDeleted: { track in
                                    if searchHistory.count == 1 {
                                        // Animate fade out if it's the last track
                                        withAnimation(AnimationConstants.easeOut) {
                                            historyOpacity = 0
                                        }
                                        // Remove track after animation
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                            removeFromSearchHistory(track)
                                            historyOpacity = 1  // Reset opacity for next time
                                        }
                                    } else {
                                        removeFromSearchHistory(track)
                                    }
                                }
                            )
                            .opacity(historyOpacity)
                            Spacer(minLength: 0)  // Push content up
                        }
                    }

                    Spacer(minLength: 0)
                }
            }
            .background(ThemeManager.backgroundColor)
            .navigationDestination(isPresented: $navigateToDetail) {
                if let track = selectedTrack {
                    TrackDetailView(track: track)
                }
            }
            .navigationBarItems(trailing: Button(action: {
                // Dismiss any active delete mode
                if activeDeleteTrackId != nil {
                    withAnimation(AnimationConstants.easeOut) {
                        activeDeleteTrackId = nil
                    }
                    return  // Don't open settings if we're dismissing delete mode
                }
                
                // Original action
                presentSettings()
            }) {
                Image(systemName: "gearshape")
            }).foregroundColor(ThemeManager.logoColors[logoColorIndex])
            .onChange(of: isSearching) { oldValue, newValue in
                withAnimation(AnimationConstants.standard) {
                    // Do nothing, just trigger animation
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    func navigateToTrack(_ track: Track) {
        // First trigger navigation
        selectedTrack = track
        navigateToDetail = true
        
        // Delay the history update
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {  // 0.3s delay matches the navigation transition
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
