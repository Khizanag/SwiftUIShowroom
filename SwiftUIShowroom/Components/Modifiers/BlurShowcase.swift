import SwiftUI

struct BlurShowcase: View {
    enum BlurState: ShowcaseState {
        case none
        case subtle
        case moderate
        case heavy

        var caption: String {
            switch self {
            case .none: "No blur (0)"
            case .subtle: "Subtle (4)"
            case .moderate: "Moderate (12)"
            case .heavy: "Heavy (30)"
            }
        }

        var blurRadius: Double {
            switch self {
            case .none: 0
            case .subtle: 4
            case .moderate: 12
            case .heavy: 30
            }
        }
    }

    @State private var radius: Double = 0
    @State private var opaque: Bool = false

    var body: some View {
        ShowcaseScreen(
            title: "Blur",
            summary: "Applies a Gaussian blur to the view's rendered content.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension BlurShowcase {
    var preview: some View {
        blurredSwatch(radius: radius, opaque: opaque)
    }

    @ViewBuilder var controls: some View {
        ShowcaseSlider("Radius", value: $radius, in: 0...30, step: 1)
        ShowcaseToggle("Opaque", isOn: $opaque)
    }

    @ViewBuilder func stateView(_ state: BlurState) -> some View {
        blurredSwatch(radius: state.blurRadius, opaque: false)
    }

    func blurredSwatch(radius: Double, opaque: Bool) -> some View {
        ZStack {
            LinearGradient(
                colors: [DesignSystem.Color.accent, .purple, .pink],
                startPoint: .topLeading,
                endPoint: .bottomTrailing,
            )
            Text("Blur")
                .font(DesignSystem.Font.title)
                .foregroundStyle(DesignSystem.Color.onAccent)
        }
        .frame(width: 200, height: 120)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        .blur(radius: radius, opaque: opaque)
    }
}

// MARK: - Code generation
private extension BlurShowcase {
    var generatedCode: String {
        let radiusStr = radius == radius.rounded()
            ? String(Int(radius))
            : String(format: "%.1f", radius)
        return """
        yourView
            .blur(radius: \(radiusStr), opaque: \(opaque))
        """
    }
}
