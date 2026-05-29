import SwiftUI

struct EllipseShowcase: View {
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

    enum EllipseStyleState: ShowcaseState {
        case fill, stroke, strokeBorder

        var caption: String {
            switch self {
            case .fill: "Fill"
            case .stroke: "Stroke"
            case .strokeBorder: "Stroke Border"
            }
        }

        var renderStyle: RenderStyleOption {
            switch self {
            case .fill: .fill
            case .stroke: .stroke
            case .strokeBorder: .strokeBorder
            }
        }
    }

    @State private var renderStyle: RenderStyleOption = .fill
    @State private var fillColor: Color = .accentColor
    @State private var lineWidth: Double = 2
    @State private var frameWidth: Double = 220
    @State private var frameHeight: Double = 120

    var body: some View {
        ShowcaseScreen(
            title: "Ellipse",
            summary: "An ellipse inscribed in its frame, stretching with non-square dimensions.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension EllipseShowcase {
    var preview: some View {
        ellipseView(
            style: renderStyle,
            color: fillColor,
            strokeWidth: lineWidth,
            size: CGSize(width: frameWidth, height: frameHeight)
        )
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Render style", selection: $renderStyle)
        ShowcaseColorControl("Color", selection: $fillColor)
        ShowcaseSlider("Line width", value: $lineWidth, in: 0.5 ... 20, step: 0.5)
        ShowcaseSlider("Width", value: $frameWidth, in: 40 ... 320)
        ShowcaseSlider("Height", value: $frameHeight, in: 40 ... 320)
    }

    @ViewBuilder
    func stateView(_ state: EllipseStyleState) -> some View {
        ellipseView(
            style: state.renderStyle,
            color: fillColor,
            strokeWidth: lineWidth,
            size: CGSize(width: 120, height: 72)
        )
    }

    @ViewBuilder
    func ellipseView(
        style: RenderStyleOption,
        color: Color,
        strokeWidth: Double,
        size: CGSize
    ) -> some View {
        switch style {
        case .fill:
            Ellipse()
                .fill(color)
                .frame(width: size.width, height: size.height)
        case .stroke:
            Ellipse()
                .stroke(color, lineWidth: strokeWidth)
                .frame(width: size.width, height: size.height)
        case .strokeBorder:
            Ellipse()
                .strokeBorder(color, lineWidth: strokeWidth)
                .frame(width: size.width, height: size.height)
        }
    }
}

// MARK: - Code generation
private extension EllipseShowcase {
    var generatedCode: String {
        let colorToken = "/* color */"
        let widthInt = Int(frameWidth)
        let heightInt = Int(frameHeight)
        let widthStr = lineWidth.formatted(.number.precision(.fractionLength(0...2)))
        let frameStr = ".frame(width: \(widthInt), height: \(heightInt))"
        let lines: [String]
        switch renderStyle {
        case .fill:
            lines = [
                "Ellipse()",
                "    .fill(\(colorToken))",
                "    \(frameStr)",
            ]
        case .stroke:
            lines = [
                "Ellipse()",
                "    .stroke(\(colorToken), lineWidth: \(widthStr))",
                "    \(frameStr)",
            ]
        case .strokeBorder:
            lines = [
                "Ellipse()",
                "    .strokeBorder(\(colorToken), lineWidth: \(widthStr))",
                "    \(frameStr)",
            ]
        }
        return lines.joined(separator: "\n")
    }
}
