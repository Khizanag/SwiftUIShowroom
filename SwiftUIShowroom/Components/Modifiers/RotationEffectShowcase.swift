import SwiftUI

struct RotationEffectShowcase: View {
    enum AnchorOption: ShowcasePickable {
        case center
        case topLeading
        case top
        case topTrailing
        case leading
        case trailing
        case bottomLeading
        case bottom
        case bottomTrailing

        var label: String {
            switch self {
            case .center: "center"
            case .topLeading: "topLeading"
            case .top: "top"
            case .topTrailing: "topTrailing"
            case .leading: "leading"
            case .trailing: "trailing"
            case .bottomLeading: "bottomLeading"
            case .bottom: "bottom"
            case .bottomTrailing: "bottomTrailing"
            }
        }

        var value: UnitPoint {
            switch self {
            case .center: .center
            case .topLeading: .topLeading
            case .top: .top
            case .topTrailing: .topTrailing
            case .leading: .leading
            case .trailing: .trailing
            case .bottomLeading: .bottomLeading
            case .bottom: .bottom
            case .bottomTrailing: .bottomTrailing
            }
        }
    }

    enum RotationState: ShowcaseState {
        case zero
        case quarter
        case half
        case threeQuarter
        case negative

        var caption: String {
            switch self {
            case .zero: "0°"
            case .quarter: "90°"
            case .half: "180°"
            case .threeQuarter: "270°"
            case .negative: "-45°"
            }
        }

        var degrees: Double {
            switch self {
            case .zero: 0
            case .quarter: 90
            case .half: 180
            case .threeQuarter: 270
            case .negative: -45
            }
        }
    }

    @State private var angleDegrees: Double = 0
    @State private var anchor: AnchorOption = .center

    var body: some View {
        ShowcaseScreen(
            title: "Rotation Effect (2D)",
            summary: "Rotates a view in 2D by an angle around an anchor point without affecting layout.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension RotationEffectShowcase {
    var preview: some View {
        Image(systemName: "arrow.up")
            .font(DesignSystem.Font.largeTitle)
            .foregroundStyle(DesignSystem.Color.accent)
            .frame(width: DesignSystem.Size.Icon.xLarge, height: DesignSystem.Size.Icon.xLarge)
            .rotationEffect(.degrees(angleDegrees), anchor: anchor.value)
            .animation(.spring, value: angleDegrees)
            .animation(.spring, value: anchor)
    }

    @ViewBuilder var controls: some View {
        ShowcaseSlider("Angle", value: $angleDegrees, in: -360...360, step: 1)
        ShowcasePicker("Anchor", selection: $anchor)
    }

    @ViewBuilder func stateView(_ state: RotationState) -> some View {
        Image(systemName: "arrow.up")
            .font(DesignSystem.Font.title2)
            .foregroundStyle(DesignSystem.Color.accent)
            .frame(width: DesignSystem.Size.Icon.large, height: DesignSystem.Size.Icon.large)
            .rotationEffect(.degrees(state.degrees), anchor: .center)
    }
}

// MARK: - Code generation
private extension RotationEffectShowcase {
    var generatedCode: String {
        let angleFormatted = angleDegrees == angleDegrees.rounded()
            ? String(Int(angleDegrees))
            : String(format: "%.1f", angleDegrees)
        return """
        Image(systemName: "arrow.up")
            .rotationEffect(.degrees(\(angleFormatted)), anchor: .\(anchor.label))
        """
    }
}
