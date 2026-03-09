import SwiftUI

struct RecommendationCardView: View {
    let recommendation: Recommendation
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: FidelTheme.spaceM) {
                ZStack {
                    RoundedRectangle(cornerRadius: FidelTheme.radiusS)
                        .fill(FidelTheme.accent.opacity(0.12))
                        .square(40)
                    Image(systemName: iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(FidelTheme.accent)
                }
                VStack(alignment: .leading, spacing: FidelTheme.spaceXS) {
                    Text(recommendation.title)
                        .font(FidelTheme.headline)
                        .foregroundStyle(.primary)
                    if let subtitle = recommendation.subtitle {
                        Text(subtitle)
                            .font(FidelTheme.callout)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(FidelTheme.spaceM)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableCardStyle())
        .background(FidelTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: FidelTheme.radiusL))
        .overlay(
            RoundedRectangle(cornerRadius: FidelTheme.radiusL)
                .stroke(priorityColor.opacity(0.3), lineWidth: recommendation.priority == .urgent ? 2 : 0)
        )
        .shadow(color: FidelTheme.cardShadow, radius: 6, x: 0, y: 2)
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
