import SwiftUI

struct ConfirmationDialogShowcase: View {
    enum TitleVisibilityOption: ShowcasePickable {
        case automatic, visible, hidden

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .visible: "visible"
            case .hidden: "hidden"
            }
        }

        var codeLabel: String { ".\(label)" }

        var visibility: Visibility {
            switch self {
            case .automatic: .automatic
            case .visible: .visible
            case .hidden: .hidden
            }
        }
    }

    enum DialogState: ShowcaseState {
        case `default`, longContent

        var caption: String {
            switch self {
            case .default: "Default"
            case .longContent: "Long content"
            }
        }
    }

    @State private var dialogTitle = "Are you sure?"
    @State private var isPresented = false
    @State private var titleVisibility: TitleVisibilityOption = .automatic
    @State private var includesDestructive = true
    @State private var messageText = "This action cannot be undone."

    var body: some View {
        ShowcaseScreen(
            title: "Confirmation Dialog",
            summary: "Bottom-sheet action list (iPhone) or popover (iPad), replacing deprecated ActionSheet.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ConfirmationDialogShowcase {
    var preview: some View {
        Button("Show Dialog") { isPresented = true }
            .buttonStyle(.borderedProminent)
            .confirmationDialog(
                LocalizedStringKey(dialogTitle),
                isPresented: $isPresented,
                titleVisibility: titleVisibility.visibility,
            ) {
                if includesDestructive {
                    Button("Delete", role: .destructive) {}
                }
                Button("Save") {}
                Button("Cancel", role: .cancel) {}
            } message: {
                if !messageText.isEmpty {
                    Text(messageText)
                }
            }
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Title", text: $dialogTitle)
        ShowcasePicker("Title visibility", selection: $titleVisibility)
        ShowcaseToggle("Destructive button", isOn: $includesDestructive)
        ShowcaseTextControl("Message", text: $messageText)
    }

    @ViewBuilder
    func stateView(_ state: DialogState) -> some View {
        switch state {
        case .default:
            dialogTrigger(
                label: "Default",
                title: "Are you sure?",
                message: "This action cannot be undone.",
                includesDestructive: true,
                visibility: .automatic,
            )
        case .longContent:
            dialogTrigger(
                label: "Long message",
                title: "Delete all items?",
                message: "All 42 items will be permanently removed and cannot be recovered.",
                includesDestructive: true,
                visibility: .visible,
            )
        }
    }

    func dialogTrigger(
        label: String,
        title: String,
        message: String,
        includesDestructive: Bool,
        visibility: Visibility,
    ) -> some View {
        StatefulDialogTrigger(
            label: label,
            title: title,
            message: message,
            includesDestructive: includesDestructive,
            visibility: visibility,
        )
    }
}

// MARK: - Code generation
private extension ConfirmationDialogShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append(".confirmationDialog(")
        lines.append("    \"\(dialogTitle)\",")
        lines.append("    isPresented: $isPresented,")
        lines.append("    titleVisibility: \(titleVisibility.codeLabel)")
        lines.append(") {")
        if includesDestructive {
            lines.append("    Button(\"Delete\", role: .destructive) { delete() }")
        }
        lines.append("    Button(\"Cancel\", role: .cancel) { }")
        lines.append("} message: {")
        if !messageText.isEmpty {
            lines.append("    Text(\"\(messageText)\")")
        }
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}

// MARK: - Supporting types
private struct StatefulDialogTrigger: View {
    let label: String
    let title: String
    let message: String
    let includesDestructive: Bool
    let visibility: Visibility

    @State private var isPresented = false

    var body: some View {
        Button(label) { isPresented = true }
            .buttonStyle(.bordered)
            .confirmationDialog(
                LocalizedStringKey(title),
                isPresented: $isPresented,
                titleVisibility: visibility,
            ) {
                if includesDestructive {
                    Button("Delete", role: .destructive) {}
                }
                Button("Save") {}
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(message)
            }
    }
}
