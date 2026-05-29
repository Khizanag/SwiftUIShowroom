import SwiftUI

struct CapsuleShowcase: View {
    enum CornerStyleOption: ShowcasePickable {
        case circular, continuous

        var label: String {
            switch self {
            case .circular: "circular"
            case .continuous: "continuous"
            }
        }

        var value: RoundedCornerStyle {
            switch self {
            case .circular: .circular
            case .continuous: .continuous
            }
        }
    }

    enum RenderStyleOption: ShowcasePickable {
        case fill, stroke, strokeBorder

        var label: String {
            switch self {
            case .fill: "fill"
            case .stroke: "stroke"
            case .strokeBorder: "strokeBorder"
            }
        }
    }

    enum CapsuleState: ShowcaseState {
        case defaultFill, selected, strokeOnly

        var caption: String {
            switch self {
            case .defaultFill: "Fill"
            case .selected: "Selected"
            case .strokeOnly: "Stroke"
            }
        }

        var cornerStyle: CornerStyleOption {
            switch self {
            case .defaultFill: .continuous
            case .selected: .continuous
            case .strokeOnly: .circular
            }
        }

        var renderStyle: RenderStyleOption {
            switch self {
            case .defaultFill: .fill
            case .selected: .fill
            case .strokeOnly: .strokeBorder
            }
        }

        var color: Color {
            switch self {
            case .defaultFill: .accentColor
            case .selected: .green
            case .strokeOnly: .accentColor
            }
        }
    }

    struct ShapeConfig {
        var cornerStyle: CornerStyleOption
        var renderStyle: RenderStyleOption
        var color: Color
        var lineWidth: CGFloat
        var size: CGSize
    }

    @State private var cornerStyle: CornerStyleOption = .continuous
    @State private var renderStyle: RenderStyleOption = .fill
    @State private var fillColor: Color = .accentColor
    @State private var lineWidth: Double = 2
    @State private var width: Double = 160
    @State private var height: Double = 48

    var body: some View {
        ShowcaseScreen(
            title: "Capsule",
            summary: "A pill shape — a rectangle whose shorter dimension's ends are fully rounded.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension CapsuleShowcase {
    var preview: some View {
        capsuleView(
            ShapeConfig(
                cornerStyle: cornerStyle,
                renderStyle: renderStyle,
                color: fillColor,
                lineWidth: CGFloat(lineWidth),
                size: CGSize(width: width, height: height)
            )
        )
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Corner style", selection: $cornerStyle)
        ShowcasePicker("Render style", selection: $renderStyle)
        ShowcaseColorControl("Color", selection: $fillColor)
        ShowcaseSlider("Line width", value: $lineWidth, in: 0.5...16, step: 0.5)
        ShowcaseSlider("Width", value: $width, in: 60...320, step: 1)
        ShowcaseSlider("Height", value: $height, in: 28...120, step: 1)
    }

    @ViewBuilder
    func stateView(_ state: CapsuleState) -> some View {
        capsuleView(
            ShapeConfig(
                cornerStyle: state.cornerStyle,
                renderStyle: state.renderStyle,
                color: state.color,
                lineWidth: 2,
                size: CGSize(width: 140, height: 44)
            )
        )
    }

    @ViewBuilder
    func capsuleView(_ config: ShapeConfig) -> some View {
        let shape = Capsule(style: config.cornerStyle.value)
        switch config.renderStyle {
        case .fill:
            shape
                .fill(config.color)
                .frame(width: config.size.width, height: config.size.height)
        case .stroke:
            shape
                .stroke(config.color, lineWidth: config.lineWidth)
                .frame(width: config.size.width, height: config.size.height)
        case .strokeBorder:
            shape
                .strokeBorder(config.color, lineWidth: config.lineWidth)
                .frame(width: config.size.width, height: config.size.height)
        }
    }
}

// MARK: - Code generation
private extension CapsuleShowcase {
    var generatedCode: String {
        let lineWidthSnippet = renderStyle == .fill
            ? ""
            : ", lineWidth: \(formatted(lineWidth))"
        return """
        Capsule(style: .\(cornerStyle.label))
            .\(renderStyle.label)(\(colorCode)\(lineWidthSnippet))
            .frame(width: \(formatted(width)), height: \(formatted(height)))
        """
    }

    var colorCode: String {
        fillColor == .accentColor ? ".accentColor" : "Color(/* configured */)"
    }

    func formatted(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(format: "%.1f", value)
    }
}
