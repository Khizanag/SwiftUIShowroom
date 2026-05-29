import Charts
import SwiftUI

struct ChartSelectionShowcase: View {
    @State private var selectionAxis: SelectionAxisOption = .axisX
    @State private var selectionMode: SelectionModeOption = .value
    @State private var scrollableAxes: ScrollableAxesOption = .horizontal
    @State private var visibleDomainLength: Int = 30
    @State private var annotationOverflow: AnnotationOverflowOption = .automatic
    @State private var selectedIndex: Int?

    var body: some View {
        ShowcaseScreen(
            title: "Chart Selection",
            summary: "Adds tap/drag value selection on an axis, surfacing a binding for RuleMark annotations.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ChartSelectionShowcase {
    var preview: some View {
        selectionChart(
            data: SampleData.items,
            selectedIndex: $selectedIndex,
            config: SelectionConfig(
                selectionAxis: selectionAxis,
                scrollableAxes: scrollableAxes,
                visibleDomainLength: visibleDomainLength,
                annotationOverflow: annotationOverflow
            )
        )
        .frame(height: 220)
        .padding(DesignSystem.Spacing.small)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Selection axis", selection: $selectionAxis)
        ShowcasePicker("Selection mode", selection: $selectionMode)
        ShowcasePicker("Scrollable axes", selection: $scrollableAxes)
        ShowcaseStepper("Visible domain length", value: $visibleDomainLength, in: 5...100)
        ShowcasePicker("Annotation overflow", selection: $annotationOverflow)
    }

    @ViewBuilder func stateView(_ state: ChartSelectionState) -> some View {
        switch state {
        case .default:
            baseChart(data: SampleData.items, highlightedIndex: nil)
                .frame(height: 140)
        case .selected:
            selectedStateChart
                .frame(height: 140)
        case .focused:
            focusedStateChart
                .frame(height: 140)
        }
    }

    @ViewBuilder var selectedStateChart: some View {
        if #available(iOS 17, macOS 14, tvOS 17, *) {
            SelectionChartView(data: SampleData.items)
        } else {
            baseChart(data: SampleData.items, highlightedIndex: 2)
        }
    }

    var focusedStateChart: some View {
        Chart(SampleData.items) { item in
            BarMark(
                x: .value("Day", item.day),
                y: .value("Value", item.value)
            )
            .foregroundStyle(DesignSystem.Color.accent.opacity(0.5))
        }
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: 5)
    }
}

// MARK: - Chart builders
private extension ChartSelectionShowcase {
    func baseChart(data: [SampleData.Item], highlightedIndex: Int?) -> some View {
        Chart(data) { item in
            BarMark(
                x: .value("Day", item.day),
                y: .value("Value", item.value)
            )
            .foregroundStyle(
                highlightedIndex == item.index
                    ? DesignSystem.Color.accent
                    : DesignSystem.Color.accent.opacity(0.4)
            )
        }
    }

    @ViewBuilder
    func selectionChart(
        data: [SampleData.Item],
        selectedIndex: Binding<Int?>,
        config: SelectionConfig
    ) -> some View {
        if #available(iOS 17, macOS 14, tvOS 17, *) {
            ConfiguredSelectionChart(
                data: data,
                selectedIndex: selectedIndex,
                config: config
            )
        } else {
            baseChart(data: data, highlightedIndex: selectedIndex.wrappedValue)
        }
    }
}

// MARK: - Code generation
private extension ChartSelectionShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("Chart {")
        lines.append("    ForEach(data) { item in")
        lines.append("        BarMark(x: .value(\"Day\", item.day), y: .value(\"Value\", item.value))")
        lines.append("            .foregroundStyle(")
        lines.append("                item.index == selectedIndex ? Color.accentColor : Color.gray")
        lines.append("            )")
        lines.append("    }")
        lines.append("    if let selectedIndex {")
        lines.append("        RuleMark(x: .value(\"Selected\", data[selectedIndex].day))")
        lines.append("            .annotation(")
        lines.append(
            "                position: .top,"
        )
        lines.append(
            "                overflowResolution: .init(x: \(annotationOverflow.codeValue), y: .fit)"
        )
        lines.append("            ) {")
        lines.append("                Text(\"\\(data[selectedIndex].value)\")")
        lines.append("            }")
        lines.append("    }")
        lines.append("}")
        switch selectionAxis {
        case .axisX:
            lines.append(".chartXSelection(value: $selectedIndex)")
        case .axisY:
            lines.append(".chartYSelection(value: $selectedIndex)")
        case .axisXY:
            lines.append(".chartXSelection(value: $selectedIndex)")
            lines.append(".chartYSelection(value: $selectedIndex)")
        }
        if scrollableAxes != .none {
            lines.append(".chartScrollableAxes(\(scrollableAxes.codeValue))")
            lines.append(".chartXVisibleDomain(length: \(visibleDomainLength))")
        }
        return lines.joined(separator: "\n")
    }
}

// MARK: - Availability-gated views
@available(iOS 17, macOS 14, tvOS 17, *)
private struct SelectionChartView: View {
    let data: [SampleData.Item]
    @State private var selectedIndex: Int? = 2

    var body: some View {
        Chart(data) { item in
            BarMark(
                x: .value("Day", item.day),
                y: .value("Value", item.value)
            )
            .foregroundStyle(
                selectedIndex == item.index
                    ? DesignSystem.Color.accent
                    : DesignSystem.Color.accent.opacity(0.4)
            )
            if let sel = selectedIndex, data.indices.contains(sel) {
                RuleMark(x: .value("Selected", data[sel].day))
                    .annotation(
                        position: .top,
                        overflowResolution: .init(x: .fit, y: .fit)
                    ) {
                        Text("\(data[sel].value)")
                            .font(DesignSystem.Font.caption2)
                            .padding(DesignSystem.Spacing.xSmall)
                            .background(DesignSystem.Color.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
                    }
            }
        }
        .chartXSelection(value: $selectedIndex)
    }
}

@available(iOS 17, macOS 14, tvOS 17, *)
private struct ConfiguredSelectionChart: View {
    let data: [SampleData.Item]
    let selectedIndex: Binding<Int?>
    let config: ChartSelectionShowcase.SelectionConfig

