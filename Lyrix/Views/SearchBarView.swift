import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @Binding var isSearching: Bool
    @FocusState private var isFocused: Bool
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(duration: 0.3)) {
                isSearching = true
                isFocused = true
            }
        }) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search song...", text: $searchText)
                    .font(ThemeManager.bodyFont)
                    .textInputAutocapitalization(.never)
                    .focused($isFocused)
                    .submitLabel(.search)
                    .allowsHitTesting(isSearching)
                
                if isSearching {
                    Button(action: {
                        withAnimation(.spring(duration: 0.3)) {
                            isSearching = false
                            searchText = ""
                            isFocused = false
                        }
                    }) {
                        Text("Cancel")
                            .font(ThemeManager.bodyFont)
                            .foregroundColor(.primary)
                    }
                    .transition(.move(edge: .trailing))
                }
            }
            .padding(15)
            .background(Color(.systemGray6))
            .cornerRadius(15)
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
    }
} 
