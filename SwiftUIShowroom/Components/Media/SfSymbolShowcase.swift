import SwiftUI

struct SfSymbolShowcase: View {
    @State private var systemName = "wifi"
    @State private var variableValue = 0.6
    @State private var renderingMode: RenderingModeOption = .monochrome
    @State private var primaryColor: Color = .accentColor
    @State private var secondaryColor: Color = .secondary
    @State private var tertiaryColor: Color = .gray
    @State private var fontStyle: FontStyleOption = .largeTitle
    @State private var fontWeight: FontWeightOption = .regular
    @State private var imageScale: ImageScaleOption = .large
    @State private var symbolVariant: SymbolVariantOption = .none
    @State private var accessibilityLabel = "Wi-Fi signal"

    var body: some View {
        ShowcaseScreen(
            title: "SF Symbol Image",
            summary: "Renders an SF Symbol with rendering mode, variable value, font sizing, and palette colors.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension SfSymbolShowcase {
    var preview: some View {
        symbolImage(config: currentConfig)
            .accessibilityLabel(accessibilityLabel)
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Symbol name", text: $systemName, prompt: "e.g. wifi")
        ShowcaseSlider("Variable value", value: $variableValue, in: 0...1, step: 0.01)
        ShowcasePicker("Rendering mode", selection: $renderingMode)
        ShowcaseColorControl("Primary color", selection: $primaryColor)
        ShowcaseColorControl("Secondary color", selection: $secondaryColor)
        ShowcaseColorControl("Tertiary color", selection: $tertiaryColor)
        ShowcasePicker("Text style", selection: $fontStyle)
        ShowcasePicker("Font weight", selection: $fontWeight)
        ShowcasePicker("Image scale", selection: $imageScale)
        ShowcasePicker("Symbol variant", selection: $symbolVariant)
        ShowcaseTextControl("Accessibility label", text: $accessibilityLabel)
    }

    @ViewBuilder
    func stateView(_ state: SymbolState) -> some View {
        switch state {
        case .default:
            symbolImage(config: currentConfig)
        case .selected:
            symbolImage(config: SymbolConfig(
                name: systemName,
                variableValue: variableValue,
                renderingMode: .hierarchical,
                primaryColor: .accentColor,
                secondaryColor: .secondary,
                tertiaryColor: .gray,
                fontStyle: fontStyle,
                fontWeight: .bold,
                imageScale: imageScale,
                symbolVariant: .fill,
            ))
        case .disabled:
            symbolImage(config: SymbolConfig(
                name: systemName,
                variableValue: variableValue,
                renderingMode: .monochrome,
                primaryColor: .gray,
                secondaryColor: .gray,
                tertiaryColor: .gray,
                fontStyle: fontStyle,
                fontWeight: fontWeight,
                imageScale: imageScale,
                symbolVariant: symbolVariant,
            ))
            .opacity(0.4)
        }
    }
}

// MARK: - Helpers
private extension SfSymbolShowcase {
    struct SymbolConfig {
        var name: String
        var variableValue: Double
        var renderingMode: RenderingModeOption
        var primaryColor: Color
        var secondaryColor: Color
        var tertiaryColor: Color
        var fontStyle: FontStyleOption
        var fontWeight: FontWeightOption
        var imageScale: ImageScaleOption
        var symbolVariant: SymbolVariantOption
    }

    var currentConfig: SymbolConfig {
        SymbolConfig(
            name: systemName,
            variableValue: variableValue,
            renderingMode: renderingMode,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            tertiaryColor: tertiaryColor,
            fontStyle: fontStyle,
            fontWeight: fontWeight,
            imageScale: imageScale,
            symbolVariant: symbolVariant,
        )
    }

    @ViewBuilder
    func symbolImage(config: SymbolConfig) -> some View {
        let base = Image(systemName: config.name, variableValue: config.variableValue)
            .symbolRenderingMode(config.renderingMode.mode)
            .imageScale(config.imageScale.scale)
            .font(config.fontStyle.font.weight(config.fontWeight.weight))
            .symbolVariant(config.symbolVariant.variant)

        switch config.renderingMode {
        case .palette:
            base.foregroundStyle(config.primaryColor, config.secondaryColor, config.tertiaryColor)
        case .hierarchical, .multicolor, .monochrome:
            base.foregroundStyle(config.primaryColor)
        }
    }
}

// MARK: - Code generation
private extension SfSymbolShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("Image(systemName: \"\(systemName)\", variableValue: \(String(format: "%.2f", variableValue)))")
        lines.append("    .symbolRenderingMode(.\(renderingMode.label))")
        lines.append("    .symbolVariant(.\(symbolVariant.label))")
        switch renderingMode {
        case .palette:
            let palette = "\(colorCode(primaryColor)), \(colorCode(secondaryColor)), \(colorCode(tertiaryColor))"
            lines.append("    .foregroundStyle(\(palette))")
        default:
            lines.append("    .foregroundStyle(\(colorCode(primaryColor)))")
        }
        lines.append("    .font(.\(fontStyle.label))")
        lines.append("    .fontWeight(.\(fontWeight.label))")
        lines.append("    .imageScale(.\(imageScale.label))")
        lines.append("    .accessibilityLabel(\"\(accessibilityLabel)\")")
        return lines.joined(separator: "\n")
    }

