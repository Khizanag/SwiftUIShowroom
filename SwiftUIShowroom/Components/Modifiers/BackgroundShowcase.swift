import SwiftUI

struct BackgroundShowcase: View {
    enum BackgroundStyleOption: ShowcasePickable {
        case regularMaterial
        case thinMaterial
        case ultraThinMaterial
        case thickMaterial
        case ultraThickMaterial
        case backgroundStyle
        case grayOpacity
        case accentTint

        var label: String {
            switch self {
            case .regularMaterial: ".regularMaterial"
            case .thinMaterial: ".thinMaterial"
            case .ultraThinMaterial: ".ultraThinMaterial"
            case .thickMaterial: ".thickMaterial"
            case .ultraThickMaterial: ".ultraThickMaterial"
            case .backgroundStyle: ".background"
            case .grayOpacity: "Color.gray.opacity(0.15)"
            case .accentTint: "Color.accentColor.opacity(0.2)"
            }
        }

        var shapeStyle: AnyShapeStyle {
            switch self {
            case .regularMaterial: AnyShapeStyle(.regularMaterial)
            case .thinMaterial: AnyShapeStyle(.thinMaterial)
            case .ultraThinMaterial: AnyShapeStyle(.ultraThinMaterial)
            case .thickMaterial: AnyShapeStyle(.thickMaterial)
            case .ultraThickMaterial: AnyShapeStyle(.ultraThickMaterial)
            case .backgroundStyle: AnyShapeStyle(.background)
            case .grayOpacity: AnyShapeStyle(Color.gray.opacity(0.15))
            case .accentTint: AnyShapeStyle(Color.accentColor.opacity(0.2))
            }
        }
    }

    enum BackgroundShapeOption: ShowcasePickable {
        case rectangle
        case roundedRectangle
        case capsule
        case circle

        var label: String {
            switch self {
            case .rectangle: "Rectangle()"
            case .roundedRectangle: "RoundedRectangle(cornerRadius: 12)"
            case .capsule: "Capsule()"
            case .circle: "Circle()"
            }
        }
    }

    enum BackgroundDemoState: ShowcaseState {
        case `default`
        case selected
        case subtle

        var caption: String {
            switch self {
            case .default: "Default"
            case .selected: "Selected"
            case .subtle: "Subtle"
            }
        }
    }

    @State private var styleOption: BackgroundStyleOption = .regularMaterial
    @State private var shapeOption: BackgroundShapeOption = .roundedRectangle

    var body: some View {
        ShowcaseScreen(
            title: "Background",
            summary: "Layers a style or view behind the modified view, optionally clipped to a shape.",
        ) {
            PreviewStage(backdrop: .colorful) { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension BackgroundShowcase {
    var preview: some View {
        cardContent
            .background(styleOption.shapeStyle, in: resolvedShape(shapeOption))
    }

    var cardContent: some View {
        Text("Card")
            .font(DesignSystem.Font.headline)
            .foregroundStyle(DesignSystem.Color.primary)
            .padding(DesignSystem.Spacing.large)
    }

    func resolvedShape(_ option: BackgroundShapeOption) -> AnyShape {
        switch option {
        case .rectangle: AnyShape(Rectangle())
        case .roundedRectangle: AnyShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        case .capsule: AnyShape(Capsule())
        case .circle: AnyShape(Circle())
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Style", selection: $styleOption)
        ShowcasePicker("Shape", selection: $shapeOption)
    }

    @ViewBuilder
    func stateView(_ state: BackgroundDemoState) -> some View {
        switch state {
        case .default:
            Text("Card")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.primary)
                .padding(DesignSystem.Spacing.large)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        case .selected:
            Text("Card")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.primary)
                .padding(DesignSystem.Spacing.large)
                .background(
                    AnyShapeStyle(Color.accentColor.opacity(0.2)),
                    in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large),
                )
        case .subtle:
            Text("Card")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.primary)
                .padding(DesignSystem.Spacing.large)
                .background(
                    AnyShapeStyle(Color.gray.opacity(0.15)),
                    in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large),
                )
        }
    }
}

// MARK: - Code generation
private extension BackgroundShowcase {
    var generatedCode: String {
        let lines = [
            "Text(\"Card\")",
            "    .padding()",
            "    .background(\(styleOption.label), in: \(shapeOption.label))",
        ]
        return lines.joined(separator: "\n")
    }
}
