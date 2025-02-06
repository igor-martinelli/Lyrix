import Foundation

class APIManager {
    private let spotifyAPI = SpotifyAPI()

    func searchTracks(query: String) async -> [Track] {
        return await spotifyAPI.searchTracks(query: query)
    }
}