    func colorCode(_ color: Color) -> String {
        if color == .accentColor { return ".accentColor" }
        if color == .secondary { return ".secondary" }
        if color == .gray { return ".gray" }
        return "Color(/* configured */)"
    }
}

// MARK: - Enums
extension SfSymbolShowcase {
    enum SymbolState: ShowcaseState {
        case `default`, selected, disabled

        var caption: String {
            switch self {
            case .default: "Default"
            case .selected: "Selected"
            case .disabled: "Disabled"
            }
        }
    }

    enum RenderingModeOption: ShowcasePickable {
        case monochrome, hierarchical, palette, multicolor

        var label: String {
            switch self {
            case .monochrome: "monochrome"
            case .hierarchical: "hierarchical"
            case .palette: "palette"
            case .multicolor: "multicolor"
            }
        }

        var mode: SymbolRenderingMode {
            switch self {
            case .monochrome: .monochrome
            case .hierarchical: .hierarchical
            case .palette: .palette
            case .multicolor: .multicolor
            }
        }
    }

    enum FontStyleOption: ShowcasePickable {
        case largeTitle, title, title2, title3, headline, body, callout, subheadline, footnote, caption

        var label: String {
            switch self {
            case .largeTitle: "largeTitle"
            case .title: "title"
            case .title2: "title2"
            case .title3: "title3"
            case .headline: "headline"
            case .body: "body"
            case .callout: "callout"
            case .subheadline: "subheadline"
            case .footnote: "footnote"
            case .caption: "caption"
            }
        }

        var font: Font {
            switch self {
            case .largeTitle: .largeTitle
            case .title: .title
            case .title2: .title2
            case .title3: .title3
            case .headline: .headline
            case .body: .body
            case .callout: .callout
            case .subheadline: .subheadline
            case .footnote: .footnote
            case .caption: .caption
            }
        }
    }

    enum FontWeightOption: ShowcasePickable {
        case ultraLight, thin, light, regular, medium, semibold, bold, heavy, black

        var label: String {
            switch self {
            case .ultraLight: "ultraLight"
            case .thin: "thin"
            case .light: "light"
            case .regular: "regular"
            case .medium: "medium"
            case .semibold: "semibold"
            case .bold: "bold"
            case .heavy: "heavy"
            case .black: "black"
            }
        }

        var weight: Font.Weight {
            switch self {
            case .ultraLight: .ultraLight
            case .thin: .thin
            case .light: .light
            case .regular: .regular
            case .medium: .medium
            case .semibold: .semibold
            case .bold: .bold
            case .heavy: .heavy
            case .black: .black
            }
        }
    }

    enum ImageScaleOption: ShowcasePickable {
        case small, medium, large

        var label: String {
            switch self {
            case .small: "small"
            case .medium: "medium"
            case .large: "large"
            }
        }

        var scale: Image.Scale {
            switch self {
            case .small: .small
            case .medium: .medium
            case .large: .large
            }
        }
    }

    enum SymbolVariantOption: ShowcasePickable {
        case none, fill, circle, square, rectangle, slash

        var label: String {
            switch self {
            case .none: "none"
            case .fill: "fill"
            case .circle: "circle"
            case .square: "square"
            case .rectangle: "rectangle"
            case .slash: "slash"
            }
        }

        var variant: SymbolVariants {
            switch self {
            case .none: .none
            case .fill: .fill
            case .circle: .circle
            case .square: .square
            case .rectangle: .rectangle
            case .slash: .slash
            }
        }
    }
}
