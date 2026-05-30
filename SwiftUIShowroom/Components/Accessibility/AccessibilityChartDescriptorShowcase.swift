import SwiftUI

struct AccessibilityChartDescriptorShowcase: View {
    @State private var descriptorKind: DescriptorKind = .barChart

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Chart Descriptor",
            summary: "Provides an audio-graph so VoiceOver users can explore a chart's data.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityChartDescriptorShowcase {
    var preview: some View {
        chartCard(kind: descriptorKind, isEmpty: false)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Descriptor", selection: $descriptorKind)
    }

    @ViewBuilder func stateView(_ state: ChartDescriptorState) -> some View {
        chartCard(kind: descriptorKind, isEmpty: state == .empty)
    }

    @ViewBuilder func chartCard(kind: DescriptorKind, isEmpty: Bool) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            chartCanvas(kind: kind, isEmpty: isEmpty)
            descriptorBadge(kind: kind, isEmpty: isEmpty)
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ViewBuilder func chartCanvas(kind: DescriptorKind, isEmpty: Bool) -> some View {
        let points = isEmpty ? [] : kind.dataPoints
        if isEmpty {
            emptyChartPlaceholder(kind: kind)
        } else {
            drawnChart(kind: kind, points: points)
                .accessibilityLabel(kind.chartTitle)
                .accessibilityChartDescriptor(
                    ChartDescriptorProxy(kind: kind, points: points)
                )
        }
    }

    @ViewBuilder func drawnChart(kind: DescriptorKind, points: [DataPoint]) -> some View {
        Canvas { context, size in
            switch kind {
            case .barChart:
                drawBars(context: context, size: size, points: points)
            case .lineChart:
                drawLine(context: context, size: size, points: points)
            case .scatter:
                drawScatter(context: context, size: size, points: points)
            }
        }
        .frame(height: 90)
    }

    func drawBars(context: GraphicsContext, size: CGSize, points: [DataPoint]) {
        guard !points.isEmpty else { return }
        let maxValue = points.map(\.value).max() ?? 1
        let spacing: CGFloat = 6
        let totalSpacing = spacing * CGFloat(points.count - 1)
        let barWidth = (size.width - totalSpacing) / CGFloat(points.count)
        for (index, point) in points.enumerated() {
            let fraction = maxValue > 0 ? point.value / maxValue : 0
            let barHeight = size.height * fraction
            let xOrigin = CGFloat(index) * (barWidth + spacing)
            let rect = CGRect(
                x: xOrigin,
                y: size.height - barHeight,
                width: barWidth,
                height: barHeight,
            )
            context.fill(Path(roundedRect: rect, cornerRadius: 3), with: .color(DesignSystem.Color.accent))
        }
    }

    func drawLine(context: GraphicsContext, size: CGSize, points: [DataPoint]) {
        guard points.count > 1 else { return }
        let maxValue = points.map(\.value).max() ?? 1
        let stepX = size.width / CGFloat(points.count - 1)
        var path = Path()
        for (index, point) in points.enumerated() {
            let fraction = maxValue > 0 ? 1 - point.value / maxValue : 1
            let xPos = CGFloat(index) * stepX
            let yPos = size.height * fraction
            if index == 0 {
                path.move(to: CGPoint(x: xPos, y: yPos))
            } else {
                path.addLine(to: CGPoint(x: xPos, y: yPos))
            }
        }
        context.stroke(path, with: .color(DesignSystem.Color.accent), lineWidth: 2)
    }

    func drawScatter(context: GraphicsContext, size: CGSize, points: [DataPoint]) {
        guard !points.isEmpty else { return }
        let maxValue = points.map(\.value).max() ?? 1
        let stepX = size.width / CGFloat(max(points.count, 1))
        for (index, point) in points.enumerated() {
            let fraction = maxValue > 0 ? 1 - point.value / maxValue : 1
            let xPos = CGFloat(index) * stepX + stepX / 2
            let yPos = size.height * fraction
            let dotRect = CGRect(x: xPos - 5, y: yPos - 5, width: 10, height: 10)
            context.fill(Path(ellipseIn: dotRect), with: .color(DesignSystem.Color.accent))
        }
    }

    func emptyChartPlaceholder(kind: DescriptorKind) -> some View {
        VStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: "chart.bar")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.secondary)
            Text("No data")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 90)
    }

    func descriptorBadge(kind: DescriptorKind, isEmpty: Bool) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: "accessibility")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(
                isEmpty
                    ? "Empty — no audio-graph data"
                    : "\(kind.label) · \(kind.dataPoints.count) data points"
            )
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.secondary)
        }
    }
}

