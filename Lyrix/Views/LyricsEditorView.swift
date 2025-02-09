import SwiftUI

struct LyricsEditorView: View {
    let track: Track
    @State private var selectedLines: Set<Int> = []
    @State private var selectedColor: Color = .red
    @State private var selectedFont: Font = .system(size: 24)
    @State private var isFavorite = false
    @Environment(\.dismiss) private var dismiss
    @State private var showingPreview = false
    
    private let colors: [Color] = [
        .red, .blue, .green, .yellow, .purple, .pink, .orange
    ]
    
    // Helper functions for line selection
    private func isLineSelected(_ index: Int) -> Bool {
        selectedLines.contains(index)
    }
    
    private func isLineBoundary(_ index: Int) -> Bool {
        guard selectedLines.contains(index) else { return false }
        let sortedIndices = selectedLines.sorted()
        return index == sortedIndices.first || index == sortedIndices.last
    }
    
    private func selectLineRange(from: Int, to: Int) {
        let range = min(from, to)...max(from, to)
        selectedLines.formUnion(range)
    }
    
    private func deselectLinesFrom(_ index: Int) {
        let sortedIndices = selectedLines.sorted()
        guard let startIdx = sortedIndices.firstIndex(of: index) else { return }
        let linesToRemove = sortedIndices[startIdx...]
        selectedLines.subtract(linesToRemove)
    }
    
    private func handleLineSelection(_ index: Int) {
        if isLineSelected(index) {
            // Deselection logic
            if isLineBoundary(index) {
                // If boundary line, just remove it
                selectedLines.remove(index)
            } else {
                // If internal line, remove it and all lines below
                deselectLinesFrom(index)
            }
        } else {
            // Selection logic
            if selectedLines.isEmpty {
                // First selection
                selectedLines.insert(index)
            } else {
                let sortedIndices = selectedLines.sorted()
                if let closestSelected = sortedIndices.min(by: { abs($0 - index) < abs($1 - index) }) {
                    // Select range between closest selected line and current line
                    selectLineRange(from: closestSelected, to: index)
                }
            }
        }
        
        // Debug print
        print("📝 Selected lines (sorted): \(selectedLines.sorted())")
        print("📍 Clicked line index: \(index)")
        if !selectedLines.isEmpty {
            print("🔄 Range: \(selectedLines.min()!) to \(selectedLines.max()!)")
        }
        print("-------------------")
    }
    
    var selectedLyrics: [String] {
        selectedLines.sorted().map { track.lyrics[$0] }
    }
    
    var body: some View {
        ZStack {
            selectedColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header bar
                HStack(alignment: .center, spacing: 0) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 44)
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text(track.title)
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                        Text(track.artists)
                            .font(.system(size: 14))
                            .opacity(0.8)
                    }
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 44)
                }
                .padding(.horizontal)
                .frame(height: 60)  // Fixed header height
                .padding(.bottom, 20)  // Add bottom padding here
                
                // Lyrics content
                ZStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 12) {
                            Color.clear.frame(height: 20)
                            
                            ForEach(Array(track.lyrics.enumerated()), id: \.offset) { index, line in
                                Text(line)
                                    .font(selectedFont)
                                    .fontWeight(.bold)
                                    .foregroundColor(isLineSelected(index) ? .white : .black)
                                    .tracking(-0.6)
                                    .padding(.horizontal, 5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(nil)
                                    .multilineTextAlignment(.leading)
                                    .onTapGesture {
                                        handleLineSelection(index)
                                    }
                            }
                            
                            Color.clear.frame(height: 20)
                        }
                        .padding()
                    }
                    
                    // Gradient masks
                    VStack {
                        LinearGradient(
                            gradient: Gradient(colors: [selectedColor, selectedColor.opacity(0)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 40)
                        
                        Spacer()
                        
                        LinearGradient(
                            gradient: Gradient(colors: [selectedColor.opacity(0), selectedColor]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 40)
                    }
                }
                
                // Color picker toolbar
                HStack(spacing: 20) {
                    HStack(spacing: 12) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: color == selectedColor ? 2 : 0)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedColor = color
                                    }
                                }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.1))
                            .frame(width: CGFloat(colors.count) * 24 + CGFloat(colors.count - 1) * 12 + 32)
                            .frame(height: 48)
                    )
                    
                    Button(action: {
                        showingPreview = true
                    }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 25, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .background(
                                Circle()
                                    .fill(selectedColor)
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 1)
                            )
                    }
                    .padding(.leading, 20)
                }
                .padding(.vertical, 30)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingPreview) {
            WallpaperPreviewView(
                track: track,
                selectedLines: selectedLyrics,
                backgroundColor: selectedColor
            )
        }
    }
} 
