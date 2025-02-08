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
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.overrideUserInterfaceStyle = .dark
        }
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .preferredColorScheme(.dark)
        }
    }
}

