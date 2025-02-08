import SwiftUI

struct LyricsEditorView: View {
    let track: Track
    @State private var lyrics: [String] = []
    @State private var selectedLines: Set<Int> = []
    @State private var selectedColor: Color = .white
    @State private var selectedFont: Font = .system(size: 17)
    @State private var isLoading = true
    @State private var error: Error?
    
    private let availableFonts: [Font] = [
        .system(size: 17),
        .custom("Georgia", size: 17),
        .custom("Helvetica Neue", size: 17),
        // Add more fonts as needed
    ]
    
    private let colors: [Color] = [
        .white, .red, .blue, .green, .yellow, .purple, .pink
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Top toolbar
            HStack {
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
                                    selectedColor = color
                                }
                        }
                    }
                }
                .padding(.horizontal)
                
                Divider()
                    .frame(height: 30)
                
                // Font picker
                Picker("Font", selection: $selectedFont) {
                    ForEach(availableFonts, id: \.self) { font in
                        Text("Aa").font(font).tag(font)
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal)
            }
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            
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
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(lyrics.enumerated()), id: \.offset) { index, line in
                            Text(line)
                                .font(selectedFont)
                                .foregroundColor(selectedLines.contains(index) ? selectedColor : .white)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(
                                    selectedLines.contains(index) ?
                                    Color.gray.opacity(0.3) : Color.clear
                                )
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