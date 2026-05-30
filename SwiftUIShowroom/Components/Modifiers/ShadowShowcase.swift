import SwiftUI

struct ShadowShowcase: View {
    enum ShadowPreset: ShowcaseState {
        case none
        case subtle
        case elevated
        case dramatic
        case sideCast

        var caption: String {
            switch self {
            case .none: "No shadow"
            case .subtle: "Subtle"
            case .elevated: "Elevated"
            case .dramatic: "Dramatic"
            case .sideCast: "Side cast"
            }
        }

        var color: Color {
            switch self {
            case .none: Color.black.opacity(0)
            case .subtle: Color.black.opacity(0.12)
            case .elevated: Color.black.opacity(0.33)
            case .dramatic: Color.black.opacity(0.55)
            case .sideCast: Color.black.opacity(0.4)
            }
        }

        var radius: CGFloat {
            switch self {
            case .none: 0
            case .subtle: 4
            case .elevated: 12
            case .dramatic: 24
            case .sideCast: 8
            }
        }

        var xOffset: CGFloat {
            switch self {
            case .none: 0
            case .subtle: 0
            case .elevated: 0
            case .dramatic: 0
            case .sideCast: 10
            }
        }

        var yOffset: CGFloat {
            switch self {
            case .none: 0
            case .subtle: 2
            case .elevated: 6
            case .dramatic: 12
            case .sideCast: 4
            }
        }
    }

    @State private var shadowColor: Color = Color.black.opacity(0.33)
    @State private var radius: Double = 8
    @State private var offsetX: Double = 0
    @State private var offsetY: Double = 4

    var body: some View {
        ShowcaseScreen(
            title: "Shadow",
            summary: "Drop shadow behind a view: configurable color, blur radius, and offset.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ShadowShowcase {
    var preview: some View {
        Text("Elevated")
            .font(DesignSystem.Font.headline)
            .padding(.horizontal, DesignSystem.Spacing.large)
            .padding(.vertical, DesignSystem.Spacing.medium)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
            .shadow(
                color: shadowColor,
                radius: radius,
                x: offsetX,
                y: offsetY,
            )
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseColorControl("Color", selection: $shadowColor, supportsOpacity: true)
        ShowcaseSlider("Radius", value: $radius, in: 0...40, step: 1)
        ShowcaseSlider("X offset", value: $offsetX, in: -20...20, step: 1)
        ShowcaseSlider("Y offset", value: $offsetY, in: -20...20, step: 1)
    }

    @ViewBuilder
    func stateView(_ state: ShadowPreset) -> some View {
        Text("Card")
            .font(DesignSystem.Font.subheadline)
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .padding(.vertical, DesignSystem.Spacing.small)
            .background(DesignSystem.Color.cardBackground,
                        in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
            .shadow(
                color: state.color,
                radius: state.radius,
                x: state.xOffset,
                y: state.yOffset,
            )
    }
}

// MARK: - Code generation
private extension ShadowShowcase {
    var generatedCode: String {
        let colorLiteral = colorDescription(shadowColor)
        let radiusStr = formatDouble(radius)
        let xOffsetStr = formatDouble(offsetX)
        let yOffsetStr = formatDouble(offsetY)
        return """
        Text("Elevated")
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            .shadow(color: \(colorLiteral), radius: \(radiusStr), x: \(xOffsetStr), y: \(yOffsetStr))
        """
    }

    func formatDouble(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(format: "%.1f", value)
    }

    func colorDescription(_ color: Color) -> String {
        let resolved = color.resolve(in: EnvironmentValues())
        let red = Double(resolved.red)
        let green = Double(resolved.green)
        let blue = Double(resolved.blue)
        let alpha = Double(resolved.opacity)
        let isBlack = red < 0.01 && green < 0.01 && blue < 0.01
        let isWhite = red > 0.99 && green > 0.99 && blue > 0.99
        if isBlack {
            return alpha >= 0.99
                ? "Color.black"
                : String(format: "Color.black.opacity(%.2f)", alpha)
        }
        if isWhite {
            return alpha >= 0.99
                ? "Color.white"
                : String(format: "Color.white.opacity(%.2f)", alpha)
        }
        return String(
            format: "Color(red: %.2f, green: %.2f, blue: %.2f).opacity(%.2f)",
            red, green, blue, alpha,
        )
    }
}
