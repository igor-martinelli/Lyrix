import Foundation

class CacheManager {
    static let shared = CacheManager()
    
    private struct Constants {
        static let maxTotalCacheSize: UInt64 = 100 * 1024 * 1024  // 100 MB total
        static let maxImageCacheSize: UInt64 = 80 * 1024 * 1024   // 80 MB for images
        static let maxOtherCacheSize: UInt64 = 20 * 1024 * 1024   // 20 MB for other cache
    }
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }
    
    /// Pre-warms cache system asynchronously
    func prewarmCache() async {
        // 1. Initialize URL cache with appropriate size
        let urlCache = URLCache(memoryCapacity: 10_485_760,    // 10 MB
                              diskCapacity: 52_428_800,        // 50 MB
                              directory: nil)
        URLCache.shared = urlCache
        
        // 2. Ensure cache directories exist
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, 
                                          withIntermediateDirectories: true)
        }
        
        if !fileManager.fileExists(atPath: ImageCache.cacheDirectory.path) {
            try? fileManager.createDirectory(at: ImageCache.cacheDirectory, 
                                          withIntermediateDirectories: true)
        }
        
        // 3. Pre-allocate NSCache
        ImageCache.shared.totalCostLimit = 50_000_000  // 50 MB for in-memory cache
        ImageCache.shared.countLimit = 100  // Max number of images in memory
    }
    
    /// Clears all app cache
    func clearAllCache() async {
        // Clear in-memory image cache
        ImageCache.shared.removeAllObjects()
        
        // Clear lyrics cache
        LyricsCache.shared.clearCache()
        
        // Clear URL cache
        URLCache.shared.removeAllCachedResponses()
        
        // Clear temp files
        try? fileManager.removeItem(at: fileManager.temporaryDirectory)
        
        // Clear all cache directory
        let cacheFiles = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        cacheFiles?.forEach { url in
            try? fileManager.removeItem(at: url)
        }
        
        // Recreate image cache directory
        try? fileManager.createDirectory(at: ImageCache.cacheDirectory, withIntermediateDirectories: true)
    }
} 