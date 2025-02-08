struct Lyrics: Codable {
    let plainLyrics: String
    
    // Convert raw lyrics string into an array of lines
    var lines: [String] {
        plainLyrics.components(separatedBy: .newlines)
            .filter { !$0.isEmpty }  // Remove empty lines
    }
}
