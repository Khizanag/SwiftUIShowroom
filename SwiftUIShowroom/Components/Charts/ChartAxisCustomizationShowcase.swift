import Charts
import SwiftUI

struct ChartAxisCustomizationShowcase: View {
    @State private var axis: AxisOption = .y
    @State private var axisPosition: AxisPositionOption = .automatic
    @State private var tickValues: TickValuesOption = .automatic
    @State private var desiredTickCount: Int = 5
    @State private var showGridLines: Bool = true
    @State private var showTicks: Bool = true
    @State private var showValueLabels: Bool = true
    @State private var labelOrientation: LabelOrientationOption = .automatic

    var body: some View {
        ShowcaseScreen(
            title: "Axis Customization",
            summary: "Customize axis ticks, grid lines, and labels via chartXAxis/chartYAxis.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ChartAxisCustomizationShowcase {
    var preview: some View {
        configuredChart(
            data: SampleItem.defaultData,
            config: currentConfig
        )
        .frame(height: 220)
        .padding(DesignSystem.Spacing.small)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Axis", selection: $axis)
        ShowcasePicker("Axis position", selection: $axisPosition)
        ShowcasePicker("Tick values", selection: $tickValues)
        if tickValues == .automaticDesiredCount {
            ShowcaseStepper("Desired tick count", value: $desiredTickCount, in: 2...12)
        }
        ShowcaseToggle("Show grid lines", isOn: $showGridLines)
        ShowcaseToggle("Show ticks", isOn: $showTicks)
        ShowcaseToggle("Show value labels", isOn: $showValueLabels)
        ShowcasePicker("Label orientation", selection: $labelOrientation)
    }

    @ViewBuilder
    func stateView(_ state: AxisCustomizationState) -> some View {
        configuredChart(
            data: state.data,
            config: state.config
        )
        .frame(height: 120)
        .padding(DesignSystem.Spacing.xSmall)
    }
}

// MARK: - Helpers
private extension ChartAxisCustomizationShowcase {
    var currentConfig: AxisConfig {
        AxisConfig(
            axis: axis,
            position: axisPosition.position,
            tickValues: tickValues,
            desiredCount: desiredTickCount,
            marks: MarkConfig(
                showGridLines: showGridLines,
                showTicks: showTicks,
                showValueLabels: showValueLabels,
                orientation: labelOrientation.orientation
            )
        )
    }

    @ViewBuilder
    func configuredChart(data: [SampleItem], config: AxisConfig) -> some View {
        let chart = Chart(data) { item in
            BarMark(
                x: .value("Category", item.category),
                y: .value("Value", item.value)
            )
            .foregroundStyle(DesignSystem.Color.accent)
        }
        if config.axis == .y {
            chart.chartYAxis {
                buildAxisMarks(config: config)
            }
        } else {
            chart.chartXAxis {
                buildAxisMarks(config: config)
            }
        }
    }

    @AxisContentBuilder
    func buildAxisMarks(config: AxisConfig) -> some AxisContent {
        switch config.tickValues {
        case .automatic:
            AxisMarks(position: config.position, values: .automatic) { _ in
                buildMarkContent(marks: config.marks)
            }
        case .automaticDesiredCount:
            AxisMarks(
                position: config.position,
                values: .automatic(desiredCount: config.desiredCount)
            ) { _ in
                buildMarkContent(marks: config.marks)
            }
        case .stride:
            AxisMarks(position: config.position, values: .stride(by: 20)) { _ in
                buildMarkContent(marks: config.marks)
            }
        case .explicit:
            AxisMarks(position: config.position, values: [0, 25, 50, 75, 100]) { _ in
                buildMarkContent(marks: config.marks)
            }
        }
    }

    @AxisMarkBuilder
    func buildMarkContent(marks: MarkConfig) -> some AxisMark {
        if marks.showGridLines { AxisGridLine() }
        if marks.showTicks { AxisTick() }
        if marks.showValueLabels { AxisValueLabel(orientation: marks.orientation) }
    }
}

// MARK: - Code generation
private extension ChartAxisCustomizationShowcase {
    var generatedCode: String {
        let modifier = axis == .y ? "chartYAxis" : "chartXAxis"
        var lines: [String] = []
        lines.append(".\(modifier) {")
        lines.append("    AxisMarks(")
        lines.append("        position: \(axisPosition.codeValue),")
        lines.append("        values: \(tickValuesCode)")
        lines.append("    ) { value in")
        if showGridLines { lines.append("        AxisGridLine()") }
        if showTicks { lines.append("        AxisTick()") }
        if showValueLabels {
            lines.append("        AxisValueLabel(orientation: \(labelOrientation.codeValue))")
        }
        lines.append("    }")
        lines.append("}")
        return lines.joined(separator: "\n")
    }

    var tickValuesCode: String {
        switch tickValues {
        case .automatic:
            return ".automatic"
        case .automaticDesiredCount:
            return ".automatic(desiredCount: \(desiredTickCount))"
        case .stride:
            return ".stride(by: 20)"
        case .explicit:
            return "[0, 25, 50, 75, 100]"
        }
    }
}

// MARK: - Nested types
extension ChartAxisCustomizationShowcase {
    struct AxisConfig {
        var axis: AxisOption
        var position: AxisMarkPosition
        var tickValues: TickValuesOption
        var desiredCount: Int
        var marks: MarkConfig
    }

    struct MarkConfig {
        var showGridLines: Bool
        var showTicks: Bool
        var showValueLabels: Bool
        var orientation: AxisValueLabelOrientation
    }

    enum AxisOption: ShowcasePickable {
        case x, y

        var label: String {
            switch self {
            case .x: "X axis"
            case .y: "Y axis"
            }
        }
    }

    enum AxisPositionOption: ShowcasePickable {
        case automatic, leading, trailing, top, bottom

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .leading: "leading"
            case .trailing: "trailing"
            case .top: "top"
            case .bottom: "bottom"
            }
        }

        var codeValue: String { ".\(label)" }

        var position: AxisMarkPosition {
            switch self {
            case .automatic: .automatic
            case .leading: .leading
            case .trailing: .trailing
            case .top: .top
            case .bottom: .bottom
            }
        }
    }

