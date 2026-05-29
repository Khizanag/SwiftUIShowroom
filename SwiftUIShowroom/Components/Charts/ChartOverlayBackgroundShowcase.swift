import Charts
import SwiftUI

struct ChartOverlayBackgroundShowcase: View {
    @State private var layer: LayerOption = .overlay
    @State private var alignment: AlignmentOption = .center
    @State private var showCrosshair: Bool = true
    @State private var accentColor: Color = .accentColor
    @State private var selectedIndex: Int?

    var body: some View {
        ShowcaseScreen(
            title: "Chart Overlay & Background",
            summary: "SwiftUI layers drawn above or behind a chart's plot area using ChartProxy.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ChartOverlayBackgroundShowcase {
    var preview: some View {
        Group {
            if layer == .overlay {
                overlayChart
            } else {
                backgroundChart
            }
        }
        .frame(height: 240)
        .padding(DesignSystem.Spacing.small)
    }

    var overlayChart: some View {
        Chart {
            ForEach(SampleData.points) { point in
                LineMark(
                    x: .value("Index", point.index),
                    y: .value("Value", point.value),
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(DesignSystem.Color.accent)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            if let idx = selectedIndex, SampleData.points.indices.contains(idx) {
                let point = SampleData.points[idx]
                RuleMark(x: .value("Selected", point.index))
                    .foregroundStyle(accentColor.opacity(0.4))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
            }
        }
        .chartOverlay(alignment: alignment.value) { proxy in
            overlayContent(proxy: proxy)
        }
    }

    var backgroundChart: some View {
        Chart {
            ForEach(SampleData.points) { point in
                BarMark(
                    x: .value("Index", point.index),
                    y: .value("Value", point.value),
                )
                .foregroundStyle(DesignSystem.Color.accent)
                .opacity(0.85)
            }
        }
        .chartBackground(alignment: alignment.value) { _ in
            backgroundDecoration
        }
    }

    @ViewBuilder
    func overlayContent(proxy: ChartProxy) -> some View {
        GeometryReader { geo in
            let origin = proxy.plotFrame.map { geo[$0].origin } ?? .zero
            #if os(tvOS)
            selectionHighlight(proxy: proxy, geo: geo, origin: origin)
            #else
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let localX = value.location.x - origin.x
                            if let rawIndex: Int = proxy.value(atX: localX) {
                                selectedIndex = SampleData.points
                                    .firstIndex { $0.index == rawIndex }
                            }
                        }
                        .onEnded { _ in
                            if !showCrosshair { selectedIndex = nil }
                        }
                )
            selectionHighlight(proxy: proxy, geo: geo, origin: origin)
            #endif
        }
    }

    @ViewBuilder
    func selectionHighlight(proxy: ChartProxy, geo: GeometryProxy, origin: CGPoint) -> some View {
        if showCrosshair, let idx = selectedIndex, SampleData.points.indices.contains(idx) {
            let point = SampleData.points[idx]
            if let xPos = proxy.position(forX: point.index) {
                let xOffset = xPos + origin.x
                Rectangle()
                    .fill(accentColor)
                    .frame(width: 2)
                    .offset(x: xOffset - 1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .allowsHitTesting(false)
            }
        }
    }

    var backgroundDecoration: some View {
        LinearGradient(
            colors: [accentColor.opacity(0.08), Color.clear],
            startPoint: .top,
            endPoint: .bottom,
        )
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Layer", selection: $layer)
        ShowcasePicker("Alignment", selection: $alignment)
        ShowcaseToggle("Show crosshair", isOn: $showCrosshair)
        ShowcaseColorControl("Accent color", selection: $accentColor, supportsOpacity: false)
    }

    @ViewBuilder
    func stateView(_ state: ChartOverlayState) -> some View {
        switch state {
        case .default:
            defaultStateChart
        case .selected:
            selectedStateChart
        case .focused:
            focusedStateChart
        }
    }

    var defaultStateChart: some View {
        Chart {
            ForEach(SampleData.points) { point in
                LineMark(
                    x: .value("Index", point.index),
                    y: .value("Value", point.value),
                )
                .foregroundStyle(Color.accentColor)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
        }
        .chartOverlay { _ in
            Color.clear
        }
        .frame(height: 120)
        .padding(DesignSystem.Spacing.xSmall)
    }

    var selectedStateChart: some View {
        Chart {
            ForEach(SampleData.points) { point in
                LineMark(
                    x: .value("Index", point.index),
                    y: .value("Value", point.value),
                )
                .foregroundStyle(Color.accentColor)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            RuleMark(x: .value("Selected", 3))
                .foregroundStyle(Color.orange.opacity(0.4))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
        }
        .chartOverlay(alignment: .center) { proxy in
            GeometryReader { geo in
                let origin = proxy.plotFrame.map { geo[$0].origin } ?? .zero
                if let xPos = proxy.position(forX: 3) {
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: 2)
                        .offset(x: xPos + origin.x - 1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .allowsHitTesting(false)
                }
            }
        }
        .frame(height: 120)
        .padding(DesignSystem.Spacing.xSmall)
    }

    var focusedStateChart: some View {
        Chart {
            ForEach(SampleData.points) { point in
                BarMark(
                    x: .value("Index", point.index),
                    y: .value("Value", point.value),
                )
                .foregroundStyle(Color.accentColor)
                .opacity(0.85)
            }
        }
        .chartBackground { _ in
            LinearGradient(
                colors: [Color.accentColor.opacity(0.12), Color.clear],
                startPoint: .top,
                endPoint: .bottom,
            )
        }
        .frame(height: 120)
        .padding(DesignSystem.Spacing.xSmall)
    }
}

// MARK: - Code generation
private extension ChartOverlayBackgroundShowcase {
    var generatedCode: String {
        let alignmentCode = alignment == .center ? ".center" : ".\(alignment.label)"
        let crosshairBlock = showCrosshair ? """
                if let selectedIndex, let xPos = proxy.position(forX: selectedIndex) {
                    Rectangle()
                        .fill(\(colorCode))
                        .frame(width: 2)
                        .offset(x: xPos + origin.x - 1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .allowsHitTesting(false)
                }
        """ : "        // no crosshair"

        if layer == .overlay {
            return """
            Chart(data) { item in
                LineMark(x: .value("Index", item.index), y: .value("Value", item.value))
            }
            .chartOverlay(alignment: \(alignmentCode)) { proxy in
                GeometryReader { geo in
                    let origin = geo[proxy.plotAreaFrame].origin
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let localX = value.location.x - origin.x
                                    selectedIndex = proxy.value(atX: localX)
                                }
                        )
            \(crosshairBlock)
                }
            }
            """
        } else {
            return """
            Chart(data) { item in
                BarMark(x: .value("Index", item.index), y: .value("Value", item.value))
            }
            .chartBackground(alignment: \(alignmentCode)) { _ in
                LinearGradient(
                    colors: [\(colorCode).opacity(0.08), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            """
        }
    }

    var colorCode: String {
        accentColor == .accentColor ? "Color.accentColor" : "Color(/* configured */)"
    }
}

// MARK: - Nested types
extension ChartOverlayBackgroundShowcase {
    enum LayerOption: ShowcasePickable {
        case overlay, background

        var label: String {
            switch self {
            case .overlay: "overlay"
            case .background: "background"
            }
        }
    }

    enum AlignmentOption: ShowcasePickable {
        case topLeading, top, topTrailing
        case leading, center, trailing
        case bottomLeading, bottom, bottomTrailing

        var label: String {
            switch self {
            case .topLeading: "topLeading"
            case .top: "top"
            case .topTrailing: "topTrailing"
            case .leading: "leading"
            case .center: "center"
            case .trailing: "trailing"
            case .bottomLeading: "bottomLeading"
            case .bottom: "bottom"
            case .bottomTrailing: "bottomTrailing"
            }
        }

        var value: Alignment {
            switch self {
            case .topLeading: .topLeading
            case .top: .top
            case .topTrailing: .topTrailing
            case .leading: .leading
            case .center: .center
            case .trailing: .trailing
            case .bottomLeading: .bottomLeading
            case .bottom: .bottom
            case .bottomTrailing: .bottomTrailing
            }
        }
    }

    enum ChartOverlayState: ShowcaseState {
        case `default`, selected, focused

        var caption: String {
            switch self {
            case .default: "Default (overlay, no selection)"
            case .selected: "Selected (crosshair at index 3)"
            case .focused: "Background decoration"
            }
        }
    }
}

// MARK: - Sample data
private extension ChartOverlayBackgroundShowcase {
    struct DataPoint: Identifiable {
        let id: Int
        let index: Int
        let value: Double
    }

    enum SampleData {
        static let points: [DataPoint] = [
            DataPoint(id: 0, index: 0, value: 30),
            DataPoint(id: 1, index: 1, value: 55),
            DataPoint(id: 2, index: 2, value: 42),
            DataPoint(id: 3, index: 3, value: 78),
            DataPoint(id: 4, index: 4, value: 60),
            DataPoint(id: 5, index: 5, value: 88),
            DataPoint(id: 6, index: 6, value: 72),
        ]
    }
}
