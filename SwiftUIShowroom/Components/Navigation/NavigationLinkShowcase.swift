import SwiftUI

struct NavigationLinkShowcase: View {
    @State private var linkMode: LinkModeOption = .value
    @State private var labelText = "Open detail"
    @State private var useCustomLabel = false
    @State private var systemImageName = "chevron.right"
    @State private var isDisabled = false

    var body: some View {
        ShowcaseScreen(
            title: "NavigationLink",
            summary: "A control that triggers a push by presenting a value or, legacy, a destination view.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension NavigationLinkShowcase {
    enum LinkModeOption: ShowcasePickable {
        case value
        case destination

        var label: String {
            switch self {
            case .value: "value"
            case .destination: "destination"
            }
        }
    }

    enum LinkState: ShowcaseState {
        case defaultState
        case disabled
        case selected
        case longContent

        var caption: String {
            switch self {
            case .defaultState: "Default"
            case .disabled: "Disabled"
            case .selected: "Selected / pushed"
            case .longContent: "Long label"
            }
        }
    }
}

// MARK: - Sub-views
private extension NavigationLinkShowcase {
    var preview: some View {
        linkStack(
            mode: linkMode,
            labelText: labelText,
            useCustom: useCustomLabel,
            imageName: systemImageName,
            disabled: isDisabled,
        )
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Link mode", selection: $linkMode)
        ShowcaseTextControl("Label", text: $labelText, prompt: "Open detail")
        ShowcaseToggle("Custom label (Label view)", isOn: $useCustomLabel)
        ShowcaseTextControl("SF Symbol", text: $systemImageName, prompt: "chevron.right")
        ShowcaseToggle("Disabled", isOn: $isDisabled)
    }

    @ViewBuilder
    func stateView(_ state: LinkState) -> some View {
        switch state {
        case .defaultState:
            linkStack(
                mode: .value,
                labelText: "Open detail",
                useCustom: false,
                imageName: "chevron.right",
                disabled: false,
            )
        case .disabled:
            linkStack(
                mode: .value,
                labelText: "Open detail",
                useCustom: false,
                imageName: "chevron.right",
                disabled: true,
            )
        case .selected:
            linkStack(
                mode: .value,
                labelText: "Open detail",
                useCustom: true,
                imageName: "arrow.right.circle.fill",
                disabled: false,
            )
        case .longContent:
            linkStack(
                mode: .value,
                labelText: "Navigate to a very long destination name that may wrap",
                useCustom: false,
                imageName: "chevron.right",
                disabled: false,
            )
        }
    }

    func linkStack(
        mode: LinkModeOption,
        labelText: String,
        useCustom: Bool,
        imageName: String,
        disabled: Bool,
    ) -> some View {
        NavigationStack {
            List {
                linkRow(
                    mode: mode,
                    labelText: labelText,
                    useCustom: useCustom,
                    imageName: imageName,
                    disabled: disabled,
                )
            }
            .navigationTitle("Links")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .navigationDestination(for: String.self) { value in
                Text("Detail: \(value)")
                    .navigationTitle(value)
            }
        }
        .frame(maxWidth: 320, minHeight: 220)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ViewBuilder
    func linkRow(
        mode: LinkModeOption,
        labelText: String,
        useCustom: Bool,
        imageName: String,
        disabled: Bool,
    ) -> some View {
        switch mode {
        case .value:
            NavigationLink(value: labelText) {
                linkLabel(text: labelText, useCustom: useCustom, imageName: imageName)
            }
            .disabled(disabled)
        case .destination:
            NavigationLink {
                Text("Detail: \(labelText)")
                    .navigationTitle(labelText)
            } label: {
                linkLabel(text: labelText, useCustom: useCustom, imageName: imageName)
            }
            .disabled(disabled)
        }
    }

    @ViewBuilder
    func linkLabel(text: String, useCustom: Bool, imageName: String) -> some View {
        if useCustom {
            Label(text, systemImage: imageName)
        } else {
            Text(text)
        }
    }
}

// MARK: - Code generation
private extension NavigationLinkShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("struct NavigationLinkDemo: View {")
        lines.append("    var body: some View {")
        lines.append("        NavigationStack {")
        lines.append("            List {")
        lines.append("                \(linkInitLine) {")
        lines.append("                    \(labelLine)")
        lines.append("                }")
        if isDisabled {
            lines.append("                .disabled(true)")
        }
        lines.append("            }")
        if linkMode == .value {
            lines.append("            .navigationDestination(for: String.self) { Text(\"Detail: \\($0)\") }")
        }
        lines.append("            .navigationTitle(\"Links\")")
        lines.append("        }")
        lines.append("    }")
        lines.append("}")
        return lines.joined(separator: "\n")
    }

    var linkInitLine: String {
        switch linkMode {
        case .value:
            return "NavigationLink(value: \"\(labelText)\")"
        case .destination:
            return "NavigationLink { Text(\"Detail\") } label:"
        }
    }

    var labelLine: String {
        if useCustomLabel {
            return "Label(\"\(labelText)\", systemImage: \"\(systemImageName)\")"
        } else {
            return "Text(\"\(labelText)\")"
        }
    }
}