    enum TickValuesOption: ShowcasePickable {
        case automatic, automaticDesiredCount, stride, explicit

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .automaticDesiredCount: "automatic(desiredCount:)"
            case .stride: "stride(by: 20)"
            case .explicit: "[0, 25, 50, 75, 100]"
            }
        }
    }

    enum LabelOrientationOption: ShowcasePickable {
        case automatic, horizontal, vertical, verticalReversed

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .horizontal: "horizontal"
            case .vertical: "vertical"
            case .verticalReversed: "verticalReversed"
            }
        }

        var codeValue: String { ".\(label)" }

        var orientation: AxisValueLabelOrientation {
            switch self {
            case .automatic: .automatic
            case .horizontal: .horizontal
            case .vertical: .vertical
            case .verticalReversed: .verticalReversed
            }
        }
    }

    enum AxisCustomizationState: ShowcaseState {
        case `default`, longContent

        var caption: String {
            switch self {
            case .default: "Default"
            case .longContent: "Many categories"
            }
        }

        var config: AxisConfig {
            switch self {
            case .default:
                AxisConfig(
                    axis: .y,
                    position: .automatic,
                    tickValues: .automaticDesiredCount,
                    desiredCount: 5,
                    marks: MarkConfig(
                        showGridLines: true,
                        showTicks: true,
                        showValueLabels: true,
                        orientation: .automatic
                    )
                )
            case .longContent:
                AxisConfig(
                    axis: .x,
                    position: .automatic,
                    tickValues: .automaticDesiredCount,
                    desiredCount: 4,
                    marks: MarkConfig(
                        showGridLines: false,
                        showTicks: true,
                        showValueLabels: true,
                        orientation: .vertical
                    )
                )
            }
        }

        var data: [SampleItem] {
            switch self {
            case .default: SampleItem.defaultData
            case .longContent: SampleItem.longData
            }
        }
    }

    struct SampleItem: Identifiable {
        let id = UUID()
        let category: String
        let value: Int

        static let defaultData: [SampleItem] = [
            SampleItem(category: "Mon", value: 42),
            SampleItem(category: "Tue", value: 78),
            SampleItem(category: "Wed", value: 55),
            SampleItem(category: "Thu", value: 91),
            SampleItem(category: "Fri", value: 63),
        ]

        static let longData: [SampleItem] = [
            SampleItem(category: "Jan", value: 30),
            SampleItem(category: "Feb", value: 55),
            SampleItem(category: "Mar", value: 70),
            SampleItem(category: "Apr", value: 45),
            SampleItem(category: "May", value: 88),
            SampleItem(category: "Jun", value: 62),
            SampleItem(category: "Jul", value: 95),
            SampleItem(category: "Aug", value: 51),
            SampleItem(category: "Sep", value: 77),
            SampleItem(category: "Oct", value: 83),
            SampleItem(category: "Nov", value: 40),
            SampleItem(category: "Dec", value: 66),
        ]
    }
}
