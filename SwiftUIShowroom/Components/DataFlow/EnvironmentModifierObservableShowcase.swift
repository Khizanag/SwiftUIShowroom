import SwiftUI

struct EnvironmentModifierObservableShowcase: View {
    @State private var allowNilInjection = false
    @State private var injectionScope: InjectionScope = .subtree
    @State private var model = ShowcaseObservableModel()

    var body: some View {
        ShowcaseScreen(
            title: "environment(_:) Observable",
            summary: "Injects an @Observable object into the environment so descendants read it by type.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension EnvironmentModifierObservableShowcase {
    fileprivate enum InjectionScope: ShowcasePickable {
        case subtree
        case nilInjected

        var label: String {
            switch self {
            case .subtree: "Non-nil (model)"
            case .nilInjected: "Nil (model as DemoModel?)"
            }
        }
    }

    fileprivate enum ObservableDemoState: ShowcaseState {
        case injected
        case nilInjected
        case multipleConsumers
        case mutated

        var caption: String {
            switch self {
            case .injected: "Injected"
            case .nilInjected: "Nil injection"
            case .multipleConsumers: "Multiple consumers"
            case .mutated: "Mutated value"
            }
        }
    }
}

// MARK: - Sub-views
private extension EnvironmentModifierObservableShowcase {
    var preview: some View {
        let injected: ShowcaseObservableModel? = allowNilInjection ? nil : model
        return ObservableConsumerView()
            .environment(injected)
            .frame(maxWidth: 320)
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("Nil injection (Optional overload)", isOn: $allowNilInjection)
        ShowcasePicker("Injection scope demo", selection: $injectionScope)
    }

    @ViewBuilder func stateView(_ state: ObservableDemoState) -> some View {
        switch state {
        case .injected:
            ObservableConsumerView()
                .environment(ShowcaseObservableModel() as ShowcaseObservableModel?)
        case .nilInjected:
            ObservableConsumerView()
                .environment(nil as ShowcaseObservableModel?)
        case .multipleConsumers:
            multipleConsumersView
        case .mutated:
            mutatedView
        }
    }

    var multipleConsumersView: some View {
        let shared: ShowcaseObservableModel? = ShowcaseObservableModel()
        return VStack(spacing: DesignSystem.Spacing.small) {
            ObservableConsumerView()
            ObservableConsumerView()
        }
        .environment(shared)
    }

    var mutatedView: some View {
        let mutated = ShowcaseObservableModel()
        mutated.counter = 42
        let optional: ShowcaseObservableModel? = mutated
        return ObservableConsumerView()
            .environment(optional)
    }
}

// MARK: - Code generation
private extension EnvironmentModifierObservableShowcase {
    var generatedCode: String {
        let injectionArg = allowNilInjection ? "model as DemoModel?" : "model"
        return """
        @Observable
        final class DemoModel {
            var counter: Int = 0
        }

        struct RootView: View {
            @State private var model = DemoModel()

            var body: some View {
                ContentView()
                    .environment(\(injectionArg))
            }
        }

        struct ContentView: View {
            @Environment(DemoModel.self) private var model

            var body: some View {
                Stepper("Count: \\(model.counter)", value: $model.counter)
            }
        }
        """
    }
}

// MARK: - Observable demo model
@Observable
fileprivate final class ShowcaseObservableModel { // swiftlint:disable:this private_over_fileprivate
    var counter: Int = 0
    var label: String = "Demo"
}

// MARK: - Consumer view
private struct ObservableConsumerView: View {
    @Environment(ShowcaseObservableModel.self) private var model: ShowcaseObservableModel?

    var body: some View {
        if let model {
            injectedBody(model: model)
        } else {
            absentBody
        }
    }
}

// MARK: - Sub-views
private extension ObservableConsumerView {
    @ViewBuilder func injectedBody(model: ShowcaseObservableModel) -> some View {
        @Bindable var bindableModel = model
        VStack(spacing: DesignSystem.Spacing.small) {
            statusRow(label: "@Environment(DemoModel.self)", value: "injected", color: .green)
            Stepper("Counter: \(model.counter)", value: $bindableModel.counter, in: 0...100)
                .padding(DesignSystem.Spacing.medium)
                .background(DesignSystem.Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        }
    }

    var absentBody: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            statusRow(label: "@Environment(DemoModel.self)", value: "nil", color: .orange)
            Text("Model not injected")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }

    func statusRow(label: String, value: String, color: Color) -> some View {
        HStack {
            Text(label)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            Spacer()
            Text(value)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(color)
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}
