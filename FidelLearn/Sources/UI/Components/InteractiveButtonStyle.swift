import SwiftUI

/// Apple-style press feedback: subtle scale on tap. Respects Reduce Motion.
struct ScaledButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.97 : 1))
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

/// Card-style button with highlight overlay on press — like iOS List rows.
struct PressableCardStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: FidelTheme.radiusL)
                    .fill(Color.primary.opacity(reduceMotion ? 0 : (configuration.isPressed ? 0.06 : 0)))
            )
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.99 : 1))
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Minimum 44pt touch target for accessibility (Apple HIG).
struct MinTouchTargetModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(minHeight: 44)
            .contentShape(Rectangle())
    }
}

extension View {
    /// Ensures minimum 44×44pt touch target per Apple HIG.
    func minTouchTarget() -> some View {
        modifier(MinTouchTargetModifier())
    }
}
