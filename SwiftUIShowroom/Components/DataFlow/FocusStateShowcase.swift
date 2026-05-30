import SwiftUI

struct FocusStateShowcase: View {
    @State private var valueShape: ValueShape = .optionalHashable
    @State private var boundModifier: BoundModifier = .focusedEquals
    @State private var programmaticFocus: ProgrammaticFocus = .none
    @State private var username: String = ""
    @State private var password: String = ""
    @FocusState private var focusedField: FocusField?

    var body: some View {
        ShowcaseScreen(
            title: "@FocusState",
            summary: "Reads and programmatically moves keyboard/system focus among focusable views.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension FocusStateShowcase {
    enum FocusField: Hashable {
        case username
        case password
    }

    enum ValueShape: ShowcasePickable {
        case bool
        case optionalHashable

        var label: String {
            switch self {
            case .bool: "Bool"
            case .optionalHashable: "Optional Hashable"
            }
        }
    }

    enum BoundModifier: ShowcasePickable {
        case focusedBool
        case focusedEquals

        var label: String {
            switch self {
            case .focusedBool: "focused(_:)"
            case .focusedEquals: "focused(_:equals:)"
            }
        }
    }

    enum ProgrammaticFocus: String, ShowcasePickable {
        case none
        case username
        case password

        var label: String {
            switch self {
            case .none: "nil (dismiss)"
            case .username: ".username"
            case .password: ".password"
            }
        }
    }

    enum FocusShowcaseState: ShowcaseState {
        case `default`
        case focused
        case disabled

        var caption: String {
            switch self {
            case .default: "Default"
            case .focused: "Focused"
            case .disabled: "Disabled"
            }
        }
    }
}

// MARK: - Sub-views
private extension FocusStateShowcase {
    var preview: some View {
        FocusFormView(
            config: FocusFormView.Config(
                valueShape: valueShape,
                boundModifier: boundModifier,
                programmaticFocus: programmaticFocus,
            ),
            username: $username,
            password: $password,
            focusedField: $focusedField,
        )
        .frame(maxWidth: 340)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Value shape", selection: $valueShape)
        ShowcasePicker("Bound modifier", selection: $boundModifier)
        ShowcasePicker("Programmatic focus", selection: $programmaticFocus)
    }

    @ViewBuilder func stateView(_ state: FocusShowcaseState) -> some View {
        switch state {
        case .default:
            staticFieldRow(label: "Username", isFocused: false, isDisabled: false)
        case .focused:
            staticFieldRow(label: "Username", isFocused: true, isDisabled: false)
        case .disabled:
            staticFieldRow(label: "Username", isFocused: false, isDisabled: true)
        }
    }

    func staticFieldRow(label: String, isFocused: Bool, isDisabled: Bool) -> some View {
        HStack {
            TextField(label, text: .constant(""))
                .textFieldStyle(.roundedBorder)
                .disabled(isDisabled)
            if isFocused {
                Image(systemName: "keyboard")
                    .foregroundStyle(DesignSystem.Color.accent)
                    .font(DesignSystem.Font.body)
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .background(
            DesignSystem.Color.cardBackground,
            in: .rect(cornerRadius: DesignSystem.CornerRadius.medium),
        )
        .frame(maxWidth: 280)
    }
}

// MARK: - Code generation
private extension FocusStateShowcase {
    var generatedCode: String {
        let focusType = valueShape == .bool ? "Bool" : "Field?"
        let initialValue = valueShape == .bool ? "false" : "nil"
        let usernameModifier = boundModifier == .focusedBool
            ? ".focused($focusedField)"
            : ".focused($focusedField, equals: .username)"
        let buttonAction = programmaticFocus == .none
            ? "focusedField = nil"
            : "focusedField = .\(programmaticFocus.rawValue)"
        let enumBlock = valueShape == .optionalHashable
            ? "\n    enum Field: Hashable { case username, password }\n"
            : ""
        return """
        struct FocusStateDemo: View {
            \(enumBlock.isEmpty ? "" : enumBlock)    @State private var username = ""
            @State private var password = \(initialValue == "nil" ? "\"\"" : initialValue)
            @FocusState private var focusedField: \(focusType)

            var body: some View {
                Form {
                    TextField("Username", text: $username)
                        \(usernameModifier)
                    SecureField("Password", text: $password)
                        .focused($focusedField, equals: .password)
                    Button("Next") { \(buttonAction) }
                        .keyboardShortcut(.return)
                }
                .onSubmit { focusedField = .password }
            }
        }
        """
    }
}

// MARK: - FocusFormView
private struct FocusFormView: View {
    struct Config {
        let valueShape: FocusStateShowcase.ValueShape
        let boundModifier: FocusStateShowcase.BoundModifier
        let programmaticFocus: FocusStateShowcase.ProgrammaticFocus
    }

    let config: Config
    @Binding var username: String
    @Binding var password: String
    @FocusState.Binding var focusedField: FocusStateShowcase.FocusField?

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            fieldStack
            actionRow
            focusIndicator
        }
        .padding(DesignSystem.Spacing.medium)
        .background(
            DesignSystem.Color.cardBackground,
            in: .rect(cornerRadius: DesignSystem.CornerRadius.medium),
        )
    }
}

// MARK: - FocusFormView sub-views
private extension FocusFormView {
    var fieldStack: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            usernameField
            passwordField
        }
    }

    @ViewBuilder var usernameField: some View {
        if config.boundModifier == .focusedBool {
            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
        } else {
            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .username)
                .onSubmit { focusedField = .password }
        }
    }

    var passwordField: some View {
        SecureField("Password", text: $password)
            .textFieldStyle(.roundedBorder)
            .focused($focusedField, equals: .password)
    }

    var actionRow: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            focusUsernameButton
            focusPasswordButton
            dismissButton
        }
    }

    var focusUsernameButton: some View {
        Button("Username") {
            focusedField = .username
        }
        .buttonStyle(.bordered)
        .font(DesignSystem.Font.caption)
    }

    var focusPasswordButton: some View {
        Button("Password") {
            focusedField = .password
        }
        .buttonStyle(.bordered)
        .font(DesignSystem.Font.caption)
    }

    var dismissButton: some View {
        Button("Dismiss") {
            focusedField = nil
        }
        .buttonStyle(.bordered)
        .font(DesignSystem.Font.caption)
    }

    var focusIndicator: some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(
                systemName: focusedField == nil
                    ? "keyboard.chevron.compact.down"
                    : "keyboard",
            )
            .foregroundStyle(
                focusedField == nil
                    ? DesignSystem.Color.secondary
                    : DesignSystem.Color.accent,
            )
            Text(focusIndicatorLabel)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }

    var focusIndicatorLabel: String {
        switch focusedField {
        case .username: "Focused: username"
        case .password: "Focused: password"
        case .none: "No focus"
        }
    }
}
