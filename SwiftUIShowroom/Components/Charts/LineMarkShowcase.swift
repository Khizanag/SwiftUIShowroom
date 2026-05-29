import Charts
import SwiftUI

struct LineMarkShowcase: View {
    @State private var interpolation: InterpolationOption = .linear
    @State private var lineWidth: Double = 2
    @State private var lineCap: LineCapOption = .round
    @State private var dashed: Bool = false
    @State private var symbol: SymbolOption = .none
    @State private var foregroundColor: Color = DesignSystem.Color.accent
    @State private var groupBySeries: Bool = false

    var body: some View {
        ShowcaseScreen(
            title: "LineMark",
            summary: "Line chart mark; supports interpolation, series grouping, stroke style, and symbols.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension LineMarkShowcase {
    var preview: some View {
        Chart {
            lineMarks(
                data: groupBySeries ? LineMarkShowcase.multiSeries : LineMarkShowcase.singleSeries,
                config: currentConfig,
            )
        }
        .frame(height: 220)
        .padding(DesignSystem.Spacing.small)
    }

    var currentConfig: LineMarkConfig {
        LineMarkConfig(
            interpolation: interpolation.method,
            stroke: strokeStyle,
            symbol: symbol,
            color: foregroundColor,
            grouped: groupBySeries,
        )
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Interpolation", selection: $interpolation)
        ShowcaseSlider("Line width", value: $lineWidth, in: 0.5...10, step: 0.5)
        ShowcasePicker("Line cap", selection: $lineCap)
        ShowcaseToggle("Dashed", isOn: $dashed)
        ShowcasePicker("Symbol", selection: $symbol)
        ShowcaseColorControl("Color", selection: $foregroundColor, supportsOpacity: false)
        ShowcaseToggle("Group by series", isOn: $groupBySeries)
    }

    @ViewBuilder
    func stateView(_ state: LineMarkState) -> some View {
        switch state {
        case .default:
            Chart {
                lineMarks(
                    data: LineMarkShowcase.singleSeries,
                    config: LineMarkConfig(
                        interpolation: .linear,
                        stroke: StrokeStyle(lineWidth: 2),
                        symbol: .none,
                        color: DesignSystem.Color.accent,
                        grouped: false,
                    ),
                )
            }
            .frame(height: 100)

        case .selected:
            Chart {
                lineMarks(
                    data: LineMarkShowcase.singleSeries,
                    config: LineMarkConfig(
                        interpolation: .monotone,
                        stroke: StrokeStyle(lineWidth: 2.5),
                        symbol: .circle,
                        color: .orange,
                        grouped: false,
                    ),
                )
            }
            .frame(height: 100)

        case .empty:
            Chart {
                let empty: [SeriesPoint] = []
                ForEach(empty) { point in
                    LineMark(
                        x: .value("Index", point.index),
                        y: .value("Value", point.value),
                    )
                }
            }
            .frame(height: 100)
            .overlay {
                Text("No data")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }

        case .longContent:
            Chart {
                lineMarks(
                    data: LineMarkShowcase.longSeries,
                    config: LineMarkConfig(
                        interpolation: .linear,
                        stroke: StrokeStyle(lineWidth: 1.5),
                        symbol: .none,
                        color: DesignSystem.Color.accent,
                        grouped: false,
                    ),
                )
            }
            .frame(height: 100)
        }
    }

    var strokeStyle: StrokeStyle {
        StrokeStyle(
            lineWidth: lineWidth,
            lineCap: lineCap.cgLineCap,
            dash: dashed ? [6, 4] : [],
        )
    }
}

// MARK: - Mark builder
private extension LineMarkShowcase {
    @ChartContentBuilder
    func lineMarks(data: [SeriesPoint], config: LineMarkConfig) -> some ChartContent {
        if config.grouped && config.symbol != .none {
            ForEach(data) { point in
                LineMark(
                    x: .value("Index", point.index),
                    y: .value("Value", point.value),
                )
                .foregroundStyle(by: .value("Series", point.seriesName))
                .interpolationMethod(config.interpolation)
                .lineStyle(config.stroke)
                .symbol(config.symbol.chartSymbol)
            }
        } else if config.grouped {
            ForEach(data) { point in
                LineMark(
                    x: .value("Index", point.index),
                    y: .value("Value", point.value),
                )
                .foregroundStyle(by: .value("Series", point.seriesName))
                .interpolationMethod(config.interpolation)
                .lineStyle(config.stroke)
            }
        } else if config.symbol != .none {
            ForEach(data) { point in
                LineMark(
                    x: .value("Index", point.index),
                    y: .value("Value", point.value),
                )
                .foregroundStyle(config.color)
                .interpolationMethod(config.interpolation)
                .lineStyle(config.stroke)
                .symbol(config.symbol.chartSymbol)
            }
        } else {
            ForEach(data) { point in
                LineMark(
                    x: .value("Index", point.index),
                    y: .value("Value", point.value),
                )
                .foregroundStyle(config.color)
                .interpolationMethod(config.interpolation)
                .lineStyle(config.stroke)
            }
        }
    }
}

// MARK: - Sample data
private extension LineMarkShowcase {
    static let singleSeries: [SeriesPoint] = [
        SeriesPoint(id: 0, index: 0, value: 30, seriesName: "A"),
        SeriesPoint(id: 1, index: 1, value: 55, seriesName: "A"),
        SeriesPoint(id: 2, index: 2, value: 40, seriesName: "A"),
        SeriesPoint(id: 3, index: 3, value: 70, seriesName: "A"),
        SeriesPoint(id: 4, index: 4, value: 60, seriesName: "A"),
        SeriesPoint(id: 5, index: 5, value: 85, seriesName: "A"),
        SeriesPoint(id: 6, index: 6, value: 75, seriesName: "A"),
    ]

    static let multiSeries: [SeriesPoint] = [
        SeriesPoint(id: 0, index: 0, value: 30, seriesName: "Alpha"),
        SeriesPoint(id: 1, index: 1, value: 55, seriesName: "Alpha"),
        SeriesPoint(id: 2, index: 2, value: 40, seriesName: "Alpha"),
        SeriesPoint(id: 3, index: 3, value: 70, seriesName: "Alpha"),
        SeriesPoint(id: 4, index: 4, value: 60, seriesName: "Alpha"),
        SeriesPoint(id: 10, index: 0, value: 80, seriesName: "Beta"),
        SeriesPoint(id: 11, index: 1, value: 45, seriesName: "Beta"),
        SeriesPoint(id: 12, index: 2, value: 65, seriesName: "Beta"),
        SeriesPoint(id: 13, index: 3, value: 35, seriesName: "Beta"),
        SeriesPoint(id: 14, index: 4, value: 55, seriesName: "Beta"),
    ]

    static let longSeries: [SeriesPoint] = {
        let values: [Double] = [
            40, 55, 48, 62, 50, 72, 65, 80, 70, 88,
            75, 60, 78, 52, 68, 82, 58, 74, 90, 66,
        ]
        return values.enumerated().map {
            SeriesPoint(id: $0.offset, index: $0.offset, value: $0.element, seriesName: "A")
        }
    }()
}

// MARK: - Code generation
private extension LineMarkShowcase {
    var generatedCode: String {
        let dashPart = dashed ? "[6, 4]" : "[]"
        let symbolLine = symbol == .none ? "" : "\n.symbol(.\(symbol.label))"
        let styleLine: String = groupBySeries
            ? ".foregroundStyle(by: .value(\"Series\", item.series))"
            : ".foregroundStyle(\(colorCode))"
        return """
        LineMark(
            x: .value("Date", item.date),
            y: .value("Value", item.value)
        )
        .interpolationMethod(.\(interpolation.label))
        .lineStyle(StrokeStyle(
            lineWidth: \(formattedWidth),
            lineCap: .\(lineCap.label),
            dash: \(dashPart)
        ))\(symbolLine)
        \(styleLine)
        """
    }

    var formattedWidth: String {
        lineWidth.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(lineWidth))
            : String(lineWidth)
    }

    var colorCode: String {
        foregroundColor == DesignSystem.Color.accent ? "DesignSystem.Color.accent" : "Color(/* configured */)"
    }
}

// MARK: - Nested types
extension LineMarkShowcase {
    struct LineMarkConfig {
        let interpolation: InterpolationMethod
        let stroke: StrokeStyle
        let symbol: SymbolOption
        let color: Color
        let grouped: Bool
    }

