import Foundation

class APIManager {
    static let shared = APIManager()  // Add shared instance
    private let spotifyAPI = SpotifyAPI()
    
    private init() {}  // Make init private for singleton pattern

    func searchTracks(query: String, limit: Int = 50) async -> [Track] {
        return await spotifyAPI.searchTracks(query: query)
    }

    /// Pre-warms the API connection with a minimal request
    func prewarmConnection() async {
        // Make a minimal search request with smallest possible payload
        _ = await searchTracks(query: "a", limit: 1)
    }
}
