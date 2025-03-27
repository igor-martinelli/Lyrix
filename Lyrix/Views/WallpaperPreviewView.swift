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
    @State private var saveCompleted = false
    
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
                                .frame(maxWidth: geometry.size.width - 32, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 120)  // Add padding here to move lyrics down
                    
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
                    .padding(.bottom, 95)  
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                // Preview of the actual wallpaper
                if let image = wallpaperImage {
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: UIScreen.main.bounds.height * 0.6)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.3), radius: 10)
                            .padding(.horizontal)
                        
                        // Saved overlay
                        if saveCompleted {
                            Color.black.opacity(0.7)
                                .cornerRadius(20)
                                .overlay(
                                    Text("Saved")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                )
                                .transition(.opacity)
                        }
                    }
                    .frame(height: UIScreen.main.bounds.height * 0.6)  // Add fixed frame to ZStack
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
                                        Group {
                                            if action.0 == "Save" && saveCompleted {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(.white)
                                                    .transition(.scale.combined(with: .opacity))
                                            } else {
                                                Image(systemName: action.1)
                                                    .font(.system(size: 24))
                                                    .foregroundColor(.white)
                                                    .transition(.scale.combined(with: .opacity))
                                            }
                                        }
                                        .animation(.spring(), value: saveCompleted)
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
            }
        }
        .onAppear {
            wallpaperImage = renderWallpaper()
        }
        .sheet(isPresented: $showingShareSheet) {
            if let image = wallpaperImage {
                ShareSheet(items: [image])
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
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
                    withAnimation {
                        saveCompleted = true
                    }
                    // Reset after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            saveCompleted = false
                        }
                    }
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

// Simplify ShareSheet back to its basic form
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 
