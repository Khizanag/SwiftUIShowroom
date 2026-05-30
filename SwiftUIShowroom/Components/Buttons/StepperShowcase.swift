import SwiftUI

struct StepperShowcase: View {
    enum StepOption: ShowcasePickable {
        case one, five, ten

        var label: String {
            switch self {
            case .one: "1"
            case .five: "5"
            case .ten: "10"
            }
        }

        var intValue: Int {
            switch self {
            case .one: 1
            case .five: 5
            case .ten: 10
            }
        }
    }

    enum StepperControlSizeOption: ShowcasePickable {
        case mini, small, regular, large, extraLarge

        var label: String {
            switch self {
            case .mini: "mini"
            case .small: "small"
            case .regular: "regular"
            case .large: "large"
            case .extraLarge: "extraLarge"
            }
        }

        var nativeSize: ControlSize {
            switch self {
            case .mini: .mini
            case .small: .small
            case .regular: .regular
            case .large: .large
            case .extraLarge: .extraLarge
            }
        }
    }

    enum StepperVisualState: ShowcaseState {
        case enabled, disabled, atMin, atMax

        var caption: String {
            switch self {
            case .enabled: "Default"
            case .disabled: "Disabled"
            case .atMin: "At minimum"
            case .atMax: "At maximum"
            }
        }

        func displayValue(in range: ClosedRange<Int>) -> Int {
            switch self {
            case .enabled: (range.lowerBound + range.upperBound) / 2
            case .disabled: (range.lowerBound + range.upperBound) / 2
            case .atMin: range.lowerBound
            case .atMax: range.upperBound
            }
        }
    }

    @State private var titleText = "Quantity"
    @State private var value = 0
    @State private var step: StepOption = .one
    @State private var controlSize: StepperControlSizeOption = .regular
    @State private var isEnabled = true

    private let range = 0...10

    var body: some View {
        ShowcaseScreen(
            title: "Stepper",
            summary: "Increments and decrements a bounded integer value via +/− buttons.",
        ) {
#if os(tvOS)
            ShowcaseSection("Not available") {
                Text("Stepper is not available on tvOS.")
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
#else
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
#endif
        }
    }
}

// MARK: - Sub-views
private extension StepperShowcase {
#if !os(tvOS)
    var preview: some View {
        stepperView(value: $value, isEnabled: isEnabled)
            .controlSize(controlSize.nativeSize)
            .frame(maxWidth: 340)
            .padding(DesignSystem.Spacing.medium)
    }

    @ViewBuilder var controls: some View {
        ShowcaseTextControl("Title", text: $titleText)
        ShowcaseStepper("Value", value: $value, in: range)
        ShowcasePicker("Step", selection: $step)
        ShowcasePicker("Control size", selection: $controlSize)
        ShowcaseToggle("Enabled", isOn: $isEnabled)
    }

    @ViewBuilder
    func stateView(_ state: StepperVisualState) -> some View {
        stepperView(
            value: .constant(state.displayValue(in: range)),
            isEnabled: state != .disabled,
        )
        .controlSize(.regular)
        .frame(maxWidth: 300)
    }

    func stepperView(value: Binding<Int>, isEnabled: Bool) -> some View {
        Stepper(value: value, in: range, step: step.intValue) {
            HStack {
                Text(titleText)
                Spacer()
                Text("\(value.wrappedValue)")
                    .font(DesignSystem.Font.codeInline)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
        .disabled(!isEnabled)
    }
#endif
}

// MARK: - Code generation
private extension StepperShowcase {
    var generatedCode: String {
        """
        Stepper(value: $value, in: \(range.lowerBound)...\(range.upperBound), step: \(step.intValue)) {
            Text("\(titleText): \\(value)")
        }
        .controlSize(.\(controlSize.label))
        .disabled(\(!isEnabled))
        """
    }
}
