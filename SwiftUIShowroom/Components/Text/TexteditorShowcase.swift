import SwiftUI

struct TexteditorShowcase: View {
    @State private var text = "This is some editable text. You can configure it live using the controls below."
    @State private var font: EditorFontOption = .body
    @State private var foregroundColor: Color = .primary
    @State private var lineSpacing: Double = 0
    @State private var lineLimitValue: Int = 0
    @State private var alignment: AlignmentOption = .leading
    @State private var scrollBg: ScrollBgOption = .automatic
    @State private var style: EditorStyleOption = .automatic
    @State private var autocorrectionDisabled = false
    @State private var isDisabled = false

    var body: some View {
        ShowcaseScreen(
            title: "TextEditor",
            summary: "A scrollable multi-line editor for long-form text input.",
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
private extension TexteditorShowcase {
    var preview: some View {
        editorView(text: $text, isDisabled: isDisabled)
            .frame(minHeight: 140)
            .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    func editorView(text: Binding<String>, isDisabled: Bool) -> some View {
        #if os(tvOS)
        Text("TextEditor is not available on tvOS.")
            .font(DesignSystem.Font.body)
            .foregroundStyle(DesignSystem.Color.secondary)
        #else
        styledEditor(text: text)
            .disabled(isDisabled)
        #endif
    }

    #if !os(tvOS)
    @ViewBuilder
    func styledEditor(text: Binding<String>) -> some View {
        let base = TextEditor(text: text)
            .font(font.swiftUIFont)
            .foregroundStyle(foregroundColor)
            .lineSpacing(lineSpacing)
            .multilineTextAlignment(alignment.textAlignment)
            .autocorrectionDisabled(autocorrectionDisabled)
            .applyLineLimitIfNeeded(lineLimitValue)
            .applyScrollBg(scrollBg)

        switch style {
        case .automatic:
            base.textEditorStyle(.automatic)
        case .plain:
            base.textEditorStyle(.plain)
        }
    }
    #endif

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Content", text: $text, prompt: "Enter text…")
        ShowcasePicker("Font", selection: $font)
        ShowcaseColorControl("Foreground color", selection: $foregroundColor, supportsOpacity: false)
        ShowcaseSlider("Line spacing", value: $lineSpacing, in: 0...20, step: 1)
        ShowcaseStepper("Line limit (0 = none)", value: $lineLimitValue, in: 0...20)
        ShowcasePicker("Alignment", selection: $alignment)
        #if !os(tvOS)
        ShowcasePicker("Scroll background", selection: $scrollBg)
        ShowcasePicker("Style", selection: $style)
        ShowcaseToggle("Autocorrection disabled", isOn: $autocorrectionDisabled)
        #endif
        ShowcaseToggle("Disabled", isOn: $isDisabled)
    }

    @ViewBuilder
    func stateView(_ state: EditorState) -> some View {
        #if os(tvOS)
        Text(state.caption)
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.secondary)
        #else
        styledEditor(text: .constant(state.sampleText))
            .disabled(state == .disabled)
            .frame(minHeight: 80)
            .frame(maxWidth: .infinity)
        #endif
    }
}

// MARK: - Code generation
private extension TexteditorShowcase {
    var generatedCode: String {
        var lines = ["TextEditor(text: $text)"]
        if font != .body {
            lines.append("    .font(\(font.codeName))")
        }
        if lineSpacing > 0 {
            lines.append("    .lineSpacing(\(Int(lineSpacing)))")
        }
        if lineLimitValue > 0 {
            lines.append("    .lineLimit(\(lineLimitValue))")
        }
        if alignment != .leading {
            lines.append("    .multilineTextAlignment(\(alignment.codeName))")
        }
        if scrollBg != .automatic {
            lines.append("    .scrollContentBackground(\(scrollBg.codeName))")
        }
        if style != .automatic {
            lines.append("    .textEditorStyle(\(style.codeName))")
        }
        if autocorrectionDisabled {
            lines.append("    .autocorrectionDisabled()")
        }
        if isDisabled {
            lines.append("    .disabled(true)")
        }
        return lines.joined(separator: "\n")
    }
}

// MARK: - Nested configuration types
extension TexteditorShowcase {
    enum EditorFontOption: ShowcasePickable {
        case body, callout, title3, headline, monospaced

        var label: String {
            switch self {
            case .body: "body"
            case .callout: "callout"
            case .title3: "title3"
            case .headline: "headline"
            case .monospaced: "monospaced"
            }
        }

        var codeName: String { ".\(label)" }

        var swiftUIFont: Font {
            switch self {
            case .body: .body
            case .callout: .callout
            case .title3: .title3
            case .headline: .headline
            case .monospaced: .system(.body, design: .monospaced)
            }
        }
    }

    enum AlignmentOption: ShowcasePickable {
        case leading, center, trailing

        var label: String {
            switch self {
            case .leading: "leading"
            case .center: "center"
            case .trailing: "trailing"
            }
        }

        var codeName: String { ".\(label)" }

        var textAlignment: TextAlignment {
            switch self {
            case .leading: .leading
            case .center: .center
            case .trailing: .trailing
            }
        }
    }

    enum ScrollBgOption: ShowcasePickable {
        case automatic, visible, hidden

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .visible: "visible"
            case .hidden: "hidden"
            }
        }

        var codeName: String { ".\(label)" }
    }

    enum EditorStyleOption: ShowcasePickable {
        case automatic, plain

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .plain: "plain"
            }
        }

        var codeName: String { ".\(label)" }
    }

    enum EditorState: ShowcaseState {
        case `default`, focused, disabled, empty, longContent

        var caption: String {
            switch self {
            case .default: "Default"
            case .focused: "Focused"
            case .disabled: "Disabled"
            case .empty: "Empty"
            case .longContent: "Long content"
            }
        }

        var sampleText: String {
            switch self {
            case .default: "This is some editable text."
            case .focused: "This is some editable text."
            case .disabled: "This content cannot be edited."
            case .empty: ""
            case .longContent:
                """
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. \
                Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. \
                Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris \
                nisi ut aliquip ex ea commodo consequat.
                """
            }
        }
    }
}

// MARK: - View helpers
private extension View {
    @ViewBuilder
    func applyLineLimitIfNeeded(_ limit: Int) -> some View {
        if limit > 0 {
            self.lineLimit(limit)
        } else {
            self
        }
    }

    #if !os(tvOS)
    @ViewBuilder
    func applyScrollBg(_ option: TexteditorShowcase.ScrollBgOption) -> some View {
        switch option {
        case .automatic:
            self
        case .visible:
            self.scrollContentBackground(.visible)
        case .hidden:
            self.scrollContentBackground(.hidden)
        }
    }
    #endif
}
