import SwiftUI

struct AnimatedTrashButton: View {
    let action: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isAnimating = true
            }
            
            action()
            
            // Reset animation after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isAnimating = false
                }
            }
        }) {
            Image(systemName: isAnimating ? "trash.fill" : "trash")
                .imageScale(.large)
                .foregroundColor(.red)
                .rotationEffect(.degrees(isAnimating ? 15 : 0))
        }
    }
} 