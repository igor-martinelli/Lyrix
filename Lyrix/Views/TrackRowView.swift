import SwiftUI

struct TrackRowView: View {
    let track: Track

    var body: some View {
        HStack {
            if let url = URL(string: track.imageUrl) {
                CachedAsyncImage(url: url)
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
            } else {
                Color.gray
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
            }

            VStack(alignment: .leading) {
                Text(track.title)
                    .font(.headline)
                    .lineLimit(1)                   // Ensure it stays on one line
                    .truncationMode(.tail)
                Text(track.artists)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)                   // Ensure it stays on one line
                    .truncationMode(.tail)
            }

            Spacer()
        }
        .padding(.vertical, 5)
    }
}
