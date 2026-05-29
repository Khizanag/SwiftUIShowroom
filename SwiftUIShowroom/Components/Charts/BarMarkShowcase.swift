import Charts
import SwiftUI

struct BarMarkShowcase: View {
    @State private var orientation: OrientationOption = .vertical
    @State private var stacking: StackingOption = .standard
    @State private var barWidth: BarWidthOption = .automatic
    @State private var cornerRadius: Double = 0
    @State private var barColor: Color = .accentColor
    @State private var groupByCategory: Bool = false
    @State private var opacity: Double = 1.0
    @State private var annotationPosition: AnnotationOption = .automatic

    var body: some View {
        ShowcaseScreen(
            title: "BarMark",
            summary: "Rectangular bars for category comparison; supports stacked, grouped, and horizontal.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension BarMarkShowcase {
    var preview: some View {
        Group {
            if orientation == .vertical {
                verticalChart
            } else {
                horizontalChart
            }
        }
        .frame(height: 220)
        .padding(DesignSystem.Spacing.small)
    }

    var verticalChart: some View {
        Chart(SampleItem.defaultData) { item in
            if groupByCategory {
                BarMark(
                    x: .value("Category", item.category),
                    y: .value("Value", item.value),
                    width: barWidth.dimension,
                    stacking: stacking.method
                )
                .cornerRadius(cornerRadius)
                .foregroundStyle(by: .value("Group", item.group))
                .opacity(opacity)
                .annotation(position: annotationPosition.position) {
                    valueAnnotation(item.value)
                }
            } else {
                BarMark(
                    x: .value("Category", item.category),
                    y: .value("Value", item.value),
                    width: barWidth.dimension,
                    stacking: stacking.method
                )
                .cornerRadius(cornerRadius)
                .foregroundStyle(barColor)
                .opacity(opacity)
                .annotation(position: annotationPosition.position) {
                    valueAnnotation(item.value)
                }
            }
        }
    }

    var horizontalChart: some View {
        Chart(SampleItem.defaultData) { item in
            if groupByCategory {
                BarMark(
                    x: .value("Value", item.value),
                    y: .value("Category", item.category),
                    height: barWidth.dimension,
                    stacking: stacking.method
                )
                .cornerRadius(cornerRadius)
                .foregroundStyle(by: .value("Group", item.group))
                .opacity(opacity)
                .annotation(position: annotationPosition.position) {
                    valueAnnotation(item.value)
                }
            } else {
                BarMark(
                    x: .value("Value", item.value),
                    y: .value("Category", item.category),
                    height: barWidth.dimension,
                    stacking: stacking.method
                )
                .cornerRadius(cornerRadius)
                .foregroundStyle(barColor)
                .opacity(opacity)
                .annotation(position: annotationPosition.position) {
                    valueAnnotation(item.value)
                }
            }
        }
    }

    @ViewBuilder
    func valueAnnotation(_ value: Int) -> some View {
        if annotationPosition != .automatic {
            Text("\(value)")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Orientation", selection: $orientation)
        ShowcasePicker("Stacking", selection: $stacking)
        ShowcasePicker("Bar width", selection: $barWidth)
        ShowcaseSlider("Corner radius", value: $cornerRadius, in: 0...20, step: 1)
        ShowcaseColorControl("Color", selection: $barColor, supportsOpacity: false)
        ShowcaseToggle("Group by category", isOn: $groupByCategory)
        ShowcaseSlider("Opacity", value: $opacity, in: 0...1, step: 0.05)
        ShowcasePicker("Annotation position", selection: $annotationPosition)
    }

    @ViewBuilder
    func stateView(_ state: BarMarkState) -> some View {
        if state.data.isEmpty {
            ContentUnavailableView("No data", systemImage: "chart.bar")
                .frame(height: 120)
        } else {
            Chart(state.data) { item in
                BarMark(
                    x: .value("Category", item.category),
                    y: .value("Value", item.value)
                )
                .cornerRadius(4)
                .foregroundStyle(state == .selected ? Color.orange : Color.accentColor)
                .opacity(state == .selected ? 1.0 : 0.85)
            }
            .frame(height: 120)
            .padding(DesignSystem.Spacing.xSmall)
        }
    }
}

// MARK: - Code generation
private extension BarMarkShowcase {
    var generatedCode: String {
        var lines: [String] = []
        if orientation == .vertical {
            let widthArg = barWidth == .automatic ? "" : ",\n    width: \(barWidth.codeValue)"
            lines.append("BarMark(")
            lines.append("    x: .value(\"Category\", item.category),")
            lines.append("    y: .value(\"Value\", item.value)\(widthArg),")
            lines.append("    stacking: \(stacking.codeValue)")
            lines.append(")")
        } else {
            let heightArg = barWidth == .automatic ? "" : ",\n    height: \(barWidth.codeValue)"
            lines.append("BarMark(")
            lines.append("    x: .value(\"Value\", item.value),")
            lines.append("    y: .value(\"Category\", item.category)\(heightArg),")
            lines.append("    stacking: \(stacking.codeValue)")
            lines.append(")")
        }
        lines.append(".cornerRadius(\(Int(cornerRadius)))")
        if groupByCategory {
            lines.append(".foregroundStyle(by: .value(\"Group\", item.group))")
        } else {
            lines.append(".foregroundStyle(\(colorCode))")
        }
        lines.append(".opacity(\(opacity.formatted(.number.precision(.fractionLength(0...2)))))")
        if annotationPosition != .automatic {
            lines.append(".annotation(position: \(annotationPosition.codeValue)) {")
            lines.append("    Text(\"\\(item.value, format: .number)\")")
            lines.append("        .font(.caption2)")
            lines.append("}")
        }
        return lines.joined(separator: "\n")
    }

    var colorCode: String {
        barColor == .accentColor ? ".accentColor" : "Color(/* configured */)"
    }
}

// MARK: - Nested types
private extension BarMarkShowcase {
    enum OrientationOption: ShowcasePickable {
        case vertical, horizontal

        var label: String {
            switch self {
            case .vertical: "vertical"
            case .horizontal: "horizontal"
            }
        }
    }

    enum StackingOption: ShowcasePickable {
        case standard, normalized, center, unstacked

        var label: String {
            switch self {
            case .standard: "standard"
            case .normalized: "normalized"
            case .center: "center"
            case .unstacked: "unstacked"
            }
        }

        var method: MarkStackingMethod {
            switch self {
            case .standard: .standard
            case .normalized: .normalized
            case .center: .center
            case .unstacked: .unstacked
            }
        }

        var codeValue: String { ".\(label)" }
    }

    enum BarWidthOption: ShowcasePickable {
        case automatic, ratio, fixed, inset

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .ratio: "ratio(0.6)"
            case .fixed: "fixed(20)"
            case .inset: "inset(4)"
            }
        }

        var dimension: MarkDimension {
            switch self {
            case .automatic: .automatic
            case .ratio: .ratio(0.6)
            case .fixed: .fixed(20)
            case .inset: .inset(4)
            }
        }

        var codeValue: String {
            switch self {
            case .automatic: ".automatic"
            case .ratio: ".ratio(0.6)"
            case .fixed: ".fixed(20)"
            case .inset: ".inset(4)"
            }
        }
    }

    enum AnnotationOption: ShowcasePickable {
        case automatic, overlay, top, bottom, leading, trailing

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .overlay: "overlay"
            case .top: "top"
            case .bottom: "bottom"
            case .leading: "leading"
            case .trailing: "trailing"
            }
        }

