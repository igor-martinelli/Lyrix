//
//  LyrixApp.swift
//  Lyrix
//
//  Created by Igor Martinelli on 21.12.2024.
//

import SwiftUI

@main
struct LyrixApp: App {
    init() {
        // Set the status bar style to light (white) content
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.overrideUserInterfaceStyle = .dark
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

