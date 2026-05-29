import SwiftUI

struct UnevenroundedRectangleShowcase: View {
    @State private var topLeadingRadius: Double = 20
    @State private var topTrailingRadius: Double = 20
    @State private var bottomLeadingRadius: Double = 0
    @State private var bottomTrailingRadius: Double = 0
    @State private var cornerStyle: CornerStyleOption = .continuous
    @State private var renderStyle: RenderStyleOption = .fill
    @State private var fillColor: Color = .accentColor
    @State private var lineWidth: Double = 2
    @State private var frameWidth: Double = 220
    @State private var frameHeight: Double = 140

    var body: some View {
        ShowcaseScreen(
            title: "UnevenRoundedRectangle",
            summary: "A rectangle with independently configurable corner radii per corner.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
private extension UnevenroundedRectangleShowcase {
    enum CornerStyleOption: ShowcasePickable {
        case circular, continuous

        var label: String {
            switch self {
            case .circular: "circular"
            case .continuous: "continuous"
            }
        }

        var cornerStyle: RoundedCornerStyle {
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

    enum CornerPresetState: ShowcaseState {
        case allRounded
        case topRounded
        case bottomRounded
        case dialogSheet
        case asymmetric

        var caption: String {
            switch self {
            case .allRounded: "All corners"
            case .topRounded: "Top only"
            case .bottomRounded: "Bottom only"
            case .dialogSheet: "Dialog sheet"
            case .asymmetric: "Asymmetric"
            }
        }

        var topLeading: Double {
            switch self {
            case .allRounded: 24
            case .topRounded: 24
            case .bottomRounded: 0
            case .dialogSheet: 20
            case .asymmetric: 40
            }
        }

        var topTrailing: Double {
            switch self {
            case .allRounded: 24
            case .topRounded: 24
            case .bottomRounded: 0
            case .dialogSheet: 20
            case .asymmetric: 8
            }
        }

        var bottomLeading: Double {
            switch self {
            case .allRounded: 24
            case .topRounded: 0
            case .bottomRounded: 24
            case .dialogSheet: 0
            case .asymmetric: 8
            }
        }

        var bottomTrailing: Double {
            switch self {
            case .allRounded: 24
            case .topRounded: 0
            case .bottomRounded: 24
            case .dialogSheet: 0
            case .asymmetric: 32
            }
        }
    }

    struct ShapeConfig {
        var topLeading: Double
        var topTrailing: Double
        var bottomLeading: Double
        var bottomTrailing: Double
        var cornerStyle: CornerStyleOption
        var renderStyle: RenderStyleOption
        var color: Color
        var strokeWidth: Double
        var width: Double
        var height: Double
    }
}

// MARK: - Sub-views
private extension UnevenroundedRectangleShowcase {
    var preview: some View {
        renderedShape(ShapeConfig(
            topLeading: topLeadingRadius,
            topTrailing: topTrailingRadius,
            bottomLeading: bottomLeadingRadius,
            bottomTrailing: bottomTrailingRadius,
            cornerStyle: cornerStyle,
            renderStyle: renderStyle,
            color: fillColor,
            strokeWidth: lineWidth,
            width: frameWidth,
            height: frameHeight,
        ))
    }

    @ViewBuilder var controls: some View {
        ShowcaseSlider("Top Leading", value: $topLeadingRadius, in: 0...60)
        ShowcaseSlider("Top Trailing", value: $topTrailingRadius, in: 0...60)
        ShowcaseSlider("Bottom Leading", value: $bottomLeadingRadius, in: 0...60)
        ShowcaseSlider("Bottom Trailing", value: $bottomTrailingRadius, in: 0...60)
        ShowcasePicker("Corner Style", selection: $cornerStyle)
        ShowcasePicker("Render Style", selection: $renderStyle)
        ShowcaseColorControl("Color", selection: $fillColor, supportsOpacity: false)
        ShowcaseSlider("Line Width", value: $lineWidth, in: 0.5...20, step: 0.5)
        ShowcaseSlider("Width", value: $frameWidth, in: 40...320)
        ShowcaseSlider("Height", value: $frameHeight, in: 40...320)
    }

    @ViewBuilder
    func stateView(_ state: CornerPresetState) -> some View {
        renderedShape(ShapeConfig(
            topLeading: state.topLeading,
            topTrailing: state.topTrailing,
            bottomLeading: state.bottomLeading,
            bottomTrailing: state.bottomTrailing,
            cornerStyle: .continuous,
            renderStyle: .fill,
            color: fillColor,
            strokeWidth: 2,
            width: 160,
            height: 100,
        ))
    }

    @ViewBuilder
    func renderedShape(_ config: ShapeConfig) -> some View {
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: config.topLeading,
            bottomLeadingRadius: config.bottomLeading,
            bottomTrailingRadius: config.bottomTrailing,
            topTrailingRadius: config.topTrailing,
            style: config.cornerStyle.cornerStyle,
        )
        switch config.renderStyle {
        case .fill:
            shape
                .fill(config.color)
                .frame(width: config.width, height: config.height)
        case .stroke:
            shape
                .stroke(config.color, lineWidth: config.strokeWidth)
                .frame(width: config.width, height: config.height)
        case .strokeBorder:
            shape
                .strokeBorder(config.color, lineWidth: config.strokeWidth)
                .frame(width: config.width, height: config.height)
        }
    }
}

// MARK: - Code generation
private extension UnevenroundedRectangleShowcase {
    var generatedCode: String {
        let topLeading = formatRadius(topLeadingRadius)
        let bottomLeading = formatRadius(bottomLeadingRadius)
        let bottomTrailing = formatRadius(bottomTrailingRadius)
        let topTrailing = formatRadius(topTrailingRadius)
        let styleName = cornerStyle.label
        let renderLine = renderStyleLine
        let widthStr = formatDimension(frameWidth)
        let heightStr = formatDimension(frameHeight)
        return """
        UnevenRoundedRectangle(
            topLeadingRadius: \(topLeading),
            bottomLeadingRadius: \(bottomLeading),
            bottomTrailingRadius: \(bottomTrailing),
            topTrailingRadius: \(topTrailing),
            style: .\(styleName)
        )
        \(renderLine)
        .frame(width: \(widthStr), height: \(heightStr))
        """
    }

    var renderStyleLine: String {
        switch renderStyle {
        case .fill:
            return ".fill(\(colorCode))"
        case .stroke:
            return ".stroke(\(colorCode), lineWidth: \(formatDimension(lineWidth)))"
        case .strokeBorder:
            return ".strokeBorder(\(colorCode), lineWidth: \(formatDimension(lineWidth)))"
        }
    }

    var colorCode: String {
        fillColor == .accentColor ? ".accentColor" : "Color(/* configured */)"
    }

    func formatRadius(_ value: Double) -> String {
        value == value.rounded() ? "\(Int(value))" : String(format: "%.1f", value)
    }

    func formatDimension(_ value: Double) -> String {
        value == value.rounded() ? "\(Int(value))" : String(format: "%.1f", value)
    }
}
