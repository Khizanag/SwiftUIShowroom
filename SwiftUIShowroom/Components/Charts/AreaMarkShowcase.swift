import Charts
import SwiftUI

struct AreaMarkShowcase: View {
    @State private var stacking: StackingOption = .standard
    @State private var interpolation: InterpolationOption = .linear
    @State private var rangeMode = false
    @State private var useGradient = false
    @State private var fillColor: Color = .accentColor
    @State private var opacity: Double = 0.7
    @State private var groupByCategory = false

    var body: some View {
        ShowcaseScreen(
            title: "AreaMark",
            summary: "Fills the area under a line or between two bounds; stacked, normalized, and range modes.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AreaMarkShowcase {
    var preview: some View {
        Chart {
            areaContent(
                data: groupByCategory ? AreaMarkShowcase.multiSeriesPoints : AreaMarkShowcase.singleSeriesPoints,
                rangeData: AreaMarkShowcase.rangePoints
            )
        }
        .opacity(opacity)
        .frame(height: 220)
        .padding(DesignSystem.Spacing.small)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Stacking", selection: $stacking)
        ShowcasePicker("Interpolation", selection: $interpolation)
        ShowcaseToggle("Range mode (min/max band)", isOn: $rangeMode)
        ShowcaseToggle("Gradient fill", isOn: $useGradient)
        ShowcaseColorControl("Fill color", selection: $fillColor, supportsOpacity: false)
        ShowcaseSlider("Opacity", value: $opacity, in: 0...1, step: 0.05)
        ShowcaseToggle("Group by category", isOn: $groupByCategory)
    }

    @ViewBuilder
    func stateView(_ state: AreaMarkState) -> some View {
        switch state {
        case .default: defaultStateChart
        case .gradient: gradientStateChart
        case .stacked: stackedStateChart
        case .rangeBand: rangeBandStateChart
        case .empty: emptyStateChart
        }
    }

    private var defaultStateChart: some View {
        Chart {
            ForEach(AreaMarkShowcase.singleSeriesPoints) { point in
                AreaMark(
                    x: .value("Index", point.index),
                    y: .value("Value", point.value),
                    stacking: .standard,
                )
                .interpolationMethod(.linear)
                .foregroundStyle(Color.accentColor)
            }
        }
        .opacity(0.7)
        .frame(height: 100)
    }

    private var gradientStateChart: some View {
        Chart {
            ForEach(AreaMarkShowcase.singleSeriesPoints) { point in
                AreaMark(
                    x: .value("Index", point.index),
                    y: .value("Value", point.value),
                    stacking: .standard,
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.accentColor, .accentColor.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom,
                    )
                )
            }
        }
        .opacity(0.7)
        .frame(height: 100)
    }

    private var stackedStateChart: some View {
        Chart {
            ForEach(AreaMarkShowcase.multiSeriesPoints) { point in
                AreaMark(
                    x: .value("Index", point.index),
                    y: .value("Value", point.value),
                    stacking: .standard,
                )
                .interpolationMethod(.linear)
                .foregroundStyle(by: .value("Series", point.seriesName))
            }
        }
        .opacity(0.8)
        .frame(height: 100)
    }

    private var rangeBandStateChart: some View {
        Chart {
            ForEach(AreaMarkShowcase.rangePoints) { point in
                AreaMark(
                    x: .value("Index", point.index),
                    yStart: .value("Min", point.rangeMin),
                    yEnd: .value("Max", point.rangeMax),
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(Color.accentColor)
            }
        }
        .opacity(0.5)
        .frame(height: 100)
    }

    private var emptyStateChart: some View {
        Chart {
            let none: [SeriesPoint] = []
            ForEach(none) { point in
                AreaMark(
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
    }
}

// MARK: - Chart content builder
private extension AreaMarkShowcase {
    @ChartContentBuilder
    func areaContent(data: [SeriesPoint], rangeData: [SeriesPoint]) -> some ChartContent {
        let gradientStyle = AnyShapeStyle(
            LinearGradient(
                colors: [fillColor, fillColor.opacity(0)],
                startPoint: .top,
                endPoint: .bottom,
            )
        )
        let solidStyle = AnyShapeStyle(fillColor)
        let resolvedStyle = useGradient ? gradientStyle : solidStyle

        if rangeMode {
            ForEach(rangeData) { point in
                AreaMark(
                    x: .value("Index", point.index),
                    yStart: .value("Min", point.rangeMin),
                    yEnd: .value("Max", point.rangeMax),
                )
                .interpolationMethod(interpolation.method)
                .foregroundStyle(resolvedStyle)
            }
        } else if groupByCategory {
            ForEach(data) { point in
                AreaMark(
                    x: .value("Index", point.index),
                    y: .value("Value", point.value),
                    stacking: stacking.value,
                )
                .interpolationMethod(interpolation.method)
                .foregroundStyle(by: .value("Series", point.seriesName))
            }
        } else {
            ForEach(data) { point in
                AreaMark(
                    x: .value("Index", point.index),
                    y: .value("Value", point.value),
                    stacking: stacking.value,
                )
                .interpolationMethod(interpolation.method)
                .foregroundStyle(resolvedStyle)
            }
        }
    }
}

// MARK: - Sample data
extension AreaMarkShowcase {
    struct SeriesPoint: Identifiable {
        let id: Int
        let index: Int
        let value: Double
        let seriesName: String
        let rangeMin: Double
        let rangeMax: Double
    }

    static let singleSeriesPoints: [SeriesPoint] = [
        SeriesPoint(id: 0, index: 0, value: 10, seriesName: "A", rangeMin: 0, rangeMax: 0),
        SeriesPoint(id: 1, index: 1, value: 25, seriesName: "A", rangeMin: 0, rangeMax: 0),
        SeriesPoint(id: 2, index: 2, value: 18, seriesName: "A", rangeMin: 0, rangeMax: 0),
        SeriesPoint(id: 3, index: 3, value: 40, seriesName: "A", rangeMin: 0, rangeMax: 0),
        SeriesPoint(id: 4, index: 4, value: 32, seriesName: "A", rangeMin: 0, rangeMax: 0),
        SeriesPoint(id: 5, index: 5, value: 55, seriesName: "A", rangeMin: 0, rangeMax: 0),
        SeriesPoint(id: 6, index: 6, value: 48, seriesName: "A", rangeMin: 0, rangeMax: 0),
        SeriesPoint(id: 7, index: 7, value: 70, seriesName: "A", rangeMin: 0, rangeMax: 0),
        SeriesPoint(id: 8, index: 8, value: 60, seriesName: "A", rangeMin: 0, rangeMax: 0),
        SeriesPoint(id: 9, index: 9, value: 80, seriesName: "A", rangeMin: 0, rangeMax: 0),
    ]

    static let multiSeriesPoints: [SeriesPoint] = [
        SeriesPoint(id: 0, index: 0, value: 10, seriesName: "Alpha", rangeMin: 0, rangeMax: 0),
        SeriesPoint(id: 1, index: 1, value: 25, seriesName: "Alpha", rangeMin: 0, rangeMax: 0),
        SeriesPoint(id: 2, index: 2, value: 18, seriesName: "Alpha", rangeMin: 0, rangeMax: 0),
        SeriesPoint(id: 3, index: 3, value: 40, seriesName: "Alpha", rangeMin: 0, rangeMax: 0),
        SeriesPoint(id: 4, index: 4, value: 32, seriesName: "Alpha", rangeMin: 0, rangeMax: 0),
        SeriesPoint(id: 5, index: 5, value: 55, seriesName: "Alpha", rangeMin: 0, rangeMax: 0),
        SeriesPoint(id: 10, index: 0, value: 8, seriesName: "Beta", rangeMin: 0, rangeMax: 0),
        SeriesPoint(id: 11, index: 1, value: 15, seriesName: "Beta", rangeMin: 0, rangeMax: 0),
        SeriesPoint(id: 12, index: 2, value: 28, seriesName: "Beta", rangeMin: 0, rangeMax: 0),
        SeriesPoint(id: 13, index: 3, value: 20, seriesName: "Beta", rangeMin: 0, rangeMax: 0),
        SeriesPoint(id: 14, index: 4, value: 35, seriesName: "Beta", rangeMin: 0, rangeMax: 0),
        SeriesPoint(id: 15, index: 5, value: 28, seriesName: "Beta", rangeMin: 0, rangeMax: 0),
    ]

    static let rangePoints: [SeriesPoint] = [
        SeriesPoint(id: 20, index: 0, value: 10, seriesName: "A", rangeMin: 5, rangeMax: 15),
        SeriesPoint(id: 21, index: 1, value: 20, seriesName: "A", rangeMin: 10, rangeMax: 30),
        SeriesPoint(id: 22, index: 2, value: 17, seriesName: "A", rangeMin: 8, rangeMax: 25),
        SeriesPoint(id: 23, index: 3, value: 33, seriesName: "A", rangeMin: 20, rangeMax: 45),
        SeriesPoint(id: 24, index: 4, value: 27, seriesName: "A", rangeMin: 15, rangeMax: 38),
        SeriesPoint(id: 25, index: 5, value: 40, seriesName: "A", rangeMin: 25, rangeMax: 55),
        SeriesPoint(id: 26, index: 6, value: 35, seriesName: "A", rangeMin: 20, rangeMax: 50),
        SeriesPoint(id: 27, index: 7, value: 48, seriesName: "A", rangeMin: 30, rangeMax: 65),
    ]
}

// MARK: - Nested enums
extension AreaMarkShowcase {
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

        var value: MarkStackingMethod {
            switch self {
            case .standard: .standard
            case .normalized: .normalized
            case .center: .center
            case .unstacked: .unstacked
            }
        }
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

    enum AreaMarkState: ShowcaseState {
        case `default`, gradient, stacked, rangeBand, empty

        var caption: String {
            switch self {
            case .default: "Default"
            case .gradient: "Gradient fill"
            case .stacked: "Stacked series"
            case .rangeBand: "Range band"
            case .empty: "Empty data"
            }
        }
    }
}

// MARK: - Code generation
private extension AreaMarkShowcase {
    var generatedCode: String {
        var lines: [String] = []
        if rangeMode {
            lines.append("AreaMark(")
            lines.append("    x: .value(\"Date\", item.date),")
            lines.append("    yStart: .value(\"Min\", item.min),")
            lines.append("    yEnd: .value(\"Max\", item.max)")
            lines.append(")")
        } else {
            lines.append("AreaMark(")
            lines.append("    x: .value(\"Date\", item.date),")
            lines.append("    y: .value(\"Value\", item.value),")
            lines.append("    stacking: .\(stacking.label)")
            lines.append(")")
        }
        lines.append(".interpolationMethod(.\(interpolation.label))")
        if groupByCategory && !rangeMode {
            lines.append(".foregroundStyle(by: .value(\"Series\", item.series))")
        } else if useGradient {
            lines.append(".foregroundStyle(")
            lines.append("    LinearGradient(")
            lines.append("        colors: [\(colorCode), .clear],")
            lines.append("        startPoint: .top,")
            lines.append("        endPoint: .bottom")
            lines.append("    )")
            lines.append(")")
        } else {
            lines.append(".foregroundStyle(\(colorCode))")
        }
        let opacityFormatted = opacity.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(opacity))
            : String(format: "%.2f", opacity)
        lines.append(".opacity(\(opacityFormatted))")
        return lines.joined(separator: "\n")
    }

    var colorCode: String {
        fillColor == .accentColor ? ".accentColor" : "Color(/* configured */)"
    }
}
