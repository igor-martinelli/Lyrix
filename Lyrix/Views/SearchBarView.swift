import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @Binding var isSearching: Bool
    @Binding var searchResults: [Track]
    @FocusState private var isFocused: Bool
    @State private var selectedTrack: Track?  // Store selected track
    
    // Use shared instance instead of creating new one
    private let apiManager = SpotifyAPIManager.shared

    
    var body: some View {
        Button(action: {
            isSearching = true
            isFocused = true
        }) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search song...", text: $searchText)
                    .font(ThemeManager.bodyFont)
                    .textInputAutocapitalization(.never)
                    .focused($isFocused)
                    .submitLabel(.search)
                    .autocorrectionDisabled(true)
                    .allowsHitTesting(isSearching)
                    .onChange(of: searchText) { oldValue, newValue in
                        if newValue.isEmpty {
                            searchResults = []
                        } else {
                            let currentSearchText = newValue
                            Task {
                                let results = await apiManager.searchTracks(query:currentSearchText)
                                if searchText == currentSearchText {
                                    searchResults = results
                                }
                            }
                        }
                    }
                    .onChange(of: isSearching) { oldValue, newValue in
                        if newValue {
                            print("User started searching!")
                        } else {
                            searchText = ""
                        }
                    }
                    .foregroundColor(.white)
                    .accentColor(.white)
                
                if isSearching {
                    Button(action: {
                        searchResults = []
                        isSearching = false
                        isFocused = false
                    }) {
                        Text("Cancel")
                            .font(ThemeManager.bodyFont)
                            .foregroundColor(.primary)
                    }
                    .transition(.move(edge: .trailing))
                }

            }
            .padding(15)
            .background(Color(.systemGray6))
            .cornerRadius(15)
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
        .animation(.spring(duration: 0.6), value: isSearching)
    }
}
