import SwiftUI

struct ScaleEffectShowcase: View {
    @State private var scaleX: Double = 1.0
    @State private var scaleY: Double = 1.0
    @State private var anchor: AnchorOption = .center

    var body: some View {
        ShowcaseScreen(
            title: "Scale Effect",
            summary: "Scales a view by x/y factors around an anchor, without affecting its layout footprint.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension ScaleEffectShowcase {
    fileprivate enum AnchorOption: ShowcasePickable {
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

        var unitPoint: UnitPoint {
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

    fileprivate enum ScaleState: ShowcaseState {
        case normal
        case selected
        case enlarged
        case mirrored

        var caption: String {
            switch self {
            case .normal: "Default (1×)"
            case .selected: "Selected (1.25×)"
            case .enlarged: "Enlarged (2×)"
            case .mirrored: "Mirrored (x: -1)"
            }
        }

        var xFactor: CGFloat {
            switch self {
            case .normal: 1.0
            case .selected: 1.25
            case .enlarged: 2.0
            case .mirrored: -1.0
            }
        }

        var yFactor: CGFloat {
            switch self {
            case .normal: 1.0
            case .selected: 1.25
            case .enlarged: 2.0
            case .mirrored: 1.0
            }
        }
    }
}

// MARK: - Sub-views
private extension ScaleEffectShowcase {
    var preview: some View {
        Image(systemName: "heart.fill")
            .font(DesignSystem.Font.largeTitle)
            .foregroundStyle(DesignSystem.Color.accent)
            .scaleEffect(x: scaleX, y: scaleY, anchor: anchor.unitPoint)
            .frame(width: 120, height: 120)
    }

    @ViewBuilder var controls: some View {
        ShowcaseSlider("Scale X", value: $scaleX, in: 0...3, step: 0.05)
        ShowcaseSlider("Scale Y", value: $scaleY, in: 0...3, step: 0.05)
        ShowcasePicker("Anchor", selection: $anchor)
    }

    @ViewBuilder func stateView(_ state: ScaleState) -> some View {
        Image(systemName: "heart.fill")
            .font(DesignSystem.Font.title)
            .foregroundStyle(DesignSystem.Color.accent)
            .scaleEffect(x: state.xFactor, y: state.yFactor, anchor: .center)
            .frame(width: 80, height: 80)
    }
}

// MARK: - Code generation
private extension ScaleEffectShowcase {
    var generatedCode: String {
        let xStr = formatScale(scaleX)
        let yStr = formatScale(scaleY)
        return """
        Image(systemName: "heart.fill")
            .scaleEffect(x: \(xStr), y: \(yStr), anchor: .\(anchor.label))
        """
    }

    func formatScale(_ value: Double) -> String {
        if value == value.rounded() {
            return String(format: "%.1f", value)
        }
        return String(format: "%.2f", value)
    }
}
