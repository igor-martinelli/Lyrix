import SwiftUI
import Photos

struct WallpaperPreviewView: View {
    let track: Track
    let selectedLines: [String]
    let backgroundColor: Color
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var showingSaveSuccess = false
    @State private var wallpaperImage: UIImage?
    @State private var showingPermissionAlert = false
    
    // Just two main actions
    private let actions = [
        ("Save", "square.and.arrow.down.fill", Color.blue),
        ("Share", "square.and.arrow.up.fill", Color.green)
    ]
    
    private var wallpaperContent: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundColor
                
                VStack {
                    Spacer()
                    
                    // Selected lyrics - exact same width as editor
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(selectedLines, id: \.self) { line in
                            Text(line)
                                .font(.system(size: 24))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .tracking(-0.6)
                                .padding(.horizontal, 5)
                                .frame(maxWidth: geometry.size.width - 32, alignment: .leading)  // Match editor's width (padding of 16 on each side)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    // Track info at bottom
                    VStack(spacing: 4) {
                        Text(track.title)
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                        Text(track.artists)
                            .font(.system(size: 14))
                            .opacity(0.8)
                    }
                    .foregroundColor(.white)
                    .padding(.bottom, 50)
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Share")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 20)
                }
                .padding()
                
                // Preview of the actual wallpaper
                if let image = wallpaperImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: UIScreen.main.bounds.height * 0.6)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.3), radius: 10)
                        .padding(.horizontal)
                }
                
                // Action buttons
                HStack(spacing: 40) {
                    ForEach(actions, id: \.0) { action in
                        VStack(spacing: 8) {
                            Button(action: {
                                handleAction(action.0)
                            }) {
                                Circle()
                                    .fill(action.2)
                                    .frame(width: 58, height: 58)
                                    .overlay(
                                        Image(systemName: action.1)
                                            .font(.system(size: 24))
                                            .foregroundColor(.white)
                                    )
                            }
                            
                            Text(action.0)
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Bottom indicator
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 40, height: 4)
                    .padding(.bottom, 10)
            }
        }
        .onAppear {
            // Generate wallpaper once when view appears
            wallpaperImage = renderWallpaper()
        }
        .sheet(isPresented: $showingShareSheet) {
            if let image = wallpaperImage {  // Use stored image
                ShareSheet(items: [image])
            }
        }
        .alert("Saved!", isPresented: $showingSaveSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Wallpaper has been saved to your photo library")
        }
        .alert("Photo Library Access", isPresented: $showingPermissionAlert) {
            Button("Open Settings", action: openSettings)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please allow access to your photo library to save wallpapers")
        }
    }
    
    private func renderWallpaper() -> UIImage? {
        let size = UIScreen.main.bounds.size
        
        // Create a UIView to render
        let controller = UIHostingController(rootView: createWallpaperView())
        controller.view.bounds = CGRect(origin: .zero, size: size)
        
        // Create format with no transparency
        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        format.scale = UIScreen.main.scale
        
        // Render the view
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
    
    private func handleAction(_ action: String) {
        guard let image = wallpaperImage else { return }
        
        switch action {
        case "Save":
            checkPhotoLibraryPermissionAndSave(image)
        case "Share":
            showingShareSheet = true
        default:
            break
        }
    }
    
    private func checkPhotoLibraryPermissionAndSave(_ image: UIImage) {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        switch status {
        case .authorized, .limited:
            saveImageToPhotoLibrary(image)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                DispatchQueue.main.async {
                    if status == .authorized || status == .limited {
                        saveImageToPhotoLibrary(image)
                    } else {
                        showingPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            showingPermissionAlert = true
        @unknown default:
            break
        }
    }
    
    private func saveImageToPhotoLibrary(_ image: UIImage) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        } completionHandler: { success, error in
            DispatchQueue.main.async {
                if success {
                    showingSaveSuccess = true
                }
            }
        }
    }
    
    private func createWallpaperView() -> some View {
        let screenSize = UIScreen.main.bounds.size
        return wallpaperContent
            .frame(width: screenSize.width, height: screenSize.height)
            .edgesIgnoringSafeArea(.all)
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// Helper view for system share sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 
