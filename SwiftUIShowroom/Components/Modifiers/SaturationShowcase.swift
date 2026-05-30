import SwiftUI

struct SaturationShowcase: View {
    enum SaturationState: ShowcaseState {
        case grayscale
        case reduced
        case normal
        case boosted
        case vivid

        var caption: String {
            switch self {
            case .grayscale: "Grayscale (0)"
            case .reduced: "Reduced (0.5)"
            case .normal: "Normal (1)"
            case .boosted: "Boosted (1.5)"
            case .vivid: "Vivid (2)"
            }
        }

        var amount: Double {
            switch self {
            case .grayscale: 0
            case .reduced: 0.5
            case .normal: 1
            case .boosted: 1.5
            case .vivid: 2
            }
        }
    }

    @State private var amount: Double = 1.0

    var body: some View {
        ShowcaseScreen(
            title: "Saturation",
            summary: "Adjusts color intensity; 0 produces grayscale, values above 1 oversaturate.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension SaturationShowcase {
    var preview: some View {
        sampleCard(amount: amount)
    }

    @ViewBuilder var controls: some View {
        ShowcaseSlider("Amount", value: $amount, in: 0...2, step: 0.01)
    }

    @ViewBuilder func stateView(_ state: SaturationState) -> some View {
        sampleCard(amount: state.amount)
    }

    func sampleCard(amount: Double) -> some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: "photo.fill")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .pink, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing,
                    ),
                )
                .frame(
                    width: DesignSystem.Size.Icon.xLarge,
                    height: DesignSystem.Size.Icon.xLarge,
                )
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                Text("Color Sample")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.primary)
                Text("Saturation: \(String(format: "%.2f", amount))")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium),
        )
        .saturation(amount)
    }
}

// MARK: - Code generation
private extension SaturationShowcase {
    var generatedCode: String {
        let isWhole = amount == amount.rounded(.toNearestOrAwayFromZero)
        let formatted = isWhole
            ? String(format: "%.1f", amount)
            : String(format: "%.2f", amount)
        return "Image(\"photo\")\n    .saturation(\(formatted))"
    }
}
