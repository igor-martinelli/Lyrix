import SwiftUI

struct AnimationConstants {
    // Main animation duration used throughout the app
    static let duration: Double = 0.4
    
    // Reusable animations
    static let standard = Animation.spring(duration: duration)
    static let easeOut = Animation.easeOut(duration: duration)
    static let easeIn = Animation.easeIn(duration: duration)
    
    // For longer animations
    static let slow = Animation.spring(duration: duration * 1.5)
    
    // For quicker animations
    static let quick = Animation.spring(duration: duration * 0.75)
    
    // Logo sizes
    static let logoSizeNormal: CGFloat = 60
    static let logoSizeSmall: CGFloat = 45
} 
