import SwiftUI

struct RecommendationCardView: View {
    let recommendation: Recommendation
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundStyle(FidelTheme.accent)
                    .frame(width: 32, alignment: .center)
                VStack(alignment: .leading, spacing: 4) {
                    Text(recommendation.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    if let subtitle = recommendation.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
        }
        .buttonStyle(.plain)
        .background(FidelTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: FidelTheme.radiusL))
        .overlay(
            RoundedRectangle(cornerRadius: FidelTheme.radiusL)
                .stroke(priorityColor.opacity(0.3), lineWidth: recommendation.priority == .urgent ? 2 : 0)
        )
    }

    private var iconName: String {
        switch recommendation.action {
        case .reviewWeakLetters: "character.textformat"
        case .reviewWeakWords: "textformat"
        case .continueLesson: "book.fill"
        case .completeDailyGoal: "target"
        case .keepStreak: "flame.fill"
        }
    }

    private var priorityColor: Color {
        switch recommendation.priority {
        case .urgent: .orange
        case .high: .blue
        case .normal, .low: .secondary
        }
    }
}
