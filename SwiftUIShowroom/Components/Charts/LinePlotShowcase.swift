import Charts
import SwiftUI

struct LinePlotShowcase: View {
    @State private var mode: PlotMode = .function
    @State private var lineWidth: Double = 3
    @State private var lineCap: LineCapOption = .round
    @State private var foregroundColor: Color = .accentColor
    @State private var opacity: Double = 0.9

    var body: some View {
        ShowcaseScreen(
            title: "LinePlot (function)",
            summary: "Vectorized line for whole collections and for plotting mathematical or parametric functions.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension LinePlotShowcase {
    var preview: some View {
        Group {
            if #available(iOS 18.0, macOS 15.0, tvOS 18.0, *) {
                configuredChart
            } else {
                unavailablePlaceholder
            }
        }
        .frame(height: 240)
        .padding(DesignSystem.Spacing.small)
    }

    @available(iOS 18.0, macOS 15.0, tvOS 18.0, *)
    var configuredChart: some View {
        Chart {
            plotContent
        }
        .chartXScale(domain: -10...10)
        .chartYScale(domain: -15...15)
    }

    @available(iOS 18.0, macOS 15.0, tvOS 18.0, *)
    @ChartContentBuilder
    var plotContent: some ChartContent {
        switch mode {
        case .function:
            LinePlot(x: "x", y: "y") { (xVal: Double) in
                xVal * xVal * 0.1
            }
            .lineStyle(strokeStyle)
            .foregroundStyle(foregroundColor)
            .opacity(opacity)
        case .collection:
            LinePlot(
                LinePlotShowcase.collectionData,
                x: .value("Index", \.xVal),
                y: .value("Value", \.yVal),
            )
            .lineStyle(strokeStyle)
            .foregroundStyle(foregroundColor)
            .opacity(opacity)
        case .parametric:
            LinePlot(x: "x", y: "y", t: "t", domain: 0...(.pi * 2)) { tVal in
                (8 * cos(tVal), 8 * sin(tVal))
            }
            .lineStyle(strokeStyle)
            .foregroundStyle(foregroundColor)
            .opacity(opacity)
        }
    }

    var strokeStyle: StrokeStyle {
        StrokeStyle(
            lineWidth: lineWidth,
            lineCap: lineCap.cgLineCap,
        )
    }

    var unavailablePlaceholder: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(DesignSystem.Color.cardBackground)
            .overlay {
                Text("Requires iOS 18 / macOS 15 / tvOS 18")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Mode", selection: $mode)
        ShowcaseSlider("Line width", value: $lineWidth, in: 0.5...10, step: 0.5)
        ShowcasePicker("Line cap", selection: $lineCap)
        ShowcaseColorControl("Color", selection: $foregroundColor, supportsOpacity: false)
        ShowcaseSlider("Opacity", value: $opacity, in: 0...1, step: 0.05)
    }

    @ViewBuilder
    func stateView(_ state: PlotState) -> some View {
        Group {
            if #available(iOS 18.0, macOS 15.0, tvOS 18.0, *) {
                stateChart(state)
            } else {
                unavailablePlaceholder
            }
        }
        .frame(height: 100)
    }

    @available(iOS 18.0, macOS 15.0, tvOS 18.0, *)
    @ViewBuilder
    func stateChart(_ state: PlotState) -> some View {
        switch state {
        case .default:
            Chart {
                LinePlot(x: "x", y: "y") { (xVal: Double) in sin(xVal) }
                    .foregroundStyle(Color.accentColor)
                    .lineStyle(StrokeStyle(lineWidth: 2))
            }
            .chartXScale(domain: -10...10)
            .chartYScale(domain: -2...2)
        case .empty:
            Chart {
                LinePlot(
                    [DataPoint](),
                    x: .value("x", \.xVal),
                    y: .value("y", \.yVal),
                )
            }
            .overlay {
                Text("No data")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        case .longContent:
            Chart {
                LinePlot(x: "x", y: "y") { (xVal: Double) in xVal * sin(xVal) }
                    .foregroundStyle(Color.accentColor)
                    .lineStyle(StrokeStyle(lineWidth: 2))
            }
            .chartXScale(domain: -50...50)
            .chartYScale(domain: -60...60)
        }
    }
}

// MARK: - Code generation
private extension LinePlotShowcase {
    var generatedCode: String {
        let widthStr = lineWidth.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(lineWidth))
            : String(lineWidth)
        let colorStr = foregroundColor == .accentColor ? ".accentColor" : "Color(/* configured */)"
        let opacityStr = opacity == 1.0 ? "1.0" : String(format: "%.2f", opacity)

        switch mode {
        case .function:
            return """
            Chart {
                LinePlot(x: "x", y: "y") { x in
                    x * x * 0.1
                }
                .lineStyle(StrokeStyle(lineWidth: \(widthStr), lineCap: .\(lineCap.label)))
                .foregroundStyle(\(colorStr))
                .opacity(\(opacityStr))
            }
            .chartXScale(domain: -10 ... 10)
            .chartYScale(domain: -15 ... 15)
            """
        case .collection:
            return """
            Chart {
                LinePlot(
                    data,
                    x: .value("Index", \\.xVal),
                    y: .value("Value", \\.yVal)
                )
                .lineStyle(StrokeStyle(lineWidth: \(widthStr), lineCap: .\(lineCap.label)))
                .foregroundStyle(\(colorStr))
                .opacity(\(opacityStr))
            }
            """
        case .parametric:
            return """
            Chart {
                LinePlot(x: "x", y: "y", t: "t", domain: 0 ... .pi * 2) { t in
                    (8 * cos(t), 8 * sin(t))
                }
                .lineStyle(StrokeStyle(lineWidth: \(widthStr), lineCap: .\(lineCap.label)))
                .foregroundStyle(\(colorStr))
                .opacity(\(opacityStr))
            }
            .chartXScale(domain: -10 ... 10)
            .chartYScale(domain: -10 ... 10)
            """
        }
    }
}

// MARK: - Supporting types
extension LinePlotShowcase {
    enum PlotMode: ShowcasePickable {
        case function
        case collection
        case parametric

        var label: String {
            switch self {
            case .function: "function"
            case .collection: "collection"
            case .parametric: "parametric"
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

    enum PlotState: ShowcaseState {
        case `default`, empty, longContent

        var caption: String {
            switch self {
            case .default: "Default"
            case .empty: "Empty"
            case .longContent: "Long content"
            }
        }
    }

    struct DataPoint: Identifiable {
        let id: Int
        let xVal: Double
        let yVal: Double
    }

    static let collectionData: [DataPoint] = (-10...10).map { idx in
        DataPoint(id: idx + 10, xVal: Double(idx), yVal: Double(idx) * Double(idx) * 0.1)
    }
}
