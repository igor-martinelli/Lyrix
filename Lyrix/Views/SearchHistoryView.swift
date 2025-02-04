import SwiftUI

struct SearchHistoryView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("History")
                .font(ThemeManager.headlineFont)
                .padding(.horizontal)
            
            ForEach(0..<4) { _ in
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                    Text("Previous search")
                        .font(ThemeManager.bodyFont)
                        .foregroundColor(.primary)
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            
            Spacer()
        }
        .padding(.top)
    }
} 