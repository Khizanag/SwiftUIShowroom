import SwiftUI

struct GlassButtonStyleShowcase: View {
    @State private var styleOption: GlassStyleOption = .glass
    @State private var tint: Color = .accentColor
    @State private var borderShapeOption: GlassBorderShapeOption = .automatic
    @State private var sizeOption: GlassSizeOption = .regular

    enum GlassStyleOption: ShowcasePickable {
        case glass, glassProminent

        var label: String {
            switch self {
            case .glass: "glass"
            case .glassProminent: "glassProminent"
            }
        }
    }

    enum GlassBorderShapeOption: ShowcasePickable {
        case automatic, capsule, roundedRectangle

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .capsule: "capsule"
            case .roundedRectangle: "roundedRectangle"
            }
        }

        var borderShape: ButtonBorderShape {
            switch self {
            case .automatic: .automatic
            case .capsule: .capsule
            case .roundedRectangle: .roundedRectangle
            }
        }
    }

    enum GlassSizeOption: ShowcasePickable {
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

    enum GlassButtonState: ShowcaseState {
        case `default`, disabled, prominent

        var caption: String {
            switch self {
            case .default: "Default"
            case .disabled: "Disabled"
            case .prominent: "Prominent"
            }
        }
    }

    var body: some View {
        ShowcaseScreen(
            title: "Glass Button Style",
            summary: "Renders a button with Liquid Glass border artwork, optionally prominent.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension GlassButtonStyleShowcase {
    var preview: some View {
        glassButton(label: "Action", style: styleOption, isEnabled: true)
            .tint(tint)
            .controlSize(sizeOption.controlSize)
            .buttonBorderShape(borderShapeOption.borderShape)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Style", selection: $styleOption)
        ShowcaseColorControl("Tint", selection: $tint, supportsOpacity: false)
        ShowcasePicker("Border shape", selection: $borderShapeOption)
        ShowcasePicker("Control size", selection: $sizeOption)
    }

    @ViewBuilder
    func stateView(_ state: GlassButtonState) -> some View {
        switch state {
        case .default:
            glassButton(label: "Action", style: .glass, isEnabled: true)
        case .disabled:
            glassButton(label: "Action", style: .glass, isEnabled: false)
        case .prominent:
            glassButton(label: "Action", style: .glassProminent, isEnabled: true)
                .tint(.accentColor)
        }
    }

    @ViewBuilder
    func glassButton(label: String, style: GlassStyleOption, isEnabled: Bool) -> some View {
        #if os(iOS) || os(macOS)
        if #available(iOS 26, macOS 26, *) {
            switch style {
            case .glass:
                Button(label) {}
                    .buttonStyle(.glass)
                    .disabled(!isEnabled)
            case .glassProminent:
                Button(label) {}
                    .buttonStyle(.glassProminent)
                    .disabled(!isEnabled)
            }
        } else {
            Button(label) {}
                .buttonStyle(.bordered)
                .disabled(!isEnabled)
        }
        #else
        Button(label) {}
            .buttonStyle(.bordered)
            .disabled(!isEnabled)
        #endif
    }
}

// MARK: - Code generation
private extension GlassButtonStyleShowcase {
    var generatedCode: String {
        [
            "Button(\"Action\") { }",
            "    .buttonStyle(.\(styleOption.label))",
            "    .buttonBorderShape(.\(borderShapeOption.label))",
            "    .controlSize(.\(sizeOption.label))",
            "    .tint(\(tintCode))",
        ].joined(separator: "\n")
    }

    var tintCode: String {
        tint == .accentColor ? ".accentColor" : "Color(/* configured */)"
    }
}
