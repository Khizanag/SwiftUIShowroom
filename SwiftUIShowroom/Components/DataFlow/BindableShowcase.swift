import SwiftUI

struct BindableShowcase: View {
    @State private var usage: UsageOption = .storedProperty
    @State private var boundProperty: String = "title"
    @State private var controlKind: ControlKind = .textField
    @State private var model = DemoModel()

    var body: some View {
        ShowcaseScreen(
            title: "@Bindable",
            summary: "Creates bindings to @Observable model properties via $model.property syntax.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested enums
extension BindableShowcase {
    enum UsageOption: ShowcasePickable {
        case storedProperty
        case localInBody
        case fromEnvironment

        var label: String {
            switch self {
            case .storedProperty: "Stored property"
            case .localInBody: "Local in body"
            case .fromEnvironment: "From @Environment"
            }
        }
    }

    enum ControlKind: ShowcasePickable {
        case textField
        case toggle
        case slider
        case stepper
        case picker

        var label: String {
            switch self {
            case .textField: "TextField"
            case .toggle: "Toggle"
            case .slider: "Slider"
            case .stepper: "Stepper"
            case .picker: "Picker"
            }
        }
    }
}

// MARK: - Sub-views
private extension BindableShowcase {
    var preview: some View {
        BindableDemoView(
            model: model,
            controlKind: controlKind,
        )
        .frame(maxWidth: 320)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Usage pattern", selection: $usage)
        ShowcaseTextControl(
            "Bound property",
            text: $boundProperty,
            prompt: "e.g. title",
        )
        ShowcasePicker("Control", selection: $controlKind)
    }

    @ViewBuilder func stateView(_ state: EnabledState) -> some View {
        BindableDemoView(
            model: model,
            controlKind: controlKind,
        )
        .disabled(state == .disabled)
        .frame(maxWidth: 280)
    }
}

// MARK: - Code generation
private extension BindableShowcase {
    var generatedCode: String {
        let modelDecl = modelDeclaration
        let controlCode = controlLine
        switch usage {
        case .storedProperty:
            return """
            @Observable
            final class DemoModel {
                var \(boundProperty) = \(defaultValueLiteral)
            }

            struct DemoView: View {
                @Bindable var model: DemoModel

                var body: some View {
                    \(controlCode)
                }
            }
            """
        case .localInBody:
            return """
            \(modelDecl)

            struct DemoView: View {
                @State private var model = DemoModel()

                var body: some View {
                    @Bindable var model = model
                    \(controlCode)
                }
            }
            """
        case .fromEnvironment:
            return """
            \(modelDecl)

            struct DemoView: View {
                @Environment(DemoModel.self) private var model

                var body: some View {
                    @Bindable var model = model
                    \(controlCode)
                }
            }
            """
        }
    }

    var modelDeclaration: String {
        """
        @Observable
        final class DemoModel {
            var \(boundProperty) = \(defaultValueLiteral)
        }
        """
    }

    var defaultValueLiteral: String {
        switch controlKind {
        case .textField: return "\"\""
        case .toggle: return "false"
        case .slider: return "0.5"
        case .stepper: return "0"
        case .picker: return "0"
        }
    }

    var controlLine: String {
        switch controlKind {
        case .textField:
            return "TextField(\"\(boundProperty.capitalized)\", text: $model.\(boundProperty))"
        case .toggle:
            return "Toggle(\"\(boundProperty.capitalized)\", isOn: $model.\(boundProperty))"
        case .slider:
            return "Slider(value: $model.\(boundProperty), in: 0...1)"
        case .stepper:
            let prop = boundProperty
            return "Stepper(\"\(prop.capitalized): \\(model.\(prop))\", value: $model.\(prop))"
        case .picker:
            let prop = boundProperty
            return "Picker(\"\(prop.capitalized)\", selection: $model.\(prop)) { ... }"
        }
    }
}

// MARK: - Observable demo model
@Observable
private final class DemoModel {
    var title: String = "Hello"
    var isEnabled: Bool = true
    var amount: Double = 0.5
    var count: Int = 0
}

// MARK: - Bindable demo view
private struct BindableDemoView: View {
    @Bindable var model: DemoModel
    let controlKind: BindableShowcase.ControlKind

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            modelLabel
            controlView
        }
        .padding(DesignSystem.Spacing.medium)
        .background(
            DesignSystem.Color.cardBackground,
            in: .rect(cornerRadius: DesignSystem.CornerRadius.medium),
        )
    }
}

// MARK: - Sub-views
private extension BindableDemoView {
    var modelLabel: some View {
        Text("@Bindable var model: DemoModel")
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder var controlView: some View {
        switch controlKind {
        case .textField:
            textFieldControl
        case .toggle:
            Toggle("Enabled", isOn: $model.isEnabled)
        case .slider:
            sliderControl
        case .stepper:
            stepperControl
        case .picker:
            pickerControl
        }
    }

    var textFieldControl: some View {
#if os(tvOS)
        Text("TextField — title: \(model.title)")
            .font(DesignSystem.Font.body)
            .foregroundStyle(DesignSystem.Color.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
#else
        TextField("Title", text: $model.title)
            .textFieldStyle(.roundedBorder)
#endif
    }

    var sliderControl: some View {
#if os(tvOS)
        Text("Slider — amount: \(model.amount, specifier: "%.2f")")
            .font(DesignSystem.Font.body)
            .foregroundStyle(DesignSystem.Color.primary)
#else
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("Amount: \(model.amount, specifier: "%.2f")")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
            Slider(value: $model.amount, in: 0...1)
        }
#endif
    }

    var stepperControl: some View {
#if os(tvOS)
        Text("Stepper — count: \(model.count)")
            .font(DesignSystem.Font.body)
            .foregroundStyle(DesignSystem.Color.primary)
#else
        Stepper("Count: \(model.count)", value: $model.count, in: 0...20)
#endif
    }

    var pickerControl: some View {
        Picker("Count", selection: $model.count) {
            ForEach(0..<5) { index in
                Text("\(index)").tag(index)
            }
        }
    }
}
