class SpotifyAPIManager {
    static let shared = SpotifyAPIManager()
    private let spotifyAPI = SpotifyAPI()
    
    private init() {}

    func searchTracks(query: String, limit: Int = 50) async -> [Track] {
        return await spotifyAPI.searchTracks(query: query)
    }
    
    /// Pre-warms the API connection with a minimal request
    func prewarmConnection() async {
        _ = await searchTracks(query: "a", limit: 1)
    }
} 