    var body: some View {
        chartBody
            .applyScrollable(config.scrollableAxes, domainLength: config.visibleDomainLength)
    }

    @ViewBuilder
    private var chartBody: some View {
        switch config.selectionAxis {
        case .axisX:
            baseChart.chartXSelection(value: selectedIndex)
        case .axisY:
#if !os(tvOS)
            baseChart.chartYSelection(value: selectedIndex)
#else
            baseChart.chartXSelection(value: selectedIndex)
#endif
        case .axisXY:
#if !os(tvOS)
            baseChart
                .chartXSelection(value: selectedIndex)
                .chartYSelection(value: selectedIndex)
#else
            baseChart.chartXSelection(value: selectedIndex)
#endif
        }
    }

    private var baseChart: some View {
        Chart(data) { item in
            BarMark(
                x: .value("Day", item.day),
                y: .value("Value", item.value)
            )
            .foregroundStyle(
                selectedIndex.wrappedValue == item.index
                    ? DesignSystem.Color.accent
                    : DesignSystem.Color.accent.opacity(0.4)
            )
            if let sel = selectedIndex.wrappedValue, data.indices.contains(sel) {
                RuleMark(x: .value("Selected", data[sel].day))
                    .annotation(
                        position: .top,
                        overflowResolution: config.annotationOverflow.resolution
                    ) {
                        Text("\(data[sel].value)")
                            .font(DesignSystem.Font.caption2)
                            .padding(DesignSystem.Spacing.xSmall)
                            .background(DesignSystem.Color.cardBackground)
                            .clipShape(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                            )
                    }
            }
        }
    }
}

// MARK: - Nested enums
extension ChartSelectionShowcase {
    struct SelectionConfig {
        let selectionAxis: SelectionAxisOption
        let scrollableAxes: ScrollableAxesOption
        let visibleDomainLength: Int
        let annotationOverflow: AnnotationOverflowOption
    }

    enum SelectionAxisOption: ShowcasePickable {
        case axisX, axisY, axisXY

        var label: String {
            switch self {
            case .axisX: "X axis"
            case .axisY: "Y axis"
            case .axisXY: "XY axes"
            }
        }
    }

    enum SelectionModeOption: ShowcasePickable {
        case value, range

        var label: String {
            switch self {
            case .value: "value"
            case .range: "range"
            }
        }
    }

    enum ScrollableAxesOption: ShowcasePickable {
        case none, horizontal, vertical

        var label: String {
            switch self {
            case .none: "none"
            case .horizontal: "horizontal"
            case .vertical: "vertical"
            }
        }

        var codeValue: String {
            switch self {
            case .none: "[]"
            case .horizontal: ".horizontal"
            case .vertical: ".vertical"
            }
        }
    }

    enum AnnotationOverflowOption: ShowcasePickable {
        case automatic, fit, padScale, disabled

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .fit: "fit"
            case .padScale: "padScale"
            case .disabled: "disabled"
            }
        }

        var codeValue: String {
            switch self {
            case .automatic: ".automatic"
            case .fit: ".fit"
            case .padScale: ".padScale"
            case .disabled: ".disabled"
            }
        }

        @available(iOS 17, macOS 14, tvOS 17, *)
        var resolution: AnnotationOverflowResolution {
            switch self {
            case .automatic: .init(x: .automatic, y: .fit)
            case .fit: .init(x: .fit, y: .fit)
            case .padScale: .init(x: .padScale, y: .fit)
            case .disabled: .init(x: .disabled, y: .fit)
            }
        }
    }

    enum ChartSelectionState: ShowcaseState {
        case `default`, selected, focused

        var caption: String {
            switch self {
            case .default: "Default (no selection)"
            case .selected: "Active selection"
            case .focused: "Scrolled / windowed"
            }
        }
    }
}

// MARK: - Sample data
private enum SampleData {
    struct Item: Identifiable {
        let id: Int
        let day: String
        let value: Int

        var index: Int { id }
    }

    static let items: [Item] = [
        Item(id: 0, day: "Mon", value: 42),
        Item(id: 1, day: "Tue", value: 78),
        Item(id: 2, day: "Wed", value: 55),
        Item(id: 3, day: "Thu", value: 91),
        Item(id: 4, day: "Fri", value: 63),
        Item(id: 5, day: "Sat", value: 38),
        Item(id: 6, day: "Sun", value: 50),
        Item(id: 7, day: "Mon2", value: 67),
        Item(id: 8, day: "Tue2", value: 84),
        Item(id: 9, day: "Wed2", value: 29),
        Item(id: 10, day: "Thu2", value: 72),
        Item(id: 11, day: "Fri2", value: 95),
    ]
}

// MARK: - View helpers
private extension View {
    @ViewBuilder
    func applyScrollable(
        _ option: ChartSelectionShowcase.ScrollableAxesOption,
        domainLength: Int
    ) -> some View {
        switch option {
        case .none:
            self
        case .horizontal:
            self
                .chartScrollableAxes(.horizontal)
                .chartXVisibleDomain(length: domainLength)
        case .vertical:
            self
                .chartScrollableAxes(.vertical)
                .chartXVisibleDomain(length: domainLength)
        }
    }
}
