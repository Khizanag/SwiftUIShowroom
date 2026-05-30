import SwiftUI

struct AccessibilityValueShowcase: View {
    @State private var valueText = "40 percent"
    @State private var isEnabled = true

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Value",
            summary: "Supplies the current value VoiceOver reads after the label, for elements whose state changes.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityValueShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            if isEnabled {
                ProgressView(value: 0.4)
                    .accessibilityValue(valueText)
            } else {
                ProgressView(value: 0.4)
            }
            HStack {
                Image(systemName: "speaker.wave.2")
                    .foregroundStyle(DesignSystem.Color.accent)
                    .font(DesignSystem.Font.caption)
                Text("VoiceOver reads: \"\(isEnabled ? valueText : "(no custom value)")\"")
                    .font(DesignSystem.Font.footnote)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
        .padding(DesignSystem.Spacing.medium)
    }

    @ViewBuilder var controls: some View {
        ShowcaseTextControl(
            "Value",
            text: $valueText,
            prompt: "e.g. 40 percent",
        )
        ShowcaseToggle("isEnabled", isOn: $isEnabled)
    }

    @ViewBuilder func stateView(_ state: EnabledState) -> some View {
        switch state {
        case .enabled:
            progressRow(label: "40 percent", valueActive: true)
        case .disabled:
            progressRow(label: "40 percent", valueActive: false)
        }
    }

    func progressRow(label: String, valueActive: Bool) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            if valueActive {
                ProgressView(value: 0.4)
                    .accessibilityValue(label)
            } else {
                ProgressView(value: 0.4)
            }
            Text(valueActive ? "Custom value active: \"\(label)\"" : "Default value (no override)")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Code generation
private extension AccessibilityValueShowcase {
    var generatedCode: String {
        if isEnabled {
            let lines = [
                "ProgressView(value: 0.4)",
                "    .accessibilityValue(\"\(valueText)\")",
            ]
            return lines.joined(separator: "\n")
        } else {
            return "ProgressView(value: 0.4)"
        }
    }
}
