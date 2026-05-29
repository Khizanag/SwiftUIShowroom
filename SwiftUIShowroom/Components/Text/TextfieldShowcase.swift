import SwiftUI

struct TextfieldShowcase: View {
    // MARK: - Nested enums
    enum FieldState: ShowcaseState {
        case `default`, focused, disabled, error, empty, longContent

        var caption: String {
            switch self {
            case .default: "Default"
            case .focused: "Focused"
            case .disabled: "Disabled"
            case .error: "Error"
            case .empty: "Empty"
            case .longContent: "Long content"
            }
        }
    }

    enum StyleOption: ShowcasePickable {
        case automatic, plain, roundedBorder

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .plain: "plain"
            case .roundedBorder: "roundedBorder"
            }
        }

        var code: String { ".\(label)" }
    }

    enum SubmitLabelOption: ShowcasePickable {
        case done, go, send, join, route, search, `return`, next, `continue`

        var label: String {
            switch self {
            case .done: "done"
            case .go: "go"
            case .send: "send"
            case .join: "join"
            case .route: "route"
            case .search: "search"
            case .return: "return"
            case .next: "next"
            case .continue: "continue"
            }
        }

        var value: SubmitLabel {
            switch self {
            case .done: .done
            case .go: .go
            case .send: .send
            case .join: .join
            case .route: .route
            case .search: .search
            case .return: .return
            case .next: .next
            case .continue: .continue
            }
        }
    }

    enum AxisOption: ShowcasePickable {
        case horizontal, vertical

        var label: String {
            switch self {
            case .horizontal: "horizontal"
            case .vertical: "vertical"
            }
        }
    }

    // MARK: - State
    @State private var titleKey = "Username"
    @State private var text = ""
    @State private var promptText = ""
    @State private var fieldStyle: StyleOption = .automatic
    @State private var submitLabel: SubmitLabelOption = .done
    @State private var axis: AxisOption = .horizontal
    @State private var lineLimitMax = 4
    @State private var autocorrectionDisabled = false
    @State private var isDisabled = false
    @FocusState private var isFocused: Bool

    var body: some View {
        ShowcaseScreen(
            title: "TextField",
            summary: "Single- or multi-line text input with configurable style, prompt, axis, and submit label.",
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
private extension TextfieldShowcase {
    var preview: some View {
        configuredField
            .frame(maxWidth: 320)
    }

    @ViewBuilder
    var configuredField: some View {
        let prompt: Text? = promptText.isEmpty ? nil : Text(promptText)
        if axis == .vertical {
            styledField(
                title: titleKey,
                text: $text,
                prompt: prompt,
                axis: .vertical,
                isDisabled: isDisabled,
            )
            .lineLimit(1...lineLimitMax)
            .submitLabel(submitLabel.value)
            .autocorrectionDisabled(autocorrectionDisabled)
            .focused($isFocused)
        } else {
            styledField(
                title: titleKey,
                text: $text,
                prompt: prompt,
                axis: .horizontal,
                isDisabled: isDisabled,
            )
            .submitLabel(submitLabel.value)
            .autocorrectionDisabled(autocorrectionDisabled)
            .focused($isFocused)
        }
    }

    @ViewBuilder
    func styledField(
        title: String,
        text: Binding<String>,
        prompt: Text?,
        axis: Axis,
        isDisabled: Bool,
    ) -> some View {
        let field = TextField(title, text: text, prompt: prompt, axis: axis)
            .disabled(isDisabled)
        switch fieldStyle {
        case .automatic:
            field.textFieldStyle(.automatic)
        case .plain:
            field.textFieldStyle(.plain)
        case .roundedBorder:
            #if os(tvOS)
            field.textFieldStyle(.automatic)
            #else
            field.textFieldStyle(.roundedBorder)
            #endif
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Label / placeholder", text: $titleKey)
        ShowcaseTextControl("Prompt text", text: $promptText, prompt: "leave empty to omit")
        ShowcasePicker("Style", selection: $fieldStyle)
        ShowcasePicker("Submit label", selection: $submitLabel)
        ShowcasePicker("Axis", selection: $axis)
        if axis == .vertical {
            ShowcaseStepper("Max line limit", value: $lineLimitMax, in: 2...10)
        }
        ShowcaseToggle("Autocorrection disabled", isOn: $autocorrectionDisabled)
        ShowcaseToggle("Disabled", isOn: $isDisabled)
    }

    @ViewBuilder
    func stateView(_ state: FieldState) -> some View {
        switch state {
        case .default:
            TFStaticView(title: "Username", text: "")
        case .focused:
            TFFocusedView()
        case .disabled:
            TFStaticView(title: "Username", text: "giga", isDisabled: true)
        case .error:
            TFErrorView()
        case .empty:
            TFStaticView(title: "Search…", text: "")
        case .longContent:
            TFStaticView(
                title: "Notes",
                text: "A very long piece of content that overflows the single line.",
            )
        }
    }
}

// MARK: - Code generation
private extension TextfieldShowcase {
    var generatedCode: String {
        var lines: [String] = []
        let promptArg = promptText.isEmpty ? "" : ", prompt: Text(\"\(promptText)\")"
        let axisArg = axis == .vertical ? ", axis: .vertical" : ""
        lines.append("TextField(\"\(titleKey)\", text: $text\(promptArg)\(axisArg))")
        if axis == .vertical {
            lines.append("    .lineLimit(1...\(lineLimitMax))")
        }
        lines.append("    .textFieldStyle(\(fieldStyle.code))")
        lines.append("    .submitLabel(.\(submitLabel.label))")
        if autocorrectionDisabled {
            lines.append("    .autocorrectionDisabled()")
        }
        if isDisabled {
            lines.append("    .disabled(true)")
        }
        return lines.joined(separator: "\n")
    }
}

// MARK: - State gallery helpers
private struct TFStaticView: View {
    let title: String
    let text: String
    var isDisabled = false

    var body: some View {
        TextField(title, text: .constant(text))
            #if os(tvOS)
            .textFieldStyle(.automatic)
            #else
            .textFieldStyle(.roundedBorder)
            #endif
            .disabled(isDisabled)
            .frame(maxWidth: 200)
    }
}

private struct TFFocusedView: View {
    @State private var text = ""
    @FocusState private var focused: Bool

    var body: some View {
        TextField("Email", text: $text)
            #if os(tvOS)
            .textFieldStyle(.automatic)
            #else
            .textFieldStyle(.roundedBorder)
            #endif
            .focused($focused)
            .frame(maxWidth: 200)
            .onAppear { focused = true }
    }
}

private struct TFErrorView: View {
    @State private var text = "invalid@"

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            TextField("Email", text: $text)
                #if os(tvOS)
                .textFieldStyle(.automatic)
                #else
                .textFieldStyle(.roundedBorder)
                #endif
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .stroke(Color.red, lineWidth: 1),
                )
                .frame(maxWidth: 200)
            Text("Invalid email address")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(.red)
        }
    }
}
