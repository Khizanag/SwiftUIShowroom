import SwiftUI

struct ButtonRoleShowcase: View {
    enum RoleOption: ShowcasePickable {
        case none
        case destructive
        case cancel
        case confirm
        case close

        var label: String {
            switch self {
            case .none: "none"
            case .destructive: "destructive"
            case .cancel: "cancel"
            case .confirm: "confirm"
            case .close: "close"
            }
        }

        var codeLabel: String { ".\(label)" }

        var buttonRole: ButtonRole? {
            switch self {
            case .none: return nil
            case .destructive: return .destructive
            case .cancel: return .cancel
            case .confirm:
                if #available(iOS 26, macOS 26, tvOS 26, *) {
                    return .confirm
                } else {
                    return nil
                }
            case .close:
                if #available(iOS 26, macOS 26, tvOS 26, *) {
                    return .close
                } else {
                    return nil
                }
            }
        }
    }

    @State private var role: RoleOption = .destructive
    @State private var titleText = "Delete"
    @State private var isEnabled = true

    var body: some View {
        ShowcaseScreen(
            title: "Button Role",
            summary: "A semantic value describing a button's purpose, driving system styling.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ButtonRoleShowcase {
    var preview: some View {
        buttonView(titleText: titleText, role: role, isEnabled: isEnabled)
    }

    @ViewBuilder var controls: some View {
        ShowcaseTextControl("Title", text: $titleText)
        ShowcasePicker("Role", selection: $role)
        ShowcaseToggle("Enabled", isOn: $isEnabled)
    }

    @ViewBuilder func stateView(_ state: EnabledState) -> some View {
        buttonView(titleText: titleText, role: role, isEnabled: state == .enabled)
    }

    @ViewBuilder func buttonView(
        titleText: String,
        role: RoleOption,
        isEnabled: Bool
    ) -> some View {
        Button(titleText, role: role.buttonRole) {}
            .buttonStyle(.bordered)
            .disabled(!isEnabled)
    }
}

// MARK: - Code generation
private extension ButtonRoleShowcase {
    var generatedCode: String {
        let roleArg = role == .none ? "" : ", role: \(role.codeLabel)"
        return [
            "Button(\"\(titleText)\"\(roleArg)) {",
            "    // action",
            "}",
        ].joined(separator: "\n")
    }
}
