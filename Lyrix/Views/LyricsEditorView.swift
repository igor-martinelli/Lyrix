import SwiftUI

struct LyricsEditorView: View {
    let track: Track
    @State private var lyrics: [String] = []
    @State private var selectedLines: Set<Int> = []
    @State private var selectedColor: Color = .red  // Default red background
    @State private var selectedFont: Font = .system(size: 20)  // Bigger font
    @State private var isLoading = true
    @State private var error: Error?
    
    private let availableFonts: [Font] = [
        .system(size: 22),
        .custom("Georgia", size: 22),
        .custom("Helvetica Neue", size: 22),
    ]
    
    private let colors: [Color] = [
        .red, .blue, .green, .yellow, .purple, .pink, .orange
    ]
    
    var body: some View {
        ZStack {
            // Background color
            selectedColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Title and artist
                VStack(alignment: .center, spacing: 8) {
                    Text(track.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text(track.artists)
                        .font(.title3)
                        .foregroundColor(.black.opacity(0.7))
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                if isLoading {
                    ProgressView()
                        .frame(maxHeight: .infinity)
                } else if let error = error {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                        Text("Failed to load lyrics")
                            .padding(.top)
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    // Lyrics content
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(Array(lyrics.enumerated()), id: \.offset) { index, line in
                                Text(line)
                                    .font(selectedFont)
                                    .fontWeight(.bold)
                                    .foregroundColor(selectedLines.contains(index) ? .white : .black)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .onTapGesture {
                                        if selectedLines.contains(index) {
                                            selectedLines.remove(index)
                                        } else {
                                            selectedLines.insert(index)
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                    
                    // Bottom toolbar
                    VStack(spacing: 15) {
                        Divider()
                        
                        // Color picker
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(colors, id: \.self) { color in
                                    Circle()
                                        .fill(color)
                                        .frame(width: 30, height: 30)
                                        .overlay(
                                            Circle()
                                                .stroke(color == selectedColor ? .white : .clear, lineWidth: 2)
                                        )
                                        .onTapGesture {
                                            withAnimation {
                                                selectedColor = color
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Font picker
                        Picker("Font", selection: $selectedFont) {
                            ForEach(availableFonts, id: \.self) { font in
                                Text("Aa").font(font).tag(font)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 30)
                    .background(Color.black.opacity(0.1))
                }
            }
        }
        .task {
            do {
                if let lyricsData = try await LyricsAPIManager.shared.getLyrics(
                    artist: track.artists,
                    title: track.title
                ) {
                    self.lyrics = lyricsData.lines
                }
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
} 
