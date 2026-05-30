import SwiftUI

struct OverlayShowcase: View {
    @State private var styleOption: OverlayStyleOption = .scrim
    @State private var shapeOption: OverlayShapeOption = .roundedRect
    @State private var alignmentOption: OverlayAlignmentOption = .topTrailing

    var body: some View {
        ShowcaseScreen(
            title: "Overlay",
            summary: "Layers a style or view in front of the modified view, aligned by the given alignment.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension OverlayShowcase {
    var preview: some View {
        baseCard()
            .overlay(styleOverlay(for: styleOption, shape: shapeOption))
            .overlay(alignment: alignmentOption.value) { badgeCircle }
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Style", selection: $styleOption)
        ShowcasePicker("Shape", selection: $shapeOption)
        ShowcasePicker("Alignment", selection: $alignmentOption)
    }

    @ViewBuilder func stateView(_ state: OverlayState) -> some View {
        switch state {
        case .default:
            baseCard()
                .overlay(alignment: .topTrailing) { badgeCircle }
        case .selected:
            selectedCard()
        case .gradient:
            baseCard()
                .overlay(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom,
                    ),
                    in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium),
                )
        }
    }

    var badgeCircle: some View {
        Circle()
            .fill(DesignSystem.Color.accent)
            .frame(
                width: DesignSystem.Size.Icon.small,
                height: DesignSystem.Size.Icon.small,
            )
            .offset(
                x: DesignSystem.Spacing.xSmall,
                y: -DesignSystem.Spacing.xSmall,
            )
    }

    func baseCard() -> some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(DesignSystem.Color.cardBackground)
            .frame(width: 140, height: 100)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .strokeBorder(DesignSystem.Color.separator, lineWidth: 1),
            )
    }

    func selectedCard() -> some View {
        baseCard()
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .strokeBorder(DesignSystem.Color.accent, lineWidth: 2),
            )
            .overlay(alignment: .topTrailing) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(DesignSystem.Color.accent)
                    .font(DesignSystem.Font.headline)
                    .offset(
                        x: DesignSystem.Spacing.xSmall,
                        y: -DesignSystem.Spacing.xSmall,
                    )
            }
    }

    @ViewBuilder func styleOverlay(
        for style: OverlayStyleOption,
        shape: OverlayShapeOption,
    ) -> some View {
        switch shape {
        case .rectangle:
            styleFilledShape(Rectangle(), style: style)
        case .roundedRect:
            styleFilledShape(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium),
                style: style,
            )
        case .capsule:
            styleFilledShape(Capsule(), style: style)
        case .circle:
            styleFilledShape(Circle(), style: style)
        }
    }

    @ViewBuilder func styleFilledShape<S: Shape>(
        _ shape: S,
        style: OverlayStyleOption,
    ) -> some View {
        switch style {
        case .tint:
            shape.fill(.tint).opacity(0.25)
        case .scrim:
            shape.fill(Color.black.opacity(0.2))
        case .linearGradient:
            shape.fill(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom,
                )
            )
        case .ultraThinMaterial:
            shape.fill(.ultraThinMaterial)
        }
    }
}

// MARK: - Code generation
private extension OverlayShowcase {
    var generatedCode: String {
        """
        baseView
            .overlay(\(styleOption.styleLiteral), in: \(shapeOption.label))
            .overlay(alignment: .\(alignmentOption.label)) {
                Circle().fill(.accent).frame(width: 14, height: 14)
            }
        """
    }
}

// MARK: - Nested types
extension OverlayShowcase {
    fileprivate enum OverlayStyleOption: ShowcasePickable {
        case tint
        case scrim
        case linearGradient
        case ultraThinMaterial

        var label: String {
            switch self {
            case .tint: ".tint"
            case .scrim: "Color.black.opacity(0.2)"
            case .linearGradient: "LinearGradient(...)"
            case .ultraThinMaterial: ".ultraThinMaterial"
            }
        }

        var styleLiteral: String {
            switch self {
            case .tint: ".tint"
            case .scrim: "Color.black.opacity(0.2)"
            case .linearGradient:
                "LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)"
            case .ultraThinMaterial: ".ultraThinMaterial"
            }
        }
    }

    fileprivate enum OverlayShapeOption: ShowcasePickable {
        case rectangle
        case roundedRect
        case capsule
        case circle

        var label: String {
            switch self {
            case .rectangle: "Rectangle()"
            case .roundedRect: "RoundedRectangle(cornerRadius: 12)"
            case .capsule: "Capsule()"
            case .circle: "Circle()"
            }
        }
    }

    fileprivate enum OverlayAlignmentOption: ShowcasePickable {
        case center
        case topTrailing
        case bottomTrailing
        case topLeading
        case bottomLeading
        case bottom

        var label: String {
            switch self {
            case .center: "center"
            case .topTrailing: "topTrailing"
            case .bottomTrailing: "bottomTrailing"
            case .topLeading: "topLeading"
            case .bottomLeading: "bottomLeading"
            case .bottom: "bottom"
            }
        }

        var value: Alignment {
            switch self {
            case .center: .center
            case .topTrailing: .topTrailing
            case .bottomTrailing: .bottomTrailing
            case .topLeading: .topLeading
            case .bottomLeading: .bottomLeading
            case .bottom: .bottom
            }
        }
    }

    fileprivate enum OverlayState: ShowcaseState {
        case `default`
        case selected
        case gradient

        var caption: String {
            switch self {
            case .default: "Default"
            case .selected: "Selected"
            case .gradient: "Gradient overlay"
            }
        }
    }
}
