import SwiftUI

struct RectangleShowcase: View {
    @State private var renderStyle: RenderStyleOption = .fill
    @State private var fillStyle: FillStyleOption = .color
    @State private var fillColor: Color = .accentColor
    @State private var lineWidth: Double = 2
    @State private var width: Double = 200
    @State private var height: Double = 120
    @State private var opacity: Double = 1
    @State private var rotation: Double = 0

    var body: some View {
        ShowcaseScreen(
            title: "Rectangle",
            summary: "A rectangular shape filling its frame, used for fills, strokes, dividers, and backgrounds.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension RectangleShowcase {
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

    enum FillStyleOption: ShowcasePickable {
        case color, linearGradient, hierarchical

        var label: String {
            switch self {
            case .color: "Color"
            case .linearGradient: "Linear Gradient"
            case .hierarchical: "Hierarchical"
            }
        }
    }

    enum RectangleState: ShowcaseState {
        case solidFill, stroked, strokeBorder, rotated

        var caption: String {
            switch self {
            case .solidFill: "Fill"
            case .stroked: "Stroke"
            case .strokeBorder: "StrokeBorder"
            case .rotated: "Rotated 30°"
            }
        }
    }

    struct RectConfig {
        var renderStyle: RenderStyleOption
        var fillStyle: FillStyleOption
        var fillColor: Color
        var lineWidth: Double
        var frameWidth: Double
        var frameHeight: Double
        var opacity: Double
        var rotation: Double
    }
}

// MARK: - Sub-views
private extension RectangleShowcase {
    var currentConfig: RectConfig {
        RectConfig(
            renderStyle: renderStyle,
            fillStyle: fillStyle,
            fillColor: fillColor,
            lineWidth: lineWidth,
            frameWidth: width,
            frameHeight: height,
            opacity: opacity,
            rotation: rotation
        )
    }

    var preview: some View {
        rectangleView(config: currentConfig)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Render style", selection: $renderStyle)
        ShowcasePicker("Fill style", selection: $fillStyle)
        ShowcaseColorControl("Fill color", selection: $fillColor)
        ShowcaseSlider("Line width", value: $lineWidth, in: 0.5...20, step: 0.5)
        ShowcaseSlider("Width", value: $width, in: 40...320)
        ShowcaseSlider("Height", value: $height, in: 40...320)
        ShowcaseSlider("Opacity", value: $opacity, in: 0...1, step: 0.05)
        ShowcaseSlider("Rotation (deg)", value: $rotation, in: 0...360)
    }

    @ViewBuilder
    func stateView(_ state: RectangleState) -> some View {
        switch state {
        case .solidFill:
            rectangleView(config: stateConfig(renderStyle: .fill, fillStyle: .color, rotation: 0))
        case .stroked:
            rectangleView(config: stateConfig(renderStyle: .stroke, fillStyle: .color, rotation: 0))
        case .strokeBorder:
            rectangleView(config: stateConfig(renderStyle: .strokeBorder, fillStyle: .color, rotation: 0))
        case .rotated:
            rectangleView(config: stateConfig(renderStyle: .fill, fillStyle: .linearGradient, rotation: 30))
        }
    }

    func stateConfig(
        renderStyle: RenderStyleOption,
        fillStyle: FillStyleOption,
        rotation: Double
    ) -> RectConfig {
        RectConfig(
            renderStyle: renderStyle,
            fillStyle: fillStyle,
            fillColor: fillColor,
            lineWidth: lineWidth,
            frameWidth: 100,
            frameHeight: 60,
            opacity: 1,
            rotation: rotation
        )
    }

    @ViewBuilder
    func rectangleView(config: RectConfig) -> some View {
        styledRectangle(config: config)
            .opacity(config.opacity)
            .rotationEffect(.degrees(config.rotation))
            .frame(width: config.frameWidth, height: config.frameHeight)
    }

    @ViewBuilder
    func styledRectangle(config: RectConfig) -> some View {
        switch config.renderStyle {
        case .fill:
            switch config.fillStyle {
            case .color:
                Rectangle().fill(config.fillColor)
            case .linearGradient:
                Rectangle().fill(
                    LinearGradient(
                        colors: [config.fillColor, config.fillColor.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            case .hierarchical:
                Rectangle().fill(config.fillColor.gradient)
            }
        case .stroke:
            Rectangle().stroke(config.fillColor, lineWidth: config.lineWidth)
        case .strokeBorder:
            Rectangle().strokeBorder(config.fillColor, lineWidth: config.lineWidth)
        }
    }
}

// MARK: - Code generation
private extension RectangleShowcase {
    var generatedCode: String {
        var lines = ["Rectangle()"]
        lines.append("    .\(styleArgument)")
        lines.append("    .opacity(\(formatDouble(opacity)))")
        lines.append("    .rotationEffect(.degrees(\(formatDouble(rotation))))")
        lines.append("    .frame(width: \(formatDouble(width)), height: \(formatDouble(height)))")
        return lines.joined(separator: "\n")
    }

    var styleArgument: String {
        switch renderStyle {
        case .fill:
            switch fillStyle {
            case .color:
                return "fill(.accentColor)"
            case .linearGradient:
                let gradient = "LinearGradient(colors: [.accentColor, .accentColor.opacity(0.4)],"
                    + " startPoint: .topLeading, endPoint: .bottomTrailing)"
                return "fill(\(gradient))"
            case .hierarchical:
                return "fill(.accentColor.gradient)"
            }
        case .stroke:
            return "stroke(.accentColor, lineWidth: \(formatDouble(lineWidth)))"
        case .strokeBorder:
            return "strokeBorder(.accentColor, lineWidth: \(formatDouble(lineWidth)))"
        }
    }

    func formatDouble(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(format: "%.2f", value)
    }
}
