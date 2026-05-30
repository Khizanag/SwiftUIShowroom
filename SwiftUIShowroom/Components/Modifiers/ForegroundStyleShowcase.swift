import SwiftUI

struct ForegroundStyleShowcase: View {
    @State private var styleOption: StyleOption = .tint
    @State private var solidColor: Color = .accentColor

    var body: some View {
        ShowcaseScreen(
            title: "Foreground Style",
            summary: "Sets the color, gradient, or hierarchical style used to fill text and symbols.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ForegroundStyleShowcase {
    var preview: some View {
        styledLabel(styleOption: styleOption, solidColor: solidColor, isDisabled: false)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Style", selection: $styleOption)
        if styleOption == .solidColor {
            ShowcaseColorControl("Color", selection: $solidColor)
        }
    }

    @ViewBuilder func stateView(_ state: ForegroundStyleState) -> some View {
        switch state {
        case .enabled:
            styledLabel(styleOption: .tint, solidColor: .accentColor, isDisabled: false)
        case .disabled:
            styledLabel(styleOption: .tint, solidColor: .accentColor, isDisabled: true)
        case .hierarchical:
            hierarchicalExample
        case .gradient:
            gradientExample
        }
    }

    func styledLabel(styleOption: StyleOption, solidColor: Color, isDisabled: Bool) -> some View {
        Label("Styled Label", systemImage: "star.fill")
            .font(DesignSystem.Font.headline)
            .foregroundStyle(styleOption.resolvedStyle(solidColor: solidColor))
            .opacity(isDisabled ? 0.4 : 1)
    }

    var hierarchicalExample: some View {
        VStack(spacing: DesignSystem.Spacing.xSmall) {
            Label("Primary", systemImage: "circle.fill")
                .font(DesignSystem.Font.body)
                .foregroundStyle(.primary)
            Label("Secondary", systemImage: "circle.fill")
                .font(DesignSystem.Font.body)
                .foregroundStyle(.secondary)
            Label("Tertiary", systemImage: "circle.fill")
                .font(DesignSystem.Font.body)
                .foregroundStyle(.tertiary)
        }
    }

    var gradientExample: some View {
        Label("Gradient", systemImage: "star.fill")
            .font(DesignSystem.Font.headline)
            .foregroundStyle(
                LinearGradient(
                    colors: [.purple, .blue, .cyan],
                    startPoint: .leading,
                    endPoint: .trailing,
                ),
            )
    }
}

// MARK: - Code generation
private extension ForegroundStyleShowcase {
    var generatedCode: String {
        let styleArg = styleOption.codeString(solidColor: solidColor)
        return """
        Label("Styled", systemImage: "star.fill")
            .foregroundStyle(\(styleArg))
        """
    }
}

// MARK: - Nested types
extension ForegroundStyleShowcase {
    fileprivate enum StyleOption: ShowcasePickable {
        case tint
        case primary
        case secondary
        case tertiary
        case quaternary
        case solidColor
        case linearGradient
        case angularGradient

        var label: String {
            switch self {
            case .tint: ".tint"
            case .primary: ".primary"
            case .secondary: ".secondary"
            case .tertiary: ".tertiary"
            case .quaternary: ".quaternary"
            case .solidColor: "Color (custom)"
            case .linearGradient: "LinearGradient"
            case .angularGradient: "AngularGradient"
            }
        }

        func resolvedStyle(solidColor: Color) -> AnyShapeStyle {
            switch self {
            case .tint:
                return AnyShapeStyle(.tint)
            case .primary:
                return AnyShapeStyle(.primary)
            case .secondary:
                return AnyShapeStyle(.secondary)
            case .tertiary:
                return AnyShapeStyle(.tertiary)
            case .quaternary:
                return AnyShapeStyle(.quaternary)
            case .solidColor:
                return AnyShapeStyle(solidColor)
            case .linearGradient:
                return AnyShapeStyle(
                    LinearGradient(
                        colors: [.purple, .blue, .cyan],
                        startPoint: .leading,
                        endPoint: .trailing,
                    ),
                )
            case .angularGradient:
                return AnyShapeStyle(
                    AngularGradient(
                        colors: [.red, .orange, .yellow, .green, .blue, .purple, .red],
                        center: .center,
                    ),
                )
            }
        }

        func codeString(solidColor: Color) -> String {
            switch self {
            case .tint: return ".tint"
            case .primary: return ".primary"
            case .secondary: return ".secondary"
            case .tertiary: return ".tertiary"
            case .quaternary: return ".quaternary"
            case .solidColor: return "Color.accentColor"
            case .linearGradient:
                return "LinearGradient(colors: [.purple, .blue, .cyan], startPoint: .leading, endPoint: .trailing)"
            case .angularGradient:
                return "AngularGradient(colors: [.red, .orange, .yellow, .green, .blue, .purple], center: .center)"
            }
        }
    }

    fileprivate enum ForegroundStyleState: ShowcaseState {
        case enabled
        case disabled
        case hierarchical
        case gradient

        var caption: String {
            switch self {
            case .enabled: "Enabled"
            case .disabled: "Disabled"
            case .hierarchical: "Hierarchical"
            case .gradient: "Gradient"
            }
        }
    }
}
