import Foundation

class HistoryStorage {
    static let shared = HistoryStorage()
    private let historyKey = "searchHistory"
    
    func saveHistory(_ tracks: [Track]) {
        if let encoded = try? JSONEncoder().encode(tracks) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }
    
    func loadHistory() -> [Track] {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let tracks = try? JSONDecoder().decode([Track].self, from: data) {
            return tracks
        }
        return []
    }
    
    func clearHistory() {
        UserDefaults.standard.removeObject(forKey: historyKey)
    }
} 