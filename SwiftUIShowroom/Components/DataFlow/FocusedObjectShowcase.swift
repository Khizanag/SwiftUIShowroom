import SwiftUI

struct FocusedObjectShowcase: View {
    @State private var publishScope: PublishScopeOption = .focusedSceneObject
    @State private var objectTypeName = "DocumentModel"
    @State private var objectPublished = true

    var body: some View {
        ShowcaseScreen(
            title: "@FocusedObject (legacy)",
            summary: "Reads an ObservableObject from the focused view — legacy counterpart to @FocusedValue.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension FocusedObjectShowcase {
    fileprivate enum PublishScopeOption: ShowcasePickable {
        case focusedObject
        case focusedSceneObject

        var label: String {
            switch self {
            case .focusedObject: ".focusedObject(_:)"
            case .focusedSceneObject: ".focusedSceneObject(_:)"
            }
        }

        var modifierName: String {
            switch self {
            case .focusedObject: "focusedObject"
            case .focusedSceneObject: "focusedSceneObject"
            }
        }
    }

    fileprivate enum FocusedObjectDemoState: ShowcaseState {
        case objectPresent
        case objectAbsent

        var caption: String {
            switch self {
            case .objectPresent: "Object present"
            case .objectAbsent: "Object absent (nil)"
            }
        }
    }
}

// MARK: - Sub-views
private extension FocusedObjectShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            publisherCard
            readerCard
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var publisherCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            sectionLabel("Publisher (document view)")
            publisherBody
        }
        .padding(DesignSystem.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .stroke(
                    objectPublished ? DesignSystem.Color.accent : DesignSystem.Color.separator,
                    lineWidth: 1
                )
        )
    }

    var publisherBody: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: objectPublished ? "doc.fill" : "doc")
                .foregroundStyle(objectPublished ? DesignSystem.Color.accent : DesignSystem.Color.secondary)
                .frame(width: DesignSystem.Size.Icon.small, height: DesignSystem.Size.Icon.small)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.hairline) {
                Text(objectPublished ? "Report Q1.docx" : "No document")
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.primary)
                Text(objectPublished ? "Publishing via .\(publishScope.modifierName)(_:)" : "Not publishing")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
    }

    var readerCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            sectionLabel("Reader (@FocusedObject)")
            readerStatus
            actionButtons
        }
        .padding(DesignSystem.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    var readerStatus: some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: objectPublished ? "checkmark.circle.fill" : "xmark.circle")
                .foregroundStyle(objectPublished ? DesignSystem.Color.accent : DesignSystem.Color.secondary)
                .frame(width: DesignSystem.Size.Icon.small, height: DesignSystem.Size.Icon.small)
            Text(objectPublished ? "document = DocumentModel(\"Report Q1.docx\")" : "document = nil")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(objectPublished ? DesignSystem.Color.primary : DesignSystem.Color.secondary)
                .lineLimit(2)
        }
    }

    var actionButtons: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Button("Export") {}
                .disabled(!objectPublished)
                .font(DesignSystem.Font.callout)
            Button("Share") {}
                .disabled(!objectPublished)
                .font(DesignSystem.Font.callout)
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Publish scope", selection: $publishScope)
        ShowcaseTextControl("Object type name", text: $objectTypeName, prompt: "e.g. DocumentModel")
        ShowcaseToggle("Object published (simulates focus)", isOn: $objectPublished)
    }

    @ViewBuilder
    func stateView(_ state: FocusedObjectDemoState) -> some View {
        switch state {
        case .objectPresent:
            stateCard(
                icon: "doc.fill",
                title: "Object present",
                detail: "@FocusedObject reads the ObservableObject; buttons and commands are enabled.",
                isPresent: true
            )
        case .objectAbsent:
            stateCard(
                icon: "slash.circle",
                title: "Object absent (nil)",
                detail: "Nothing focused publishes the object — @FocusedObject is nil; buttons are disabled.",
                isPresent: false
            )
        }
    }

    func stateCard(icon: String, title: String, detail: String, isPresent: Bool) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.medium) {
            Image(systemName: icon)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(isPresent ? DesignSystem.Color.accent : DesignSystem.Color.secondary)
                .frame(width: DesignSystem.Size.Icon.medium, height: DesignSystem.Size.Icon.medium)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                Text(title)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.primary)
                Text(detail)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
                HStack(spacing: DesignSystem.Spacing.small) {
                    Button("Export") {}
                        .disabled(!isPresent)
                        .font(DesignSystem.Font.callout)
                    Button("Share") {}
                        .disabled(!isPresent)
                        .font(DesignSystem.Font.callout)
                }
                .padding(.top, DesignSystem.Spacing.xSmall)
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.Color.cardBackground, in: .rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.secondary)
    }
}

// MARK: - Code generation
private extension FocusedObjectShowcase {
    var generatedCode: String {
        let safeTypeName = objectTypeName.isEmpty ? "DocumentModel" : objectTypeName
        let modifier = publishScope.modifierName
        return [
            "// 1. Define the ObservableObject model",
            "final class \(safeTypeName): ObservableObject {",
            "    @Published var title: String",
            "    init(title: String) { self.title = title }",
            "    func export() { /* … */ }",
            "}",
            "",
            "// 2. Publish from the focused document view",
            "struct DocumentView: View {",
            "    @StateObject private var model = \(safeTypeName)(title: \"Untitled\")",
            "",
            "    var body: some View {",
            "        Text(model.title)",
            "            .\(modifier)(model)",
            "    }",
            "}",
            "",
            "// 3. Read in a command or toolbar action",
            "struct ExportCommand: View {",
            "    @FocusedObject private var document: \(safeTypeName)?",
            "",
            "    var body: some View {",
            "        Button(\"Export\") { document?.export() }",
            "            .disabled(document == nil)",
            "    }",
            "}",
            "",
            "// Note: prefer @FocusedValue + @Observable for new code.",
            "// Use @FocusedObject only with existing ObservableObject types.",
        ].joined(separator: "\n")
    }
}
