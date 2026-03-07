import SwiftUI

/// Reusable card container with rounded corners and shadow.
struct CardView<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    CardView {
        Text("Card content")
            .padding()
    }
    .padding()
}
