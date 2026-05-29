import Charts
import SwiftUI

struct ChartForegroundStyleScaleShowcase: View {
    enum ScaleModeOption: ShowcasePickable {
        case discrete, continuous

        var label: String {
            switch self {
            case .discrete: "Discrete"
            case .continuous: "Continuous"
            }
        }
    }

    enum ForegroundScaleState: ShowcaseState {
        case `default`, manyCategories

        var caption: String {
            switch self {
            case .default: "Default (3 categories)"
            case .manyCategories: "Many categories"
            }
        }
    }

    struct SeriesItem: Identifiable {
        let id: UUID = UUID()
        let category: String
        let group: String
        let value: Double
    }

    @State private var scaleMode: ScaleModeOption = .discrete
    @State private var paletteColor1: Color = .blue
    @State private var paletteColor2: Color = .green
    @State private var paletteColor3: Color = .orange

    var body: some View {
        ShowcaseScreen(
            title: "Foreground Style Scale",
            summary: "Maps categorical or continuous data to colors via chartForegroundStyleScale.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sample data
private extension ChartForegroundStyleScaleShowcase {
    static let defaultItems: [SeriesItem] = [
        SeriesItem(category: "Jan", group: "Alpha", value: 40),
        SeriesItem(category: "Feb", group: "Alpha", value: 55),
        SeriesItem(category: "Mar", group: "Alpha", value: 70),
        SeriesItem(category: "Jan", group: "Beta", value: 60),
        SeriesItem(category: "Feb", group: "Beta", value: 45),
        SeriesItem(category: "Mar", group: "Beta", value: 80),
        SeriesItem(category: "Jan", group: "Gamma", value: 30),
        SeriesItem(category: "Feb", group: "Gamma", value: 75),
        SeriesItem(category: "Mar", group: "Gamma", value: 50),
    ]

    static let manyItems: [SeriesItem] = {
        let groups = ["Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta"]
        let months = ["Jan", "Feb", "Mar"]
        var items: [SeriesItem] = []
        var seed = 7
        for group in groups {
            for month in months {
                let val = Double((seed * 13 + 17) % 80 + 20)
                items.append(SeriesItem(category: month, group: group, value: val))
                seed += 3
            }
        }
        return items
    }()

    static let continuousItems: [SeriesItem] = (0..<8).map { index in
        SeriesItem(
            category: "Item \(index + 1)",
            group: "Value",
            value: Double(index * 12 + 10)
        )
    }
}

// MARK: - Sub-views
private extension ChartForegroundStyleScaleShowcase {
    var preview: some View {
        Group {
            if scaleMode == .continuous {
                continuousChart(items: Self.continuousItems)
            } else {
                discreteChart(items: Self.defaultItems)
            }
        }
        .frame(height: 220)
        .padding(DesignSystem.Spacing.small)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Scale mode", selection: $scaleMode)
        ShowcaseColorControl("Color 1", selection: $paletteColor1, supportsOpacity: false)
        ShowcaseColorControl("Color 2", selection: $paletteColor2, supportsOpacity: false)
        if scaleMode == .discrete {
            ShowcaseColorControl("Color 3", selection: $paletteColor3, supportsOpacity: false)
        }
    }

    @ViewBuilder func stateView(_ state: ForegroundScaleState) -> some View {
        switch state {
        case .default:
            discreteChart(items: Self.defaultItems)
                .frame(height: 140)
                .padding(DesignSystem.Spacing.xSmall)
        case .manyCategories:
            discreteChart(items: Self.manyItems)
                .frame(height: 140)
                .padding(DesignSystem.Spacing.xSmall)
        }
    }
}

// MARK: - Chart builders
private extension ChartForegroundStyleScaleShowcase {
    func discreteChart(items: [SeriesItem]) -> some View {
        Chart(items) { item in
            BarMark(
                x: .value("Category", item.category),
                y: .value("Value", item.value)
            )
            .foregroundStyle(by: .value("Group", item.group))
        }
        .chartForegroundStyleScale(
            range: [paletteColor1, paletteColor2, paletteColor3]
        )
    }

    func continuousChart(items: [SeriesItem]) -> some View {
        Chart(items) { item in
            BarMark(
                x: .value("Category", item.category),
                y: .value("Value", item.value)
            )
            .foregroundStyle(by: .value("Value", item.value))
        }
        .chartForegroundStyleScale(
            range: [paletteColor1, paletteColor2]
        )
    }
}

// MARK: - Code generation
private extension ChartForegroundStyleScaleShowcase {
    var generatedCode: String {
        var lines: [String] = [
            "Chart(data) { item in",
            "    BarMark(",
            "        x: .value(\"Category\", item.category),",
            "        y: .value(\"Value\", item.value)",
            "    )",
        ]
        if scaleMode == .continuous {
            lines.append("    .foregroundStyle(by: .value(\"Value\", item.value))")
            lines.append("}")
            lines.append(".chartForegroundStyleScale(")
            lines.append("    range: [\(colorLabel(paletteColor1)), \(colorLabel(paletteColor2))]")
            lines.append(")")
        } else {
            lines.append("    .foregroundStyle(by: .value(\"Group\", item.group))")
            lines.append("}")
            lines.append(".chartForegroundStyleScale(")
            let colors = "\(colorLabel(paletteColor1)), \(colorLabel(paletteColor2)), \(colorLabel(paletteColor3))"
            lines.append("    range: [\(colors)]")
            lines.append(")")
        }
        return lines.joined(separator: "\n")
    }

    func colorLabel(_ color: Color) -> String {
        if color == .blue { return ".blue" }
        if color == .green { return ".green" }
        if color == .orange { return ".orange" }
        if color == .red { return ".red" }
        if color == .purple { return ".purple" }
        if color == .yellow { return ".yellow" }
        if color == .pink { return ".pink" }
        return "Color(/* configured */)"
    }
}
