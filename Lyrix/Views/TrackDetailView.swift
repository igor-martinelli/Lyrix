//
//  TrackDetailView.swift
//  Lyrix
//
//  Created by Igor Martinelli on 06.02.2025.
//

import SwiftUI

struct TrackDetailView: View {
    let track: Track
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: track.imageUrl)) { image in
                image.resizable()
                     .scaledToFit()
                     .frame(width: 250, height: 250)
                     .clipShape(RoundedRectangle(cornerRadius: 20))
            } placeholder: {
                ProgressView()
            }
            
            Text(track.title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            Text(track.artists)
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.top, 5)
            
            Spacer()
        }
        .padding()
        .background(ThemeManager.backgroundColor.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}
