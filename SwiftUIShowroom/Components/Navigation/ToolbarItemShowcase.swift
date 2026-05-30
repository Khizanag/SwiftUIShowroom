import SwiftUI

struct ToolbarItemShowcase: View {
    @State private var placement: PlacementOption = .automatic
    @State private var label = "Done"
    @State private var customizationID = ""

    var body: some View {
        ShowcaseScreen(
            title: "ToolbarItem",
            summary: "A single placed toolbar element, optionally identified for customization.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension ToolbarItemShowcase {
    enum PlacementOption: ShowcasePickable {
        case automatic
        case primaryAction
        case confirmationAction
        case cancellationAction
        case destructiveAction
        case topBarLeading
        case topBarTrailing
        case bottomBar
        case principal
        case navigation
        case status
        case secondaryAction

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .primaryAction: "primaryAction"
            case .confirmationAction: "confirmationAction"
            case .cancellationAction: "cancellationAction"
            case .destructiveAction: "destructiveAction"
            case .topBarLeading: "topBarLeading"
            case .topBarTrailing: "topBarTrailing"
            case .bottomBar: "bottomBar"
            case .principal: "principal"
            case .navigation: "navigation"
            case .status: "status"
            case .secondaryAction: "secondaryAction"
            }
        }

        var placement: ToolbarItemPlacement {
            switch self {
            case .automatic: .automatic
            case .primaryAction: .primaryAction
            case .confirmationAction: .confirmationAction
            case .cancellationAction: .cancellationAction
            case .destructiveAction: .destructiveAction
            case .topBarLeading:
#if os(macOS)
                .automatic
#else
                .topBarLeading
#endif
            case .topBarTrailing:
#if os(macOS)
                .automatic
#else
                .topBarTrailing
#endif
            case .bottomBar:
#if os(macOS)
                .automatic
#else
                .bottomBar
#endif
            case .principal: .principal
            case .navigation: .navigation
            case .status: .status
            case .secondaryAction: .secondaryAction
            }
        }
    }
}

// MARK: - Sub-views
private extension ToolbarItemShowcase {
    var preview: some View {
        toolbarPreview(buttonLabel: label, placement: placement, isDisabled: false)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Placement", selection: $placement)
        ShowcaseTextControl("Label", text: $label, prompt: "Done")
        ShowcaseTextControl("Customization ID", text: $customizationID, prompt: "optional")
    }

    @ViewBuilder
    func stateView(_ state: EnabledState) -> some View {
        toolbarPreview(
            buttonLabel: label,
            placement: placement,
            isDisabled: state == .disabled,
        )
    }

    func toolbarPreview(
        buttonLabel: String,
        placement: PlacementOption,
        isDisabled: Bool,
    ) -> some View {
        NavigationStack {
            Text("Content")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("Screen")
                .toolbar {
                    toolbarItemContent(
                        buttonLabel: buttonLabel,
                        placement: placement,
                        isDisabled: isDisabled,
                    )
                }
        }
        .frame(maxWidth: 320, minHeight: 160)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ToolbarContentBuilder
    func toolbarItemContent(
        buttonLabel: String,
        placement: PlacementOption,
        isDisabled: Bool,
    ) -> some ToolbarContent {
        ToolbarItem(placement: placement.placement) {
            Button(buttonLabel) {}
                .disabled(isDisabled)
        }
    }
}

// MARK: - Code generation
private extension ToolbarItemShowcase {
    var generatedCode: String {
        var lines: [String] = []
        if customizationID.isEmpty {
            lines.append("ToolbarItem(placement: .\(placement.label)) {")
        } else {
            lines.append("ToolbarItem(id: \"\(customizationID)\", placement: .\(placement.label)) {")
        }
        lines.append("    Button(\"\(label)\") {}")
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}
