import Charts
import SwiftUI

struct RuleMarkShowcase: View {
    @State private var orientation: OrientationOption = .horizontal
    @State private var lineWidth: Double = 1
    @State private var dashed: Bool = true
    @State private var foregroundStyle: Color = .red
    @State private var annotationPosition: AnnotationPositionOption = .top

    var body: some View {
        ShowcaseScreen(
            title: "RuleMark",
            summary: "Draws a horizontal or vertical reference line, threshold, or interval span across the plot.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension RuleMarkShowcase {
    var preview: some View {
        Chart {
            ForEach(SampleData.bars, id: \.category) { item in
                BarMark(
                    x: .value("Category", item.category),
                    y: .value("Value", item.value)
                )
                .foregroundStyle(DesignSystem.Color.accent)
            }
            ruleMarkContent(
                orientation: orientation,
                lineWidth: lineWidth,
                dashed: dashed,
                color: foregroundStyle,
                annotationPosition: annotationPosition.annotationPosition
            )
        }
        .frame(height: 220)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Orientation", selection: $orientation)
        ShowcaseSlider("Line width", value: $lineWidth, in: 0.5...6, step: 0.5)
        ShowcaseToggle("Dashed", isOn: $dashed)
        ShowcaseColorControl("Color", selection: $foregroundStyle)
        ShowcasePicker("Annotation position", selection: $annotationPosition)
    }

    @ViewBuilder func stateView(_ state: RuleMarkState) -> some View {
        Chart {
            ForEach(SampleData.bars, id: \.category) { item in
                BarMark(
                    x: .value("Category", item.category),
                    y: .value("Value", item.value)
                )
                .foregroundStyle(DesignSystem.Color.accent)
            }
            ruleMarkContent(
                orientation: state.orientation,
                lineWidth: state.lineWidth,
                dashed: state.dashed,
                color: state.color,
                annotationPosition: .top
            )
        }
        .frame(height: 160)
    }

    @ChartContentBuilder
    func ruleMarkContent(
        orientation: OrientationOption,
        lineWidth: Double,
        dashed: Bool,
        color: Color,
        annotationPosition: AnnotationPosition
    ) -> some ChartContent {
        let dash: [CGFloat] = dashed ? [4, 4] : []
        let stroke = StrokeStyle(lineWidth: lineWidth, dash: dash)
        switch orientation {
        case .horizontal:
            RuleMark(y: .value("Threshold", SampleData.threshold))
                .lineStyle(stroke)
                .foregroundStyle(color)
                .annotation(position: annotationPosition, alignment: .leading) {
                    Text("Goal")
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(color)
                }
        case .vertical:
            RuleMark(x: .value("Marker", SampleData.verticalMarker))
                .lineStyle(stroke)
                .foregroundStyle(color)
                .annotation(position: annotationPosition, alignment: .leading) {
                    Text("Now")
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(color)
                }
        }
    }
}

// MARK: - Code generation
private extension RuleMarkShowcase {
    var generatedCode: String {
        let dashPart = dashed ? "[4, 4]" : "[]"
        let posLabel = annotationPosition.label
        let colorCode = foregroundStyle == .red ? ".red" : "Color(/* configured */)"
        let axis = orientation == .horizontal ? "y" : "x"
        let axisLabel = orientation == .horizontal ? "Threshold" : "Marker"
        return """
        RuleMark(
            \(axis): .value("\(axisLabel)", threshold)
        )
        .lineStyle(StrokeStyle(lineWidth: \(Int(lineWidth)), dash: \(dashPart)))
        .foregroundStyle(\(colorCode))
        .annotation(position: .\(posLabel), alignment: .leading) {
            Text("Goal")
                .font(.caption2)
                .foregroundStyle(\(colorCode))
        }
        """
    }
}

// MARK: - Nested enums
private extension RuleMarkShowcase {
    enum OrientationOption: ShowcasePickable {
        case horizontal, vertical

        var label: String {
            switch self {
            case .horizontal: "horizontal"
            case .vertical: "vertical"
            }
        }
    }

    enum AnnotationPositionOption: ShowcasePickable {
        case automatic, top, topLeading, topTrailing, leading, trailing

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .top: "top"
            case .topLeading: "topLeading"
            case .topTrailing: "topTrailing"
            case .leading: "leading"
            case .trailing: "trailing"
            }
        }

        var annotationPosition: AnnotationPosition {
            switch self {
            case .automatic: .automatic
            case .top: .top
            case .topLeading: .topLeading
            case .topTrailing: .topTrailing
            case .leading: .leading
            case .trailing: .trailing
            }
        }
    }

    enum RuleMarkState: ShowcaseState {
        case solidHorizontal, dashedHorizontal, vertical, colored

        var caption: String {
            switch self {
            case .solidHorizontal: "Solid horizontal"
            case .dashedHorizontal: "Dashed horizontal"
            case .vertical: "Vertical marker"
            case .colored: "Custom color"
            }
        }

        var orientation: OrientationOption {
            switch self {
            case .solidHorizontal, .dashedHorizontal, .colored: .horizontal
            case .vertical: .vertical
            }
        }

        var lineWidth: Double {
            switch self {
            case .solidHorizontal: 2
            case .dashedHorizontal: 1
            case .vertical: 1.5
            case .colored: 2
            }
        }

        var dashed: Bool {
            switch self {
            case .solidHorizontal: false
            case .dashedHorizontal: true
            case .vertical: true
            case .colored: false
            }
        }

        var color: Color {
            switch self {
            case .solidHorizontal: .secondary
            case .dashedHorizontal: .red
            case .vertical: .blue
            case .colored: .orange
            }
        }
    }
}

// MARK: - Sample data
private enum SampleData {
    struct Bar {
        let category: String
        let value: Double
    }

    static let threshold: Double = 65
    static let verticalMarker: String = "C"

    static let bars: [Bar] = [
        Bar(category: "A", value: 40),
        Bar(category: "B", value: 80),
        Bar(category: "C", value: 55),
        Bar(category: "D", value: 90),
        Bar(category: "E", value: 30),
    ]
}
