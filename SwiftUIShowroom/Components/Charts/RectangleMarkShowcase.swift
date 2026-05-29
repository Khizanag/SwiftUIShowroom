import Charts
import SwiftUI

struct RectangleMarkShowcase: View {
    @State private var valueColor: Color = .accentColor
    @State private var useContinuousScale = true
    @State private var cellWidth: CellDimensionOption = .ratio
    @State private var cellHeight: CellDimensionOption = .ratio
    @State private var opacity = 1.0

    var body: some View {
        ShowcaseScreen(
            title: "RectangleMark",
            summary: "Fills rectangular cells by intervals on both axes; ideal for heat maps and matrix charts.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension RectangleMarkShowcase {
    enum CellDimensionOption: ShowcasePickable {
        case automatic, ratio, fixed, inset

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .ratio: "ratio(0.9)"
            case .fixed: "fixed(28)"
            case .inset: "inset(2)"
            }
        }

        var codeValue: String {
            switch self {
            case .automatic: ".automatic"
            case .ratio: ".ratio(0.9)"
            case .fixed: ".fixed(28)"
            case .inset: ".inset(2)"
            }
        }

        func markDimension() -> MarkDimension {
            switch self {
            case .automatic: .automatic
            case .ratio: .ratio(0.9)
            case .fixed: .fixed(28)
            case .inset: .inset(2)
            }
        }
    }

    enum HeatMapState: ShowcaseState {
        case `default`, selected, empty, longContent

        var caption: String {
            switch self {
            case .default: "Default"
            case .selected: "Selected cell"
            case .empty: "Empty"
            case .longContent: "Long content"
            }
        }
    }

    struct HeatCell: Identifiable {
        let column: String
        let row: String
        let value: Double
        var id: String { "\(column)-\(row)" }
    }

    struct ChartConfig {
        var color: Color
        var continuous: Bool
        var width: MarkDimension
        var height: MarkDimension
        var itemOpacity: Double
    }
}

// MARK: - Sample data
private extension RectangleMarkShowcase {
    static let heatColumns = ["Mon", "Tue", "Wed", "Thu", "Fri"]
    static let heatRows = ["Morning", "Afternoon", "Evening"]

    static var defaultCells: [HeatCell] {
        let rawValues: [Double] = [
            20, 45, 80, 60, 30,
            55, 90, 70, 40, 65,
            35, 50, 25, 85, 75,
        ]
        var pos = 0
        var result: [HeatCell] = []
        for row in heatRows {
            for col in heatColumns {
                result.append(HeatCell(column: col, row: row, value: rawValues[pos]))
                pos += 1
            }
        }
        return result
    }

    static var longCells: [HeatCell] {
        let extraColumns = heatColumns + ["Sat", "Sun", "Mon+", "Tue+"]
        var result: [HeatCell] = []
        var counter = 0
        for row in heatRows {
            for col in extraColumns {
                let val = Double((counter * 17 + 13) % 100)
                result.append(HeatCell(column: col, row: row, value: val))
                counter += 1
            }
        }
        return result
    }

    var currentConfig: ChartConfig {
        ChartConfig(
            color: valueColor,
            continuous: useContinuousScale,
            width: cellWidth.markDimension(),
            height: cellHeight.markDimension(),
            itemOpacity: opacity,
        )
    }
}

// MARK: - Sub-views
private extension RectangleMarkShowcase {
    var preview: some View {
        heatChart(data: Self.defaultCells, highlightID: nil, config: currentConfig)
            .frame(height: 200)
    }

    @ViewBuilder var controls: some View {
        ShowcaseColorControl("Value color", selection: $valueColor, supportsOpacity: false)
        ShowcaseToggle("Continuous color scale", isOn: $useContinuousScale)
        ShowcasePicker("Cell width", selection: $cellWidth)
        ShowcasePicker("Cell height", selection: $cellHeight)
        ShowcaseSlider("Opacity", value: $opacity, in: 0.0...1.0, step: 0.05)
    }

    @ViewBuilder func stateView(_ state: HeatMapState) -> some View {
        switch state {
        case .default:
            heatChart(data: Self.defaultCells, highlightID: nil, config: currentConfig)
                .frame(height: 140)

        case .selected:
            heatChart(data: Self.defaultCells, highlightID: "Wed-Afternoon", config: currentConfig)
                .frame(height: 140)

        case .empty:
            emptyCellChart()
                .frame(height: 140)
                .overlay {
                    Text("No data")
                        .font(DesignSystem.Font.callout)
                        .foregroundStyle(DesignSystem.Color.secondary)
                }

        case .longContent:
            let wideConfig = ChartConfig(
                color: currentConfig.color,
                continuous: currentConfig.continuous,
                width: .ratio(0.9),
                height: .ratio(0.9),
                itemOpacity: currentConfig.itemOpacity,
            )
            heatChart(data: Self.longCells, highlightID: nil, config: wideConfig)
                .frame(height: 140)
        }
    }
}

// MARK: - Chart builders
private extension RectangleMarkShowcase {
    @ViewBuilder func heatChart(
        data: [HeatCell],
        highlightID: String?,
        config: ChartConfig
    ) -> some View {
        if config.continuous {
            Chart(data) { cell in
                RectangleMark(
                    x: .value("Column", cell.column),
                    y: .value("Row", cell.row),
                    width: config.width,
                    height: config.height,
                )
                .foregroundStyle(by: .value("Value", cell.value))
                .opacity(cellOpacity(id: cell.id, highlightID: highlightID, base: config.itemOpacity))
            }
            .chartForegroundStyleScale(range: Gradient(colors: [.white, config.color]))
        } else {
            Chart(data) { cell in
                RectangleMark(
                    x: .value("Column", cell.column),
                    y: .value("Row", cell.row),
                    width: config.width,
                    height: config.height,
                )
                .foregroundStyle(config.color)
                .opacity(cellOpacity(id: cell.id, highlightID: highlightID, base: config.itemOpacity))
            }
        }
    }

    func emptyCellChart() -> some View {
        Chart {
            RectangleMark(
                x: .value("Column", ""),
                y: .value("Row", ""),
                width: .ratio(0.9),
                height: .ratio(0.9),
            )
            .opacity(0)
        }
    }

    func cellOpacity(id: String, highlightID: String?, base: Double) -> Double {
        guard let highlightID else { return base }
        return id == highlightID ? 1.0 : min(base, 0.35)
    }
}

// MARK: - Code generation
private extension RectangleMarkShowcase {
    var generatedCode: String {
        var lines: [String] = [
            "RectangleMark(",
            "    x: .value(\"Column\", item.column),",
            "    y: .value(\"Row\", item.row),",
            "    width: \(cellWidth.codeValue),",
            "    height: \(cellHeight.codeValue)",
            ")",
        ]
        if useContinuousScale {
            lines.append(".foregroundStyle(by: .value(\"Value\", item.value))")
        } else {
            lines.append(".foregroundStyle(\(colorCode))")
        }
        if opacity < 1.0 {
            lines.append(String(format: ".opacity(%.2f)", opacity))
        }
        if useContinuousScale {
            lines.append("// Pair with:")
            lines.append("// .chartForegroundStyleScale(")
            lines.append("//     range: Gradient(colors: [.white, \(colorCode)])")
            lines.append("// )")
        }
        return lines.joined(separator: "\n")
    }

    var colorCode: String {
        valueColor == .accentColor ? "Color.accentColor" : "Color(/* configured */)"
    }
}
