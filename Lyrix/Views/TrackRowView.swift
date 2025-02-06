import SwiftUI

struct TrackRowView: View {
    let track: Track

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: track.imageUrl)) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 50, height: 50)
            .cornerRadius(8)

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
