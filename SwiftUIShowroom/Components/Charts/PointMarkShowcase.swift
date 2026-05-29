import Charts
import SwiftUI

struct PointMarkShowcase: View {
    @State private var symbol: SymbolOption = .circle
    @State private var symbolSize: Double = 60
    @State private var pointColor: Color = .accentColor
    @State private var opacity: Double = 0.8
    @State private var groupByCategory = false

    var body: some View {
        ShowcaseScreen(
            title: "PointMark",
            summary: "Plots individual data points as symbols for scatter plots and bubble charts.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension PointMarkShowcase {
    var preview: some View {
        Chart {
            ForEach(ScatterData.sample) { point in
                pointMark(for: point, grouped: groupByCategory)
            }
        }
        .frame(height: 220)
        .chartXScale(domain: 0...10)
        .chartYScale(domain: 0...10)
    }

    @ChartContentBuilder
    func pointMark(for point: ScatterData, grouped: Bool) -> some ChartContent {
        if grouped {
            PointMark(
                x: .value("X", point.xValue),
                y: .value("Y", point.yValue)
            )
            .symbol(symbol.chartSymbol)
            .symbolSize(CGFloat(symbolSize))
            .foregroundStyle(by: .value("Category", point.category))
            .opacity(opacity)
        } else {
            PointMark(
                x: .value("X", point.xValue),
                y: .value("Y", point.yValue)
            )
            .symbol(symbol.chartSymbol)
            .symbolSize(CGFloat(symbolSize))
            .foregroundStyle(pointColor)
            .opacity(opacity)
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Symbol", selection: $symbol)
        ShowcaseSlider("Symbol size", value: $symbolSize, in: 10...300, step: 10)
        ShowcaseColorControl("Foreground style", selection: $pointColor, supportsOpacity: false)
        ShowcaseSlider("Opacity", value: $opacity, in: 0...1, step: 0.05)
        ShowcaseToggle("Group by category", isOn: $groupByCategory)
    }

    @ViewBuilder
    func stateView(_ state: PointMarkState) -> some View {
        Chart {
            ForEach(state.data) { point in
                PointMark(
                    x: .value("X", point.xValue),
                    y: .value("Y", point.yValue)
                )
                .symbol(.circle)
                .symbolSize(CGFloat(state.resolvedSymbolSize))
                .foregroundStyle(state.resolvedColor)
                .opacity(state.resolvedOpacity)
            }
        }
        .frame(height: 120)
        .chartXScale(domain: 0...10)
        .chartYScale(domain: 0...10)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
}

// MARK: - Code generation
private extension PointMarkShowcase {
    var generatedCode: String {
        var lines = [
            "PointMark(",
            "    x: .value(\"X\", item.x),",
            "    y: .value(\"Y\", item.y)",
            ")",
            ".symbol(.\(symbol.label))",
            ".symbolSize(\(Int(symbolSize)))",
        ]
        if groupByCategory {
            lines.append(".foregroundStyle(by: .value(\"Category\", item.category))")
            lines.append(".symbol(by: .value(\"Category\", item.category))")
        } else {
            lines.append(".foregroundStyle(\(colorCode))")
        }
        lines.append(".opacity(\(String(format: "%.2f", opacity)))")
        return lines.joined(separator: "\n")
    }

    var colorCode: String {
        pointColor == .accentColor ? ".accentColor" : "Color(/* configured */)"
    }
}

// MARK: - Nested types
private extension PointMarkShowcase {
    enum SymbolOption: ShowcasePickable {
        case circle, square, triangle, diamond, pentagon, plus, cross, asterisk

        var label: String {
            switch self {
            case .circle: "circle"
            case .square: "square"
            case .triangle: "triangle"
            case .diamond: "diamond"
            case .pentagon: "pentagon"
            case .plus: "plus"
            case .cross: "cross"
            case .asterisk: "asterisk"
            }
        }

        var chartSymbol: BasicChartSymbolShape {
            switch self {
            case .circle: .circle
            case .square: .square
            case .triangle: .triangle
            case .diamond: .diamond
            case .pentagon: .pentagon
            case .plus: .plus
            case .cross: .cross
            case .asterisk: .asterisk
            }
        }
    }

    enum PointMarkState: ShowcaseState {
        case `default`, selected, empty, longContent

        var caption: String {
            switch self {
            case .default: "Default"
            case .selected: "Selected"
            case .empty: "Empty"
            case .longContent: "Dense"
            }
        }

        var data: [ScatterData] {
            switch self {
            case .default: ScatterData.sample
            case .selected: ScatterData.selected
            case .empty: []
            case .longContent: ScatterData.dense
            }
        }

        var resolvedSymbolSize: Double {
            switch self {
            case .selected: 120
            default: 60
            }
        }

        var resolvedColor: Color {
            switch self {
            case .selected: .accentColor
            default: .blue
            }
        }

        var resolvedOpacity: Double {
            switch self {
            case .selected: 1.0
            default: 0.8
            }
        }
    }

    struct ScatterData: Identifiable {
        let id: Int
        let xValue: Double
        let yValue: Double
        let category: String

        static let sample: [ScatterData] = [
            ScatterData(id: 0, xValue: 1.2, yValue: 2.5, category: "A"),
            ScatterData(id: 1, xValue: 2.8, yValue: 5.1, category: "B"),
            ScatterData(id: 2, xValue: 3.5, yValue: 3.8, category: "A"),
            ScatterData(id: 3, xValue: 5.0, yValue: 7.2, category: "C"),
            ScatterData(id: 4, xValue: 6.3, yValue: 4.9, category: "B"),
            ScatterData(id: 5, xValue: 7.8, yValue: 8.1, category: "A"),
            ScatterData(id: 6, xValue: 8.5, yValue: 6.3, category: "C"),
            ScatterData(id: 7, xValue: 9.1, yValue: 9.5, category: "B"),
        ]

        static let selected: [ScatterData] = [
            ScatterData(id: 0, xValue: 2.0, yValue: 3.0, category: "A"),
            ScatterData(id: 1, xValue: 5.0, yValue: 6.0, category: "A"),
            ScatterData(id: 2, xValue: 8.0, yValue: 4.0, category: "A"),
        ]

        static let dense: [ScatterData] = (0..<40).map { idx in
            let xVal = Double(idx % 10) + Double(idx / 10) * 0.3
            let yVal = Double.random(in: 0.5...9.5)
            return ScatterData(
                id: idx,
                xValue: min(xVal, 9.8),
                yValue: yVal,
                category: ["A", "B", "C"][idx % 3],
            )
        }
    }
}