// MARK: - Code generation
private extension AccessibilityChartDescriptorShowcase {
    var generatedCode: String {
        """
        // 1. Conform a type to AXChartDescriptorRepresentable
        struct \(descriptorKind.structName): AXChartDescriptorRepresentable {
            var data: [\(descriptorKind.pointTypeName)]

            func makeChartDescriptor() -> AXChartDescriptor {
                let xAxis = AXCategoricalDataAxisDescriptor(
                    title: "\(descriptorKind.xAxisTitle)",
                    categoryOrder: data.map(\\.label),
                )
                let maxVal = data.map(\\.value).max() ?? 1
                let yAxis = AXNumericDataAxisDescriptor(
                    title: "\(descriptorKind.yAxisTitle)",
                    range: 0...max(maxVal, 1),
                    gridlinePositions: [],
                    valueDescriptionProvider: { String(format: "%.1f", $0) }
                )
                let series = AXDataSeriesDescriptor(
                    name: "\(descriptorKind.seriesName)",
                    isContinuous: \(descriptorKind.isContinuous),
                    dataPoints: data.map {
                        AXDataPoint(x: $0.label, y: Double($0.value))
                    },
                )
                return AXChartDescriptor(
                    title: "\(descriptorKind.chartTitle)",
                    summary: nil,
                    xAxis: xAxis,
                    yAxis: yAxis,
                    additionalAxes: [],
                    series: [series],
                )
            }
        }

        // 2. Attach to your chart view
        ChartView(data: data)
            .accessibilityChartDescriptor(\(descriptorKind.structName)(data: data))
        """
    }
}

// MARK: - Chart descriptor proxy
private extension AccessibilityChartDescriptorShowcase {
    struct ChartDescriptorProxy: AXChartDescriptorRepresentable {
        let kind: DescriptorKind
        let points: [DataPoint]

        func makeChartDescriptor() -> AXChartDescriptor {
            let xAxis = AXCategoricalDataAxisDescriptor(
                title: kind.xAxisTitle,
                categoryOrder: points.map(\.label),
            )
            let maxValue = points.map(\.value).max().map { Double($0) } ?? 1
            let yAxis = AXNumericDataAxisDescriptor(
                title: kind.yAxisTitle,
                range: 0...max(maxValue, 1),
                gridlinePositions: [],
                valueDescriptionProvider: { String(format: "%.1f", $0) }
            )
            let series = AXDataSeriesDescriptor(
                name: kind.seriesName,
                isContinuous: kind.isContinuous,
                dataPoints: points.map {
                    AXDataPoint(x: $0.label, y: Double($0.value))
                },
            )
            return AXChartDescriptor(
                title: kind.chartTitle,
                summary: nil,
                xAxis: xAxis,
                yAxis: yAxis,
                additionalAxes: [],
                series: [series],
            )
        }
    }
}

// MARK: - Nested types
extension AccessibilityChartDescriptorShowcase {
    fileprivate struct DataPoint {
        let label: String
        let value: Double
    }

    fileprivate enum DescriptorKind: ShowcasePickable {
        case barChart
        case lineChart
        case scatter

        var label: String {
            switch self {
            case .barChart: "Bar chart descriptor"
            case .lineChart: "Line chart descriptor"
            case .scatter: "Scatter descriptor"
            }
        }

        var chartTitle: String {
            switch self {
            case .barChart: "Monthly Sales"
            case .lineChart: "Temperature Over Week"
            case .scatter: "Height vs Weight"
            }
        }

        var xAxisTitle: String {
            switch self {
            case .barChart: "Month"
            case .lineChart: "Day"
            case .scatter: "Sample"
            }
        }

        var yAxisTitle: String {
            switch self {
            case .barChart: "Units"
            case .lineChart: "°C"
            case .scatter: "Value"
            }
        }

        var seriesName: String {
            switch self {
            case .barChart: "Sales"
            case .lineChart: "Temperature"
            case .scatter: "Measurement"
            }
        }

        var isContinuous: Bool {
            switch self {
            case .barChart: false
            case .lineChart: true
            case .scatter: false
            }
        }

        var structName: String {
            switch self {
            case .barChart: "SalesChartDescriptor"
            case .lineChart: "TemperatureChartDescriptor"
            case .scatter: "ScatterChartDescriptor"
            }
        }

        var pointTypeName: String {
            switch self {
            case .barChart: "SalesPoint"
            case .lineChart: "TempPoint"
            case .scatter: "MeasurementPoint"
            }
        }

        var dataPoints: [DataPoint] {
            switch self {
            case .barChart:
                return [
                    DataPoint(label: "Jan", value: 42),
                    DataPoint(label: "Feb", value: 58),
                    DataPoint(label: "Mar", value: 73),
                    DataPoint(label: "Apr", value: 61),
                    DataPoint(label: "May", value: 85),
                ]
            case .lineChart:
                return [
                    DataPoint(label: "Mon", value: 14),
                    DataPoint(label: "Tue", value: 18),
                    DataPoint(label: "Wed", value: 22),
                    DataPoint(label: "Thu", value: 19),
                    DataPoint(label: "Fri", value: 25),
                    DataPoint(label: "Sat", value: 21),
                ]
            case .scatter:
                return [
                    DataPoint(label: "A", value: 30),
                    DataPoint(label: "B", value: 55),
                    DataPoint(label: "C", value: 45),
                    DataPoint(label: "D", value: 70),
                    DataPoint(label: "E", value: 40),
                ]
            }
        }
    }

    fileprivate enum ChartDescriptorState: ShowcaseState {
        case `default`
        case empty

        var caption: String {
            switch self {
            case .default: "Default"
            case .empty: "Empty (no data)"
            }
        }
    }
}
