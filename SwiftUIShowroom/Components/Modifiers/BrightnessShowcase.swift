import SwiftUI

struct BrightnessShowcase: View {
    @State private var amount: Double = 0.0

    var body: some View {
        ShowcaseScreen(
            title: "Brightness",
            summary: "Adds a constant to each color channel, lightening (positive) or darkening (negative) the view.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension BrightnessShowcase {
    var preview: some View {
        swatch(amount: amount)
    }

    @ViewBuilder var controls: some View {
        ShowcaseSlider("Amount", value: $amount, in: -1...1, step: 0.01)
    }

    @ViewBuilder func stateView(_ state: BrightnessState) -> some View {
        switch state {
        case .neutral:
            swatch(amount: 0.0)
        case .lightened:
            swatch(amount: 0.4)
        case .darkened:
            swatch(amount: -0.4)
        case .maxWhite:
            swatch(amount: 1.0)
        case .maxBlack:
            swatch(amount: -1.0)
        }
    }

    func swatch(amount brightnessAmount: Double) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "sun.max.fill")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.accent)
            Text("Brightness")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.primary)
        }
        .padding(DesignSystem.Spacing.large)
        .background(DesignSystem.Color.cardBackground, in: RoundedRectangle(
            cornerRadius: DesignSystem.CornerRadius.medium
        ))
        .brightness(brightnessAmount)
    }
}

// MARK: - State
private extension BrightnessShowcase {
    enum BrightnessState: ShowcaseState {
        case neutral
        case lightened
        case darkened
        case maxWhite
        case maxBlack

        var caption: String {
            switch self {
            case .neutral: return "amount: 0 (unchanged)"
            case .lightened: return "amount: 0.4 (lighter)"
            case .darkened: return "amount: -0.4 (darker)"
            case .maxWhite: return "amount: 1.0 (white)"
            case .maxBlack: return "amount: -1.0 (black)"
            }
        }
    }
}

// MARK: - Code generation
private extension BrightnessShowcase {
    var generatedCode: String {
        let formatted = String(format: "%.2f", amount)
        return "Image(\"photo\")\n    .brightness(\(formatted))"
    }
}
