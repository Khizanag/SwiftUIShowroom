import SwiftUI

struct AccessibilityRespondsToUserInteractionShowcase: View {
    @State private var respondsToUserInteraction = true

    var body: some View {
        ShowcaseScreen(
            title: "Responds To User Interaction",
            summary: "Declares whether an element is interactive so assistive tech can correctly group or skip it.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityRespondsToUserInteractionShowcase {
    var preview: some View {
        infoCard(responds: respondsToUserInteraction)
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("respondsToUserInteraction", isOn: $respondsToUserInteraction)
    }

    @ViewBuilder func stateView(_ state: InteractionState) -> some View {
        infoCard(responds: state.responds)
    }
}

// MARK: - Card builder
private extension AccessibilityRespondsToUserInteractionShowcase {
    func infoCard(responds: Bool) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            cardContent(responds: responds)
            interactionBadge(responds: responds)
        }
        .padding(DesignSystem.Spacing.medium)
    }

    func cardContent(responds: Bool) -> some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: "info.circle.fill")
                .font(DesignSystem.Font.title3)
                .foregroundStyle(DesignSystem.Color.accent)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.hairline) {
                Text("Info Card")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.primary)
                Text(responds ? "Marked interactive" : "Marked non-interactive")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
            Spacer()
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .accessibilityElement(children: .combine)
        .accessibilityRespondsToUserInteraction(responds)
    }

    func interactionBadge(responds: Bool) -> some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: responds ? "hand.tap" : "hand.tap.fill")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(responds ? DesignSystem.Color.accent : DesignSystem.Color.secondary)
            Text(responds ? "VoiceOver: interactive" : "VoiceOver: non-interactive")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }
}

// MARK: - Code generation
private extension AccessibilityRespondsToUserInteractionShowcase {
    var generatedCode: String {
        """
        InfoCard()
            .accessibilityElement(children: .combine)
            .accessibilityRespondsToUserInteraction(\(respondsToUserInteraction))
        """
    }
}

// MARK: - Nested types
extension AccessibilityRespondsToUserInteractionShowcase {
    fileprivate enum InteractionState: ShowcaseState {
        case interactive
        case nonInteractive

        var caption: String {
            switch self {
            case .interactive: "Interactive"
            case .nonInteractive: "Non-interactive"
            }
        }

        var responds: Bool {
            switch self {
            case .interactive: true
            case .nonInteractive: false
            }
        }
    }
}
