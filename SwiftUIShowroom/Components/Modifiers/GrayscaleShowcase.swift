import SwiftUI

struct GrayscaleShowcase: View {
    @State private var amount: Double = 0.0

    var body: some View {
        ShowcaseScreen(
            title: "Grayscale",
            summary: "Desaturates the view toward gray by the given amount.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension GrayscaleShowcase {
    var preview: some View {
        swatch(amount: amount)
    }

    @ViewBuilder var controls: some View {
        ShowcaseSlider("Amount", value: $amount, in: 0...1, step: 0.01)
    }

    @ViewBuilder func stateView(_ state: EnabledState) -> some View {
        switch state {
        case .enabled:
            swatch(amount: 0.0)
        case .disabled:
            swatch(amount: 1.0)
        }
    }

    func swatch(amount grayscaleAmount: Double) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "photo.fill")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.accent)
            Text("Grayscale")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.primary)
        }
        .padding(DesignSystem.Spacing.large)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
        .grayscale(grayscaleAmount)
    }
}

// MARK: - Code generation
private extension GrayscaleShowcase {
    var generatedCode: String {
        let formatted = String(format: "%.2f", amount)
        return "Image(\"photo\")\n    .grayscale(\(formatted))"
    }
}
