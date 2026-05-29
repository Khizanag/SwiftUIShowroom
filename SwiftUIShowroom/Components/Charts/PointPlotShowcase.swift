import Charts
import SwiftUI

@available(iOS 18.0, macOS 15.0, tvOS 18.0, *)
struct PointPlotShowcase: View {
    @State private var symbolSize: Double = 40
    @State private var pointColor: Color = .accentColor
    @State private var opacity: Double = 0.7
    @State private var groupByCategory = false

    var body: some View {
        ShowcaseScreen(
            title: "PointPlot (vectorized)",
            summary: "Vectorized point content for plotting large scatter collections efficiently.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
@available(iOS 18.0, macOS 15.0, tvOS 18.0, *)
extension PointPlotShowcase {
    struct DataPoint: Identifiable {
        let id: Int
        let xValue: Double
        let yValue: Double
        let category: String

        static let sample: [DataPoint] = [
            DataPoint(id: 0, xValue: 1.2, yValue: 2.5, category: "A"),
            DataPoint(id: 1, xValue: 2.8, yValue: 5.1, category: "B"),
            DataPoint(id: 2, xValue: 3.5, yValue: 3.8, category: "A"),
            DataPoint(id: 3, xValue: 5.0, yValue: 7.2, category: "C"),
            DataPoint(id: 4, xValue: 6.3, yValue: 4.9, category: "B"),
            DataPoint(id: 5, xValue: 7.8, yValue: 8.1, category: "A"),
            DataPoint(id: 6, xValue: 8.5, yValue: 6.3, category: "C"),
            DataPoint(id: 7, xValue: 9.1, yValue: 9.5, category: "B"),
        ]

        static let dense: [DataPoint] = (0..<80).map { idx in
            DataPoint(
                id: idx,
                xValue: Double(idx % 10) + Double(idx % 7) * 0.13,
                yValue: Double(idx % 8) + Double(idx % 5) * 0.21,
                category: ["A", "B", "C"][idx % 3],
            )
        }
    }

    enum PointPlotState: ShowcaseState {
        case `default`, empty, dense

        var caption: String {
            switch self {
            case .default: "Default"
            case .empty: "Empty"
            case .dense: "Dense (large dataset)"
            }
        }

        var data: [DataPoint] {
            switch self {
            case .default: DataPoint.sample
            case .empty: []
            case .dense: DataPoint.dense
            }
        }
    }
}

// MARK: - Sub-views
@available(iOS 18.0, macOS 15.0, tvOS 18.0, *)
private extension PointPlotShowcase {
    var preview: some View {
        chart(data: DataPoint.sample)
            .frame(height: 220)
            .chartXScale(domain: 0...10)
            .chartYScale(domain: 0...10)
            .padding(DesignSystem.Spacing.small)
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseSlider("Symbol size", value: $symbolSize, in: 10...200, step: 10)
        ShowcaseColorControl("Point color", selection: $pointColor, supportsOpacity: false)
        ShowcaseSlider("Opacity", value: $opacity, in: 0...1, step: 0.05)
        ShowcaseToggle("Group by category", isOn: $groupByCategory)
    }

    @ViewBuilder
    func stateView(_ state: PointPlotState) -> some View {
        chart(data: state.data)
            .frame(height: 120)
            .chartXScale(domain: 0...10)
            .chartYScale(domain: 0...10)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
    }

    @ViewBuilder
    func chart(data: [DataPoint]) -> some View {
        if data.isEmpty {
            ContentUnavailableView("No data", systemImage: "chart.dots.scatter")
                .frame(height: 120)
        } else if groupByCategory {
            Chart {
                PointPlot(
                    data,
                    x: .value("X", \.xValue),
                    y: .value("Y", \.yValue),
                )
                .symbolSize(by: .value("Size", \.id))
                .foregroundStyle(by: .value("Category", \.category))
                .opacity(opacity)
            }
            .chartSymbolSizeScale(mapping: { (_: Int) in CGFloat(symbolSize) })
        } else {
            Chart {
                PointPlot(
                    data,
                    x: .value("X", \.xValue),
                    y: .value("Y", \.yValue),
                )
                .symbolSize(by: .value("Size", \.id))
                .foregroundStyle(pointColor)
                .opacity(opacity)
            }
            .chartSymbolSizeScale(mapping: { (_: Int) in CGFloat(symbolSize) })
        }
    }
}

// MARK: - Code generation
@available(iOS 18.0, macOS 15.0, tvOS 18.0, *)
private extension PointPlotShowcase {
    var generatedCode: String {
        let opacityStr = opacity.formatted(.number.precision(.fractionLength(0...2)))
        let sizeStr = Int(symbolSize)
        if groupByCategory {
            return """
            Chart {
                PointPlot(
                    data,
                    x: .value("X", \\.x),
                    y: .value("Y", \\.y)
                )
                .symbolSize(by: .value("Size", \\.id))
                .foregroundStyle(by: .value("Category", \\.category))
                .opacity(\(opacityStr))
            }
            .chartSymbolSizeScale(mapping: { (_: Int) in \(sizeStr) })
            """
        } else {
            return """
            Chart {
                PointPlot(
                    data,
                    x: .value("X", \\.x),
                    y: .value("Y", \\.y)
                )
                .symbolSize(by: .value("Size", \\.id))
                .foregroundStyle(\(colorCode))
                .opacity(\(opacityStr))
            }
            .chartSymbolSizeScale(mapping: { (_: Int) in \(sizeStr) })
            """
        }
    }

    var colorCode: String {
        pointColor == .accentColor ? ".accentColor" : "Color(/* configured */)"
    }
}
