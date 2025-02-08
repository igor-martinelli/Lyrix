import SwiftUI

struct SettingsView: View {
    @Binding var showSettings: Bool
    @State private var showCacheCleared = false
    @State private var showHistoryCleared = false
    @Binding var searchHistory: [Track]

    var body: some View {
        ZStack {
            ThemeManager.settingsBackgroundColor
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 40) {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 32) {
                    // Cache Section
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Clear cache")
                                .foregroundColor(.white)
                                .font(.system(size: 17))
                            
                            Text("Clears locally stored files")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        AnimatedTrashButton {
                            clearCache()
                            showCacheCleared = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showCacheCleared = false
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // History Section
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Clear search history")
                                .foregroundColor(.white)
                                .font(.system(size: 17))
                            
                            Text("Removes searched tracks")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        AnimatedTrashButton {
                            clearHistory()
                            showHistoryCleared = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showHistoryCleared = false
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.8)
    }

    private func clearCache() {
        ImageCache.clearCache()
    }
    
    private func clearHistory() {
        searchHistory.removeAll()
        HistoryStorage.shared.clearHistory()
    }
} 
