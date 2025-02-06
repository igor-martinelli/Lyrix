import Foundation

class SpotifyAPI {
    private let clientID = "84093ed5893243aa99b808d2efa3525f"
    private let clientSecret = "872bb41d512d4469af2ab72d35eb3524"
    private let tokenURL = "https://accounts.spotify.com/api/token"
    private let searchURL = "https://api.spotify.com/v1/search"

    private var accessToken: String? = nil
    private var tokenExpirationDate: Date? = nil

    /// Fetches a new access token if expired
    func getAccessToken() async -> String? {
        if let token = accessToken, let expiration = tokenExpirationDate, expiration > Date() {
            return token // Use cached token if still valid
        }

        guard let url = URL(string: tokenURL) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let bodyString = "grant_type=client_credentials"
        let bodyData = bodyString.data(using: .utf8)

        let credentials = "\(clientID):\(clientSecret)"
        guard let encodedCredentials = credentials.data(using: .utf8)?.base64EncodedString() else { return nil }
        request.setValue("Basic \(encodedCredentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decodedResponse = try JSONDecoder().decode(SpotifyTokenResponse.self, from: data)
            accessToken = decodedResponse.access_token
            tokenExpirationDate = Date().addingTimeInterval(TimeInterval(decodedResponse.expires_in))
            return accessToken
        } catch {
            print("Error fetching access token: \(error)")
            return nil
        }
    }

    /// Searches for tracks using the Spotify API
    func searchTracks(query: String) async -> [Track] {
        guard let token = await getAccessToken(), let url = URL(string: "\(searchURL)?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&type=track&limit=10") else {
            return []
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(SpotifyResponse.self, from: data)
            return response.tracks.items.map { track in
                let artistNames = track.artists.map { $0.name }.joined(separator: ", ")
                return Track(id: track.id, title: track.name, artists: artistNames, imageUrl: track.album.images.first?.url ?? "")
            }
        } catch {
            print("Error fetching tracks: \(error)")
            return []
        }
    }
}

struct SpotifyTokenResponse: Codable {
    let access_token: String
    let token_type: String
    let expires_in: Int
}

struct SpotifyResponse: Codable {
    let tracks: Tracks
}

struct Tracks: Codable {
    let items: [TrackItem]
}

struct TrackItem: Codable {
    let id: String
    let name: String
    let artists: [Artist]
    let album: Album
}

struct Artist: Codable {
    let name: String
}

struct Album: Codable {
    let images: [AlbumImage]
}

struct AlbumImage: Codable {
    let url: String
}

