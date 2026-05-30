import SwiftUI

struct PositionShowcase: View {
    enum PositionState: ShowcaseState {
        case center
        case topLeading
        case topTrailing
        case bottomLeading
        case bottomTrailing

        var caption: String {
            switch self {
            case .center: "Center"
            case .topLeading: "Top Leading"
            case .topTrailing: "Top Trailing"
            case .bottomLeading: "Bottom Leading"
            case .bottomTrailing: "Bottom Trailing"
            }
        }
    }

    private static let stageSize: CGFloat = 260

    @State private var posX: Double = 130
    @State private var posY: Double = 130

    var body: some View {
        ShowcaseScreen(
            title: "Position",
            summary: "Centers a view at an absolute point in the parent's coordinate space, claiming all space.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension PositionShowcase {
    var preview: some View {
        ZStack(alignment: .topLeading) {
            crosshairGrid
            positionedLabel(x: posX, y: posY, label: "Positioned")
        }
        .frame(
            width: PositionShowcase.stageSize,
            height: PositionShowcase.stageSize,
        )
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ViewBuilder var controls: some View {
        ShowcaseSlider("X position", value: $posX, in: 0...260, step: 1)
        ShowcaseSlider("Y position", value: $posY, in: 0...260, step: 1)
    }

    @ViewBuilder func stateView(_ state: PositionState) -> some View {
        let size = PositionShowcase.stageSize
        let (stateX, stateY) = coordinates(for: state, size: size)
        ZStack(alignment: .topLeading) {
            crosshairGrid
            positionedLabel(x: stateX, y: stateY, label: state.caption)
        }
        .frame(width: size, height: size)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    var crosshairGrid: some View {
        Canvas { context, size in
            let gridColor = DesignSystem.Color.separator
            let step: CGFloat = 52
            var col: CGFloat = 0
            while col <= size.width {
                var path = Path()
                path.move(to: CGPoint(x: col, y: 0))
                path.addLine(to: CGPoint(x: col, y: size.height))
                context.stroke(path, with: .color(gridColor.opacity(0.3)), lineWidth: 0.5)
                col += step
            }
            var row: CGFloat = 0
            while row <= size.height {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: row))
                path.addLine(to: CGPoint(x: size.width, y: row))
                context.stroke(path, with: .color(gridColor.opacity(0.3)), lineWidth: 0.5)
                row += step
            }
        }
    }

    func positionedLabel(x: Double, y: Double, label: String) -> some View {
        Text(label)
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(.horizontal, DesignSystem.Spacing.small)
            .padding(.vertical, DesignSystem.Spacing.xSmall)
            .background(DesignSystem.Color.accent, in: Capsule())
            .position(x: x, y: y)
    }

    func coordinates(
        for state: PositionState,
        size: CGFloat,
    ) -> (CGFloat, CGFloat) {
        let margin: CGFloat = 40
        let mid = size / 2
        switch state {
        case .center: return (mid, mid)
        case .topLeading: return (margin, margin)
        case .topTrailing: return (size - margin, margin)
        case .bottomLeading: return (margin, size - margin)
        case .bottomTrailing: return (size - margin, size - margin)
        }
    }
}

// MARK: - Code generation
private extension PositionShowcase {
    var generatedCode: String {
        """
        Text("Positioned")
            .position(x: \(Int(posX)), y: \(Int(posY)))
        """
    }
}
