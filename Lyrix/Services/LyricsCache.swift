import Foundation

class LyricsCache {
    static let shared = LyricsCache()
    private var cache: [String: [String]] = [:]  // [trackId: lyrics]
    
    private init() {}
    
    func getLyrics(for trackId: String) -> [String]? {
        return cache[trackId]
    }
    
    func setLyrics(_ lyrics: [String], for trackId: String) {
        cache[trackId] = lyrics
    }
    
    func clearCache() {
        cache.removeAll()
    }
} 