import SwiftUI

struct SliderShowcase: View {
    @State private var value: Double = 50
    @State private var stepSize: Int = 1
    @State private var showLabels: Bool = true
    @State private var useNeutral: Bool = false
    @State private var labelStyle: LabelStyleOption = .speakerVolume
    @State private var isEnabled: Bool = true

    var body: some View {
        ShowcaseScreen(
            title: "Slider",
            summary: "Continuous or stepped value from a bounded range with optional edge labels.",
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
private extension SliderShowcase {
    var preview: some View {
        sliderView(
            value: $value,
            config: SliderConfig(
                showLabels: showLabels,
                useNeutral: useNeutral,
                step: Double(stepSize),
                labelStyle: labelStyle,
            ),
            isEnabled: isEnabled,
        )
        .frame(maxWidth: 400)
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseSlider("Value", value: $value, in: 0...100, step: Double(stepSize))
        ShowcaseStepper("Step", value: $stepSize, in: 1...25)
        ShowcaseToggle("Show labels", isOn: $showLabels)
        ShowcaseToggle("Neutral origin (center)", isOn: $useNeutral)
        ShowcasePicker("Label style", selection: $labelStyle)
        ShowcaseToggle("Enabled", isOn: $isEnabled)
    }

    @ViewBuilder
    func stateView(_ state: VisualState) -> some View {
        sliderView(
            value: .constant(state.value),
            config: SliderConfig(
                showLabels: true,
                useNeutral: false,
                step: 1,
                labelStyle: labelStyle,
            ),
            isEnabled: state != .disabled,
        )
        .frame(maxWidth: 300)
    }

    @ViewBuilder
    func sliderView(
        value: Binding<Double>,
        config: SliderConfig,
        isEnabled: Bool,
    ) -> some View {
        let neutralArg: Double? = config.useNeutral ? 50 : nil
        if config.showLabels {
            Slider(
                value: value,
                in: 0...100,
                step: config.step,
                neutralValue: neutralArg,
            ) {
                Text("Speed")
            } minimumValueLabel: {
                Image(systemName: config.labelStyle.minimumSymbol)
                    .imageScale(.small)
            } maximumValueLabel: {
                Image(systemName: config.labelStyle.maximumSymbol)
                    .imageScale(.small)
            }
            .disabled(!isEnabled)
        } else {
            Slider(value: value, in: 0...100, step: config.step, neutralValue: neutralArg) {
                Text("Speed")
            }
            .labelsHidden()
            .disabled(!isEnabled)
        }
    }
}

// MARK: - Nested types
extension SliderShowcase {
    struct SliderConfig {
        var showLabels: Bool
        var useNeutral: Bool
        var step: Double
        var labelStyle: LabelStyleOption
    }

    enum LabelStyleOption: ShowcasePickable {
        case speakerVolume
        case brightness
        case temperature

        var label: String {
            switch self {
            case .speakerVolume: "Speaker (volume)"
            case .brightness: "Brightness"
            case .temperature: "Temperature"
            }
        }

        var minimumSymbol: String {
            switch self {
            case .speakerVolume: "speaker.fill"
            case .brightness: "sun.min.fill"
            case .temperature: "thermometer.low"
            }
        }

        var maximumSymbol: String {
            switch self {
            case .speakerVolume: "speaker.wave.3.fill"
            case .brightness: "sun.max.fill"
            case .temperature: "thermometer.high"
            }
        }
    }

    enum VisualState: ShowcaseState {
        case atMinimum
        case midpoint
        case atMaximum
        case disabled

        var caption: String {
            switch self {
            case .atMinimum: "At minimum"
            case .midpoint: "Midpoint"
            case .atMaximum: "At maximum"
            case .disabled: "Disabled"
            }
        }

        var value: Double {
            switch self {
            case .atMinimum: 0
            case .midpoint: 50
            case .atMaximum: 100
            case .disabled: 35
            }
        }
    }
}

// MARK: - Code generation
private extension SliderShowcase {
    var generatedCode: String {
        let stepPart = stepSize == 1 ? "" : ",\n    step: \(stepSize)"
        let neutralPart = useNeutral ? ",\n    neutralValue: 50" : ""
        let disabledLine = isEnabled ? "" : "\n.disabled(true)"

        if showLabels {
            return """
            Slider(
                value: $value,
                in: 0...100\(stepPart)\(neutralPart)
            ) {
                Text("Speed")
            } minimumValueLabel: {
                Image(systemName: "\(labelStyle.minimumSymbol)")
            } maximumValueLabel: {
                Image(systemName: "\(labelStyle.maximumSymbol)")
            }\(disabledLine)
            """
        } else {
            return """
            Slider(value: $value, in: 0...100\(stepPart)\(neutralPart)) {
                Text("Speed")
            }
            .labelsHidden()\(disabledLine)
            """
        }
    }
}
