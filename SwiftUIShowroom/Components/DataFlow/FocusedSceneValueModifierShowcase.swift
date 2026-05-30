import SwiftUI

// MARK: - FocusedValues extensions (demo keys)
extension FocusedValues {
    @Entry var sceneShowcaseDocument: String?
    @Entry var showcaseDocumentTitle: String?
}

struct FocusedSceneValueModifierShowcase: View {
    @State private var scope: ScopeOption = .focusedSceneValue
    @State private var keyPathOption: KeyPathOption = .selectedDocument
    @State private var documentValue = "MyDocument"
    @State private var isPublishing = true

    var body: some View {
        ShowcaseScreen(
            title: "focusedSceneValue",
            summary: "Publishes a value into FocusedValues so commands and menus can observe it.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension FocusedSceneValueModifierShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            publisherCard
            readerCard
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var publisherCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("Publisher (view that sets the value)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            Text(publisherSnippet)
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.primary)
            HStack(spacing: DesignSystem.Spacing.small) {
                Image(systemName: isPublishing
                    ? "antenna.radiowaves.left.and.right"
                    : "antenna.radiowaves.left.and.right.slash"
                )
                    .foregroundStyle(isPublishing ? DesignSystem.Color.accent : DesignSystem.Color.secondary)
                Text(isPublishing ? "Publishing \"\(documentValue)\"" : "Not publishing (value is nil)")
                    .font(DesignSystem.Font.footnote)
                    .foregroundStyle(isPublishing ? DesignSystem.Color.accent : DesignSystem.Color.secondary)
            }
            .padding(.top, DesignSystem.Spacing.xSmall)
        }
        .padding(DesignSystem.Spacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    var readerCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("Reader (@FocusedValue)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            Text(readerSnippet)
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.primary)
            HStack(spacing: DesignSystem.Spacing.small) {
                Image(systemName: isPublishing ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(isPublishing ? .green : DesignSystem.Color.secondary)
                Text(isPublishing ? "Reads: \"\(documentValue)\"" : "Reads: nil (nothing focused)")
                    .font(DesignSystem.Font.footnote)
                    .foregroundStyle(isPublishing ? DesignSystem.Color.primary : DesignSystem.Color.secondary)
            }
            .padding(.top, DesignSystem.Spacing.xSmall)
        }
        .padding(DesignSystem.Spacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Scope", selection: $scope)
        ShowcasePicker("Key path", selection: $keyPathOption)
        ShowcaseTextControl(
            "Published value",
            text: $documentValue,
            prompt: "e.g. MyDocument",
        )
        ShowcaseToggle("Is publishing", isOn: $isPublishing)
    }

    @ViewBuilder
    func stateView(_ state: PublishState) -> some View {
        switch state {
        case .publishing:
            stateCard(
                icon: "antenna.radiowaves.left.and.right",
                label: "Publishing",
                detail: "Reader gets the value",
                isActive: true,
            )
        case .notPublishing:
            stateCard(
                icon: "antenna.radiowaves.left.and.right.slash",
                label: "Not publishing",
                detail: "Reader gets nil",
                isActive: false,
            )
        case .sceneScope:
            stateCard(
                icon: "macwindow",
                label: "Scene scope",
                detail: ".focusedSceneValue — always active",
                isActive: true,
            )
        case .viewScope:
            stateCard(
                icon: "rectangle.dashed",
                label: "View scope",
                detail: ".focusedValue — only while focused",
                isActive: true,
            )
        }
    }

    func stateCard(icon: String, label: String, detail: String, isActive: Bool) -> some View {
        VStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: icon)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(isActive ? DesignSystem.Color.accent : DesignSystem.Color.secondary)
            Text(label)
                .font(DesignSystem.Font.footnote)
                .fontWeight(.medium)
                .foregroundStyle(DesignSystem.Color.primary)
            Text(detail)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.small)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Code generation
private extension FocusedSceneValueModifierShowcase {
    var publisherSnippet: String {
        "DocumentView().\(scope.rawValue)(\(keyPathOption.keyPathString), \(safeDocumentValue))"
    }

    var readerSnippet: String {
        "@FocusedValue(\(keyPathOption.keyPathString)) private var value"
    }

    var safeDocumentValue: String {
        documentValue.isEmpty ? "document" : documentValue
    }

    var generatedCode: String {
        let value = safeDocumentValue
        let keyPathRef = keyPathOption.keyPathString
        let modifier = scope.rawValue
        return [
            "// 1. Declare the FocusedValues entry",
            "extension FocusedValues {",
            "    @Entry var \(keyPathOption.entryName): String?",
            "}",
            "",
            "// 2. Publish from the focused view",
            "struct DocumentView: View {",
            "    let document: String",
            "",
            "    var body: some View {",
            "        Text(document)",
            "            .\(modifier)(\(keyPathRef), document)",
            "    }",
            "}",
            "",
            "// 3. Read in a command or menu",
            "struct ExportCommand: View {",
            "    @FocusedValue(\(keyPathRef)) private var document",
            "",
            "    var body: some View {",
            "        Button(\"Export\") { export(\(value)) }",
            "            .disabled(document == nil)",
            "    }",
            "}",
        ].joined(separator: "\n")
    }
}

// MARK: - Nested enums
extension FocusedSceneValueModifierShowcase {
    fileprivate enum ScopeOption: String, ShowcasePickable {
        case focusedValue
        case focusedSceneValue

        var label: String {
            switch self {
            case .focusedValue: ".focusedValue"
            case .focusedSceneValue: ".focusedSceneValue"
            }
        }
    }

    fileprivate enum KeyPathOption: ShowcasePickable {
        case selectedDocument
        case documentTitle

        var label: String {
            switch self {
            case .selectedDocument: "\\.selectedDocument"
            case .documentTitle: "\\.documentTitle"
            }
        }

        var keyPathString: String {
            switch self {
            case .selectedDocument: "\\.sceneShowcaseDocument"
            case .documentTitle: "\\.showcaseDocumentTitle"
            }
        }

        var entryName: String {
            switch self {
            case .selectedDocument: "sceneShowcaseDocument"
            case .documentTitle: "showcaseDocumentTitle"
            }
        }
    }

    fileprivate enum PublishState: ShowcaseState {
        case publishing
        case notPublishing
        case sceneScope
        case viewScope

        var caption: String {
            switch self {
            case .publishing: "Publishing"
            case .notPublishing: "Not publishing"
            case .sceneScope: "Scene scope"
            case .viewScope: "View scope"
            }
        }
    }
}
