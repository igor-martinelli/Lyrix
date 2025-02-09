import SwiftUI

struct HistoryGridView: View {
    let searchHistory: [Track]
    let logoColorIndex: Int
    @Binding var activeDeleteTrackId: String?  // Change to binding
    let onTrackSelected: (Track) -> Void
    let onTrackDeleted: (Track) -> Void
    @State private var currentPage = 0
    @State private var opacity: Double = 0
    
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
                                ForEach(searchHistory[pageIndex * Constants.itemsPerPage..<min((pageIndex + 1) * Constants.itemsPerPage, searchHistory.count)], id: \.id) { track in
                                    TrackHistoryCell(
                                        track: track,
                                        isShowingDelete: activeDeleteTrackId == track.id,
                                        logoColor: ThemeManager.logoColors[logoColorIndex],
                                        onDelete: { onTrackDeleted(track) },
                                        onLongPress: { isPressed in
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                activeDeleteTrackId = isPressed ? track.id : nil
                                            }
                                        },
                                        onTap: {
                                            if activeDeleteTrackId == nil {
                                                onTrackSelected(track)
                                            } else {
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    activeDeleteTrackId = nil
                                                }
                                            }
                                        }
                                    )
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
    let isShowingDelete: Bool
    let logoColor: Color
    let onDelete: () -> Void
    let onLongPress: (Bool) -> Void
    let onTap: () -> Void
    @GestureState private var isDetectingLongPress = false
    @State private var rotationAngle: Double = 0  // Change from shakeOffset to rotationAngle
    
    private struct Constants {
        static let imageSize: CGFloat = 80
        static let cellHeight: CGFloat = 100
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            ZStack {
                if let url = URL(string: track.imageUrl) {
                    CachedAsyncImage(url: url)
                        .frame(width: Constants.imageSize, height: Constants.imageSize)
                        .cornerRadius(8)
                        .opacity(isShowingDelete ? 0.5 : 1.0)
                        .rotationEffect(.degrees(rotationAngle))  // Use rotation instead of offset
                        .onChange(of: isShowingDelete) { oldValue, newValue in
                            if newValue {
                                // Trigger rotation animation when bin appears
                                withAnimation(.interpolatingSpring(stiffness: 300, damping: 15)) {
                                    rotationAngle = 5
                                }
                                withAnimation(.interpolatingSpring(stiffness: 300, damping: 15).delay(0.1)) {
                                    rotationAngle = -5
                                }
                                withAnimation(.interpolatingSpring(stiffness: 300, damping: 15).delay(0.2)) {
                                    rotationAngle = 0
                                }
                            }
                        }
                } else {
                    Color.gray
                        .frame(width: Constants.imageSize, height: Constants.imageSize)
                        .cornerRadius(8)
                }
                
                if isShowingDelete {
                    Button(action: onDelete) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 24))
                            .foregroundColor(logoColor)
                            .padding(8)
                            .background(Circle().fill(.black).opacity(0.6))
                            .shadow(radius: 2)
                    }
                }
            }
            .gesture(
                LongPressGesture(minimumDuration: 0.5)
                    .updating($isDetectingLongPress) { currentState, gestureState, _ in
                        gestureState = currentState
                    }
                    .onEnded { _ in
                        onLongPress(true)
                    }
            )
            .onTapGesture {
                onTap()
            }
            
            Text(track.title)
                .foregroundColor(.white)
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: Constants.imageSize, alignment: .center)
                .opacity(isShowingDelete ? 0.5 : 1.0)
            
        }
        .frame(height: Constants.cellHeight)
    }
} 
