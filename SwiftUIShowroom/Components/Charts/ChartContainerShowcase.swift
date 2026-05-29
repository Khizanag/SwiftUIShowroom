import Charts
import SwiftUI

struct ChartContainerShowcase: View {
    @State private var plotHeight: Double = 260
    @State private var showLegend: LegendVisibility = .automatic
    @State private var legendPosition: LegendPosition = .automatic
    @State private var xAxisVisible = true
    @State private var yAxisVisible = true
    @State private var plotBackground: Color = .clear
    @State private var scrollableX = false
    @State private var selectionEnabled = false
    @State private var selectedX: String?

    var body: some View {
        ShowcaseScreen(
            title: "Chart",
            summary: "Hosts marks and renders a data-driven chart, generating scales, axes, and legends automatically.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ChartContainerShowcase {
    @ViewBuilder
    var preview: some View {
        if scrollableX {
            styledChart
                .chartScrollableAxes(.horizontal)
        } else if selectionEnabled {
            if #available(iOS 17, macOS 14, tvOS 17, *) {
                styledChart
                    .chartXSelection(value: $selectedX)
            } else {
                styledChart
            }
        } else {
            styledChart
        }
    }

    var styledChart: some View {
        legendApplied(baseChart(data: ChartData.sample).frame(height: plotHeight))
            .chartXAxis(xAxisVisible ? .automatic : .hidden)
            .chartYAxis(yAxisVisible ? .automatic : .hidden)
            .chartPlotStyle { plotArea in plotArea.background(plotBackground) }
            .padding(DesignSystem.Spacing.small)
    }

    @ViewBuilder
    func legendApplied(_ chart: some View) -> some View {
        if showLegend.visibility == .hidden {
            chart.chartLegend(.hidden)
        } else {
            chart.chartLegend(position: legendPosition.position)
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseSlider("Plot height", value: $plotHeight, in: 120...500, step: 10)
        ShowcasePicker("Legend", selection: $showLegend)
        ShowcasePicker("Legend position", selection: $legendPosition)
        ShowcaseToggle("X axis visible", isOn: $xAxisVisible)
        ShowcaseToggle("Y axis visible", isOn: $yAxisVisible)
        ShowcaseColorControl("Plot background", selection: $plotBackground)
        ShowcaseToggle("Scrollable X", isOn: $scrollableX)
        ShowcaseToggle("Selection enabled", isOn: $selectionEnabled)
    }

    @ViewBuilder
    func stateView(_ state: ChartContainerState) -> some View {
        switch state {
        case .default:
            baseChart(data: ChartData.sample).frame(height: 120)
        case .empty:
            baseChart(data: [])
                .frame(height: 120)
                .overlay {
                    Text("No data")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.secondary)
                }
        case .loading:
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(DesignSystem.Color.cardBackground)
                .frame(height: 120)
                .overlay { ProgressView() }
        case .longContent:
            baseChart(data: ChartData.long)
                .frame(height: 120)
                .chartScrollableAxes(.horizontal)
        }
    }
}

// MARK: - Chart builders
private extension ChartContainerShowcase {
    func baseChart(data: [ChartData]) -> some View {
        Chart(data) { item in
            BarMark(
                x: .value("Category", item.category),
                y: .value("Value", item.value)
            )
            .foregroundStyle(by: .value("Category", item.category))
        }
    }
}

// MARK: - Code generation
private extension ChartContainerShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("Chart {")
        lines.append("    BarMark(")
        lines.append("        x: .value(\"Category\", item.category),")
        lines.append("        y: .value(\"Value\", item.value)")
        lines.append("    )")
        lines.append("}")
        lines.append(".frame(height: \(Int(plotHeight)))")
        lines.append(".chartLegend(\(showLegend.code), position: \(legendPosition.code))")
        lines.append(".chartXAxis(\(xAxisVisible ? ".automatic" : ".hidden"))")
        lines.append(".chartYAxis(\(yAxisVisible ? ".automatic" : ".hidden"))")
        lines.append(".chartPlotStyle { plotArea in")
        lines.append("    plotArea.background(\(plotBackgroundCode))")
        lines.append("}")
        if scrollableX {
            lines.append(".chartScrollableAxes(.horizontal)")
        }
        if selectionEnabled {
            lines.append(".chartXSelection(value: $selectedX)")
        }
        return lines.joined(separator: "\n")
    }

    var plotBackgroundCode: String {
        plotBackground == .clear ? ".clear" : "plotBackground"
    }
}

// MARK: - Supporting types
private extension ChartContainerShowcase {
    struct ChartData: Identifiable {
        let id: String
        let category: String
        let value: Double

        static let sample: [ChartData] = [
            ChartData(id: "a", category: "Mon", value: 42),
            ChartData(id: "b", category: "Tue", value: 78),
            ChartData(id: "c", category: "Wed", value: 55),
            ChartData(id: "d", category: "Thu", value: 91),
            ChartData(id: "e", category: "Fri", value: 63),
            ChartData(id: "f", category: "Sat", value: 38),
            ChartData(id: "g", category: "Sun", value: 50),
        ]

        static let long: [ChartData] = {
            let values: [Double] = [
                42, 78, 55, 91, 63, 38, 50, 72, 45, 88,
                33, 60, 74, 49, 95, 41, 67, 53, 80, 36,
            ]
            return values.enumerated().map { idx, val in
                ChartData(id: "w\(idx + 1)", category: "W\(idx + 1)", value: val)
            }
        }()
    }

    enum ChartContainerState: ShowcaseState {
        case `default`, empty, loading, longContent

        var caption: String {
            switch self {
            case .default: "Default"
            case .empty: "Empty"
            case .loading: "Loading"
            case .longContent: "Long content"
            }
        }
    }

    enum LegendVisibility: ShowcasePickable {
        case automatic, visible, hidden

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .visible: "visible"
            case .hidden: "hidden"
            }
        }

        var code: String {
            switch self {
            case .automatic: ".automatic"
            case .visible: ".visible"
            case .hidden: ".hidden"
            }
        }

        var visibility: Visibility {
            switch self {
            case .automatic: .automatic
            case .visible: .visible
            case .hidden: .hidden
            }
        }
    }

    enum LegendPosition: ShowcasePickable {
        case automatic, top, bottom, leading, trailing
        case topLeading, topTrailing, bottomLeading, bottomTrailing

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .top: "top"
            case .bottom: "bottom"
            case .leading: "leading"
            case .trailing: "trailing"
            case .topLeading: "topLeading"
            case .topTrailing: "topTrailing"
            case .bottomLeading: "bottomLeading"
            case .bottomTrailing: "bottomTrailing"
            }
        }

        var code: String {
            switch self {
            case .automatic: ".automatic"
            case .top: ".top"
            case .bottom: ".bottom"
            case .leading: ".leading"
            case .trailing: ".trailing"
            case .topLeading: ".topLeading"
            case .topTrailing: ".topTrailing"
            case .bottomLeading: ".bottomLeading"
            case .bottomTrailing: ".bottomTrailing"
            }
        }

        var position: AnnotationPosition {
            switch self {
            case .automatic: .automatic
            case .top: .top
            case .bottom: .bottom
            case .leading: .leading
            case .trailing: .trailing
            case .topLeading: .topLeading
            case .topTrailing: .topTrailing
            case .bottomLeading: .bottomLeading
            case .bottomTrailing: .bottomTrailing
            }
        }
    }
}
