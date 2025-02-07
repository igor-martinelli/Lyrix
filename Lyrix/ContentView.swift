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
                    .onChange(of: isSearching) { oldValue, newValue in
                        if newValue {
                            showHistory = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                showHistory = true
                            }
                        } else {
                            showHistory = false
                        }
                    }

                // Search History (Appears with delay)
                if isSearching && searchText.isEmpty && showHistory {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("History")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                            .padding(.top, 5)

                        List {
                            ForEach(searchHistory, id: \.id) { track in
                                HStack {
                                    Button(action: {
                                        navigateToTrack(track)
                                    }) {
                                        HStack {
                                            TrackRowView(track: track)
                                            Spacer()
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .listRowSeparator(.hidden)

                                    Button(action: {
                                        removeFromSearchHistory(track)
                                    }) {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                    .buttonStyle(BorderlessButtonStyle()) // Prevents full row selection
                                }
                                .contentShape(Rectangle()) // Ensures tapable area
                            }
                            .onDelete(perform: deleteHistoryItem) // Swipe-to-delete support
                        }
                        .listStyle(PlainListStyle())
                        .transition(.opacity)
                    }
                }
                
                // Search Results
                if isSearching && !searchText.isEmpty {
                    List(searchResults, id: \.id) { track in
                        Button(action: {
                            navigateToTrack(track)
                        }) {
                            HStack {
                                TrackRowView(track: track)
                                Spacer()
                                Image(systemName: "chevron.right") // Keeps ">" symbol
                                    .foregroundColor(.gray)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(PlainListStyle())
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
        }
        .preferredColorScheme(.dark)
    }

    func navigateToTrack(_ track: Track) {
        addToSearchHistory(track)
        selectedTrack = track
        navigateToDetail = true
    }

    func addToSearchHistory(_ track: Track) {
        if let existingIndex = searchHistory.firstIndex(where: { $0.id == track.id }) {
            let existingTrack = searchHistory.remove(at: existingIndex)
            searchHistory.insert(existingTrack, at: 0)
        } else {
            searchHistory.insert(track, at: 0)
            if searchHistory.count > 15 {
                searchHistory.removeLast()
            }
        }
    }

    func removeFromSearchHistory(_ track: Track) {
        searchHistory.removeAll { $0.id == track.id }
    }

    func deleteHistoryItem(at offsets: IndexSet) {
        searchHistory.remove(atOffsets: offsets)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
