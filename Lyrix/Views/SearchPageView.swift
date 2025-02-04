import SwiftUI

struct SearchPageView: View {
    @Binding var searchText: String
    @Binding var isSearchActive: Bool
    @FocusState private var isFocused: Bool
    
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
                        .focused($isFocused)
                        .submitLabel(.search)
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Cancel button
                Button("Cancel") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isSearchActive = false
                        isFocused = false
                    }
                }
                .foregroundColor(.primary)
            }
            .padding()
            
            // History section
            VStack(alignment: .leading, spacing: 16) {
                Text("History")
                    .font(.headline)
                    .padding(.horizontal)
                    .opacity(isFocused ? 1 : 0)
                
                // Example history items
                ForEach(0..<4) { _ in
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.gray)
                        Text("Previous search")
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
                .opacity(isFocused ? 1 : 0)
                
                Spacer()
            }
            .padding(.top)
        }
        .background(Color(.systemBackground))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isFocused = true
            }
        }
    }
} 