        var position: AnnotationPosition {
            switch self {
            case .automatic: .automatic
            case .overlay: .overlay
            case .top: .top
            case .bottom: .bottom
            case .leading: .leading
            case .trailing: .trailing
            }
        }

        var codeValue: String { ".\(label)" }
    }

    enum BarMarkState: ShowcaseState {
        case `default`, selected, empty, longContent

        var caption: String {
            switch self {
            case .default: "Default"
            case .selected: "Selected (highlighted)"
            case .empty: "Empty"
            case .longContent: "Many bars"
            }
        }

        var data: [SampleItem] {
            switch self {
            case .default, .selected: return SampleItem.defaultData
            case .empty: return []
            case .longContent: return SampleItem.longData
            }
        }
    }

    struct SampleItem: Identifiable {
        let id = UUID()
        let category: String
        let value: Int
        let group: String

        static let defaultData: [SampleItem] = [
            SampleItem(category: "Mon", value: 42, group: "A"),
            SampleItem(category: "Tue", value: 78, group: "B"),
            SampleItem(category: "Wed", value: 55, group: "A"),
            SampleItem(category: "Thu", value: 91, group: "B"),
            SampleItem(category: "Fri", value: 63, group: "A"),
        ]

        static let longData: [SampleItem] = [
            SampleItem(category: "W1", value: 30, group: "A"),
            SampleItem(category: "W2", value: 55, group: "B"),
            SampleItem(category: "W3", value: 70, group: "A"),
            SampleItem(category: "W4", value: 45, group: "B"),
            SampleItem(category: "W5", value: 88, group: "A"),
            SampleItem(category: "W6", value: 62, group: "B"),
            SampleItem(category: "W7", value: 95, group: "A"),
            SampleItem(category: "W8", value: 51, group: "B"),
        ]
    }
}
