import SwiftUI

// MARK: - FocusedValues entries used by this showcase
extension FocusedValues {
    @Entry var showcaseDocument: String?
    @Entry var showcaseEditor: String?
    @Entry var showcaseSelection: String?
}

struct FocusedValueShowcase: View {
    @State private var keyPathOption: FocusedKeyOption = .selectedDocument
    @State private var useTypeRead = false
    @State private var publishedLabel = "Report Q1"
    @FocusState private var focusedPanel: FocusedPanel?

    var body: some View {
        ShowcaseScreen(
            title: "@FocusedValue",
            summary: "Reads a value published by the focused view, reflecting the value closest to focus.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension FocusedValueShowcase {
    fileprivate enum FocusedKeyOption: ShowcasePickable {
        case selectedDocument, activeEditor, currentSelection

        var label: String {
            switch self {
            case .selectedDocument: "\\.selectedDocument"
            case .activeEditor: "\\.activeEditor"
            case .currentSelection: "\\.currentSelection"
            }
        }

        var entryName: String {
            switch self {
            case .selectedDocument: "selectedDocument"
            case .activeEditor: "activeEditor"
            case .currentSelection: "currentSelection"
            }
        }
    }

    fileprivate enum FocusedPanel: Hashable {
        case publisherPanel
    }

    fileprivate enum FocusedValueDemoState: ShowcaseState {
        case valuePresent, valueAbsent

        var caption: String {
            switch self {
            case .valuePresent: "Value present"
            case .valueAbsent: "Value absent (nil)"
            }
        }
    }
}

// MARK: - Sub-views
private extension FocusedValueShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            publisherPanel
            readerPanel
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var publisherPanel: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("Publisher (focused view)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            Button {
                focusedPanel = focusedPanel == .publisherPanel ? nil : .publisherPanel
            } label: {
                HStack {
                    Image(systemName: "doc.text")
                        .frame(
                            width: DesignSystem.Size.Icon.small,
                            height: DesignSystem.Size.Icon.small,
                        )
                    Text(publishedLabel.isEmpty ? "Untitled" : publishedLabel)
                        .font(DesignSystem.Font.body)
                    Spacer()
                    if focusedPanel == .publisherPanel {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(DesignSystem.Color.accent)
                    }
                }
                .padding(DesignSystem.Spacing.medium)
                .background(
                    focusedPanel == .publisherPanel
                        ? DesignSystem.Color.accent.opacity(0.12)
                        : DesignSystem.Color.cardBackground,
                )
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
            }
            .focused($focusedPanel, equals: .publisherPanel)
            .focusedValue(\.showcaseDocument, focusedPanel == .publisherPanel ? publishedLabel : nil)
            .focusedValue(\.showcaseEditor, focusedPanel == .publisherPanel ? publishedLabel : nil)
            .focusedValue(\.showcaseSelection, focusedPanel == .publisherPanel ? publishedLabel : nil)
            Text(focusedPanel == .publisherPanel ? "Tap again to unfocus" : "Tap to focus and publish")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var readerPanel: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("Reader (@FocusedValue)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            FocusedValueReaderView(
                keyPathOption: keyPathOption,
                useTypeRead: useTypeRead,
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Key path", selection: $keyPathOption)
        ShowcaseToggle("Type-based read (@FocusedValue(Type.self))", isOn: $useTypeRead)
        ShowcaseTextControl("Published label", text: $publishedLabel, prompt: "e.g. Report Q1")
    }

    @ViewBuilder
    func stateView(_ state: FocusedValueDemoState) -> some View {
        switch state {
        case .valuePresent:
            valuePresentGalleryItem
        case .valueAbsent:
            valueAbsentGalleryItem
        }
    }

    var valuePresentGalleryItem: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            codeLabel("@FocusedValue(\\.selectedDocument) private var doc")
            statusRow(label: "document", value: "\"Report Q1\"", isNil: false)
            actionRow(isNil: false)
        }
        .galleryCardStyle()
    }

    var valueAbsentGalleryItem: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            codeLabel("@FocusedValue(\\.selectedDocument) private var doc")
            statusRow(label: "document", value: "nil", isNil: true)
            actionRow(isNil: true)
        }
        .galleryCardStyle()
    }

    func codeLabel(_ text: String) -> some View {
        Text(text)
            .font(DesignSystem.Font.codeInline)
            .foregroundStyle(DesignSystem.Color.secondary)
            .lineLimit(2)
    }

    func statusRow(label: String, value: String, isNil: Bool) -> some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: isNil ? "xmark.circle" : "checkmark.circle.fill")
                .foregroundStyle(isNil ? DesignSystem.Color.secondary : DesignSystem.Color.accent)
                .frame(
                    width: DesignSystem.Size.Icon.small,
                    height: DesignSystem.Size.Icon.small,
                )
            Text("\(label) = \(value)")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(isNil ? DesignSystem.Color.secondary : DesignSystem.Color.primary)
        }
    }

    func actionRow(isNil: Bool) -> some View {
        Button("Export") {}
            .disabled(isNil)
            .font(DesignSystem.Font.callout)
    }
}

// MARK: - Gallery card style
private extension View {
    func galleryCardStyle() -> some View {
        self
            .padding(DesignSystem.Spacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DesignSystem.Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Focused value reader (reads live FocusedValues)
private struct FocusedValueReaderView: View {
    let keyPathOption: FocusedValueShowcase.FocusedKeyOption
    let useTypeRead: Bool

    @FocusedValue(\.showcaseDocument) private var documentValue
    @FocusedValue(\.showcaseEditor) private var editorValue
    @FocusedValue(\.showcaseSelection) private var selectionValue

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            resolvedValueRow
            Button("Export") {}
                .disabled(resolvedValue == nil)
                .font(DesignSystem.Font.callout)
        }
        .padding(DesignSystem.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    private var resolvedValue: String? {
        switch keyPathOption {
        case .selectedDocument: documentValue
        case .activeEditor: editorValue
        case .currentSelection: selectionValue
        }
    }

    private var resolvedValueRow: some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: resolvedValue == nil ? "xmark.circle" : "checkmark.circle.fill")
                .foregroundStyle(resolvedValue == nil ? DesignSystem.Color.secondary : DesignSystem.Color.accent)
                .frame(
                    width: DesignSystem.Size.Icon.small,
                    height: DesignSystem.Size.Icon.small,
                )
            Text(resolvedValue.map { "value = \"\($0)\"" } ?? "value = nil")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(resolvedValue == nil ? DesignSystem.Color.secondary : DesignSystem.Color.primary)
        }
    }
}

// MARK: - Code generation
private extension FocusedValueShowcase {
    var generatedCode: String {
        let keyName = keyPathOption.entryName
        let keyPathStr = "\\." + keyName
        let readerDecl = useTypeRead
            ? "@FocusedValue(Document.self) private var document"
            : "@FocusedValue(\\." + keyName + ") private var document"

        return [
            "// 1. Declare the FocusedValues entry",
            "extension FocusedValues {",
            "    @Entry var \(keyName): String?",
            "}",
            "",
            "// 2. Publish from the focused view",
            "struct DocumentView: View {",
            "    let title: String",
            "    var body: some View {",
            "        Text(title)",
            "            .focusedValue(\(keyPathStr), title)",
            "    }",
            "}",
            "",
            "// 3. Read in a command or toolbar",
            "struct DocumentCommands: View {",
            "    \(readerDecl)",
            "",
            "    var body: some View {",
            "        Button(\"Export\") { document.map { export($0) } }",
            "            .disabled(document == nil)",
            "    }",
            "}",
        ].joined(separator: "\n")
    }
}
