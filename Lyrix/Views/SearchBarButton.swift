import SwiftUI

struct SearchBarButton: View {
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            Text("Search song...")
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding(15)
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .padding(.horizontal)
    }
} 