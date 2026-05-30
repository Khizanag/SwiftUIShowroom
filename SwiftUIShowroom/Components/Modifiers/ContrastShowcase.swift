import SwiftUI

struct ContrastShowcase: View {
    @State private var amount: Double = 1.0

    var body: some View {
        ShowcaseScreen(
            title: "Contrast",
            summary: "Multiplies the color separation from gray, increasing (>1) or decreasing (<1) contrast.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ContrastShowcase {
    var preview: some View {
        swatch(amount: amount)
    }

    @ViewBuilder var controls: some View {
        ShowcaseSlider("Amount", value: $amount, in: 0...3, step: 0.01)
    }

    @ViewBuilder func stateView(_ state: ContrastState) -> some View {
        switch state {
        case .flat:
            swatch(amount: 0.0)
        case .normal:
            swatch(amount: 1.0)
        case .boosted:
            swatch(amount: 2.0)
        case .inverted:
            swatch(amount: -1.0)
        }
    }

    func swatch(amount contrastAmount: Double) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            HStack(spacing: DesignSystem.Spacing.xSmall) {
                Circle()
                    .fill(DesignSystem.Color.accent)
                    .frame(
                        width: DesignSystem.Size.Icon.medium,
                        height: DesignSystem.Size.Icon.medium,
                    )
                Circle()
                    .fill(Color.orange)
                    .frame(
                        width: DesignSystem.Size.Icon.medium,
                        height: DesignSystem.Size.Icon.medium,
                    )
                Circle()
                    .fill(Color.green)
                    .frame(
                        width: DesignSystem.Size.Icon.medium,
                        height: DesignSystem.Size.Icon.medium,
                    )
            }
            Text("Contrast")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.primary)
        }
        .padding(DesignSystem.Spacing.large)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium),
        )
        .contrast(contrastAmount)
    }
}

// MARK: - State enum
extension ContrastShowcase {
    fileprivate enum ContrastState: ShowcaseState {
        case flat
        case normal
        case boosted
        case inverted

        var caption: String {
            switch self {
            case .flat: return "Flat (0)"
            case .normal: return "Normal (1)"
            case .boosted: return "Boosted (2)"
            case .inverted: return "Inverted (-1)"
            }
        }
    }
}

// MARK: - Code generation
private extension ContrastShowcase {
    var generatedCode: String {
        let formatted = String(format: "%.2f", amount)
        return "Image(\"photo\")\n    .contrast(\(formatted))"
    }
}
