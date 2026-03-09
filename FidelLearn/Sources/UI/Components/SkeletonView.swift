import SwiftUI

/// Pulsing skeleton placeholder for loading states.
struct SkeletonView: View {
    @State private var opacity: Double = 0.4

    var body: some View {
        RoundedRectangle(cornerRadius: FidelTheme.radiusM)
            .fill(Color(.tertiarySystemFill))
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    opacity = 0.7
                }
            }
    }
}

/// Skeleton row mimicking a lesson list item.
struct LessonSkeletonRow: View {
    var body: some View {
        HStack(spacing: FidelTheme.spaceM) {
            SkeletonView()
                .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: FidelTheme.spaceS) {
                SkeletonView()
                    .frame(height: 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                SkeletonView()
                    .frame(width: 140, height: 12)
            }
            Spacer()
        }
        .padding(.vertical, FidelTheme.spaceM)
    }
}
