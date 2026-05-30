import SwiftUI

struct AccessibilityRepresentationShowcase: View {
    enum RepresentationKind: ShowcasePickable {
        case slider
        case toggle
        case stepper
        case progressView
        case button

        var label: String {
            switch self {
            case .slider: "Slider"
            case .toggle: "Toggle"
            case .stepper: "Stepper"
            case .progressView: "ProgressView"
            case .button: "Button"
            }
        }

        var symbolName: String {
            switch self {
            case .slider: "slider.horizontal.3"
            case .toggle: "switch.2"
            case .stepper: "plus.forwardslash.minus"
            case .progressView: "chart.bar.fill"
            case .button: "hand.tap.fill"
            }
        }

        var codeBody: String {
            switch self {
            case .slider: "Slider(value: $value, in: 0...100)"
            case .toggle: "Toggle(\"Custom control\", isOn: $isOn)"
            case .stepper: "Stepper(\"Custom control\", value: $count, in: 0...10)"
            case .progressView: "ProgressView(value: progress, total: 1.0)"
            case .button: "Button(\"Custom control\") { action() }"
            }
        }
    }

    enum RepresentationState: ShowcaseState {
        case slider
        case toggle
        case stepper
        case progressView
        case button

        var caption: String {
            switch self {
            case .slider: "Slider (adjustable)"
            case .toggle: "Toggle (on/off)"
            case .stepper: "Stepper (increment)"
            case .progressView: "ProgressView (progress)"
            case .button: "Button (activatable)"
            }
        }

        var symbolName: String {
            switch self {
            case .slider: "slider.horizontal.3"
            case .toggle: "switch.2"
            case .stepper: "plus.forwardslash.minus"
            case .progressView: "chart.bar.fill"
            case .button: "hand.tap.fill"
            }
        }

        var apiSignature: String {
            switch self {
            case .slider: "Slider(value:in:)"
            case .toggle: "Toggle(_:isOn:)"
            case .stepper: "Stepper(_:value:in:)"
            case .progressView: "ProgressView(value:total:)"
            case .button: "Button(_:action:)"
            }
        }
    }

    @State private var representation: RepresentationKind = .slider
    @State private var sliderValue: Double = 50
    @State private var toggleIsOn = true
    @State private var stepperCount = 3

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Representation",
            summary: "Substitutes a custom view's accessibility with that of a standard control.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityRepresentationShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            customDial
            representationHint
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var customDial: some View {
        ZStack {
            Circle()
                .strokeBorder(DesignSystem.Color.accent, lineWidth: 3)
                .frame(width: 96, height: 96)
            dialIndicator
        }
        .accessibilityRepresentation {
            representationView
        }
    }

    var dialIndicator: some View {
        Image(systemName: representation.symbolName)
            .font(DesignSystem.Font.title2)
            .foregroundStyle(DesignSystem.Color.accent)
    }

    var representationHint: some View {
        Text("Representation: \(representation.label)")
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.secondary)
    }

    @ViewBuilder var representationView: some View {
        switch representation {
        case .slider:
            Slider(value: $sliderValue, in: 0...100)
                .accessibilityLabel("Custom dial")
        case .toggle:
            Toggle("Custom dial", isOn: $toggleIsOn)
        case .stepper:
            Stepper("Custom dial", value: $stepperCount, in: 0...10)
        case .progressView:
            ProgressView(value: sliderValue, total: 100)
                .accessibilityLabel("Custom dial")
        case .button:
            Button("Custom dial") {}
        }
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Representation", selection: $representation)
    }

    @ViewBuilder func stateView(_ state: RepresentationState) -> some View {
        stateRow(state)
    }

    func stateRow(_ state: RepresentationState) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            ZStack {
                Circle()
                    .strokeBorder(DesignSystem.Color.accent, lineWidth: 3)
                    .frame(width: 72, height: 72)
                Image(systemName: state.symbolName)
                    .font(DesignSystem.Font.title3)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
            .accessibilityRepresentation {
                stateRepresentationContent(state)
            }
            Text(state.apiSignature)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(DesignSystem.Spacing.medium)
    }

    @ViewBuilder func stateRepresentationContent(_ state: RepresentationState) -> some View {
        switch state {
        case .slider:
            Slider(value: .constant(50.0), in: 0...100)
                .accessibilityLabel("Example dial")
        case .toggle:
            Toggle("Example dial", isOn: .constant(true))
        case .stepper:
            Stepper("Example dial", value: .constant(3), in: 0...10)
        case .progressView:
            ProgressView(value: 0.5, total: 1.0)
                .accessibilityLabel("Example dial")
        case .button:
            Button("Example dial") {}
        }
    }
}

// MARK: - Code generation
private extension AccessibilityRepresentationShowcase {
    var generatedCode: String {
        """
        CustomDial()
            .accessibilityRepresentation {
                \(representation.codeBody)
            }
        """
    }
}