    struct SeriesPoint: Identifiable {
        let id: Int
        let index: Int
        let value: Double
        let seriesName: String
    }

    enum InterpolationOption: ShowcasePickable {
        case linear, monotone, cardinal, catmullRom, stepStart, stepCenter, stepEnd

        var label: String {
            switch self {
            case .linear: "linear"
            case .monotone: "monotone"
            case .cardinal: "cardinal"
            case .catmullRom: "catmullRom"
            case .stepStart: "stepStart"
            case .stepCenter: "stepCenter"
            case .stepEnd: "stepEnd"
            }
        }

        var method: InterpolationMethod {
            switch self {
            case .linear: .linear
            case .monotone: .monotone
            case .cardinal: .cardinal
            case .catmullRom: .catmullRom
            case .stepStart: .stepStart
            case .stepCenter: .stepCenter
            case .stepEnd: .stepEnd
            }
        }
    }

    enum LineCapOption: ShowcasePickable {
        case butt, round, square

        var label: String {
            switch self {
            case .butt: "butt"
            case .round: "round"
            case .square: "square"
            }
        }

        var cgLineCap: CGLineCap {
            switch self {
            case .butt: .butt
            case .round: .round
            case .square: .square
            }
        }
    }

    enum SymbolOption: ShowcasePickable {
        case none, circle, square, triangle, diamond, pentagon, plus, cross, asterisk

        var label: String {
            switch self {
            case .none: "none"
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
            case .none: .circle
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

    enum LineMarkState: ShowcaseState {
        case `default`, selected, empty, longContent

        var caption: String {
            switch self {
            case .default: "Default"
            case .selected: "With symbols"
            case .empty: "Empty data"
            case .longContent: "Long content"
            }
        }
    }
}
