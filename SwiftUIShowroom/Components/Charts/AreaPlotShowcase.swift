import Charts
import SwiftUI

struct AreaPlotShowcase: View {
    @State private var mode: PlotMode = .function
    @State private var fillColor: Color = .accentColor
    @State private var useGradient = true
    @State private var opacity: Double = 0.6

    var body: some View {
        ShowcaseScreen(
            title: "AreaPlot (function)",
            summary: "Vectorized area content for whole collections and for filling under a plotted function.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AreaPlotShowcase {
    var preview: some View {
        Group {
            if #available(iOS 18.0, macOS 15.0, tvOS 18.0, *) {
                liveChart
            } else {
                unavailableOverlay
            }
        }
        .frame(height: 220)
        .padding(DesignSystem.Spacing.small)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Mode", selection: $mode)
        ShowcaseColorControl("Fill color", selection: $fillColor, supportsOpacity: false)
        ShowcaseToggle("Gradient fill", isOn: $useGradient)
        ShowcaseSlider("Opacity", value: $opacity, in: 0...1, step: 0.05)
    }

    @ViewBuilder
    func stateView(_ state: AreaPlotState) -> some View {
        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, *) {
            state.chart
        } else {
            unavailableOverlay
                .frame(height: 100)
        }
    }
}

// MARK: - Live chart
@available(iOS 18.0, macOS 15.0, tvOS 18.0, *)
private extension AreaPlotShowcase {
    var resolvedStyle: AnyShapeStyle {
        useGradient
            ? AnyShapeStyle(
                LinearGradient(
                    colors: [fillColor, fillColor.opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            : AnyShapeStyle(fillColor)
    }

    @ViewBuilder var liveChart: some View {
        switch mode {
        case .function:
            functionChart(style: resolvedStyle, opacity: opacity)
        case .band:
            bandChart(style: resolvedStyle, opacity: opacity)
        case .collection:
            collectionChart(style: resolvedStyle, opacity: opacity)
        }
    }

    func functionChart(style: AnyShapeStyle, opacity: Double) -> some View {
        Chart {
            AreaPlot(x: "x", y: "y") { (xVal: Double) in
                sin(xVal)
            }
            .foregroundStyle(style)
            .opacity(opacity)
        }
        .chartXScale(domain: -Double.pi * 2 ... Double.pi * 2)
        .chartYScale(domain: -1.5 ... 1.5)
    }

    func bandChart(style: AnyShapeStyle, opacity: Double) -> some View {
        Chart {
            AreaPlot(x: "x", yStart: "min", yEnd: "max") { (xVal: Double) in
                (yStart: cos(xVal) - 0.3, yEnd: cos(xVal) + 0.3)
            }
            .foregroundStyle(style)
            .opacity(opacity)
        }
        .chartXScale(domain: -Double.pi * 2 ... Double.pi * 2)
        .chartYScale(domain: -1.8 ... 1.8)
    }

    func collectionChart(style: AnyShapeStyle, opacity: Double) -> some View {
        Chart {
            AreaPlot(
                AreaPlotShowcase.samplePoints,
                x: .value("x", \.xVal),
                y: .value("y", \.yVal)
            )
            .foregroundStyle(style)
            .opacity(opacity)
        }
        .chartXScale(domain: 0 ... 11)
        .chartYScale(domain: 0 ... 100)
    }
}

// MARK: - Unavailable fallback
private extension AreaPlotShowcase {
    var unavailableOverlay: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(DesignSystem.Color.cardBackground)
            .overlay {
                Text("Requires iOS 18 / macOS 15 / tvOS 18")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
    }
}

// MARK: - State gallery views
@available(iOS 18.0, macOS 15.0, tvOS 18.0, *)
private extension AreaPlotShowcase.AreaPlotState {
    @ViewBuilder var chart: some View {
        switch self {
        case .function:
            Chart {
                AreaPlot(x: "x", y: "y") { (xVal: Double) in
                    sin(xVal)
                }
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.accentColor, Color.accentColor.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .opacity(0.6)
            }
            .chartXScale(domain: -Double.pi * 2 ... Double.pi * 2)
            .chartYScale(domain: -1.5 ... 1.5)
            .frame(height: 120)

        case .band:
            Chart {
                AreaPlot(x: "x", yStart: "min", yEnd: "max") { (xVal: Double) in
                    (yStart: cos(xVal) - 0.3, yEnd: cos(xVal) + 0.3)
                }
                .foregroundStyle(Color.accentColor)
                .opacity(0.5)
            }
            .chartXScale(domain: -Double.pi * 2 ... Double.pi * 2)
            .chartYScale(domain: -1.8 ... 1.8)
            .frame(height: 120)

        case .collection:
            Chart {
                AreaPlot(
                    AreaPlotShowcase.samplePoints,
                    x: .value("x", \.xVal),
                    y: .value("y", \.yVal)
                )
                .foregroundStyle(Color.accentColor)
                .opacity(0.7)
            }
            .chartXScale(domain: 0 ... 11)
            .chartYScale(domain: 0 ... 100)
            .frame(height: 120)

        case .empty:
            Chart {
                AreaPlot(
                    [AreaPlotShowcase.SamplePoint](),
                    x: .value("x", \.xVal),
                    y: .value("y", \.yVal)
                )
            }
            .frame(height: 120)
            .overlay {
                Text("No data")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
    }
}

// MARK: - Sample data
extension AreaPlotShowcase {
    struct SamplePoint: Identifiable, Sendable {
        let id: Int
        let xVal: Double
        let yVal: Double
    }

    static let samplePoints: [SamplePoint] = [
        SamplePoint(id: 0, xVal: 0, yVal: 10),
        SamplePoint(id: 1, xVal: 1, yVal: 25),
        SamplePoint(id: 2, xVal: 2, yVal: 18),
        SamplePoint(id: 3, xVal: 3, yVal: 40),
        SamplePoint(id: 4, xVal: 4, yVal: 32),
        SamplePoint(id: 5, xVal: 5, yVal: 55),
        SamplePoint(id: 6, xVal: 6, yVal: 48),
        SamplePoint(id: 7, xVal: 7, yVal: 70),
        SamplePoint(id: 8, xVal: 8, yVal: 60),
        SamplePoint(id: 9, xVal: 9, yVal: 80),
        SamplePoint(id: 10, xVal: 10, yVal: 72),
        SamplePoint(id: 11, xVal: 11, yVal: 90),
    ]
}

// MARK: - Code generation
private extension AreaPlotShowcase {
    var generatedCode: String {
        let stylePart: String
        if useGradient {
            stylePart = """
            .foregroundStyle(
                LinearGradient(
                    colors: [\(colorCode), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            """
        } else {
            stylePart = ".foregroundStyle(\(colorCode))"
        }
        let opacityFormatted = opacity.formatted(.number.precision(.fractionLength(0...2)))

        switch mode {
        case .function:
            return """
            Chart {
                AreaPlot(x: "x", y: "y") { x in
                    sin(x)
                }
            \(stylePart)
                .opacity(\(opacityFormatted))
            }
            .chartXScale(domain: -.pi * 2 ... .pi * 2)
            .chartYScale(domain: -1.5 ... 1.5)
            """
        case .band:
            return """
            Chart {
                AreaPlot(x: "x", yStart: "min", yEnd: "max") { x in
                    (yStart: cos(x) - 0.3, yEnd: cos(x) + 0.3)
                }
            \(stylePart)
                .opacity(\(opacityFormatted))
            }
            .chartXScale(domain: -.pi * 2 ... .pi * 2)
            .chartYScale(domain: -1.8 ... 1.8)
            """
        case .collection:
            return """
            Chart {
                AreaPlot(
                    data,
                    x: .value("x", \\.xVal),
                    y: .value("y", \\.yVal)
                )
            \(stylePart)
                .opacity(\(opacityFormatted))
            }
            """
        }
    }

    var colorCode: String {
        fillColor == .accentColor ? ".accentColor" : "Color(/* configured */)"
    }
}

// MARK: - Nested enums
extension AreaPlotShowcase {
    enum PlotMode: ShowcasePickable {
        case function, band, collection

        var label: String {
            switch self {
            case .function: "function"
            case .band: "band"
            case .collection: "collection"
            }
        }
    }

    enum AreaPlotState: ShowcaseState {
        case function, band, collection, empty

        var caption: String {
            switch self {
            case .function: "Function (sin x)"
            case .band: "Band (cos ± 0.3)"
            case .collection: "Collection"
            case .empty: "Empty data"
            }
        }
    }
}
