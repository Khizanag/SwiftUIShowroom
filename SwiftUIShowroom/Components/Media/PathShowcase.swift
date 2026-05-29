import SwiftUI

struct PathShowcase: View {
    @State private var preset: PathPreset = .triangle
    @State private var renderStyle: PathRenderStyle = .fill
    @State private var fillColor: Color = .accentColor
    @State private var lineWidth: Double = 4
    @State private var lineJoin: PathLineJoin = .round
    @State private var fillRule: PathFillRule = .nonZero
    @State private var size: Double = 180

    var body: some View {
        ShowcaseScreen(
            title: "Path",
            summary: "A custom 2D outline built from move/line/curve/arc commands, fillable and strokable.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") {
                StateGallery(content: stateView)
            }
            ShowcaseSection("Generated code") {
                CodeBlock(code: generatedCode)
            }
        }
    }
}

// MARK: - Supporting types
extension PathShowcase {
    struct PathRenderConfig {
        var preset: PathPreset
        var renderStyle: PathRenderStyle
        var fillColor: Color
        var lineWidth: CGFloat
        var lineJoin: CGLineJoin
        var fillRule: PathFillRule
        var size: CGFloat
    }
}

// MARK: - Sub-views
private extension PathShowcase {
    var currentConfig: PathRenderConfig {
        PathRenderConfig(
            preset: preset,
            renderStyle: renderStyle,
            fillColor: fillColor,
            lineWidth: CGFloat(lineWidth),
            lineJoin: lineJoin.cgLineJoin,
            fillRule: fillRule,
            size: CGFloat(size)
        )
    }

    var preview: some View {
        renderedPath(config: currentConfig)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Preset", selection: $preset)
        ShowcasePicker("Render style", selection: $renderStyle)
        ShowcaseColorControl("Color", selection: $fillColor)
        ShowcaseSlider("Line width", value: $lineWidth, in: 1...24, step: 1)
        ShowcasePicker("Line join", selection: $lineJoin)
        ShowcasePicker("Fill rule", selection: $fillRule)
        ShowcaseSlider("Canvas size", value: $size, in: 80...300, step: 4)
    }

    @ViewBuilder
    func stateView(_ state: PathPresetState) -> some View {
        renderedPath(
            config: PathRenderConfig(
                preset: state.preset,
                renderStyle: renderStyle,
                fillColor: fillColor,
                lineWidth: CGFloat(lineWidth),
                lineJoin: lineJoin.cgLineJoin,
                fillRule: fillRule,
                size: 120
            )
        )
    }

    @ViewBuilder
    func renderedPath(config: PathRenderConfig) -> some View {
        let path = config.preset.path(in: config.size)
        let strokeStyle = StrokeStyle(lineWidth: config.lineWidth, lineJoin: config.lineJoin)
        switch config.renderStyle {
        case .fill:
            path
                .fill(config.fillColor, style: FillStyle(eoFill: config.fillRule == .evenOdd))
                .frame(width: config.size, height: config.size)
        case .stroke:
            path
                .stroke(config.fillColor, style: strokeStyle)
                .frame(width: config.size, height: config.size)
        }
    }
}

// MARK: - Code generation
private extension PathShowcase {
    var generatedCode: String {
        let sizeInt = Int(size)
        let lineWidthInt = Int(lineWidth)
        let geometryComment = preset.geometryComment(size: sizeInt)
        let styleCode = renderStyleCode(sizeInt: sizeInt, lineWidthInt: lineWidthInt)
        return """
Path { path in
    // \(geometryComment)
\(preset.codeBody(size: sizeInt))
}
\(styleCode)
.frame(width: \(sizeInt), height: \(sizeInt))
"""
    }

    func renderStyleCode(sizeInt: Int, lineWidthInt: Int) -> String {
        switch renderStyle {
        case .fill:
            let eoFill = fillRule == .evenOdd ? "true" : "false"
            return ".fill(\(colorCode), style: FillStyle(eoFill: \(eoFill)))"
        case .stroke:
            return ".stroke(\(colorCode), style: StrokeStyle(lineWidth: \(lineWidthInt), lineJoin: .\(lineJoin.label)))"
        }
    }

    var colorCode: String {
        fillColor == .accentColor ? ".accentColor" : "Color(/* configured */)"
    }
}

// MARK: - Enums
extension PathShowcase {
    enum PathPreset: ShowcasePickable {
        case triangle, star, wave, chevron, heart

        var label: String {
            switch self {
            case .triangle: "triangle"
            case .star: "star"
            case .wave: "wave"
            case .chevron: "chevron"
            case .heart: "heart"
            }
        }

        func path(in size: CGFloat) -> Path {
            switch self {
            case .triangle: trianglePath(size: size)
            case .star: starPath(size: size)
            case .wave: wavePath(size: size)
            case .chevron: chevronPath(size: size)
            case .heart: heartPath(size: size)
            }
        }

        func geometryComment(size: Int) -> String {
            "\(label) geometry inside a \(size)x\(size) box"
        }

