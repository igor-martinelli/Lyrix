import SwiftUI

class ImageCache {
    static let shared = NSCache<NSURL, UIImage>()
    static let fileManager = FileManager.default
    static let cacheDirectory: URL = {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent("ImageCache")
    }()

    static func getImage(for url: URL) -> UIImage? {
        if let cachedImage = shared.object(forKey: url as NSURL) {
            return cachedImage
        } else if let diskImage = loadImageFromDisk(for: url) {
            shared.setObject(diskImage, forKey: url as NSURL)
            return diskImage
        }
        return nil
    }

    static func setImage(_ image: UIImage, for url: URL) {
        shared.setObject(image, forKey: url as NSURL)
        saveImageToDisk(image, for: url)
    }

    private static func loadImageFromDisk(for url: URL) -> UIImage? {
        let fileURL = cacheDirectory.appendingPathComponent(url.lastPathComponent)
        if let data = try? Data(contentsOf: fileURL), let image = UIImage(data: data) {
            return image
        }
        return nil
    }

    private static func saveImageToDisk(_ image: UIImage, for url: URL) {
        let fileURL = cacheDirectory.appendingPathComponent(url.lastPathComponent)
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        if let data = image.pngData() {
            try? data.write(to: fileURL)
        }
    }
}

struct CachedAsyncImage: View {
    let url: URL

    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView() // Show loading indicator
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }

    private func loadImage() {
        if let cachedImage = ImageCache.getImage(for: url) {
            self.image = cachedImage
        } else {
            Task {
                if let data = try? Data(contentsOf: url),
                   let uiImage = UIImage(data: data) {
                    ImageCache.setImage(uiImage, for: url)
                    DispatchQueue.main.async {
                        self.image = uiImage
                    }
                }
            }
        }
    }
}
