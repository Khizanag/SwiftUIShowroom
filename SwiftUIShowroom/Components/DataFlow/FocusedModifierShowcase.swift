import SwiftUI

struct FocusedModifierShowcase: View {
    @State private var usernameText = ""
    @State private var passwordText = ""
    @FocusState private var focusedField: FocusedModifierShowcase.DemoField?
    @State private var modifierVariant: ModifierVariant = .equalsValue
    @State private var equalsTarget: EqualsTarget = .username
    @State private var isFormEnabled = true

    var body: some View {
        ShowcaseScreen(
            title: "focused(_:) / focused(_:equals:)",
            summary: "Associates a focusable view with a @FocusState binding by Boolean or by matching a value.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension FocusedModifierShowcase {
    enum DemoField: Hashable {
        case username, password
    }

    enum ModifierVariant: ShowcasePickable {
        case boolForm
        case equalsValue

        var label: String {
            switch self {
            case .boolForm: ".focused($binding)"
            case .equalsValue: ".focused($binding, equals:)"
            }
        }

        var modifierString: String {
            switch self {
            case .boolForm: ".focused($isFocused)"
            case .equalsValue: ".focused($focusedField, equals: .username)"
            }
        }
    }

    enum EqualsTarget: ShowcasePickable {
        case username, password

        var label: String {
            switch self {
            case .username: ".username"
            case .password: ".password"
            }
        }

        var codeLabel: String { label }

        var field: DemoField {
            switch self {
            case .username: .username
            case .password: .password
            }
        }
    }

    enum FocusedDemoState: ShowcaseState {
        case `default`, focused, disabled

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
private extension FocusedModifierShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            demoForm(
                focusBinding: $focusedField,
                isEnabled: isFormEnabled,
            )
            focusStatusLabel
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var focusStatusLabel: some View {
        let statusText: String
        switch focusedField {
        case .username: statusText = "Focused: username"
        case .password: statusText = "Focused: password"
        case .none: statusText = "No focus"
        }
        return Text(statusText)
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.secondary)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Modifier variant", selection: $modifierVariant)
        ShowcasePicker("equals: target", selection: $equalsTarget)
        ShowcaseToggle("Form enabled", isOn: $isFormEnabled)
        HStack(spacing: DesignSystem.Spacing.small) {
            focusMoveButton(label: "Focus Username", field: .username)
            focusMoveButton(label: "Focus Password", field: .password)
            focusClearButton
        }
    }

    func focusMoveButton(label: String, field: DemoField) -> some View {
        Button(label) {
            focusedField = field
        }
        .font(DesignSystem.Font.caption)
        .padding(.horizontal, DesignSystem.Spacing.small)
        .padding(.vertical, DesignSystem.Spacing.xSmall)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
    }

    var focusClearButton: some View {
        Button("Clear") {
            focusedField = nil
        }
        .font(DesignSystem.Font.caption)
        .padding(.horizontal, DesignSystem.Spacing.small)
        .padding(.vertical, DesignSystem.Spacing.xSmall)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
    }

    @ViewBuilder
    func stateView(_ state: FocusedDemoState) -> some View {
        switch state {
        case .default:
            StaticFieldRow(label: "Username", isFocused: false, isEnabled: true)
        case .focused:
            StaticFieldRow(label: "Username", isFocused: true, isEnabled: true)
        case .disabled:
            StaticFieldRow(label: "Username", isFocused: false, isEnabled: false)
        }
    }
}

// MARK: - Demo form helper
private extension FocusedModifierShowcase {
    @ViewBuilder
    func demoForm(
        focusBinding: FocusState<DemoField?>.Binding,
        isEnabled: Bool
    ) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            fieldRow(
                label: "Username",
                text: $usernameText,
                field: .username,
                focusBinding: focusBinding,
                isEnabled: isEnabled,
            )
            fieldRow(
                label: "Password",
                text: $passwordText,
                field: .password,
                focusBinding: focusBinding,
                isEnabled: isEnabled,
            )
        }
    }

    func fieldRow(
        label: String,
        text: Binding<String>,
        field: DemoField,
        focusBinding: FocusState<DemoField?>.Binding,
        isEnabled: Bool
    ) -> some View {
        let isFocused = focusedField == field
        return HStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: field == .password ? "lock" : "person")
                .foregroundStyle(isFocused ? DesignSystem.Color.accent : DesignSystem.Color.secondary)
                .frame(width: DesignSystem.Size.Icon.small, height: DesignSystem.Size.Icon.small)
            if field == .password {
                SecureField(label, text: text)
                    .focused(focusBinding, equals: field)
                    .disabled(!isEnabled)
                    .font(DesignSystem.Font.body)
            } else {
                TextField(label, text: text)
                    .focused(focusBinding, equals: field)
                    .disabled(!isEnabled)
                    .font(DesignSystem.Font.body)
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(DesignSystem.Color.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .stroke(
                            isFocused ? DesignSystem.Color.accent : DesignSystem.Color.separator,
                            lineWidth: isFocused ? 2 : 1,
                        )
                )
        )
        .opacity(isEnabled ? 1 : 0.5)
    }
}

// MARK: - Code generation
private extension FocusedModifierShowcase {
    var generatedCode: String {
        switch modifierVariant {
        case .boolForm:
            return boolFormCode
        case .equalsValue:
            return equalsFormCode(target: equalsTarget)
        }
    }

    var boolFormCode: String {
        [
            "struct SingleFieldDemo: View {",
            "    @State private var text = \"\"",
            "    @FocusState private var isFocused: Bool",
            "",
            "    var body: some View {",
            "        VStack {",
            "            TextField(\"Field\", text: $text)",
            "                .focused($isFocused)",
            "            Button(\"Focus\") { isFocused = true }",
            "            Button(\"Dismiss\") { isFocused = false }",
            "        }",
            "    }",
            "}",
        ].joined(separator: "\n")
    }

    func equalsFormCode(target: EqualsTarget) -> String {
        let enabledMarker = isFormEnabled ? "" : "\n        .disabled(true)"
        return [
            "struct MultiFieldDemo: View {",
            "    enum Field: Hashable { case username, password }",
            "    @State private var username = \"\"",
            "    @State private var password = \"\"",
            "    @FocusState private var focusedField: Field?",
            "",
            "    var body: some View {",
            "        Form {",
            "            TextField(\"Username\", text: $username)",
            "                .focused($focusedField, equals: .username)\(enabledMarker)",
            "            SecureField(\"Password\", text: $password)",
            "                .focused($focusedField, equals: .password)\(enabledMarker)",
            "            Button(\"Next\") {",
            "                focusedField = \(target.codeLabel)",
            "            }",
            "        }",
            "    }",
            "}",
        ].joined(separator: "\n")
    }
}

// MARK: - StaticFieldRow
private struct StaticFieldRow: View {
    let label: String
    let isFocused: Bool
    let isEnabled: Bool

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "person")
                .foregroundStyle(isFocused ? DesignSystem.Color.accent : DesignSystem.Color.secondary)
                .frame(width: DesignSystem.Size.Icon.small, height: DesignSystem.Size.Icon.small)
            Text(label)
                .font(DesignSystem.Font.body)
                .foregroundStyle(isEnabled ? DesignSystem.Color.primary : DesignSystem.Color.secondary)
        }
        .padding(DesignSystem.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(DesignSystem.Color.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .stroke(
                            isFocused ? DesignSystem.Color.accent : DesignSystem.Color.separator,
                            lineWidth: isFocused ? 2 : 1,
                        )
                )
        )
        .opacity(isEnabled ? 1 : 0.5)
    }
}
