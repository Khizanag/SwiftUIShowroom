import SwiftUI

struct Rotation3dEffectShowcase: View {
    @State private var angleDegrees: Double = 0
    @State private var axisOption: AxisOption = .yAxis
    @State private var anchorOption: AnchorOption = .center
    @State private var anchorZ: Double = 0
    @State private var perspective: Double = 1

    var body: some View {
        ShowcaseScreen(
            title: "Rotation 3D Effect",
            summary: "Rotates a view in 3D around an arbitrary axis with optional perspective foreshortening.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension Rotation3dEffectShowcase {
    fileprivate enum AxisOption: ShowcasePickable {
        case xAxis
        case yAxis
        case zAxis

        var label: String {
            switch self {
            case .xAxis: "(1, 0, 0)"
            case .yAxis: "(0, 1, 0)"
            case .zAxis: "(0, 0, 1)"
            }
        }

        var axisCodeLabel: String {
            switch self {
            case .xAxis: "x: 1, y: 0, z: 0"
            case .yAxis: "x: 0, y: 1, z: 0"
            case .zAxis: "x: 0, y: 0, z: 1"
            }
        }

        var tuple: (x: CGFloat, y: CGFloat, z: CGFloat) {
            switch self {
            case .xAxis: (x: 1, y: 0, z: 0)
            case .yAxis: (x: 0, y: 1, z: 0)
            case .zAxis: (x: 0, y: 0, z: 1)
            }
        }
    }

    fileprivate enum AnchorOption: ShowcasePickable {
        case center
        case leading
        case trailing
        case top
        case bottom

        var label: String {
            switch self {
            case .center: "center"
            case .leading: "leading"
            case .trailing: "trailing"
            case .top: "top"
            case .bottom: "bottom"
            }
        }

        var value: UnitPoint {
            switch self {
            case .center: .center
            case .leading: .leading
            case .trailing: .trailing
            case .top: .top
            case .bottom: .bottom
            }
        }
    }

    fileprivate enum CardState: ShowcaseState {
        case flat
        case selected

        var caption: String {
            switch self {
            case .flat: "Default (0°)"
            case .selected: "Flipped (60°)"
            }
        }

        var degrees: Double {
            switch self {
            case .flat: 0
            case .selected: 60
            }
        }
    }
}

// MARK: - Sub-views
private extension Rotation3dEffectShowcase {
    var preview: some View {
        cardView
            .rotation3DEffect(
                .degrees(angleDegrees),
                axis: axisOption.tuple,
                anchor: anchorOption.value,
                anchorZ: anchorZ,
                perspective: perspective,
            )
            .animation(.spring, value: angleDegrees)
            .animation(.spring, value: axisOption)
            .animation(.spring, value: anchorOption)
    }

    var cardView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .fill(DesignSystem.Color.accent)
            VStack(spacing: DesignSystem.Spacing.xSmall) {
                Image(systemName: "creditcard.fill")
                    .font(DesignSystem.Font.title)
                    .foregroundStyle(DesignSystem.Color.onAccent)
                Text("Card")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.onAccent)
            }
        }
        .frame(width: 160, height: 100)
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseSlider("Angle", value: $angleDegrees, in: -180...180, step: 1)
        ShowcasePicker("Axis", selection: $axisOption)
        ShowcasePicker("Anchor", selection: $anchorOption)
        ShowcaseSlider("Anchor Z", value: $anchorZ, in: -100...100, step: 1)
        ShowcaseSlider("Perspective", value: $perspective, in: 0...2, step: 0.05)
    }

    @ViewBuilder
    func stateView(_ state: CardState) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(DesignSystem.Color.accent)
            VStack(spacing: DesignSystem.Spacing.xSmall) {
                Image(systemName: "creditcard.fill")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.onAccent)
                Text("Card")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.onAccent)
            }
        }
        .frame(width: 110, height: 70)
        .rotation3DEffect(
            .degrees(state.degrees),
            axis: (x: 0, y: 1, z: 0),
            anchor: .center,
            anchorZ: 0,
            perspective: 1,
        )
    }
}

// MARK: - Code generation
private extension Rotation3dEffectShowcase {
    var generatedCode: String {
        let angleFormatted = angleDegrees == angleDegrees.rounded()
            ? String(Int(angleDegrees))
            : String(format: "%.1f", angleDegrees)
        let anchorZFormatted = anchorZ == anchorZ.rounded()
            ? String(Int(anchorZ))
            : String(format: "%.1f", anchorZ)
        let perspectiveFormatted = String(format: "%.2f", perspective)
        return """
        CardView()
            .rotation3DEffect(
                .degrees(\(angleFormatted)),
                axis: (\(axisOption.axisCodeLabel)),
                anchor: .\(anchorOption.label),
                anchorZ: \(anchorZFormatted),
                perspective: \(perspectiveFormatted)
            )
        """
    }
}
