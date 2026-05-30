import SwiftUI

struct ColorMultiplyShowcase: View {
    enum ColorMultiplyState: ShowcaseState {
        case white
        case red
        case blue
        case black
        case yellow

        var caption: String {
            switch self {
            case .white: return ".white (unchanged)"
            case .red: return ".red (red tint)"
            case .blue: return ".blue (blue tint)"
            case .black: return ".black (fully darkened)"
            case .yellow: return ".yellow (warm tint)"
            }
        }
    }

    @State private var multiplyColor: Color = .white

    var body: some View {
        ShowcaseScreen(
            title: "Color Multiply",
            summary: "Multiplies the view's colors by a tint color, darkening toward that hue.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ColorMultiplyShowcase {
    var preview: some View {
        swatch(color: multiplyColor)
    }

    @ViewBuilder var controls: some View {
        ShowcaseColorControl("Color", selection: $multiplyColor, supportsOpacity: false)
    }

    @ViewBuilder func stateView(_ state: ColorMultiplyState) -> some View {
        switch state {
        case .white:
            swatch(color: .white)
        case .red:
            swatch(color: .red)
        case .blue:
            swatch(color: .blue)
        case .black:
            swatch(color: .black)
        case .yellow:
            swatch(color: .yellow)
        }
    }

    func swatch(color: Color) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "photo.fill")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.accent)
            Text("Color Multiply")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.primary)
        }
        .padding(DesignSystem.Spacing.large)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium),
        )
        .colorMultiply(color)
    }
}

// MARK: - Code generation
private extension ColorMultiplyShowcase {
    var generatedCode: String {
        "Image(\"photo\")\n    .colorMultiply(\(colorLiteral(multiplyColor)))"
    }

    func colorLiteral(_ color: Color) -> String {
        switch color {
        case .white: return ".white"
        case .black: return ".black"
        case .red: return ".red"
        case .blue: return ".blue"
        case .green: return ".green"
        case .yellow: return ".yellow"
        case .orange: return ".orange"
        case .purple: return ".purple"
        case .pink: return ".pink"
        default: return "color"
        }
    }
}
