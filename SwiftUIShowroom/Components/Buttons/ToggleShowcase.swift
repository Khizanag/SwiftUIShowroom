import SwiftUI

struct ToggleShowcase: View {
    @State private var titleText = "Wi-Fi"
    @State private var isOn = true
    @State private var style: ToggleStyleOption = .switchStyle
    @State private var tint: Color = .green

    var body: some View {
        ShowcaseScreen(
            title: "Toggle",
            summary: "A control that switches between on and off. Configure its style and tint.",
        ) {
            PreviewStage {
                styled(Toggle(titleText, isOn: $isOn))
                    .tint(tint)
                    .frame(maxWidth: 320)
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
private extension ToggleShowcase {
    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Title", text: $titleText)
        ShowcaseToggle("Is on", isOn: $isOn)
        ShowcasePicker("Style", selection: $style)
        ShowcaseColorControl("Tint", selection: $tint, supportsOpacity: false)
    }

    @ViewBuilder
    func styled(_ toggle: Toggle<Text>) -> some View {
        switch style {
        case .automatic: toggle.toggleStyle(.automatic)
        case .switchStyle: toggle.toggleStyle(.switch)
        case .button: toggle.toggleStyle(.button)
        case .checkbox:
            #if os(macOS)
            toggle.toggleStyle(.checkbox)
            #else
            toggle.toggleStyle(.automatic)
            #endif
        }
    }

    @ViewBuilder
    func stateView(_ state: ToggleVisualState) -> some View {
        styled(Toggle(titleText, isOn: .constant(state.isOn)))
            .tint(tint)
            .disabled(state == .disabled)
    }
}

// MARK: - Configuration options
enum ToggleStyleOption: ShowcasePickable {
    case automatic, switchStyle, button, checkbox

    var label: String {
        switch self {
        case .automatic: "automatic"
        case .switchStyle: "switch"
        case .button: "button"
        case .checkbox: "checkbox (macOS)"
        }
    }

    var code: String {
        switch self {
        case .automatic: ".automatic"
        case .switchStyle: ".switch"
        case .button: ".button"
        case .checkbox: ".checkbox"
        }
    }
}

enum ToggleVisualState: ShowcaseState {
    case on, off, disabled

    var caption: String {
        switch self {
        case .on: "On"
        case .off: "Off"
        case .disabled: "Disabled"
        }
    }

    var isOn: Bool {
        switch self {
        case .on: true
        case .off, .disabled: false
        }
    }
}

// MARK: - Code generation
private extension ToggleShowcase {
    var generatedCode: String {
        """
        Toggle("\(titleText)", isOn: $isOn)
            .toggleStyle(\(style.code))
            .tint(.\(tintName))
        """
    }

    var tintName: String {
        tint == .green ? "green" : "accentColor"
    }
}
