import SwiftUI

struct ButtonShowcase: View {
    @State private var titleText = "Continue"
    @State private var style: ButtonStyleOption = .borderedProminent
    @State private var size: ControlSizeOption = .regular
    @State private var role: ButtonRoleOption = .none
    @State private var tint: Color = .accentColor
    @State private var showsIcon = false

    var body: some View {
        ShowcaseScreen(
            title: "Button",
            summary: "A control that performs an action. Configure its style, role, control size, and tint.",
        ) {
            PreviewStage {
                sampleButton
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
private extension ButtonShowcase {
    var sampleButton: some View {
        styled(buttonView(isEnabled: true))
    }

    func buttonView(isEnabled: Bool) -> some View {
        Button(role: role.role) {
            // Showcase action — intentionally empty.
        } label: {
            if showsIcon {
                Label(titleText, systemImage: "arrow.right.circle.fill")
            } else {
                Text(titleText)
            }
        }
        .disabled(!isEnabled)
    }

    @ViewBuilder
    func styled(_ button: some View) -> some View {
        let sized = button.controlSize(size.controlSize).tint(tint)
        switch style {
        case .automatic: sized.buttonStyle(.automatic)
        case .bordered: sized.buttonStyle(.bordered)
        case .borderedProminent: sized.buttonStyle(.borderedProminent)
        case .borderless: sized.buttonStyle(.borderless)
        case .plain: sized.buttonStyle(.plain)
        case .glass: sized.buttonStyle(.glass)
        case .glassProminent: sized.buttonStyle(.glassProminent)
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Title", text: $titleText)
        ShowcasePicker("Style", selection: $style)
        ShowcasePicker("Control size", selection: $size)
        ShowcasePicker("Role", selection: $role)
        ShowcaseColorControl("Tint", selection: $tint, supportsOpacity: false)
        ShowcaseToggle("Show icon", isOn: $showsIcon)
    }

    @ViewBuilder
    func stateView(_ state: EnabledState) -> some View {
        styled(buttonView(isEnabled: state == .enabled))
    }
}

// MARK: - Configuration options
enum ButtonStyleOption: ShowcasePickable {
    case automatic, bordered, borderedProminent, borderless, plain, glass, glassProminent

    var label: String {
        switch self {
        case .automatic: "automatic"
        case .bordered: "bordered"
        case .borderedProminent: "borderedProminent"
        case .borderless: "borderless"
        case .plain: "plain"
        case .glass: "glass"
        case .glassProminent: "glassProminent"
        }
    }

    var code: String { ".\(label)" }
}

enum ControlSizeOption: ShowcasePickable {
    case mini, small, regular, large, extraLarge

    var label: String {
        switch self {
        case .mini: "mini"
        case .small: "small"
        case .regular: "regular"
        case .large: "large"
        case .extraLarge: "extraLarge"
        }
    }

    var controlSize: ControlSize {
        switch self {
        case .mini: .mini
        case .small: .small
        case .regular: .regular
        case .large: .large
        case .extraLarge: .extraLarge
        }
    }
}

enum ButtonRoleOption: ShowcasePickable {
    case none, destructive, cancel

    var label: String {
        switch self {
        case .none: "none"
        case .destructive: "destructive"
        case .cancel: "cancel"
        }
    }

    var role: ButtonRole? {
        switch self {
        case .none: nil
        case .destructive: .destructive
        case .cancel: .cancel
        }
    }
}

/// The enabled / disabled axis, shared by many controls' state galleries.
enum EnabledState: ShowcaseState {
    case enabled, disabled

    var caption: String {
        switch self {
        case .enabled: "Enabled"
        case .disabled: "Disabled"
        }
    }
}

// MARK: - Code generation
private extension ButtonShowcase {
    var generatedCode: String {
        var lines = ["Button(\(roleArgument)action: {}) {"]
        if showsIcon {
            lines.append("    Label(\"\(titleText)\", systemImage: \"arrow.right.circle.fill\")")
        } else {
            lines.append("    Text(\"\(titleText)\")")
        }
        lines.append("}")
        lines.append(".buttonStyle(\(style.code))")
        lines.append(".controlSize(.\(size.label))")
        lines.append(".tint(\(tintCode))")
        return lines.joined(separator: "\n")
    }

    var roleArgument: String {
        guard let role = role.role else { return "" }
        return role == .destructive ? "role: .destructive, " : "role: .cancel, "
    }

    var tintCode: String {
        tint == .accentColor ? ".accentColor" : "Color(/* configured */)"
    }
}
