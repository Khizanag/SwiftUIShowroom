import SwiftUI

struct DisclosureGroupShowcase: View {
    enum GroupState: ShowcaseState {
        case collapsed
        case expanded
        case disabled
        case longContent

        var caption: String {
            switch self {
            case .collapsed: "Collapsed"
            case .expanded: "Expanded"
            case .disabled: "Disabled"
            case .longContent: "Long content"
            }
        }
    }

    @State private var labelText = "Details"
    @State private var isExpanded = true
    @State private var isDisabled = false
    @State private var optionA = true
    @State private var optionB = false

    var body: some View {
        ShowcaseScreen(
            title: "DisclosureGroup",
            summary: "A container that shows or hides content behind a disclosure control.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension DisclosureGroupShowcase {
    var preview: some View {
        DisclosureGroup(labelText, isExpanded: $isExpanded) {
            Toggle("Option A", isOn: $optionA)
            Toggle("Option B", isOn: $optionB)
        }
        .padding(DesignSystem.Spacing.medium)
        .disabled(isDisabled)
    }

    @ViewBuilder var controls: some View {
        ShowcaseTextControl("Label", text: $labelText)
        ShowcaseToggle("Expanded", isOn: $isExpanded)
        ShowcaseToggle("Disabled", isOn: $isDisabled)
    }

    @ViewBuilder func stateView(_ state: GroupState) -> some View {
        switch state {
        case .collapsed:
            collapsedExample
        case .expanded:
            expandedExample
        case .disabled:
            disabledExample
        case .longContent:
            longContentExample
        }
    }

    var collapsedExample: some View {
        DisclosureGroup("Settings") { settingsContent }
    }

    var expandedExample: some View {
        DisclosureGroup(isExpanded: .constant(true)) {
            settingsContent
        } label: {
            Text("Settings")
        }
    }

    var disabledExample: some View {
        DisclosureGroup(isExpanded: .constant(false)) {
            settingsContent
        } label: {
            Text("Settings")
        }
        .disabled(true)
    }

    var longContentExample: some View {
        DisclosureGroup(isExpanded: .constant(true)) {
            ForEach(["Wi-Fi", "Bluetooth", "Cellular", "VPN", "Hotspot"], id: \.self) { item in
                Toggle(item, isOn: .constant(true))
                    .font(DesignSystem.Font.footnote)
            }
        } label: {
            Text("Connectivity")
        }
    }

    var settingsContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Toggle("Option A", isOn: .constant(true))
            Toggle("Option B", isOn: .constant(false))
        }
        .font(DesignSystem.Font.footnote)
    }
}

// MARK: - Code generation
private extension DisclosureGroupShowcase {
    var generatedCode: String {
        """
        DisclosureGroup("\(labelText)", isExpanded: $isExpanded) {
            Toggle("Option A", isOn: $a)
            Toggle("Option B", isOn: $b)
        }
        .disclosureGroupStyle(.automatic)
        """
    }
}
