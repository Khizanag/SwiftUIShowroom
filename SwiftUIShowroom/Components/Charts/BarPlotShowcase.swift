import Charts
import SwiftUI

@available(iOS 18.0, macOS 15.0, tvOS 18.0, *)
struct BarPlotShowcase: View {
    @State private var barColor: Color = .accentColor
    @State private var groupByKeyPath = false

    var body: some View {
        ShowcaseScreen(
            title: "BarPlot (vectorized)",
            summary: "Vectorized bar mark that plots an entire collection in one declaration.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }

    // MARK: - Nested types
    struct DataPoint: Identifiable {
        let id = UUID()
        let category: String
        let value: Double
        let group: String
    }

    enum BarPlotState: ShowcaseState {
        case `default`, empty, longContent

        var caption: String {
            switch self {
            case .default: "Default"
            case .empty: "Empty"
            case .longContent: "Long (12 bars)"
            }
        }

        var data: [DataPoint] {
            switch self {
            case .default: DataPoint.sample
            case .empty: []
            case .longContent: DataPoint.extended
            }
        }
    }
}

// MARK: - Sub-views
@available(iOS 18.0, macOS 15.0, tvOS 18.0, *)
private extension BarPlotShowcase {
    var preview: some View {
        chart(data: DataPoint.sample)
            .frame(height: 220)
            .padding(DesignSystem.Spacing.small)
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseColorControl("Bar color", selection: $barColor, supportsOpacity: false)
        ShowcaseToggle("Group by category", isOn: $groupByKeyPath)
    }

    @ViewBuilder
    func stateView(_ state: BarPlotState) -> some View {
        chart(data: state.data)
            .frame(height: 160)
    }

    @ViewBuilder
    func chart(data: [DataPoint]) -> some View {
        if data.isEmpty {
            ContentUnavailableView("No data", systemImage: "chart.bar")
                .frame(height: 160)
        } else if groupByKeyPath {
            Chart {
                BarPlot(
                    data,
                    x: .value("Category", \.category),
                    y: .value("Value", \.value),
                )
                .foregroundStyle(by: .value("Group", \.group))
            }
        } else {
            Chart {
                BarPlot(
                    data,
                    x: .value("Category", \.category),
                    y: .value("Value", \.value),
                )
                .foregroundStyle(barColor)
            }
        }
    }
}

// MARK: - Sample data
@available(iOS 18.0, macOS 15.0, tvOS 18.0, *)
private extension BarPlotShowcase.DataPoint {
    static let sample: [BarPlotShowcase.DataPoint] = [
        BarPlotShowcase.DataPoint(category: "Jan", value: 42, group: "A"),
        BarPlotShowcase.DataPoint(category: "Feb", value: 68, group: "B"),
        BarPlotShowcase.DataPoint(category: "Mar", value: 55, group: "A"),
        BarPlotShowcase.DataPoint(category: "Apr", value: 89, group: "B"),
        BarPlotShowcase.DataPoint(category: "May", value: 73, group: "A"),
    ]

    static let extended: [BarPlotShowcase.DataPoint] = [
        BarPlotShowcase.DataPoint(category: "Jan", value: 42, group: "A"),
        BarPlotShowcase.DataPoint(category: "Feb", value: 68, group: "B"),
        BarPlotShowcase.DataPoint(category: "Mar", value: 55, group: "A"),
        BarPlotShowcase.DataPoint(category: "Apr", value: 89, group: "B"),
        BarPlotShowcase.DataPoint(category: "May", value: 73, group: "A"),
        BarPlotShowcase.DataPoint(category: "Jun", value: 61, group: "B"),
        BarPlotShowcase.DataPoint(category: "Jul", value: 84, group: "A"),
        BarPlotShowcase.DataPoint(category: "Aug", value: 47, group: "B"),
        BarPlotShowcase.DataPoint(category: "Sep", value: 92, group: "A"),
        BarPlotShowcase.DataPoint(category: "Oct", value: 38, group: "B"),
        BarPlotShowcase.DataPoint(category: "Nov", value: 76, group: "A"),
        BarPlotShowcase.DataPoint(category: "Dec", value: 59, group: "B"),
    ]
}

// MARK: - Code generation
@available(iOS 18.0, macOS 15.0, tvOS 18.0, *)
private extension BarPlotShowcase {
    var generatedCode: String {
        if groupByKeyPath {
            return """
            Chart {
                BarPlot(
                    data,
                    x: .value("Category", \\.category),
                    y: .value("Value", \\.value)
                )
                .foregroundStyle(by: .value("Group", \\.group))
            }
            """
        } else {
            return """
            Chart {
                BarPlot(
                    data,
                    x: .value("Category", \\.category),
                    y: .value("Value", \\.value)
                )
                .foregroundStyle(\(colorCode))
            }
            """
        }
    }

    var colorCode: String {
        barColor == .accentColor ? ".accentColor" : "Color(/* configured */)"
    }
}
