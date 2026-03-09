import SwiftUI

/// Reusable card container with rounded corners and shadow.
struct CardView<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .background(FidelTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: FidelTheme.radiusL))
            .shadow(color: FidelTheme.cardShadow, radius: 6, x: 0, y: 2)
    }
}

#Preview {
    CardView {
        Text("Card content")
            .padding()
    }
    .padding()
}
