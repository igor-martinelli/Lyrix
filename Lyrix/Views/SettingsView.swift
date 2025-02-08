import SwiftUI

struct SettingsView: View {
    @Binding var showSettings: Bool
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
        Task {
            await CacheManager.shared.clearAllCache()
        }
    }
    
    private func clearHistory() {
        searchHistory.removeAll()
        HistoryStorage.shared.clearHistory()
    }
} 
