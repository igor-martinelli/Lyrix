//
//  TrackDetailView.swift
//  Lyrix
//
//  Created by Igor Martinelli on 06.02.2025.
//

import SwiftUI

struct TrackDetailView: View {
    @State private var trackWithLyrics: Track
    @State private var showLyrics = false
    @State private var error: Error?
    @State private var isLoadingLyrics = true
    @State private var showLyricsEditor = false
    @State private var opacity = 0.0  // Start fully transparent
    @Environment(\.dismiss) private var dismiss  // Add this for custom back button
    
    init(track: Track) {
        _trackWithLyrics = State(initialValue: track)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CustomTopBar()
            
            VStack {
                if let url = URL(string: trackWithLyrics.imageUrl) {
                    CachedAsyncImage(url: url)
                        .frame(width: 250, height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                } else {
                    ProgressView()
                        .frame(width: 250, height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                
                Text(trackWithLyrics.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                Text(trackWithLyrics.artists)
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.top, 2)
                
                VStack(spacing: 8) {
                    Button(action: {
                        showLyricsEditor = true
                    }) {
                        Text("Create Wallpaper")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(error == nil ? Color.white : Color.gray.opacity(0.5))
                            )
                    }
                    .disabled(error != nil)
                    
                    if error != nil {
                        Text("Lyrics unavailable")
                            .font(.system(size: 12))
                            .foregroundColor(.gray.opacity(0.8))
                    }
                }
                .padding(.top, 24)
                
                Spacer()
            }
            .padding()
        }
        .background(ThemeManager.backgroundColor.ignoresSafeArea())
        .navigationBarHidden(true)  // Hide navigation bar completely
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    // Check if the drag starts near the left edge and is moved far enough
                    if value.startLocation.x < 50 && value.translation.width > 100 {
                        dismiss()
                    }
                }
        )
        .task {
            // First check cache
            if let cachedLyrics = LyricsCache.shared.getLyrics(for: trackWithLyrics.id) {
                print("📝 Found cached lyrics for track: \(trackWithLyrics.title)")
                trackWithLyrics = Track(
                    id: trackWithLyrics.id,
                    title: trackWithLyrics.title,
                    artists: trackWithLyrics.artists,
                    imageUrl: trackWithLyrics.imageUrl,
                    lyrics: cachedLyrics
                )
            } else {
                // If not in cache, fetch from API
                print("🌐 Fetching lyrics from API for track: \(trackWithLyrics.title)")
                do {
                    if let lyricsData = try await LyricsAPIManager.shared.getLyrics(
                        artist: trackWithLyrics.artists,
                        title: trackWithLyrics.title
                    ) {
                        let lyrics = lyricsData.lines
                        // Cache the lyrics
                        LyricsCache.shared.setLyrics(lyrics, for: trackWithLyrics.id)
                        print("💾 Cached lyrics for track: \(trackWithLyrics.title)")
                        // Update the track
                        trackWithLyrics = Track(
                            id: trackWithLyrics.id,
                            title: trackWithLyrics.title,
                            artists: trackWithLyrics.artists,
                            imageUrl: trackWithLyrics.imageUrl,
                            lyrics: lyrics
                        )
                    }
                } catch {
                    self.error = error
                    print("❌ Failed to fetch lyrics for track: \(trackWithLyrics.title), error: \(error.localizedDescription)")
                }
            }
        }
        .opacity(opacity)  // Apply opacity
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                opacity = 1  // Animate to fully opaque
            }
        }
        .navigationDestination(isPresented: $showLyricsEditor) {
            LyricsEditorView(track: trackWithLyrics)
        }
    }
}
