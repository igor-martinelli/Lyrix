import SwiftUI

struct SettingsView: View {
    @Binding var showSettings: Bool
    @State private var showCacheCleared = false
    @State private var showHistoryCleared = false
    @Binding var searchHistory: [Track]


    var body: some View {
        VStack(spacing: 32) {
            // Cache Button Section
            VStack(spacing: 8) {
                Button(action: {
                    clearCache()
                    showCacheCleared = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showCacheCleared = false
                    }
                }) {
                    Text("Clear Cache")
                        .foregroundColor(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .stroke(Color.red, lineWidth: 1)
                        )
                }
                
                Text("Clears locally stored files to free up space")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            
            // History Button Section
            VStack(spacing: 8) {
                Button(action: {
                    clearHistory()
                    showHistoryCleared = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showHistoryCleared = false
                    }
                }) {
                    Text("Clear Search History")
                        .foregroundColor(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .stroke(Color.red, lineWidth: 1)
                        )
                }
                
                Text("Removes all previously searched tracks")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            
            // Success Messages
            if showCacheCleared {
                Text("Cache cleared successfully!")
                    .foregroundColor(.green)
                    .transition(.opacity)
            }
            
            if showHistoryCleared {
                Text("History cleared successfully!")
                    .foregroundColor(.green)
                    .transition(.opacity)
            }

            Spacer()
        }
        .padding(.top, 20)
        .padding(.horizontal)
        .navigationTitle("Settings")
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .tint(.white)
    }

    private func clearCache() {
        ImageCache.clearCache()
    }
    
    private func clearHistory() {
        searchHistory.removeAll()
        HistoryStorage.shared.clearHistory()
    }
} 
