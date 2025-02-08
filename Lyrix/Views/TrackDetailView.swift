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
    
    init(track: Track) {
        _trackWithLyrics = State(initialValue: track)
    }
    
    var body: some View {
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
                .padding(.top, 5)
            
            VStack(spacing: 8) {
                Button(action: {
                    showLyrics = true
                }) {
                    Text("Edit Lyrics")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(error == nil ? Color.blue : Color.gray)
                        )
                }
                .disabled(error != nil)
                
                if error != nil {
                    Text("Lyrics unavailable")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 30)
            
            Spacer()
        }
        .padding()
        .background(ThemeManager.backgroundColor.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
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
        .navigationDestination(isPresented: $showLyrics) {
            LyricsEditorView(track: trackWithLyrics)
        }
    }
}
