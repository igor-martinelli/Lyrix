import Foundation

class LyricsAPI {
    private let baseURL = "https://api.lyrics.ovh/v1"
    
    /// Fetches lyrics for a given artist and title
    func fetchLyrics(artist: String, title: String) async throws -> Lyrics? {
        // Get first artist from comma-separated list
        let firstArtist = artist.split(separator: ",").first?.trimmingCharacters(in: .whitespaces) ?? artist
        
        // Format artist and title for URL
        let formattedArtist = firstArtist.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? firstArtist
        let formattedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? title
        
        print("Fetching lyrics for artist: \(firstArtist), title: \(title)")  // Debug print
        
        guard let url = URL(string: "\(baseURL)/\(formattedArtist)/\(formattedTitle)") else {
            throw LyricsError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw LyricsError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                return try JSONDecoder().decode(Lyrics.self, from: data)
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