import SwiftUI

struct LinearGradientShowcase: View {
    @State private var colorStart: Color = .blue
    @State private var colorEnd: Color = .purple
    @State private var useThreeStops: Bool = false
    @State private var colorMid: Color = .pink
    @State private var startPoint: UnitPointOption = .top
    @State private var endPoint: UnitPointOption = .bottom
    @State private var width: Double = 240
    @State private var height: Double = 160

    var body: some View {
        ShowcaseScreen(
            title: "LinearGradient",
            summary: "Interpolates colors along a straight line between two configurable unit points.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension LinearGradientShowcase {
    var preview: some View {
        gradientView(config: currentConfig)
    }

    @ViewBuilder var controls: some View {
        ShowcaseColorControl("Start color", selection: $colorStart)
        ShowcaseColorControl("End color", selection: $colorEnd)
        ShowcaseToggle("Three stops", isOn: $useThreeStops)
        if useThreeStops {
            ShowcaseColorControl("Mid color", selection: $colorMid)
        }
        ShowcasePicker("Start point", selection: $startPoint)
        ShowcasePicker("End point", selection: $endPoint)
        ShowcaseSlider("Width", value: $width, in: 80...320)
        ShowcaseSlider("Height", value: $height, in: 60...320)
    }

    @ViewBuilder
    func stateView(_ state: GradientState) -> some View {
        gradientView(config: state.config)
    }

    var currentConfig: GradientConfig {
        GradientConfig(
            colorStart: colorStart,
            colorEnd: colorEnd,
            colorMid: useThreeStops ? colorMid : nil,
            startPoint: startPoint.value,
            endPoint: endPoint.value,
            size: CGSize(width: width, height: height)
        )
    }

    func gradientView(config: GradientConfig) -> some View {
        LinearGradient(
            colors: config.colors,
            startPoint: config.startPoint,
            endPoint: config.endPoint
        )
        .frame(width: config.size.width, height: config.size.height)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous))
    }
}

// MARK: - Code generation
private extension LinearGradientShowcase {
    var generatedCode: String {
        let colorsLiteral: String
        if useThreeStops {
            colorsLiteral = """
            [\(colorLiteral(colorStart)), \(colorLiteral(colorMid)), \(colorLiteral(colorEnd))]
            """
        } else {
            colorsLiteral = "[\(colorLiteral(colorStart)), \(colorLiteral(colorEnd))]"
        }
        return """
        LinearGradient(
            colors: \(colorsLiteral),
            startPoint: .\(startPoint.label),
            endPoint: .\(endPoint.label)
        )
        .frame(width: \(Int(width)), height: \(Int(height)))
        """
    }

    func colorLiteral(_ color: Color) -> String {
        switch color {
        case .blue: ".blue"
        case .purple: ".purple"
        case .pink: ".pink"
        case .red: ".red"
        case .orange: ".orange"
        case .yellow: ".yellow"
        case .green: ".green"
        case .mint: ".mint"
        case .teal: ".teal"
        case .cyan: ".cyan"
        case .indigo: ".indigo"
        case .accentColor: ".accentColor"
        default: "Color(/* configured */)"
        }
    }
}

// MARK: - Nested types
private extension LinearGradientShowcase {
    struct GradientConfig {
        var colorStart: Color
        var colorEnd: Color
        var colorMid: Color?
        var startPoint: UnitPoint
        var endPoint: UnitPoint
        var size: CGSize

        var colors: [Color] {
            if let mid = colorMid {
                return [colorStart, mid, colorEnd]
            }
            return [colorStart, colorEnd]
        }
    }

    enum UnitPointOption: ShowcasePickable {
        case top, bottom, leading, trailing
        case topLeading, topTrailing, bottomLeading, bottomTrailing, center

        var label: String {
            switch self {
            case .top: "top"
            case .bottom: "bottom"
            case .leading: "leading"
            case .trailing: "trailing"
            case .topLeading: "topLeading"
            case .topTrailing: "topTrailing"
            case .bottomLeading: "bottomLeading"
            case .bottomTrailing: "bottomTrailing"
            case .center: "center"
            }
        }

        var value: UnitPoint {
            switch self {
            case .top: .top
            case .bottom: .bottom
            case .leading: .leading
            case .trailing: .trailing
            case .topLeading: .topLeading
            case .topTrailing: .topTrailing
            case .bottomLeading: .bottomLeading
            case .bottomTrailing: .bottomTrailing
            case .center: .center
            }
        }
    }

    enum GradientState: ShowcaseState {
        case topToBottom
        case leadingToTrailing
        case diagonalThreeStops
        case warmSunset
        case coolOcean

        var caption: String {
            switch self {
            case .topToBottom: "Top to bottom"
            case .leadingToTrailing: "Leading to trailing"
            case .diagonalThreeStops: "Diagonal / 3 stops"
            case .warmSunset: "Warm sunset"
            case .coolOcean: "Cool ocean"
            }
        }

        var config: GradientConfig {
            GradientConfig(
                colorStart: colorStart,
                colorEnd: colorEnd,
                colorMid: midColor,
                startPoint: startPoint,
                endPoint: endPoint,
                size: CGSize(width: 200, height: 100)
            )
        }

        private var colorStart: Color {
            switch self {
            case .topToBottom: .blue
            case .leadingToTrailing: .purple
            case .diagonalThreeStops: .red
            case .warmSunset: .orange
            case .coolOcean: .cyan
            }
        }

        private var colorEnd: Color {
            switch self {
            case .topToBottom: .purple
            case .leadingToTrailing: .pink
            case .diagonalThreeStops: .blue
            case .warmSunset: .pink
            case .coolOcean: .indigo
            }
        }

        private var midColor: Color? {
            self == .diagonalThreeStops ? .purple : nil
        }

        private var startPoint: UnitPoint {
            switch self {
            case .topToBottom: .top
            case .leadingToTrailing: .leading
            case .diagonalThreeStops: .topLeading
            case .warmSunset: .top
            case .coolOcean: .topLeading
            }
        }

        private var endPoint: UnitPoint {
            switch self {
            case .topToBottom: .bottom
            case .leadingToTrailing: .trailing
            case .diagonalThreeStops: .bottomTrailing
            case .warmSunset: .bottom
            case .coolOcean: .bottomTrailing
            }
        }
    }
}
