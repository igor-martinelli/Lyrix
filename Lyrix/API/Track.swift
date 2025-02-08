//
//  SpotifyTrack.swift
//  Lyrix
//
//  Created by Igor Martinelli on 06.02.2025.
//
import Foundation

struct Track: Identifiable, Codable {
    let id: String
    let title: String
    let artists: String
    let imageUrl: String
    let lyrics: [String]
}
