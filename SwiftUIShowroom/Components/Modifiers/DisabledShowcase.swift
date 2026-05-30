import SwiftUI

struct DisabledShowcase: View {
    @State private var isDisabled: Bool = true

    var body: some View {
        ShowcaseScreen(
            title: "Disabled",
            summary: "Disables user interaction for the view and its controls, dimming them and blocking input.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension DisabledShowcase {
    var preview: some View {
        controlGroup(disabled: isDisabled)
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("Disabled", isOn: $isDisabled)
    }

    @ViewBuilder func stateView(_ state: EnabledState) -> some View {
        switch state {
        case .enabled:
            controlGroup(disabled: false)
        case .disabled:
            controlGroup(disabled: true)
        }
    }

    func controlGroup(disabled: Bool) -> some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            Button("Submit") {}
                .buttonStyle(.borderedProminent)
            Toggle("Notifications", isOn: .constant(true))
            Slider(value: .constant(0.6), in: 0...1)
        }
        .padding(DesignSystem.Spacing.large)
        .background(DesignSystem.Color.cardBackground,
                    in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .disabled(disabled)
    }
}

// MARK: - Code generation
private extension DisabledShowcase {
    var generatedCode: String {
        "Button(\"Submit\") { submit() }\n    .disabled(\(isDisabled))"
    }
}
