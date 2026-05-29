import SwiftUI

struct CanvasShowcase: View {
    @State private var opaque = false
    @State private var colorMode: ColorModeOption = .nonLinear
    @State private var rendersAsynchronously = false
    @State private var drawingPrimitive: DrawingPrimitive = .strokedPath
    @State private var strokeColor: Color = .accentColor
    @State private var lineWidth: Double = 4
    @State private var blendMode: BlendModeOption = .normal
    @State private var canvasHeight: Double = 240

    var body: some View {
        ShowcaseScreen(
            title: "Canvas",
            summary: "Immediate-mode 2D drawing surface using GraphicsContext for high-performance custom graphics.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension CanvasShowcase {
    enum ColorModeOption: ShowcasePickable {
        case nonLinear, linear, extendedLinear

        var label: String {
            switch self {
            case .nonLinear: "nonLinear"
            case .linear: "linear"
            case .extendedLinear: "extendedLinear"
            }
        }

        var renderingMode: ColorRenderingMode {
            switch self {
            case .nonLinear: .nonLinear
            case .linear: .linear
            case .extendedLinear: .extendedLinear
            }
        }
    }

    enum DrawingPrimitive: ShowcasePickable {
        case strokedPath, filledPath, text, image, gradientFill

        var label: String {
            switch self {
            case .strokedPath: "strokedPath"
            case .filledPath: "filledPath"
            case .text: "text"
            case .image: "image"
            case .gradientFill: "gradientFill"
            }
        }
    }

    enum BlendModeOption: ShowcasePickable {
        case normal, multiply, screen, overlay, plusLighter

        var label: String {
            switch self {
            case .normal: "normal"
            case .multiply: "multiply"
            case .screen: "screen"
            case .overlay: "overlay"
            case .plusLighter: "plusLighter"
            }
        }

        var blendMode: GraphicsContext.BlendMode {
            switch self {
            case .normal: .normal
            case .multiply: .multiply
            case .screen: .screen
            case .overlay: .overlay
            case .plusLighter: .plusLighter
            }
        }
    }

    enum CanvasDrawingState: ShowcaseState {
        case ellipse, grid, radial

        var caption: String {
            switch self {
            case .ellipse: "Ellipse stroke"
            case .grid: "Grid lines"
            case .radial: "Radial gradient fill"
            }
        }
    }
}

// MARK: - Sub-views
private extension CanvasShowcase {
    var preview: some View {
        Canvas(
            opaque: opaque,
            colorMode: colorMode.renderingMode,
            rendersAsynchronously: rendersAsynchronously,
        ) { ctx, size in
            ctx.blendMode = blendMode.blendMode
            draw(primitive: drawingPrimitive, in: &ctx, size: size)
        }
        .frame(maxWidth: .infinity)
        .frame(height: canvasHeight)
        .accessibilityLabel("Canvas drawing preview")
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("Opaque", isOn: $opaque)
        ShowcasePicker("Color Mode", selection: $colorMode)
        ShowcaseToggle("Renders Asynchronously", isOn: $rendersAsynchronously)
        ShowcasePicker("Drawing Primitive", selection: $drawingPrimitive)
        ShowcaseColorControl("Stroke / Fill Color", selection: $strokeColor)
        ShowcaseSlider("Line Width", value: $lineWidth, in: 1...24, step: 1)
        ShowcasePicker("Blend Mode", selection: $blendMode)
        ShowcaseSlider("Canvas Height", value: $canvasHeight, in: 120...400, step: 4)
    }

    @ViewBuilder func stateView(_ state: CanvasDrawingState) -> some View {
        Canvas { ctx, size in
            switch state {
            case .ellipse:
                let path = Path(ellipseIn: CGRect(origin: .zero, size: size).insetBy(dx: 12, dy: 12))
                ctx.stroke(path, with: .color(.accentColor), lineWidth: 3)
            case .grid:
                let cols = 5
                let rows = 4
                for col in 0...cols {
                    let xPos = size.width * CGFloat(col) / CGFloat(cols)
                    var line = Path()
                    line.move(to: CGPoint(x: xPos, y: 0))
                    line.addLine(to: CGPoint(x: xPos, y: size.height))
                    ctx.stroke(line, with: .color(.secondary), lineWidth: 1)
                }
                for row in 0...rows {
                    let yPos = size.height * CGFloat(row) / CGFloat(rows)
                    var line = Path()
                    line.move(to: CGPoint(x: 0, y: yPos))
                    line.addLine(to: CGPoint(x: size.width, y: yPos))
                    ctx.stroke(line, with: .color(.secondary), lineWidth: 1)
                }
            case .radial:
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let radius = min(size.width, size.height) / 2
                let path = Path(ellipseIn: CGRect(
                    x: center.x - radius,
                    y: center.y - radius,
                    width: radius * 2,
                    height: radius * 2,
                ))
                ctx.fill(path, with: .color(.purple.opacity(0.7)))
            }
        }
        .frame(height: 100)
        .accessibilityLabel(state.caption)
    }
}

// MARK: - Drawing helpers
private extension CanvasShowcase {
    func draw(
        primitive: DrawingPrimitive,
        in ctx: inout GraphicsContext,
        size: CGSize,
    ) {
        let rect = CGRect(origin: .zero, size: size)
        switch primitive {
        case .strokedPath:
            let path = Path(ellipseIn: rect.insetBy(dx: 16, dy: 16))
            ctx.stroke(path, with: .color(strokeColor), lineWidth: lineWidth)
        case .filledPath:
            let path = Path(ellipseIn: rect.insetBy(dx: 16, dy: 16))
            ctx.fill(path, with: .color(strokeColor))
        case .text:
            let resolved = ctx.resolve(Text("Canvas")
                .font(DesignSystem.Font.title)
                .foregroundStyle(strokeColor))
            ctx.draw(resolved, at: CGPoint(x: size.width / 2, y: size.height / 2), anchor: .center)
        case .image:
            let symbolPath = Path(ellipseIn: rect.insetBy(dx: size.width * 0.2, dy: size.height * 0.2))
            ctx.fill(symbolPath, with: .color(strokeColor.opacity(0.25)))
            ctx.stroke(symbolPath, with: .color(strokeColor), lineWidth: lineWidth)
        case .gradientFill:
            let gradient = Gradient(colors: [strokeColor, strokeColor.opacity(0)])
            ctx.fill(
                Path(rect),
                with: .linearGradient(
                    gradient,
                    startPoint: CGPoint(x: size.width / 2, y: 0),
                    endPoint: CGPoint(x: size.width / 2, y: size.height),
                ),
            )
        }
    }
}

// MARK: - Code generation
private extension CanvasShowcase {
    var generatedCode: String {
        let heightLine = ".frame(height: \(Int(canvasHeight)))"
        let blendLine = "    context.blendMode = .\(blendMode.label)"
        let bodyLine: String
        let colorStr = colorLiteral(strokeColor)
        switch drawingPrimitive {
        case .strokedPath:
            let pathLine = "    let path = Path(ellipseIn: CGRect(origin: .zero, size: size))"
            let strokeLine = "    context.stroke(path, with: .color(\(colorStr)), lineWidth: \(Int(lineWidth)))"
            bodyLine = pathLine + "\n" + strokeLine
        case .filledPath:
            let pathLine = "    let path = Path(ellipseIn: CGRect(origin: .zero, size: size))"
            let fillLine = "    context.fill(path, with: .color(\(colorStr)))"
            bodyLine = pathLine + "\n" + fillLine
        case .text:
            let textLine = "    let txt = context.resolve(Text(\"Hello\").foregroundStyle(\(colorStr)))"
            let drawLine = "    context.draw(txt, at: CGPoint(x: size.width / 2, y: size.height / 2), anchor: .center)"
            bodyLine = textLine + "\n" + drawLine
        case .image:
            bodyLine = "    // draw image via context.draw(_:in:)"
        case .gradientFill:
            let gradLine = "    let gradient = Gradient(colors: [\(colorStr), \(colorStr).opacity(0)])"
            let fillLine = "    context.fill(Path(CGRect(origin: .zero, size: size)),"
            let withLine = "        with: .linearGradient(gradient, startPoint: .zero,"
            let endLine = "        endPoint: CGPoint(x: 0, y: size.height)))"
            bodyLine = gradLine + "\n" + fillLine + "\n" + withLine + "\n" + endLine
        }
        return """
        Canvas(
            opaque: \(opaque),
            colorMode: .\(colorMode.label),
            rendersAsynchronously: \(rendersAsynchronously),
        ) { context, size in
        \(blendLine)
        \(bodyLine)
        }
        \(heightLine)
        """
    }

    func colorLiteral(_ color: Color) -> String {
        if color == .red { return ".red" }
        if color == .green { return ".green" }
        if color == .blue { return ".blue" }
        if color == .orange { return ".orange" }
        if color == .purple { return ".purple" }
        if color == .yellow { return ".yellow" }
        if color == .pink { return ".pink" }
        return ".accentColor"
    }
}
