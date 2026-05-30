import SwiftUI

struct AccessibilityInputLabelsShowcase: View {
    @State private var labelsText = "Favorite, Like, Heart"
    @State private var isEnabled = true

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Input Labels",
            summary: "Provides alternate spoken names Voice Control and Switch Control accept to target an element.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityInputLabelsShowcase {
    var preview: some View {
        inputLabelsDemo(labels: parsedLabels, isEnabled: isEnabled)
    }

    @ViewBuilder var controls: some View {
        ShowcaseTextControl(
            "Input labels (comma-separated)",
            text: $labelsText,
            prompt: "e.g. Favorite, Like, Heart",
        )
        ShowcaseToggle("isEnabled", isOn: $isEnabled)
    }

    @ViewBuilder func stateView(_ state: EnabledState) -> some View {
        switch state {
        case .enabled:
            inputLabelsDemo(labels: ["Favorite", "Like", "Heart"], isEnabled: true)
        case .disabled:
            inputLabelsDemo(labels: ["Favorite", "Like", "Heart"], isEnabled: false)
        }
    }

    func inputLabelsDemo(labels: [String], isEnabled: Bool) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Button(
                action: {},
                label: {
                    Image(systemName: "heart")
                        .font(DesignSystem.Font.title2)
                        .foregroundStyle(DesignSystem.Color.accent)
                }
            )
            .buttonStyle(.plain)
            .accessibilityLabel("Favorite")
            .accessibilityInputLabels(labels, isEnabled: isEnabled)

            VStack(spacing: DesignSystem.Spacing.xSmall) {
                Text(isEnabled ? "Voice Control accepts:" : "Input labels disabled")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
                if isEnabled {
                    Text(labels.joined(separator: ", "))
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.primary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(DesignSystem.Spacing.medium)
    }
}

// MARK: - Code generation
private extension AccessibilityInputLabelsShowcase {
    var parsedLabels: [String] {
        labelsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    var generatedCode: String {
        let labelsLiteral = parsedLabels
            .map { "\"\($0)\"" }
            .joined(separator: ", ")
        let labelsArg = "[\(labelsLiteral)]"
        let enabledArg = isEnabled ? "" : ", isEnabled: false"
        return """
        Button(action: {}) { Image(systemName: "heart") }
            .accessibilityLabel("Favorite")
            .accessibilityInputLabels(\(labelsArg)\(enabledArg))
        """
    }
}
