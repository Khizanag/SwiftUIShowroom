import SwiftUI

struct MaterialShowcase: View {
    @State private var materialOption: MaterialOption = .regular
    @State private var clipShapeOption: ClipShapeOption = .roundedRectangle
    @State private var cornerRadius: Double = 20
    @State private var labelStyle: LabelStyleOption = .secondary
    @State private var reduceTransparencyFallback = true
    @State private var padding: Double = 20

    var body: some View {
        ShowcaseScreen(
            title: "Material (Blur)",
            summary: "Translucent blur backdrop (ultraThin to thick) as a ShapeStyle for backgrounds and overlays.",
        ) {
            PreviewStage(backdrop: .colorful) { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension MaterialShowcase {
    enum MaterialOption: ShowcasePickable {
        case ultraThin, thin, regular, thick, ultraThick, bar

        var label: String {
            switch self {
            case .ultraThin: "ultraThinMaterial"
            case .thin: "thinMaterial"
            case .regular: "regularMaterial"
            case .thick: "thickMaterial"
            case .ultraThick: "ultraThickMaterial"
            case .bar: "bar"
            }
        }

        var value: Material {
            switch self {
            case .ultraThin: .ultraThinMaterial
            case .thin: .thinMaterial
            case .regular: .regularMaterial
            case .thick: .thickMaterial
            case .ultraThick: .ultraThickMaterial
            case .bar: .bar
            }
        }
    }

    enum ClipShapeOption: ShowcasePickable {
        case roundedRectangle, capsule, circle, rectangle

        var label: String {
            switch self {
            case .roundedRectangle: "roundedRectangle"
            case .capsule: "capsule"
            case .circle: "circle"
            case .rectangle: "rectangle"
            }
        }
    }

    enum LabelStyleOption: ShowcasePickable {
        case primary, secondary, tertiary

        var label: String {
            switch self {
            case .primary: "primary"
            case .secondary: "secondary"
            case .tertiary: "tertiary"
            }
        }

        var style: HierarchicalShapeStyle {
            switch self {
            case .primary: .primary
            case .secondary: .secondary
            case .tertiary: .tertiary
            }
        }
    }

    enum MaterialGalleryState: ShowcaseState {
        case ultraThin, thin, regular, thick, ultraThick, bar

        var caption: String {
            switch self {
            case .ultraThin: "Ultra Thin"
            case .thin: "Thin"
            case .regular: "Regular"
            case .thick: "Thick"
            case .ultraThick: "Ultra Thick"
            case .bar: "Bar"
            }
        }

        var material: Material {
            switch self {
            case .ultraThin: .ultraThinMaterial
            case .thin: .thinMaterial
            case .regular: .regularMaterial
            case .thick: .thickMaterial
            case .ultraThick: .ultraThickMaterial
            case .bar: .bar
            }
        }
    }
}

// MARK: - Sub-views
private extension MaterialShowcase {
    var preview: some View {
        MaterialCardView(config: previewConfig)
    }

    var previewConfig: MaterialCardView.Config {
        MaterialCardView.Config(
            material: materialOption.value,
            clipShape: clipShapeOption,
            cornerRadius: cornerRadius,
            labelStyle: labelStyle,
            padding: padding,
            reduceTransparencyFallback: reduceTransparencyFallback,
        )
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Material", selection: $materialOption)
        ShowcasePicker("Clip shape", selection: $clipShapeOption)
        ShowcaseSlider("Corner radius", value: $cornerRadius, in: 0...60, step: 1)
        ShowcasePicker("Label style", selection: $labelStyle)
        ShowcaseToggle("Reduce transparency fallback", isOn: $reduceTransparencyFallback)
        ShowcaseSlider("Padding", value: $padding, in: 8...40, step: 1)
    }

    @ViewBuilder
    func stateView(_ state: MaterialGalleryState) -> some View {
        ZStack {
            LinearGradient(
                colors: [.purple, .blue, .teal],
                startPoint: .topLeading,
                endPoint: .bottomTrailing,
            )
            .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
            MaterialCardView(config: galleryConfig(for: state))
        }
    }

    func galleryConfig(for state: MaterialGalleryState) -> MaterialCardView.Config {
        MaterialCardView.Config(
            material: state.material,
            clipShape: .roundedRectangle,
            cornerRadius: 16,
            labelStyle: .secondary,
            padding: 16,
            reduceTransparencyFallback: false,
        )
    }
}

// MARK: - Code generation
private extension MaterialShowcase {
    var generatedCode: String {
        let shapeCode: String
        switch clipShapeOption {
        case .roundedRectangle:
            shapeCode = "RoundedRectangle(cornerRadius: \(Int(cornerRadius)), style: .continuous)"
        case .capsule:
            shapeCode = "Capsule()"
        case .circle:
            shapeCode = "Circle()"
        case .rectangle:
            shapeCode = "Rectangle()"
        }
        return """
        Text("Material")
            .foregroundStyle(.\(labelStyle.label))
            .padding(\(Int(padding)))
            .background(.\(materialOption.label), in: \(shapeCode))
        """
    }
}

// MARK: - MaterialCardView
private struct MaterialCardView: View {
    struct Config {
        var material: Material
        var clipShape: MaterialShowcase.ClipShapeOption
        var cornerRadius: Double
        var labelStyle: MaterialShowcase.LabelStyleOption
        var padding: Double
        var reduceTransparencyFallback: Bool
    }

    let config: Config

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        labelContent
            .modifier(ShapedMaterialBackground(
                material: resolvedMaterial,
                clipShape: config.clipShape,
                cornerRadius: config.cornerRadius,
            ))
    }

    private var resolvedMaterial: AnyShapeStyle {
        if reduceTransparency && config.reduceTransparencyFallback {
            return AnyShapeStyle(Color(white: 0.3))
        }
        return AnyShapeStyle(config.material)
    }

    private var labelContent: some View {
        Text("Material")
            .font(DesignSystem.Font.headline)
            .foregroundStyle(config.labelStyle.style)
            .padding(config.padding)
    }
}

// MARK: - ShapedMaterialBackground
private struct ShapedMaterialBackground: ViewModifier {
    let material: AnyShapeStyle
    let clipShape: MaterialShowcase.ClipShapeOption
    let cornerRadius: Double

    @ViewBuilder
    func body(content: Content) -> some View {
        switch clipShape {
        case .roundedRectangle:
            content.background(
                material,
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous),
            )
        case .capsule:
            content.background(material, in: Capsule())
        case .circle:
            content.background(material, in: Circle())
        case .rectangle:
            content.background(material, in: Rectangle())
        }
    }
}
