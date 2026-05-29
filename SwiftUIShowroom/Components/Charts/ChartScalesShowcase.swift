import Charts
import SwiftUI

struct ChartScalesShowcase: View {
    @State private var axis: AxisOption = .yAxis
    @State private var scaleType: ScaleTypeOption = .linear
    @State private var useFixedDomain: Bool = false
    @State private var domainLower: Double = 0
    @State private var domainUpper: Double = 100

    var body: some View {
        ShowcaseScreen(
            title: "Scales & Domains",
            summary: "Controls data-to-plot mapping via chartXScale/chartYScale domain, range, and scale type.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ChartScalesShowcase {
    var preview: some View {
        scaledChart(data: ScaleSampleData.positiveData)
            .frame(height: 220)
            .padding(DesignSystem.Spacing.small)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Axis", selection: $axis)
        ShowcasePicker("Scale type", selection: $scaleType)
        ShowcaseToggle("Fixed domain", isOn: $useFixedDomain)
        ShowcaseSlider("Domain lower", value: $domainLower, in: -100...100, step: 10)
        ShowcaseSlider("Domain upper", value: $domainUpper, in: 0...1000, step: 10)
    }

    @ViewBuilder
    func stateView(_ state: ScaleState) -> some View {
        chartForState(state)
            .frame(height: 120)
            .padding(DesignSystem.Spacing.xSmall)
    }

    func baseChart(data: [ScaleSampleData]) -> some View {
        Chart(data) { item in
            BarMark(
                x: .value("Category", item.category),
                y: .value("Value", item.value),
            )
            .foregroundStyle(DesignSystem.Color.accent)
        }
    }

    @ViewBuilder
    func scaledChart(data: [ScaleSampleData]) -> some View {
        let lower = min(domainLower, domainUpper - 1)
        let upper = max(domainUpper, lower + 1)
        if axis == .xAxis {
            if useFixedDomain {
                baseChart(data: data).chartXScale(domain: lower...upper, type: scaleType.scaleType)
            } else {
                baseChart(data: data).chartXScale(type: scaleType.scaleType)
            }
        } else {
            if useFixedDomain {
                baseChart(data: data).chartYScale(domain: lower...upper, type: scaleType.scaleType)
            } else {
                baseChart(data: data).chartYScale(type: scaleType.scaleType)
            }
        }
    }

    @ViewBuilder
    func chartForState(_ state: ScaleState) -> some View {
        switch state {
        case .default:
            baseChart(data: ScaleSampleData.positiveData).chartYScale(type: .linear)
        case .logScale:
            baseChart(data: ScaleSampleData.exponentialData).chartYScale(type: .log)
        case .squareRootScale:
            baseChart(data: ScaleSampleData.exponentialData).chartYScale(type: .squareRoot)
        case .symmetricLogScale:
            baseChart(data: ScaleSampleData.positiveData).chartYScale(type: .symmetricLog)
        case .fixedDomain:
            baseChart(data: ScaleSampleData.positiveData).chartYScale(domain: 0.0...150.0, type: .linear)
        }
    }
}

// MARK: - Code generation
private extension ChartScalesShowcase {
    var generatedCode: String {
        let modifierName = axis == .xAxis ? "chartXScale" : "chartYScale"
        let typeArg = "type: .\(scaleType.label)"
        if useFixedDomain {
            let lower = min(domainLower, domainUpper - 1)
            let upper = max(domainUpper, lower + 1)
            let lowerStr = lower.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(lower))
                : String(format: "%.1f", lower)
            let upperStr = upper.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(upper))
                : String(format: "%.1f", upper)
            return """
            .\(modifierName)(
                domain: \(lowerStr) ... \(upperStr),
                \(typeArg)
            )
            """
        } else {
            return ".\(modifierName)(\(typeArg))"
        }
    }
}

// MARK: - Nested types
private extension ChartScalesShowcase {
    enum AxisOption: ShowcasePickable {
        case xAxis, yAxis

        var label: String {
            switch self {
            case .xAxis: "x"
            case .yAxis: "y"
            }
        }
    }

    enum ScaleTypeOption: ShowcasePickable {
        case linear, log, symmetricLog, squareRoot, category

        var label: String {
            switch self {
            case .linear: "linear"
            case .log: "log"
            case .symmetricLog: "symmetricLog"
            case .squareRoot: "squareRoot"
            case .category: "category"
            }
        }

        var scaleType: ScaleType {
            switch self {
            case .linear: .linear
            case .log: .log
            case .symmetricLog: .symmetricLog
            case .squareRoot: .squareRoot
            case .category: .category
            }
        }
    }

    enum ScaleState: ShowcaseState {
        case `default`, logScale, squareRootScale, symmetricLogScale, fixedDomain

        var caption: String {
            switch self {
            case .default: "Linear (auto)"
            case .logScale: "Log scale"
            case .squareRootScale: "Square root"
            case .symmetricLogScale: "Symmetric log"
            case .fixedDomain: "Fixed domain 0–150"
            }
        }
    }

    struct ScaleSampleData: Identifiable {
        let id: String
        let category: String
        let value: Double

        static let positiveData: [ScaleSampleData] = [
            ScaleSampleData(id: "aaa", category: "Mon", value: 20),
            ScaleSampleData(id: "bbb", category: "Tue", value: 55),
            ScaleSampleData(id: "ccc", category: "Wed", value: 38),
            ScaleSampleData(id: "ddd", category: "Thu", value: 90),
            ScaleSampleData(id: "eee", category: "Fri", value: 72),
        ]

        static let exponentialData: [ScaleSampleData] = [
            ScaleSampleData(id: "aaa", category: "Jan", value: 1),
            ScaleSampleData(id: "bbb", category: "Feb", value: 4),
            ScaleSampleData(id: "ccc", category: "Mar", value: 16),
            ScaleSampleData(id: "ddd", category: "Apr", value: 64),
            ScaleSampleData(id: "eee", category: "May", value: 256),
        ]
    }
}
