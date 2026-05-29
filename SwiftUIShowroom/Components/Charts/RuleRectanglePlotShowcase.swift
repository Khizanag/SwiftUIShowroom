import Charts
import SwiftUI

struct RuleRectanglePlotShowcase: View {
    @State private var markType: MarkTypeOption = .rule
    @State private var foregroundColor: Color = .secondary
    @State private var lineWidth: Double = 1
    @State private var itemOpacity: Double = 0.8

    var body: some View {
        ShowcaseScreen(
            title: "RuleMark & RectangleMark",
            summary: "Reference lines and filled cells for annotating chart data with thresholds or ranges.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension RuleRectanglePlotShowcase {
    var preview: some View {
        chartView(
            type: markType,
            color: foregroundColor,
            strokeWidth: lineWidth,
            opacity: itemOpacity
        )
        .frame(height: 220)
        .padding(DesignSystem.Spacing.small)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Mark type", selection: $markType)
        ShowcaseColorControl("Color", selection: $foregroundColor)
        ShowcaseSlider("Line width", value: $lineWidth, in: 0.5...6, step: 0.5)
        ShowcaseSlider("Opacity", value: $itemOpacity, in: 0.0...1.0, step: 0.05)
    }

    @ViewBuilder func stateView(_ state: PlotState) -> some View {
        switch state {
        case .ruleDefault:
            chartView(type: .rule, color: .secondary, strokeWidth: 1, opacity: 0.8)
                .frame(height: 160)
        case .ruleThick:
            chartView(type: .rule, color: .blue, strokeWidth: 3, opacity: 1.0)
                .frame(height: 160)
        case .rectangleDefault:
            chartView(type: .rectangle, color: .accentColor, strokeWidth: 1, opacity: 0.5)
                .frame(height: 160)
        case .rectangleOpaque:
            chartView(type: .rectangle, color: .green, strokeWidth: 1, opacity: 1.0)
                .frame(height: 160)
        case .empty:
            ContentUnavailableView("No data", systemImage: "chart.bar")
                .frame(height: 160)
        }
    }
}

// MARK: - Chart builder
private extension RuleRectanglePlotShowcase {
    @ViewBuilder func chartView(
        type: MarkTypeOption,
        color: Color,
        strokeWidth: Double,
        opacity: Double
    ) -> some View {
        switch type {
        case .rule:
            Chart(PlotSample.defaultItems) { item in
                RuleMark(x: .value("Value", item.xValue))
                    .lineStyle(StrokeStyle(lineWidth: strokeWidth))
                    .foregroundStyle(color.opacity(opacity))
            }
        case .rectangle:
            Chart(PlotSample.defaultItems) { item in
                RectangleMark(
                    x: .value("Category", item.category),
                    y: .value("Slot", item.slot)
                )
                .foregroundStyle(color.opacity(opacity))
            }
        }
    }
}

// MARK: - Code generation
private extension RuleRectanglePlotShowcase {
    var generatedCode: String {
        let colorLiteral = colorLiteralCode
        let opacityLiteral = String(format: "%.2f", itemOpacity)
        switch markType {
        case .rule:
            return """
            Chart(data) { item in
                RuleMark(x: .value("Value", item.xValue))
                    .lineStyle(StrokeStyle(lineWidth: \(Int(lineWidth))))
                    .foregroundStyle(\(colorLiteral).opacity(\(opacityLiteral)))
            }
            """
        case .rectangle:
            return """
            Chart(data) { item in
                RectangleMark(
                    x: .value("Category", item.category),
                    y: .value("Slot", item.slot)
                )
                .foregroundStyle(\(colorLiteral).opacity(\(opacityLiteral)))
            }
            """
        }
    }

    var colorLiteralCode: String {
        if foregroundColor == .secondary {
            return ".secondary"
        } else {
            return "Color(/* custom */)"
        }
    }
}

// MARK: - Nested enums
extension RuleRectanglePlotShowcase {
    enum MarkTypeOption: ShowcasePickable {
        case rule, rectangle

        var label: String {
            switch self {
            case .rule: "RuleMark"
            case .rectangle: "RectangleMark"
            }
        }
    }

    enum PlotState: ShowcaseState {
        case ruleDefault, ruleThick, rectangleDefault, rectangleOpaque, empty

        var caption: String {
            switch self {
            case .ruleDefault: "Rule — default"
            case .ruleThick: "Rule — thick"
            case .rectangleDefault: "Rectangle — 50% opacity"
            case .rectangleOpaque: "Rectangle — opaque"
            case .empty: "Empty"
            }
        }
    }
}

// MARK: - Data model
extension RuleRectanglePlotShowcase {
    struct PlotSample: Identifiable {
        let id = UUID()
        let xValue: Double
        let category: String
        let slot: String

        static let defaultItems: [PlotSample] = [
            PlotSample(xValue: 10, category: "Mon", slot: "Morning"),
            PlotSample(xValue: 30, category: "Tue", slot: "Afternoon"),
            PlotSample(xValue: 50, category: "Wed", slot: "Morning"),
            PlotSample(xValue: 70, category: "Thu", slot: "Evening"),
            PlotSample(xValue: 90, category: "Fri", slot: "Afternoon"),
        ]
    }
}