        func codeBody(size: Int) -> String {
            let mid = size / 2
            switch self {
            case .triangle:
                return [
                    "path.move(to: CGPoint(x: \(mid), y: 0))",
                    "path.addLine(to: CGPoint(x: \(size), y: \(size)))",
                    "path.addLine(to: CGPoint(x: 0, y: \(size)))",
                    "path.closeSubpath()",
                ].joined(separator: "\n")
            case .star:
                return [
                    "// 5-point star, outer radius \(mid), inner radius \(mid / 2)",
                    "path.move(to: CGPoint(x: \(mid), y: 0))",
                    "// ... addLine calls for each of the 10 vertices",
                    "path.closeSubpath()",
                ].joined(separator: "\n")
            case .wave:
                return [
                    "path.move(to: CGPoint(x: 0, y: \(mid)))",
                    "path.addCurve(",
                    "    to: CGPoint(x: \(size), y: \(mid)),",
                    "    control1: CGPoint(x: \(size / 4), y: 0),",
                    "    control2: CGPoint(x: \(size * 3 / 4), y: \(size))",
                    ")",
                ].joined(separator: "\n")
            case .chevron:
                return [
                    "path.move(to: CGPoint(x: 0, y: 0))",
                    "path.addLine(to: CGPoint(x: \(mid), y: \(mid)))",
                    "path.addLine(to: CGPoint(x: 0, y: \(size)))",
                ].joined(separator: "\n")
            case .heart:
                return [
                    "path.move(to: CGPoint(x: \(mid), y: \(size / 4)))",
                    "// addCurve calls for left and right lobes",
                    "path.closeSubpath()",
                ].joined(separator: "\n")
            }
        }

        private func trianglePath(size: CGFloat) -> Path {
            Path { path in
                path.move(to: CGPoint(x: size / 2, y: 0))
                path.addLine(to: CGPoint(x: size, y: size))
                path.addLine(to: CGPoint(x: 0, y: size))
                path.closeSubpath()
            }
        }

        private func starPath(size: CGFloat) -> Path {
            Path { path in
                let center = CGPoint(x: size / 2, y: size / 2)
                let outerRadius = size / 2
                let innerRadius = size / 4
                let points = 5
                let angleOffset = -Double.pi / 2
                for index in 0..<(points * 2) {
                    let angle = angleOffset + Double(index) * Double.pi / Double(points)
                    let radius = index.isMultiple(of: 2) ? outerRadius : innerRadius
                    let point = CGPoint(
                        x: center.x + CGFloat(cos(angle)) * radius,
                        y: center.y + CGFloat(sin(angle)) * radius
                    )
                    if index == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }
                path.closeSubpath()
            }
        }

        private func wavePath(size: CGFloat) -> Path {
            Path { path in
                let mid = size / 2
                path.move(to: CGPoint(x: 0, y: mid))
                path.addCurve(
                    to: CGPoint(x: size, y: mid),
                    control1: CGPoint(x: size / 4, y: 0),
                    control2: CGPoint(x: size * 3 / 4, y: size)
                )
            }
        }

        private func chevronPath(size: CGFloat) -> Path {
            Path { path in
                let mid = size / 2
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: mid, y: mid))
                path.addLine(to: CGPoint(x: 0, y: size))
            }
        }

        private func heartPath(size: CGFloat) -> Path {
            Path { path in
                let width = size
                let height = size
                let midX = width / 2
                path.move(to: CGPoint(x: midX, y: height * 0.25))
                path.addCurve(
                    to: CGPoint(x: 0, y: height * 0.35),
                    control1: CGPoint(x: midX, y: 0),
                    control2: CGPoint(x: 0, y: height * 0.1)
                )
                path.addCurve(
                    to: CGPoint(x: midX, y: height),
                    control1: CGPoint(x: 0, y: height * 0.65),
                    control2: CGPoint(x: midX * 0.5, y: height * 0.85)
                )
                path.addCurve(
                    to: CGPoint(x: width, y: height * 0.35),
                    control1: CGPoint(x: midX * 1.5, y: height * 0.85),
                    control2: CGPoint(x: width, y: height * 0.65)
                )
                path.addCurve(
                    to: CGPoint(x: midX, y: height * 0.25),
                    control1: CGPoint(x: width, y: height * 0.1),
                    control2: CGPoint(x: midX, y: 0)
                )
                path.closeSubpath()
            }
        }
    }

    enum PathRenderStyle: ShowcasePickable {
        case fill, stroke

        var label: String {
            switch self {
            case .fill: "fill"
            case .stroke: "stroke"
            }
        }
    }

    enum PathLineJoin: ShowcasePickable {
        case miter, round, bevel

        var label: String {
            switch self {
            case .miter: "miter"
            case .round: "round"
            case .bevel: "bevel"
            }
        }

        var cgLineJoin: CGLineJoin {
            switch self {
            case .miter: .miter
            case .round: .round
            case .bevel: .bevel
            }
        }
    }

    enum PathFillRule: ShowcasePickable {
        case nonZero, evenOdd

        var label: String {
            switch self {
            case .nonZero: "nonZero"
            case .evenOdd: "evenOdd"
            }
        }
    }

    enum PathPresetState: ShowcaseState {
        case triangle, star, wave, chevron, heart

        var caption: String {
            switch self {
            case .triangle: "Triangle"
            case .star: "Star"
            case .wave: "Wave"
            case .chevron: "Chevron"
            case .heart: "Heart"
            }
        }

        var preset: PathPreset {
            switch self {
            case .triangle: .triangle
            case .star: .star
            case .wave: .wave
            case .chevron: .chevron
            case .heart: .heart
            }
        }
    }
}
