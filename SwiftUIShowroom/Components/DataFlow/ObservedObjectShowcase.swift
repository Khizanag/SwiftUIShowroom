import SwiftUI

struct ObservedObjectShowcase: View {
    @State private var bindingProperty: String = "isOn"
    @StateObject private var ownedModel = LegacyDemoModel()

    var body: some View {
        ShowcaseScreen(
            title: "@ObservedObject (legacy)",
            summary: "Observes an externally-owned ObservableObject passed into a view.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ObservedObjectShowcase {
    var preview: some View {
        ObservedChildView(model: ownedModel)
            .frame(maxWidth: 320)
    }

    @ViewBuilder var controls: some View {
        ShowcaseTextControl(
            "Binding property",
            text: $bindingProperty,
            prompt: "e.g. isOn",
        )
    }

    @ViewBuilder func stateView(_ state: EnabledState) -> some View {
        ObservedChildView(model: LegacyDemoModel())
            .disabled(state == .disabled)
            .frame(maxWidth: 280)
    }
}

// MARK: - Code generation
private extension ObservedObjectShowcase {
    var generatedCode: String {
        let prop = bindingProperty.isEmpty ? "isOn" : bindingProperty
        return """
        class ViewModel: ObservableObject {
            @Published var \(prop) = false
        }

        struct ParentView: View {
            @StateObject private var model = ViewModel()

            var body: some View {
                ChildView(model: model)
            }
        }

        struct ChildView: View {
            @ObservedObject var model: ViewModel

            var body: some View {
                Toggle("Flag", isOn: $model.\(prop))
            }
        }
        """
    }
}

// MARK: - Shared legacy model
private final class LegacyDemoModel: ObservableObject {
    @Published var isOn: Bool = false
}

// MARK: - Child view using @ObservedObject
private struct ObservedChildView: View {
    @ObservedObject var model: LegacyDemoModel

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            declarationLabel
            Toggle("Flag", isOn: $model.isOn)
            stateLabel
        }
        .padding(DesignSystem.Spacing.medium)
        .background(
            DesignSystem.Color.cardBackground,
            in: .rect(cornerRadius: DesignSystem.CornerRadius.medium),
        )
    }
}

// MARK: - ObservedChildView sub-views
private extension ObservedChildView {
    var declarationLabel: some View {
        Text("@ObservedObject var model: ViewModel")
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    var stateLabel: some View {
        Text("isOn = \(model.isOn ? "true" : "false")")
            .font(DesignSystem.Font.footnote)
            .foregroundStyle(DesignSystem.Color.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
