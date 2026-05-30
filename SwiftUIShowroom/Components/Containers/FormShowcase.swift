import SwiftUI

struct FormShowcase: View {
    @State private var style: FormStyleOption = .automatic
    @State private var nameText = "Jane Appleseed"
    @State private var notificationsOn = true

    var body: some View {
        ShowcaseScreen(
            title: "Form",
            summary: "A container for grouping controls used for data entry, with platform-appropriate styling.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension FormShowcase {
    var preview: some View {
        applyFormStyle(
            to: profileForm(nameValue: nameText, notifyValue: notificationsOn),
            disabled: false,
        )
        .frame(maxWidth: 480)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Style", selection: $style)
        ShowcaseTextControl("Name field value", text: $nameText)
        ShowcaseToggle("Notifications on", isOn: $notificationsOn)
    }

    @ViewBuilder
    func stateView(_ state: FormState) -> some View {
        switch state {
        case .default:
            applyFormStyle(
                to: profileForm(nameValue: "Jane Appleseed", notifyValue: true),
                disabled: false,
            )
            .frame(maxWidth: 320)
        case .disabled:
            applyFormStyle(
                to: profileForm(nameValue: "Jane Appleseed", notifyValue: true),
                disabled: true,
            )
            .frame(maxWidth: 320)
        case .longContent:
            applyFormStyle(to: extendedForm(), disabled: false)
                .frame(maxWidth: 320)
        }
    }

    func profileForm(nameValue: String, notifyValue: Bool) -> some View {
        Form {
            Section("Profile") {
                LabeledContent("Name", value: nameValue)
                LabeledContent("Notifications", value: notifyValue ? "On" : "Off")
            }
            Section {
                LabeledContent("Version", value: "1.0.0")
            }
        }
    }

    func extendedForm() -> some View {
        Form {
            Section("Account") {
                LabeledContent("Username", value: "jappleseed")
                LabeledContent("Email", value: "jane@example.com")
                LabeledContent("Plan", value: "Pro")
            }
            Section("Notifications") {
                LabeledContent("Push", value: "Enabled")
                LabeledContent("Email digest", value: "Weekly")
                LabeledContent("SMS", value: "Off")
            }
            Section("About") {
                LabeledContent("Version", value: "1.0.0")
                LabeledContent("Build", value: "42")
            }
        }
    }

    @ViewBuilder
    func applyFormStyle(to form: some View, disabled: Bool) -> some View {
        let disabledForm = form.disabled(disabled)
        switch style {
        case .automatic:
            disabledForm.formStyle(.automatic)
        case .grouped:
            disabledForm.formStyle(.grouped)
        case .columns:
            #if os(macOS)
            disabledForm.formStyle(.columns)
            #else
            disabledForm.formStyle(.automatic)
            #endif
        }
    }
}

// MARK: - Code generation
private extension FormShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("Form {")
        lines.append("    Section(\"Profile\") {")
        lines.append("        TextField(\"Name\", text: $name)")
        lines.append("        Toggle(\"Notifications\", isOn: $notify)")
        lines.append("    }")
        lines.append("    Section {")
        lines.append("        LabeledContent(\"Version\", value: appVersion)")
        lines.append("    }")
        lines.append("}")
        lines.append(".formStyle(.\(style.label))")
        return lines.joined(separator: "\n")
    }
}

// MARK: - Nested types
private extension FormShowcase {
    enum FormStyleOption: ShowcasePickable {
        case automatic, grouped, columns

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .grouped: "grouped"
            case .columns: "columns"
            }
        }
    }

    enum FormState: ShowcaseState {
        case `default`, disabled, longContent

        var caption: String {
            switch self {
            case .default: "Default"
            case .disabled: "Disabled"
            case .longContent: "Long content"
            }
        }
    }
}
