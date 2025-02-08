struct TrackQueue {
    private let capacity: Int = 16
    private var items: [Track] = []
    
    mutating func enqueue(_ track: Track) {
        // Remove if exists
        items.removeAll { $0.id == track.id }
        
        // Add to front
        items.insert(track, at: 0)
        
        // Remove oldest if over capacity
        if items.count > capacity {
            items.removeLast()
        }
    }
    
    func getItems() -> [Track] {
        return items
    }
} 
