import Charts
import SwiftUI

@available(iOS 18.0, macOS 15.0, tvOS 18.0, *)
struct SectorPlotShowcase: View {
    struct SliceItem: Identifiable {
        let name: String
        let value: Double
        var id: String { name }

        static let defaultData: [SliceItem] = [
            SliceItem(name: "Swift", value: 40),
            SliceItem(name: "SwiftUI", value: 25),
            SliceItem(name: "UIKit", value: 20),
            SliceItem(name: "Combine", value: 10),
            SliceItem(name: "Other", value: 5),
        ]

        static let longData: [SliceItem] = [
            SliceItem(name: "Swift", value: 30),
            SliceItem(name: "SwiftUI", value: 20),
            SliceItem(name: "UIKit", value: 15),
            SliceItem(name: "Combine", value: 12),
            SliceItem(name: "CoreData", value: 10),
            SliceItem(name: "CloudKit", value: 8),
            SliceItem(name: "Other", value: 5),
        ]
    }

    enum SectorPlotState: ShowcaseState {
        case `default`
        case empty
        case longContent

        var caption: String {
            switch self {
            case .default: "Default (donut)"
            case .empty: "Empty"
            case .longContent: "7 slices"
            }
        }

        var data: [SliceItem] {
            switch self {
            case .default: SliceItem.defaultData
            case .empty: []
            case .longContent: SliceItem.longData
            }
        }

        var innerRatio: Double {
            switch self {
            case .default: 0.5
            case .empty: 0.5
            case .longContent: 0.618
            }
        }

        var angularInset: CGFloat {
            switch self {
            case .default: 1.5
            case .empty: 1.5
            case .longContent: 2
            }
        }
    }

    @State private var innerRadiusRatio: Double = 0.5
    @State private var angularInset: Double = 1.5

    var body: some View {
        ShowcaseScreen(
            title: "SectorPlot",
            summary: "Renders a pie or donut chart from a collection with one vectorized plot declaration.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
@available(iOS 18.0, macOS 15.0, tvOS 18.0, *)
private extension SectorPlotShowcase {
    var preview: some View {
        chart(
            data: SliceItem.defaultData,
            innerRatio: innerRadiusRatio,
            angularInset: CGFloat(angularInset)
        )
        .frame(width: 240, height: 240)
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseSlider("Inner radius ratio", value: $innerRadiusRatio, in: 0...0.9, step: 0.01)
        ShowcaseSlider("Angular inset", value: $angularInset, in: 0...8, step: 0.5)
    }

    @ViewBuilder
    func stateView(_ state: SectorPlotState) -> some View {
        chart(
            data: state.data,
            innerRatio: state.innerRatio,
            angularInset: state.angularInset
        )
        .frame(width: 140, height: 140)
    }
}

// MARK: - Chart builder
@available(iOS 18.0, macOS 15.0, tvOS 18.0, *)
private extension SectorPlotShowcase {
    @ViewBuilder
    func chart(
        data: [SliceItem],
        innerRatio: Double,
        angularInset: CGFloat
    ) -> some View {
        if data.isEmpty {
            ContentUnavailableView("No data", systemImage: "chart.pie")
        } else {
            Chart {
                SectorPlot(
                    data,
                    angle: .value("Value", \.value),
                    innerRadius: .ratio(innerRatio),
                    angularInset: angularInset
                )
                .foregroundStyle(by: .value("Category", \.name))
            }
        }
    }
}

// MARK: - Code generation
@available(iOS 18.0, macOS 15.0, tvOS 18.0, *)
private extension SectorPlotShowcase {
    var generatedCode: String {
        let innerLine = String(format: "    innerRadius: .ratio(%.2f),", innerRadiusRatio)
        let angularLine = String(format: "    angularInset: %.1f", angularInset)
        return """
        Chart {
            SectorPlot(
                data,
                angle: .value("Value", \\.value),
        \(innerLine)
        \(angularLine)
            )
            .foregroundStyle(by: .value("Category", \\.name))
        }
        """
    }
}
