import SwiftUI

struct ZIndexShowcase: View {
    enum LayerState: ShowcaseState {
        case behind
        case same
        case above

        var caption: String {
            switch self {
            case .behind: "Behind (−1)"
            case .same: "Default (0)"
            case .above: "On top (+1)"
            }
        }

        var zValue: Double {
            switch self {
            case .behind: -1
            case .same: 0
            case .above: 1
            }
        }
    }

    @State private var zIndexValue: Double = 0

    var body: some View {
        ShowcaseScreen(
            title: "Z-Index",
            summary: "Sets front-to-back stacking order within a parent layout; higher value draws on top.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ZIndexShowcase {
    var preview: some View {
        stackPreview(zIndex: zIndexValue)
    }

    @ViewBuilder var controls: some View {
        ShowcaseSlider("Z-Index value", value: $zIndexValue, in: -10...10, step: 1)
    }

    @ViewBuilder func stateView(_ state: LayerState) -> some View {
        stackPreview(zIndex: state.zValue)
    }

    func stackPreview(zIndex: Double) -> some View {
        ZStack {
            cardView(label: "Card A", color: DesignSystem.Color.accent)
            cardView(label: "Card B", color: .orange)
                .offset(x: 30, y: 20)
                .zIndex(zIndex)
        }
        .frame(width: 180, height: 120)
    }

    func cardView(label: String, color: Color) -> some View {
        Text(label)
            .font(DesignSystem.Font.headline)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .frame(width: 110, height: 70)
            .background(color, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Code generation
private extension ZIndexShowcase {
    var generatedCode: String {
        let formatted = zIndexValue == zIndexValue.rounded()
            ? String(Int(zIndexValue))
            : String(format: "%.1f", zIndexValue)
        return """
        ZStack {
            cardA
            cardB.zIndex(\(formatted))
        }
        """
    }
}
