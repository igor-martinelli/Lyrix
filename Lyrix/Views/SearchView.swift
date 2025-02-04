import SwiftUI

struct SearchView: View {
    @Binding var searchText: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Search header
            HStack(spacing: 12) {
                // Search field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("What are you looking for?", text: $searchText)
                        .textInputAutocapitalization(.never)
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Go back button
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.primary)
            }
            .padding()
            
            // History section
            VStack(alignment: .leading, spacing: 16) {
                Text("History")
                    .font(.headline)
                    .padding(.horizontal)
                
                // Placeholder for search history
                // Will be implemented later
                Spacer()
            }
            .padding(.top)
        }
        .background(ThemeManager.backgroundColor)
    }
} 