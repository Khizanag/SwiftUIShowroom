import SwiftUI

struct OpacityShowcase: View {
    @State private var opacityValue: Double = 1.0

    var body: some View {
        ShowcaseScreen(
            title: "Opacity",
            summary: "Controls view transparency from fully transparent (0) to fully opaque (1).",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension OpacityShowcase {
    var preview: some View {
        swatch(opacity: opacityValue)
    }

    @ViewBuilder var controls: some View {
        ShowcaseSlider("Opacity", value: $opacityValue, in: 0...1, step: 0.01)
    }

    @ViewBuilder func stateView(_ state: EnabledState) -> some View {
        switch state {
        case .enabled:
            swatch(opacity: 1.0)
        case .disabled:
            swatch(opacity: 0.3)
        }
    }

    func swatch(opacity: Double) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "star.fill")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.accent)
            Text("Faded")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.primary)
        }
        .padding(DesignSystem.Spacing.large)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
        .opacity(opacity)
    }
}

// MARK: - Code generation
private extension OpacityShowcase {
    var generatedCode: String {
        let isWhole = opacityValue == opacityValue.rounded()
        let formatted = isWhole ? String(format: "%.1f", opacityValue) : String(format: "%.2f", opacityValue)
        return "Text(\"Faded\")\n    .opacity(\(formatted))"
    }
}
