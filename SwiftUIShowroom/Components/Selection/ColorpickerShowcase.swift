import SwiftUI

struct ColorpickerShowcase: View {
    // MARK: - Nested types
    enum ColorPickerState: ShowcaseState {
        case `default`
        case noOpacity
        case labelsHidden
        case disabled

        var caption: String {
            switch self {
            case .default: "Default"
            case .noOpacity: "No Opacity"
            case .labelsHidden: "Labels Hidden"
            case .disabled: "Disabled"
            }
        }

        var color: Color {
            switch self {
            case .default: .accentColor
            case .noOpacity: .blue
            case .labelsHidden: .purple
            case .disabled: .gray
            }
        }

        var label: String {
            switch self {
            case .default: "Accent Color"
            case .noOpacity: "Solid Blue"
            case .labelsHidden: "Theme"
            case .disabled: "Locked"
            }
        }

        var supportsOpacity: Bool {
            self != .noOpacity
        }

        var hideLabels: Bool {
            self == .labelsHidden
        }
    }

    // MARK: - State
    @State private var selectedColor: Color = .accentColor
    @State private var labelText = "Background Color"
    @State private var supportsOpacity = true
    @State private var labelsHidden = false
    @State private var isEnabled = true

    // MARK: - Body
    var body: some View {
        ShowcaseScreen(
            title: "ColorPicker",
            summary: "Opens the system color picker to select a Color, with optional opacity support.",
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
private extension ColorpickerShowcase {
    var preview: some View {
        #if os(tvOS)
        unavailableView
        #else
        configuredPicker(
            color: $selectedColor,
            label: labelText,
            supportsOpacity: supportsOpacity,
            hideLabels: labelsHidden,
            isEnabled: isEnabled
        )
        .frame(maxWidth: 320)
        #endif
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Label", text: $labelText)
        ShowcaseColorControl("Color", selection: $selectedColor, supportsOpacity: supportsOpacity)
        ShowcaseToggle("Supports Opacity", isOn: $supportsOpacity)
        ShowcaseToggle("Labels Hidden", isOn: $labelsHidden)
        ShowcaseToggle("Enabled", isOn: $isEnabled)
    }

    @ViewBuilder
    func stateView(_ state: ColorPickerState) -> some View {
        #if os(tvOS)
        unavailableView
        #else
        configuredPicker(
            color: .constant(state.color),
            label: state.label,
            supportsOpacity: state.supportsOpacity,
            hideLabels: state.hideLabels,
            isEnabled: state != .disabled
        )
        #endif
    }

    var unavailableView: some View {
        Text("ColorPicker is not available on tvOS")
            .font(DesignSystem.Font.callout)
            .foregroundStyle(DesignSystem.Color.secondary)
    }

    #if !os(tvOS)
    func configuredPicker(
        color: Binding<Color>,
        label: String,
        supportsOpacity: Bool,
        hideLabels: Bool,
        isEnabled: Bool
    ) -> some View {
        Group {
            if hideLabels {
                ColorPicker(label, selection: color, supportsOpacity: supportsOpacity)
                    .labelsHidden()
                    .disabled(!isEnabled)
            } else {
                ColorPicker(label, selection: color, supportsOpacity: supportsOpacity)
                    .disabled(!isEnabled)
            }
        }
    }
    #endif
}

// MARK: - Code generation
private extension ColorpickerShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("ColorPicker(")
        lines.append("    \"\(labelText)\",")
        lines.append("    selection: $color,")
        lines.append("    supportsOpacity: \(supportsOpacity),")
        lines.append(")")
        if labelsHidden {
            lines.append(".labelsHidden()")
        }
        if !isEnabled {
            lines.append(".disabled(true)")
        }
        return lines.joined(separator: "\n")
    }
}
