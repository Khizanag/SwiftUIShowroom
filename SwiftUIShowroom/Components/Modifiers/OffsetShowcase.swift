import SwiftUI

struct OffsetShowcase: View {
    enum OffsetDirection: ShowcaseState {
        case none
        case right
        case down
        case diagonal

        var caption: String {
            switch self {
            case .none: "No offset"
            case .right: "Right (+x)"
            case .down: "Down (+y)"
            case .diagonal: "Diagonal"
            }
        }

        var xValue: CGFloat {
            switch self {
            case .none: 0
            case .right: 40
            case .down: 0
            case .diagonal: 30
            }
        }

        var yValue: CGFloat {
            switch self {
            case .none: 0
            case .right: 0
            case .down: 40
            case .diagonal: 30
            }
        }
    }

    @State private var offsetX: Double = 0
    @State private var offsetY: Double = 0

    var body: some View {
        ShowcaseScreen(
            title: "Offset",
            summary: "Shifts the rendered position without affecting layout footprint.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}
// MARK: - Sub-views
private extension OffsetShowcase {
    var preview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .strokeBorder(DesignSystem.Color.separator, lineWidth: 1)
                .frame(width: 120, height: 48)

            Text("Offset")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .padding(.horizontal, DesignSystem.Spacing.medium)
                .padding(.vertical, DesignSystem.Spacing.small)
                .background(
                    DesignSystem.Color.accent,
                    in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium),
                )
                .offset(x: offsetX, y: offsetY)
        }
        .frame(height: 160)
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseSlider("X offset", value: $offsetX, in: -100...100, step: 1)
        ShowcaseSlider("Y offset", value: $offsetY, in: -100...100, step: 1)
    }

    @ViewBuilder
    func stateView(_ state: OffsetDirection) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .strokeBorder(DesignSystem.Color.separator, lineWidth: 1)
                .frame(width: 80, height: 36)

            Text("View")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .padding(.horizontal, DesignSystem.Spacing.small)
                .padding(.vertical, DesignSystem.Spacing.xSmall)
                .background(
                    DesignSystem.Color.accent,
                    in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small),
                )
                .offset(x: state.xValue, y: state.yValue)
        }
        .frame(width: 100, height: 80)
    }
}
// MARK: - Code generation
private extension OffsetShowcase {
    var generatedCode: String {
        let xFormatted = formatted(offsetX)
        let yFormatted = formatted(offsetY)
        return """
        Text("Offset")
            .offset(x: \(xFormatted), y: \(yFormatted))
        """
    }

    func formatted(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(format: "%.1f", value)
    }
}
