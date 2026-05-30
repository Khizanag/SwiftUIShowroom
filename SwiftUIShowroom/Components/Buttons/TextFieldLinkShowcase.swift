import SwiftUI

struct TextFieldLinkShowcase: View {
    @State private var labelText = "Add Comment"
    @State private var promptText = "Enter name"
    @State private var isEnabled = true
    @State private var lastSubmitted: String?

    var body: some View {
        ShowcaseScreen(
            title: "TextFieldLink",
            summary: "A watchOS button that opens the system text-input interface and returns entered text.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension TextFieldLinkShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            simulatedButton(label: labelText, enabled: isEnabled)
            if let submitted = lastSubmitted {
                Text("Submitted: \"\(submitted)\"")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
            platformNote
        }
    }

    var platformNote: some View {
        Label(
            "TextFieldLink is watchOS-only. This preview simulates its appearance.",
            systemImage: "applewatch"
        )
        .font(DesignSystem.Font.caption)
        .foregroundStyle(DesignSystem.Color.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, DesignSystem.Spacing.medium)
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Label", text: $labelText)
        ShowcaseTextControl("Prompt", text: $promptText)
        ShowcaseToggle("Enabled", isOn: $isEnabled)
    }

    @ViewBuilder
    func stateView(_ state: EnabledState) -> some View {
        simulatedButton(label: labelText, enabled: state == .enabled)
    }

    func simulatedButton(label: String, enabled: Bool) -> some View {
        Button {
            lastSubmitted = "Hello, world!"
        } label: {
            Label(label, systemImage: "keyboard")
        }
        .buttonStyle(.bordered)
        .disabled(!enabled)
        .accessibilityLabel(label)
    }
}

// MARK: - Code generation
private extension TextFieldLinkShowcase {
    var generatedCode: String {
        let prompt = promptText.isEmpty ? "" : "Text(\"\(promptText)\")"
        let promptArg = prompt.isEmpty ? "" : "prompt: \(prompt)"
        let disabledLine = isEnabled ? "" : "\n.disabled(true)"
        let header = promptArg.isEmpty
            ? "TextFieldLink {"
            : "TextFieldLink(\(promptArg)) {"
        return """
        \(header)
            Text("\(labelText)")
        } onSubmit: { text in
            // handle entered text
        }\(disabledLine)
        """
    }
}
