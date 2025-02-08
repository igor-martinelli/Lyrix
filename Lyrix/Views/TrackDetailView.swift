//
//  TrackDetailView.swift
//  Lyrix
//
//  Created by Igor Martinelli on 06.02.2025.
//

import SwiftUI

struct TrackDetailView: View {
    let track: Track
    @State private var showLyrics = false
    
    var body: some View {
        VStack {
            if let url = URL(string: track.imageUrl) {
                CachedAsyncImage(url: url)
                    .frame(width: 250, height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                ProgressView()
                    .frame(width: 250, height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            
            Text(track.title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            Text(track.artists)
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.top, 5)
            
            Button(action: {
                showLyrics = true
            }) {
                Text("Edit Lyrics")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.blue)
                    )
            }
            .padding(.top, 30)
            
            Spacer()
        }
        .padding()
        .background(ThemeManager.backgroundColor.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showLyrics) {
            LyricsEditorView(track: track)
        }
    }
}
