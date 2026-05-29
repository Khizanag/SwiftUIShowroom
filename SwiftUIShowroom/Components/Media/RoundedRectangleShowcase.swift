import SwiftUI

struct RoundedRectangleShowcase: View {
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

    enum RenderState: ShowcaseState {
        case fillContinuous
        case strokeCircular
        case strokeBorderContinuous
        case smallRadius
        case largeRadius

        var caption: String {
            switch self {
            case .fillContinuous: "Fill / continuous"
            case .strokeCircular: "Stroke / circular"
            case .strokeBorderContinuous: "StrokeBorder / continuous"
            case .smallRadius: "Small radius (4 pt)"
            case .largeRadius: "Large radius (40 pt)"
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .fillContinuous: 20
            case .strokeCircular: 20
            case .strokeBorderContinuous: 20
            case .smallRadius: 4
            case .largeRadius: 40
            }
        }

        var cornerStyle: RoundedCornerStyle {
            switch self {
            case .strokeCircular: .circular
            default: .continuous
            }
        }

        var renderStyle: RenderStyleOption {
            switch self {
            case .fillContinuous: .fill
            case .strokeCircular: .stroke
            case .strokeBorderContinuous: .strokeBorder
            case .smallRadius: .fill
            case .largeRadius: .fill
            }
        }

        var color: Color {
            switch self {
            case .fillContinuous: .accentColor
            case .strokeCircular: .accentColor
            case .strokeBorderContinuous: .accentColor
            case .smallRadius: .orange
            case .largeRadius: .purple
            }
        }

        var lineWidth: CGFloat { 3 }
    }

    struct ShapeConfig {
        var cornerRadius: CGFloat
        var cornerStyle: RoundedCornerStyle
        var renderStyle: RenderStyleOption
        var color: Color
        var lineWidth: CGFloat
    }

    @State private var cornerRadius: Double = 20
    @State private var cornerStyle: CornerStyleOption = .continuous
    @State private var renderStyle: RenderStyleOption = .fill
    @State private var fillColor: Color = .accentColor
    @State private var lineWidth: Double = 2
    @State private var width: Double = 220
    @State private var height: Double = 120

    var body: some View {
        ShowcaseScreen(
            title: "RoundedRectangle",
            summary: "A rectangle with rounded corners; circular or continuous corner style.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension RoundedRectangleShowcase {
    var preview: some View {
        let config = ShapeConfig(
            cornerRadius: CGFloat(cornerRadius),
            cornerStyle: cornerStyle.value,
            renderStyle: renderStyle,
            color: fillColor,
            lineWidth: CGFloat(lineWidth)
        )
        return renderedShape(config: config, width: CGFloat(width), height: CGFloat(height))
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseSlider("Corner radius", value: $cornerRadius, in: 0...80)
        ShowcasePicker("Corner style", selection: $cornerStyle)
        ShowcasePicker("Render style", selection: $renderStyle)
        ShowcaseColorControl("Color", selection: $fillColor)
        ShowcaseSlider("Line width", value: $lineWidth, in: 0.5...20, step: 0.5)
        ShowcaseSlider("Width", value: $width, in: 40...320)
        ShowcaseSlider("Height", value: $height, in: 40...320)
    }

    @ViewBuilder
    func stateView(_ state: RenderState) -> some View {
        let config = ShapeConfig(
            cornerRadius: state.cornerRadius,
            cornerStyle: state.cornerStyle,
            renderStyle: state.renderStyle,
            color: state.color,
            lineWidth: state.lineWidth
        )
        renderedShape(config: config, width: 180, height: 90)
    }

    @ViewBuilder
    func renderedShape(config: ShapeConfig, width: CGFloat, height: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: config.cornerRadius, style: config.cornerStyle)
        switch config.renderStyle {
        case .fill:
            shape
                .fill(config.color)
                .frame(width: width, height: height)
        case .stroke:
            shape
                .stroke(config.color, lineWidth: config.lineWidth)
                .frame(width: width, height: height)
        case .strokeBorder:
            shape
                .strokeBorder(config.color, lineWidth: config.lineWidth)
                .frame(width: width, height: height)
        }
    }
}

// MARK: - Code generation
private extension RoundedRectangleShowcase {
    var generatedCode: String {
        let styleArg = "cornerRadius: \(Int(cornerRadius)), style: .\(cornerStyle.label)"
        let colorArg = fillColor == .accentColor ? ".accentColor" : "Color(/* configured */)"
        var lines = ["RoundedRectangle(\(styleArg))"]
        switch renderStyle {
        case .fill:
            lines.append("    .fill(\(colorArg))")
        case .stroke:
            lines.append("    .stroke(\(colorArg), lineWidth: \(lineWidth.formattedCompact()))")
        case .strokeBorder:
            lines.append("    .strokeBorder(\(colorArg), lineWidth: \(lineWidth.formattedCompact()))")
        }
        lines.append("    .frame(width: \(Int(width)), height: \(Int(height)))")
        return lines.joined(separator: "\n")
    }
}

// MARK: - Double
private extension Double {
    func formattedCompact() -> String {
        truncatingRemainder(dividingBy: 1) == 0 ? String(Int(self)) : String(self)
    }
}
