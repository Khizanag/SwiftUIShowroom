import SwiftUI

struct ContainerRelativeShapeShowcase: View {
    enum RenderStyleOption: ShowcasePickable {
        case fill, strokeBorder

        var label: String {
            switch self {
            case .fill: "fill"
            case .strokeBorder: "strokeBorder"
            }
        }
    }

    enum ContainerRelativeShapeState: ShowcaseState {
        case concentric, tightInset, wideInset, stroked

        var caption: String {
            switch self {
            case .concentric: "Default (12pt inset)"
            case .tightInset: "Tight inset (4pt)"
            case .wideInset: "Wide inset (28pt)"
            case .stroked: "Stroke border"
            }
        }
    }

    @State private var fillColor: Color = .accentColor
    @State private var renderStyle: RenderStyleOption = .fill
    @State private var inset: Double = 12
    @State private var containerCornerRadius: Double = 32

    var body: some View {
        ShowcaseScreen(
            title: "ContainerRelativeShape",
            summary: "An adaptive shape that inherits its container's corner shape.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ContainerRelativeShapeShowcase {
    var preview: some View {
        containerWidget(
            cornerRadius: containerCornerRadius,
            inset: inset,
            fillColor: fillColor,
            renderStyle: renderStyle
        )
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseColorControl("Fill color", selection: $fillColor)
        ShowcasePicker("Render style", selection: $renderStyle)
        ShowcaseSlider("Inset", value: $inset, in: 0...40)
        ShowcaseSlider("Container corner radius", value: $containerCornerRadius, in: 0...60)
    }

    @ViewBuilder
    func stateView(_ state: ContainerRelativeShapeState) -> some View {
        switch state {
        case .concentric:
            containerWidget(
                cornerRadius: 32,
                inset: 12,
                fillColor: .accentColor,
                renderStyle: .fill
            )
        case .tightInset:
            containerWidget(
                cornerRadius: 32,
                inset: 4,
                fillColor: .accentColor,
                renderStyle: .fill
            )
        case .wideInset:
            containerWidget(
                cornerRadius: 32,
                inset: 28,
                fillColor: .accentColor,
                renderStyle: .fill
            )
        case .stroked:
            containerWidget(
                cornerRadius: 32,
                inset: 12,
                fillColor: .accentColor,
                renderStyle: .strokeBorder
            )
        }
    }

    @ViewBuilder
    func containerWidget(
        cornerRadius: Double,
        inset: Double,
        fillColor: Color,
        renderStyle: RenderStyleOption
    ) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(DesignSystem.Color.cardBackground)
            .containerShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                innerShape(fillColor: fillColor, renderStyle: renderStyle)
                    .padding(inset)
            }
            .frame(width: 180, height: 180)
    }

    @ViewBuilder
    func innerShape(fillColor: Color, renderStyle: RenderStyleOption) -> some View {
        switch renderStyle {
        case .fill:
            ContainerRelativeShape()
                .fill(fillColor)
        case .strokeBorder:
            ContainerRelativeShape()
                .strokeBorder(fillColor, lineWidth: 3)
        }
    }
}

// MARK: - Code generation
private extension ContainerRelativeShapeShowcase {
    var generatedCode: String {
        let radiusStr = formatDouble(containerCornerRadius)
        let insetStr = formatDouble(inset)
        let colorStr = colorCode(fillColor)
        let styleStr: String
        switch renderStyle {
        case .fill:
            styleStr = "fill(\(colorStr))"
        case .strokeBorder:
            styleStr = "strokeBorder(\(colorStr), lineWidth: 3)"
        }
        return [
            "RoundedRectangle(cornerRadius: \(radiusStr), style: .continuous)",
            "    .fill(.gray.opacity(0.2))",
            "    .containerShape(RoundedRectangle(cornerRadius: \(radiusStr), style: .continuous))",
            "    .overlay {",
            "        ContainerRelativeShape()",
            "            .\(styleStr)",
            "            .padding(\(insetStr))",
            "    }",
        ].joined(separator: "\n")
    }

    func colorCode(_ color: Color) -> String {
        let components = colorComponents(color)
        return "Color(red: \(formatDouble(components.red)), " +
            "green: \(formatDouble(components.green)), " +
            "blue: \(formatDouble(components.blue)))"
    }

    func colorComponents(_ color: Color) -> (red: Double, green: Double, blue: Double) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        #if os(macOS)
        let nsColor = NSColor(color).usingColorSpace(.sRGB) ?? NSColor(color)
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        #else
        UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: nil)
        #endif
        return (Double(red), Double(green), Double(blue))
    }

    func formatDouble(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(format: "%.2f", value)
    }
}
