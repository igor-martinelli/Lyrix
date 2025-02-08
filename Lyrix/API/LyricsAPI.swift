import Foundation

class LyricsAPI {
    private let baseURL = "https://lrclib.net/api"
    
    /// Fetches lyrics for a given track
    func fetchLyrics(artist: String, title: String) async throws -> Lyrics? {
        // Get first artist from comma-separated list
        let firstArtist = artist.split(separator: ",")
            .first?
            .trimmingCharacters(in: .whitespaces) ?? artist
        
        // Format query parameters
        let queryItems = [
            URLQueryItem(name: "artist_name", value: firstArtist),
            URLQueryItem(name: "track_name", value: title)
        ]
                
        var urlComponents = URLComponents(string: "\(baseURL)/get")
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            throw LyricsError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw LyricsError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                let lrcLibResponse = try JSONDecoder().decode(LRCLibResponse.self, from: data)
                return Lyrics(plainLyrics: lrcLibResponse.plainLyrics)
            case 404:
                throw LyricsError.lyricsNotFound
            default:
                throw LyricsError.serverError(statusCode: httpResponse.statusCode)
            }
        } catch let error as LyricsError {
            throw error
        } catch {
            throw LyricsError.networkError(error)
        }
    }
}

struct LRCLibResponse: Codable {
    let id: Int
    let trackName: String
    let artistName: String
    let albumName: String?
    let duration: Int?
    let instrumental: Bool
    let plainLyrics: String
    let syncedLyrics: String?
}

enum LyricsError: LocalizedError {
    case invalidURL
    case invalidResponse
    case lyricsNotFound
    case serverError(statusCode: Int)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL format"
        case .invalidResponse:
            return "Invalid response from server"
        case .lyricsNotFound:
            return "Lyrics not found for this song"
        case .serverError(let statusCode):
            return "Server error (Status: \(statusCode))"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
} 