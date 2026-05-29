import SwiftUI

struct CircleShowcase: View {
    @State private var renderStyle: RenderStyleOption = .fill
    @State private var fillColor: Color = DesignSystem.Color.accent
    @State private var lineWidth: Double = 6
    @State private var trimFrom: Double = 0
    @State private var trimTo: Double = 1
    @State private var lineCap: LineCapOption = .round
    @State private var diameter: Double = 160

    var body: some View {
        ShowcaseScreen(
            title: "Circle",
            summary: "A circle inscribed in its frame, used for avatars, badges, dots, and progress rings.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension CircleShowcase {
    var preview: some View {
        circleView(config: currentConfig)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Render style", selection: $renderStyle)
        ShowcaseColorControl("Color", selection: $fillColor)
        ShowcaseSlider("Line width", value: $lineWidth, in: 1...30)
        ShowcaseSlider("Trim from", value: $trimFrom, in: 0...1, step: 0.01)
        ShowcaseSlider("Trim to", value: $trimTo, in: 0...1, step: 0.01)
        ShowcasePicker("Line cap", selection: $lineCap)
        ShowcaseSlider("Diameter", value: $diameter, in: 40...300)
    }

    @ViewBuilder
    func stateView(_ state: CircleGalleryState) -> some View {
        circleView(config: state.config)
    }
}

// MARK: - Circle builder
private extension CircleShowcase {
    fileprivate struct CircleConfig {
        var renderStyle: RenderStyleOption
        var fillColor: Color
        var lineWidth: Double
        var trimFrom: Double
        var trimTo: Double
        var lineCap: LineCapOption
        var diameter: Double
    }

    var currentConfig: CircleConfig {
        CircleConfig(
            renderStyle: renderStyle,
            fillColor: fillColor,
            lineWidth: lineWidth,
            trimFrom: trimFrom,
            trimTo: trimTo,
            lineCap: lineCap,
            diameter: diameter,
        )
    }

    @ViewBuilder
    func circleView(config: CircleConfig) -> some View {
        let size = CGFloat(config.diameter)
        let strokeStyle = StrokeStyle(
            lineWidth: CGFloat(config.lineWidth),
            lineCap: config.lineCap.cgLineCap,
        )
        switch config.renderStyle {
        case .fill:
            Circle()
                .trim(from: CGFloat(config.trimFrom), to: CGFloat(config.trimTo))
                .fill(config.fillColor)
                .frame(width: size, height: size)
        case .stroke:
            Circle()
                .trim(from: CGFloat(config.trimFrom), to: CGFloat(config.trimTo))
                .stroke(config.fillColor, style: strokeStyle)
                .frame(width: size, height: size)
        case .strokeBorder:
            Circle()
                .inset(by: CGFloat(config.lineWidth) / 2)
                .trim(from: CGFloat(config.trimFrom), to: CGFloat(config.trimTo))
                .stroke(config.fillColor, style: strokeStyle)
                .frame(width: size, height: size)
        }
    }
}

// MARK: - Code generation
private extension CircleShowcase {
    var generatedCode: String {
        var lines: [String] = ["Circle()"]
        let hasTrim = trimFrom != 0 || trimTo != 1
        if hasTrim {
            lines.append(
                "    .trim(from: \(formatted(trimFrom)), to: \(formatted(trimTo)))"
            )
        }
        switch renderStyle {
        case .fill:
            lines.append("    .fill(\(colorCode(fillColor)))")
        case .stroke:
            lines.append(
                "    .stroke(\(colorCode(fillColor)), style: StrokeStyle(" +
                "lineWidth: \(Int(lineWidth)), lineCap: .\(lineCap.label)))"
            )
        case .strokeBorder:
            lines.append(
                "    .strokeBorder(\(colorCode(fillColor)), style: StrokeStyle(" +
                "lineWidth: \(Int(lineWidth)), lineCap: .\(lineCap.label)))"
            )
        }
        lines.append("    .frame(width: \(Int(diameter)), height: \(Int(diameter)))")
        return lines.joined(separator: "\n")
    }

    func formatted(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(format: "%.2f", value)
    }

    func colorCode(_ color: Color) -> String {
        color == DesignSystem.Color.accent ? ".accentColor" : "Color(/* configured */)"
    }
}

// MARK: - Nested enums
extension CircleShowcase {
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

    enum LineCapOption: ShowcasePickable {
        case butt, round, square

        var label: String {
            switch self {
            case .butt: "butt"
            case .round: "round"
            case .square: "square"
            }
        }

        var cgLineCap: CGLineCap {
            switch self {
            case .butt: .butt
            case .round: .round
            case .square: .square
            }
        }
    }

    enum CircleGalleryState: ShowcaseState {
        case filled, stroked, strokeBordered, arc, selected

        var caption: String {
            switch self {
            case .filled: "Fill"
            case .stroked: "Stroke"
            case .strokeBordered: "Stroke Border"
            case .arc: "Arc (trim)"
            case .selected: "Selected"
            }
        }

        fileprivate var config: CircleShowcase.CircleConfig {
            switch self {
            case .filled:
                CircleConfig(
                    renderStyle: .fill,
                    fillColor: DesignSystem.Color.accent,
                    lineWidth: 6,
                    trimFrom: 0,
                    trimTo: 1,
                    lineCap: .round,
                    diameter: 80,
                )
            case .stroked:
                CircleConfig(
                    renderStyle: .stroke,
                    fillColor: DesignSystem.Color.accent,
                    lineWidth: 6,
                    trimFrom: 0,
                    trimTo: 1,
                    lineCap: .round,
                    diameter: 80,
                )
            case .strokeBordered:
                CircleConfig(
                    renderStyle: .strokeBorder,
                    fillColor: DesignSystem.Color.accent,
                    lineWidth: 6,
                    trimFrom: 0,
                    trimTo: 1,
                    lineCap: .round,
                    diameter: 80,
                )
            case .arc:
                CircleConfig(
                    renderStyle: .stroke,
                    fillColor: DesignSystem.Color.accent,
                    lineWidth: 8,
                    trimFrom: 0,
                    trimTo: 0.75,
                    lineCap: .round,
                    diameter: 80,
                )
            case .selected:
                CircleConfig(
                    renderStyle: .fill,
                    fillColor: .green,
                    lineWidth: 6,
                    trimFrom: 0,
                    trimTo: 1,
                    lineCap: .round,
                    diameter: 80,
                )
            }
        }
    }
}
