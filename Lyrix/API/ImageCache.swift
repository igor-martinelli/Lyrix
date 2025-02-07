import SwiftUI

class ImageCache {
    static let shared = NSCache<NSURL, UIImage>()

    static func getImage(for url: URL) -> UIImage? {
        return shared.object(forKey: url as NSURL)
    }

    static func setImage(_ image: UIImage, for url: URL) {
        shared.setObject(image, forKey: url as NSURL)
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
