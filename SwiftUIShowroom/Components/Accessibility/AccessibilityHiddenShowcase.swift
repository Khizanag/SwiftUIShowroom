import SwiftUI

struct AccessibilityHiddenShowcase: View {
    enum HiddenShowcaseState: ShowcaseState {
        case hiddenTrue
        case hiddenFalse

        var caption: String {
            switch self {
            case .hiddenTrue: return "hidden: true — removed from accessibility tree"
            case .hiddenFalse: return "hidden: false — visible to VoiceOver"
            }
        }
    }

    @State private var hidden = true

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Hidden",
            summary: "Removes an element from the accessibility tree without affecting visual layout.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityHiddenShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            decorativeIcon(hidden: hidden)
            Text(hiddenStatusText)
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(DesignSystem.Spacing.medium)
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("Hidden", isOn: $hidden)
    }

    @ViewBuilder func stateView(_ state: HiddenShowcaseState) -> some View {
        switch state {
        case .hiddenTrue:
            stateRow(hidden: true)
        case .hiddenFalse:
            stateRow(hidden: false)
        }
    }

    var hiddenStatusText: String {
        hidden
            ? "Hidden from VoiceOver — decorative element ignored"
            : "Visible to VoiceOver"
    }

    func decorativeIcon(hidden: Bool) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "photo.artframe")
                .resizable()
                .scaledToFit()
                .frame(width: DesignSystem.Size.Icon.xLarge, height: DesignSystem.Size.Icon.xLarge)
                .foregroundStyle(DesignSystem.Color.secondary)
                .accessibilityHidden(hidden)
            if hidden {
                Image(systemName: "eye.slash")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .accessibilityHidden(true)
            }
        }
    }

    func stateRow(hidden: Bool) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            decorativeIcon(hidden: hidden)
            Text(hidden ? "Removed from accessibility tree" : "Exposed to VoiceOver")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Code generation
private extension AccessibilityHiddenShowcase {
    var generatedCode: String {
        let lines = [
            "Image(\"decorative-pattern\")",
            "    .accessibilityHidden(\(hidden))",
        ]
        return lines.joined(separator: "\n")
    }
}
