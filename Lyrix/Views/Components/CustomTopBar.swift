import SwiftUI
struct CustomTopBar: View {
    let title: String?
    let subtitle: String?
    @Environment(\.dismiss) private var dismiss
    
    init(title: String? = nil, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 44)
            
            Spacer()
            
            if let title = title {
                VStack(spacing: 2) {
                    Text(title)
                        .font(.system(size: 16))
                        .fontWeight(.bold)
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 14))
                            .opacity(0.8)
                    }
                }
                .foregroundColor(.white)
            }
            
            Spacer()
            
            Color.clear
                .frame(width: 44)
        }
        .padding(.horizontal)
        .frame(height: 60)
    }
} 