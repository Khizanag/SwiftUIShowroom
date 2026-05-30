import SwiftUI

struct HelpLinkShowcase: View {
    @State private var anchor = "accountSetupHelp"
    @State private var useAction = false
    @State private var isEnabled = true

    var body: some View {
        ShowcaseScreen(
            title: "HelpLink",
            summary: "A system help button (?) that opens documentation. macOS 14+ only.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension HelpLinkShowcase {
    var preview: some View {
        #if os(macOS)
        helpLink(isEnabled: isEnabled)
        #else
        unavailableView
        #endif
    }

    @ViewBuilder var controls: some View {
        #if os(macOS)
        ShowcaseToggle("Use action closure", isOn: $useAction)
        if !useAction {
            ShowcaseTextControl("Anchor", text: $anchor)
        }
        ShowcaseToggle("Enabled", isOn: $isEnabled)
        #else
        unavailableView
        #endif
    }

    @ViewBuilder func stateView(_ state: EnabledState) -> some View {
        #if os(macOS)
        helpLink(isEnabled: state == .enabled)
        #else
        unavailableView
        #endif
    }

    #if os(macOS)
    @ViewBuilder func helpLink(isEnabled: Bool) -> some View {
        if useAction {
            HelpLink {}
                .disabled(!isEnabled)
        } else {
            HelpLink(anchor: anchor)
                .disabled(!isEnabled)
        }
    }
    #endif

    var unavailableView: some View {
        ContentUnavailableView(
            "macOS Only",
            systemImage: "desktopcomputer",
            description: Text("HelpLink is available on macOS 14 and later.")
        )
    }
}

// MARK: - Code generation
private extension HelpLinkShowcase {
    var generatedCode: String {
        #if os(macOS)
        if useAction {
            return """
            HelpLink {}
                .disabled(\(!isEnabled))
            """
        } else {
            return """
            HelpLink(anchor: "\(anchor)")
                .disabled(\(!isEnabled))
            """
        }
        #else
        return "#if os(macOS)\nHelpLink(anchor: \"\(anchor)\")\n#endif"
        #endif
    }
}
