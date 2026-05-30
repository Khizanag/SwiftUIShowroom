import SwiftUI

struct AccessibilityHintShowcase: View {
    @State private var hintText = "Adds the item to your favorites."
    @State private var isEnabled = true

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Hint",
            summary: "Adds a longer description of what activating an element does; spoken after a pause.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityHintShowcase {
    var preview: some View {
        hintRow(hint: hintText, isEnabled: isEnabled)
    }

    @ViewBuilder var controls: some View {
        ShowcaseTextControl(
            "Hint",
            text: $hintText,
            prompt: "e.g. Adds the item to your favorites.",
        )
        ShowcaseToggle("isEnabled", isOn: $isEnabled)
    }

    @ViewBuilder func stateView(_ state: EnabledState) -> some View {
        switch state {
        case .enabled:
            hintRow(hint: hintText, isEnabled: true)
        case .disabled:
            hintRow(hint: hintText, isEnabled: false)
        }
    }

    func hintRow(hint: String, isEnabled: Bool) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Group {
                if isEnabled {
                    Button("Favorite") { }
                        .buttonStyle(.bordered)
                        .tint(DesignSystem.Color.accent)
                        .accessibilityHint(hint)
                } else {
                    Button("Favorite") { }
                        .buttonStyle(.bordered)
                        .tint(DesignSystem.Color.accent)
                }
            }
            HStack(spacing: DesignSystem.Spacing.xSmall) {
                Image(systemName: "quote.bubble")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.accent)
                Text(isEnabled ? "\"\(hint)\"" : "(hint suppressed)")
                    .font(DesignSystem.Font.footnote)
                    .foregroundStyle(DesignSystem.Color.secondary)
                    .lineLimit(2)
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Code generation
private extension AccessibilityHintShowcase {
    var generatedCode: String {
        if isEnabled {
            return """
            Button("Favorite") { }
                .accessibilityHint("\(hintText)")
            """
        } else {
            return """
            Button("Favorite") { }
            // accessibilityHint omitted (disabled in configuration)
            """
        }
    }
}
