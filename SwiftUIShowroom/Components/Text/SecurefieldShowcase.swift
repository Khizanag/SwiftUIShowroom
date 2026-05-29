import SwiftUI

struct SecurefieldShowcase: View {
    @State private var placeholder = "Password"
    @State private var text = ""
    @State private var promptText = ""
    @State private var showPrompt = false
    @State private var style: FieldStyleOption = .automatic
    @State private var submitLabel: SubmitLabelOption = .done
    @State private var contentType: ContentTypeOption = .password
    @State private var isDisabled = false
    @FocusState private var isFocused: Bool

    var body: some View {
        ShowcaseScreen(
            title: "SecureField",
            summary: "A masked text input for passwords and sensitive data; obscures every character.",
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

// MARK: - Nested types
extension SecurefieldShowcase {
    enum FieldStyleOption: ShowcasePickable {
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
        case done, go, send, join, `continue`, `return`

        var label: String {
            switch self {
            case .done: "done"
            case .go: "go"
            case .send: "send"
            case .join: "join"
            case .continue: "continue"
            case .return: "return"
            }
        }

        var submitLabel: SubmitLabel {
            switch self {
            case .done: .done
            case .go: .go
            case .send: .send
            case .join: .join
            case .continue: .continue
            case .return: .return
            }
        }
    }

    enum ContentTypeOption: ShowcasePickable {
        case password, newPassword, oneTimeCode

        var label: String {
            switch self {
            case .password: "password"
            case .newPassword: "newPassword"
            case .oneTimeCode: "oneTimeCode"
            }
        }

        var code: String { ".\(label)" }
    }

    enum SecureFieldState: ShowcaseState {
        case `default`, focused, disabled, error, empty

        var caption: String {
            switch self {
            case .default: "Default"
            case .focused: "Focused"
            case .disabled: "Disabled"
            case .error: "Error"
            case .empty: "Empty"
            }
        }
    }
}

// MARK: - Sub-views
private extension SecurefieldShowcase {
    var preview: some View {
        styledField(
            text: $text,
            placeholder: placeholder,
            prompt: resolvedPrompt,
            isDisabled: isDisabled,
        )
        .focused($isFocused)
        .submitLabel(submitLabel.submitLabel)
        .frame(maxWidth: 320)
        #if os(iOS)
        .textContentType(contentType.textContentTypeValue)
        #endif
    }

    @ViewBuilder var controls: some View {
        ShowcaseTextControl("Placeholder", text: $placeholder)
        ShowcaseToggle("Show prompt", isOn: $showPrompt)
        if showPrompt {
            ShowcaseTextControl("Prompt text", text: $promptText, prompt: "e.g. Required")
        }
        ShowcasePicker("Style", selection: $style)
        ShowcasePicker("Submit label", selection: $submitLabel)
        #if os(iOS)
        ShowcasePicker("Content type", selection: $contentType)
        #endif
        ShowcaseToggle("Disabled", isOn: $isDisabled)
        ShowcaseToggle("Focused", isOn: Binding(
            get: { isFocused },
            set: { isFocused = $0 },
        ))
    }

    @ViewBuilder
    func stateView(_ state: SecureFieldState) -> some View {
        switch state {
        case .default:
            styledField(
                text: .constant("••••••••"),
                placeholder: "Password",
                prompt: nil,
                isDisabled: false,
            )
        case .focused:
            styledField(
                text: .constant(""),
                placeholder: "Password",
                prompt: nil,
                isDisabled: false,
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .stroke(DesignSystem.Color.accent, lineWidth: 2),
            )
        case .disabled:
            styledField(
                text: .constant(""),
                placeholder: "Password",
                prompt: nil,
                isDisabled: true,
            )
        case .error:
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                styledField(
                    text: .constant(""),
                    placeholder: "Password",
                    prompt: nil,
                    isDisabled: false,
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .stroke(.red, lineWidth: 1.5),
                )
                Text("Password is required")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(.red)
            }
        case .empty:
            styledField(
                text: .constant(""),
                placeholder: "Password",
                prompt: Text("Required"),
                isDisabled: false,
            )
        }
    }
}

// MARK: - Helpers
private extension SecurefieldShowcase {
    var resolvedPrompt: Text? {
        showPrompt && !promptText.isEmpty ? Text(promptText) : nil
    }

    @ViewBuilder
    func styledField(
        text: Binding<String>,
        placeholder: String,
        prompt: Text?,
        isDisabled: Bool,
    ) -> some View {
        let field = SecureField(placeholder, text: text, prompt: prompt)
            .disabled(isDisabled)
        switch style {
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
}

// MARK: - Code generation
private extension SecurefieldShowcase {
    var generatedCode: String {
        var lines: [String] = []
        let promptArg = showPrompt && !promptText.isEmpty
            ? ", prompt: Text(\"\(promptText)\")"
            : ""
        lines.append("SecureField(\"\(placeholder)\", text: $password\(promptArg))")
        lines.append("    .textFieldStyle(\(style.code))")
        lines.append("    .submitLabel(.\(submitLabel.label))")
        #if os(iOS)
        lines.append("    .textContentType(\(contentType.code))")
        #endif
        if isDisabled {
            lines.append("    .disabled(true)")
        }
        return lines.joined(separator: "\n")
    }
}

// MARK: - Platform helpers
#if os(iOS)
private extension SecurefieldShowcase.ContentTypeOption {
    var textContentTypeValue: UITextContentType? {
        switch self {
        case .password: .password
        case .newPassword: .newPassword
        case .oneTimeCode: .oneTimeCode
        }
    }
}
#endif
