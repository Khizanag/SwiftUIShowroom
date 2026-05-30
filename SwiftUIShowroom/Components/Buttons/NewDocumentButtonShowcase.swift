import SwiftUI

struct NewDocumentButtonShowcase: View {
    @State private var labelText = "Start Writing…"
    @State private var usesTemplate = false
    @State private var isEnabled = true

    var body: some View {
        ShowcaseScreen(
            title: "NewDocumentButton",
            summary: "Creates a new document from a DocumentGroupLaunchScene. iOS 18 / macOS 15+.",
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
private extension NewDocumentButtonShowcase {
    var preview: some View {
        simulatedButton(label: labelText, isEnabled: isEnabled)
    }

    @ViewBuilder var controls: some View {
        ShowcaseTextControl("Label", text: $labelText)
        ShowcaseToggle("Uses template picker", isOn: $usesTemplate)
        ShowcaseToggle("Enabled", isOn: $isEnabled)
    }

    @ViewBuilder
    func stateView(_ state: EnabledState) -> some View {
        simulatedButton(label: labelText, isEnabled: state == .enabled)
    }

    func simulatedButton(label: String, isEnabled: Bool) -> some View {
        Button {
        } label: {
            Label(label, systemImage: usesTemplate ? "doc.badge.plus" : "doc.fill.badge.plus")
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(!isEnabled)
    }
}

// MARK: - Code generation
private extension NewDocumentButtonShowcase {
    var generatedCode: String {
        if usesTemplate {
            return templateCode
        }
        return simpleCode
    }

    var simpleCode: String {
        """
        DocumentGroupLaunchScene("My Documents") {
            NewDocumentButton(Text("\(labelText)"))
        }
        """
    }

    var templateCode: String {
        """
        DocumentGroupLaunchScene("My Documents") {
            NewDocumentButton(
                Text("\(labelText)"),
                for: MyDocument.self
            ) {
                await MyDocument()
            }
        }
        """
    }
}
