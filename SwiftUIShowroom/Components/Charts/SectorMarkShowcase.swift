import SwiftUI
import Charts

struct SectorMarkShowcase: View {
    @State private var innerRadiusRatio: Double = 0.618
    @State private var outerRadiusInset: Double = 0
    @State private var angularInset: Double = 1
    @State private var cornerRadius: Double = 4
    @State private var groupByCategory: Bool = true

    var body: some View {
        ShowcaseScreen(
            title: "SectorMark",
            summary: "Renders a pie or donut sector sized by angular proportion; donut when innerRadius > 0.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension SectorMarkShowcase {
    var preview: some View {
        chart(config: ChartConfig(
            data: SectorMarkShowcase.defaultData,
            innerRatio: innerRadiusRatio,
            outerInset: CGFloat(outerRadiusInset),
            angularInset: CGFloat(angularInset),
            cornerRadius: CGFloat(cornerRadius),
            groupByCategory: groupByCategory
        ))
        .frame(width: 240, height: 240)
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseSlider("Inner radius ratio", value: $innerRadiusRatio, in: 0...0.9, step: 0.01)
        ShowcaseSlider("Outer radius inset", value: $outerRadiusInset, in: 0...40, step: 1)
        ShowcaseSlider("Angular inset", value: $angularInset, in: 0...8, step: 0.5)
        ShowcaseSlider("Corner radius", value: $cornerRadius, in: 0...12, step: 1)
        ShowcaseToggle("Group by category", isOn: $groupByCategory)
    }

    @ViewBuilder
    func stateView(_ state: SectorState) -> some View {
        chart(config: ChartConfig(
            data: state.data,
            innerRatio: state.innerRatio,
            outerInset: 0,
            angularInset: state.angularInset,
            cornerRadius: 4,
            groupByCategory: true
        ))
        .frame(width: 140, height: 140)
    }
}

// MARK: - Chart builder
private extension SectorMarkShowcase {
    struct ChartConfig {
        var data: [SliceData]
        var innerRatio: Double
        var outerInset: CGFloat
        var angularInset: CGFloat
        var cornerRadius: CGFloat
        var groupByCategory: Bool
    }

    @ChartContentBuilder
    func sectors(config: ChartConfig) -> some ChartContent {
        ForEach(config.data) { item in
            if config.groupByCategory {
                SectorMark(
                    angle: .value("Value", item.value),
                    innerRadius: .ratio(config.innerRatio),
                    outerRadius: .inset(config.outerInset),
                    angularInset: config.angularInset
                )
                .cornerRadius(config.cornerRadius)
                .foregroundStyle(by: .value("Category", item.name))
            } else {
                SectorMark(
                    angle: .value("Value", item.value),
                    innerRadius: .ratio(config.innerRatio),
                    outerRadius: .inset(config.outerInset),
                    angularInset: config.angularInset
                )
                .cornerRadius(config.cornerRadius)
            }
        }
    }

    func chart(config: ChartConfig) -> some View {
        Chart {
            sectors(config: config)
        }
    }
}

// MARK: - Data
private extension SectorMarkShowcase {
    struct SliceData: Identifiable {
        let name: String
        let value: Double
        var id: String { name }
    }

    static let defaultData: [SliceData] = [
        SliceData(name: "Swift", value: 40),
        SliceData(name: "SwiftUI", value: 25),
        SliceData(name: "UIKit", value: 20),
        SliceData(name: "Combine", value: 10),
        SliceData(name: "Other", value: 5),
    ]

    static let selectedData: [SliceData] = [
        SliceData(name: "Swift", value: 55),
        SliceData(name: "SwiftUI", value: 30),
        SliceData(name: "UIKit", value: 10),
        SliceData(name: "Other", value: 5),
    ]

    static let longData: [SliceData] = [
        SliceData(name: "Swift", value: 30),
        SliceData(name: "SwiftUI", value: 20),
        SliceData(name: "UIKit", value: 15),
        SliceData(name: "Combine", value: 12),
        SliceData(name: "CoreData", value: 10),
        SliceData(name: "CloudKit", value: 8),
        SliceData(name: "Other", value: 5),
    ]
}

// MARK: - States
private extension SectorMarkShowcase {
    enum SectorState: ShowcaseState {
        case `default`
        case selected
        case empty
        case longContent

        var caption: String {
            switch self {
            case .default: "Default (donut)"
            case .selected: "Pie (no hole)"
            case .empty: "Empty"
            case .longContent: "7 slices"
            }
        }

        var data: [SliceData] {
            switch self {
            case .default: SectorMarkShowcase.defaultData
            case .selected: SectorMarkShowcase.selectedData
            case .empty: []
            case .longContent: SectorMarkShowcase.longData
            }
        }

        var innerRatio: Double {
            switch self {
            case .default, .longContent: 0.618
            case .selected: 0
            case .empty: 0.5
            }
        }

        var angularInset: CGFloat {
            switch self {
            case .default, .selected, .empty: 1
            case .longContent: 2
            }
        }
    }
}

// MARK: - Code generation
private extension SectorMarkShowcase {
    var generatedCode: String {
        let innerLine = String(format: "    innerRadius: .ratio(%.3f),", innerRadiusRatio)
        let outerLine = String(format: "    outerRadius: .inset(%.0f),", outerRadiusInset)
        let angularLine = String(format: "    angularInset: %.1f", angularInset)
        let cornerLine = String(format: ".cornerRadius(%.0f)", cornerRadius)
        let foregroundLine = groupByCategory
            ? ".foregroundStyle(by: .value(\"Category\", item.name))"
            : "// single foreground style"

        return """
        Chart {
            ForEach(data) { item in
                SectorMark(
                    angle: .value("Value", item.value),
        \(innerLine)
        \(outerLine)
        \(angularLine)
                )
                \(cornerLine)
                \(foregroundLine)
            }
        }
        """
    }
}
