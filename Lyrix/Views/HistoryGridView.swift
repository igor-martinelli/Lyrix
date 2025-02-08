import SwiftUI

struct HistoryGridView: View {
    let searchHistory: [Track]
    let logoColorIndex: Int
    let onTrackSelected: (Track) -> Void
    let onTrackDeleted: (Track) -> Void
    @State private var currentPage = 0
    @State private var opacity: Double = 0  // Start fully transparent
    
    private struct Constants {
        static let rowHeight: CGFloat = 170
        static let itemSpacing: CGFloat = 5
        static let itemsPerPage: Int = 4
    }
    
    private var numberOfPages: Int {
        Int(ceil(Double(searchHistory.count) / Double(Constants.itemsPerPage)))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("History")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.horizontal)
                .padding(.top)
            
            GeometryReader { geometry in
                let pageWidth = geometry.size.width - 32
                
                VStack(spacing: 10) {
                    TabView(selection: $currentPage) {
                        ForEach(0..<numberOfPages, id: \.self) { pageIndex in
                            HStack(spacing: Constants.itemSpacing) {
                                ForEach(0..<min(Constants.itemsPerPage, searchHistory.count - pageIndex * Constants.itemsPerPage), id: \.self) { itemIndex in
                                    let track = searchHistory[pageIndex * Constants.itemsPerPage + itemIndex]
                                    Button(action: {
                                        onTrackSelected(track)
                                    }) {
                                        TrackHistoryCell(track: track) {
                                            onTrackDeleted(track)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .id(track.id)
                                }
                                Spacer()
                            }
                            .frame(width: pageWidth, alignment: .leading)
                            .tag(pageIndex)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    // Always show the HStack for page indicators, but make it invisible when not needed
                    HStack(spacing: 6) {
                        if numberOfPages > 1 {
                            ForEach(0..<numberOfPages, id: \.self) { index in
                                Circle()
                                    .fill(index == currentPage ? Color.white : Color.gray.opacity(0.5))
                                    .frame(width: 6, height: 6)
                            }
                        }
                    }
                    .padding(.bottom, 15)
                    .frame(height: 6)  // Fixed height for the indicators
                }
            }
        }
        .frame(height: Constants.rowHeight)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(ThemeManager.logoColors[logoColorIndex], lineWidth: 1.5)
        )
        .padding()
        .opacity(opacity)  // Apply opacity
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                opacity = 1  // Animate to fully opaque
            }
        }
    }
} 

struct TrackHistoryCell: View {
    let track: Track
    let onDelete: () -> Void
    
    private struct Constants {
        static let imageSize: CGFloat = 80
        static let cellHeight: CGFloat = 100
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            ZStack(alignment: .topTrailing) {
                if let url = URL(string: track.imageUrl) {
                    CachedAsyncImage(url: url)
                        .frame(width: Constants.imageSize, height: Constants.imageSize)
                        .cornerRadius(8)
                        .id(track.imageUrl)
                } else {
                    Color.gray
                        .frame(width: Constants.imageSize, height: Constants.imageSize)
                        .cornerRadius(8)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
                .padding(4)
            }
            
            Text(track.title)
                .foregroundColor(.white)
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: Constants.imageSize, alignment: .center)
        }
        .frame(height: Constants.cellHeight)
    }
} 
