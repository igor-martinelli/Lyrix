class LyricsAPIManager {
    static let shared = LyricsAPIManager()
    private let lyricsAPI = LyricsAPI()
    
    private init() {}
    
    func getLyrics(artist: String, title: String) async throws -> Lyrics? {
        return try await lyricsAPI.fetchLyrics(artist: artist, title: title)
    }

} 
