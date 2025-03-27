import SwiftUI

struct LyricsEditorView: View {
    let track: Track
    @State private var selectedLines: Set<Int> = []
    @State private var selectedColor: Color = .red
    @State private var selectedFont: Font = .system(size: 23)
    @State private var isFavorite = false
    @Environment(\.dismiss) private var dismiss
    @State private var showingPreview = false
    @State private var opacity = 0.0  // For fade-in animation
    
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
    }
    
    var selectedLyrics: [String] {
        selectedLines.sorted().map { track.lyrics[$0] }
    }
    
    // Simplified color picker
    private var colorPickerView: some View {
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
                        selectedColor = color
                    }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.1))
                .frame(width: CGFloat(colors.count) * 24 + CGFloat(colors.count - 1) * 12 + 32)
                .frame(height: 48)
        )
    }
    
    var body: some View {
        ZStack {
            selectedColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header bar
                CustomTopBar(title: track.title, subtitle: track.artists)
                    .padding(.bottom, 20)
                
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
                                    .padding(.horizontal, 10)    
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
                    colorPickerView
                    
                    Button(action: {
                        if !selectedLines.isEmpty {
                            showingPreview = true
                        }
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
                    .opacity(selectedLines.isEmpty ? 0.4 : 1.0)
                    .disabled(selectedLines.isEmpty)
                    .animation(AnimationConstants.standard, value: selectedLines.isEmpty)
                }
                .padding(.vertical, 30)
            }
        }
        .navigationBarHidden(true)
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    if value.startLocation.x < 50 && value.translation.width > 100 {
                        dismiss()
                    }
                }
        )
        .sheet(isPresented: $showingPreview) {
            WallpaperPreviewView(
                track: track,
                selectedLines: selectedLyrics,
                backgroundColor: selectedColor
            )
            .presentationDetents([.large])  // Always full screen
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                opacity = 1  // Animate to fully opaque
            }
        }
    }
} 
