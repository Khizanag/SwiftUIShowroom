import SwiftUI

struct GaugeShowcase: View {
    @State private var value: Double = 114
    @State private var style: GaugeStyleOption = .linearCapacity
    @State private var tint: Color = .red
    @State private var showBoundsLabels: Bool = true
    @State private var isEnabled: Bool = true

    private let range: ClosedRange<Double> = 0...170

    // MARK: - Nested enums
    enum GaugeStyleOption: ShowcasePickable {
        case automatic
        case linearCapacity
        case accessoryLinear
        case accessoryLinearCapacity
        case accessoryCircular
        case accessoryCircularCapacity

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .linearCapacity: "linearCapacity"
            case .accessoryLinear: "accessoryLinear"
            case .accessoryLinearCapacity: "accessoryLinearCapacity"
            case .accessoryCircular: "accessoryCircular"
            case .accessoryCircularCapacity: "accessoryCircularCapacity"
            }
        }

        var code: String { ".\(label)" }
    }

    enum GaugeVisualState: ShowcaseState {
        case low
        case mid
        case high
        case disabled

        var caption: String {
            switch self {
            case .low: "Low (30 BPM)"
            case .mid: "Mid (85 BPM)"
            case .high: "High (155 BPM)"
            case .disabled: "Disabled"
            }
        }

        var sampleValue: Double {
            switch self {
            case .low: 30
            case .mid: 85
            case .high: 155
            case .disabled: 85
            }
        }

        var tintColor: Color {
            switch self {
            case .low: .blue
            case .mid: .orange
            case .high: .red
            case .disabled: .gray
            }
        }
    }

    // MARK: - Body
    var body: some View {
        ShowcaseScreen(
            title: "Gauge",
            summary: "Shows a current value within a finite range, with a tintable indicator.",
        ) {
            PreviewStage {
                preview
            }
            ShowcaseSection("Configuration") {
                controls
            }
            ShowcaseSection("States") {
                StateGallery(content: stateView)
            }
            ShowcaseSection("Generated code") {
                CodeBlock(code: generatedCode)
            }
        }
    }
}

// MARK: - Sub-views
private extension GaugeShowcase {
    @ViewBuilder
    var preview: some View {
        #if os(tvOS)
        Text("Gauge is not available on tvOS.")
            .font(DesignSystem.Font.callout)
            .foregroundStyle(DesignSystem.Color.secondary)
        #else
        styledGauge(value: value, style: style, showBounds: showBoundsLabels)
            .tint(tint)
            .disabled(!isEnabled)
            .frame(maxWidth: 360)
            .padding(DesignSystem.Spacing.medium)
        #endif
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseSlider("Value (0–170)", value: $value, in: range, step: 1)
        #if !os(tvOS)
        ShowcasePicker("Style", selection: $style)
        #endif
        ShowcaseColorControl("Tint", selection: $tint, supportsOpacity: false)
        ShowcaseToggle("Show bounds labels", isOn: $showBoundsLabels)
        ShowcaseToggle("Enabled", isOn: $isEnabled)
    }

    @ViewBuilder
    func stateView(_ state: GaugeVisualState) -> some View {
        #if os(tvOS)
        Text("Unavailable")
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.secondary)
        #else
        styledGauge(value: state.sampleValue, style: .linearCapacity, showBounds: true)
            .tint(state.tintColor)
            .disabled(state == .disabled)
            .frame(maxWidth: 280)
        #endif
    }

    #if !os(tvOS)
    @ViewBuilder
    func styledGauge(
        value: Double,
        style: GaugeStyleOption,
        showBounds: Bool,
    ) -> some View {
        switch style {
        case .automatic:
            gaugeView(value: value, showBounds: showBounds).gaugeStyle(.automatic)
        case .linearCapacity:
            gaugeView(value: value, showBounds: showBounds).gaugeStyle(.linearCapacity)
        case .accessoryLinear:
            gaugeView(value: value, showBounds: showBounds).gaugeStyle(.accessoryLinear)
        case .accessoryLinearCapacity:
            gaugeView(value: value, showBounds: showBounds)
                .gaugeStyle(.accessoryLinearCapacity)
        case .accessoryCircular:
            gaugeView(value: value, showBounds: showBounds).gaugeStyle(.accessoryCircular)
        case .accessoryCircularCapacity:
            gaugeView(value: value, showBounds: showBounds)
                .gaugeStyle(.accessoryCircularCapacity)
        }
    }

    func gaugeView(value: Double, showBounds: Bool) -> some View {
        Gauge(value: value, in: range) {
            Text("BPM")
        } currentValueLabel: {
            Text(value.formatted(.number.precision(.fractionLength(0))))
        } minimumValueLabel: {
            if showBounds { Text("0") }
        } maximumValueLabel: {
            if showBounds { Text("170") }
        }
    }
    #endif
}

// MARK: - Code generation
private extension GaugeShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("Gauge(value: \(Int(value)), in: 0...170) {")
        lines.append("    Text(\"BPM\")")
        lines.append("} currentValueLabel: {")
        lines.append("    Text(\"\\(Int(value))\")")
        if showBoundsLabels {
            lines.append("} minimumValueLabel: {")
            lines.append("    Text(\"0\")")
            lines.append("} maximumValueLabel: {")
            lines.append("    Text(\"170\")")
        }
        lines.append("}")
        lines.append(".gaugeStyle(\(style.code))")
        lines.append(".tint(/* configured color */)")
        if !isEnabled {
            lines.append(".disabled(true)")
        }
        return lines.joined(separator: "\n")
    }
}
