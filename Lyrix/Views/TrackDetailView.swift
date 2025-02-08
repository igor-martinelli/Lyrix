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
            do {
                if let lyricsData = try await LyricsAPIManager.shared.getLyrics(
                    artist: trackWithLyrics.artists,
                    title: trackWithLyrics.title
                ) {
                    trackWithLyrics = Track(
                        id: trackWithLyrics.id,
                        title: trackWithLyrics.title,
                        artists: trackWithLyrics.artists,
                        imageUrl: trackWithLyrics.imageUrl,
                        lyrics: lyricsData.lines
                    )
                }
            } catch {
                self.error = error
            }
        }
        .navigationDestination(isPresented: $showLyrics) {
            LyricsEditorView(track: trackWithLyrics)
        }
    }
}
