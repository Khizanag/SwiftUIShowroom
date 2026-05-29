import SwiftUI

struct RadialGradientShowcase: View {
    @State private var colorCenter: Color = .yellow
    @State private var colorEdge: Color = .orange
    @State private var centerOption: CenterOption = .center
    @State private var startRadius: Double = 0
    @State private var endRadius: Double = 140
    @State private var frameSize: Double = 220

    var body: some View {
        ShowcaseScreen(
            title: "RadialGradient",
            summary: "Interpolates colors outward from a center point between a start and end radius.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
private extension RadialGradientShowcase {
    enum CenterOption: ShowcasePickable {
        case center, top, bottom, leading, trailing
        case topLeading, topTrailing, bottomLeading, bottomTrailing

        var label: String {
            switch self {
            case .center: "center"
            case .top: "top"
            case .bottom: "bottom"
            case .leading: "leading"
            case .trailing: "trailing"
            case .topLeading: "topLeading"
            case .topTrailing: "topTrailing"
            case .bottomLeading: "bottomLeading"
            case .bottomTrailing: "bottomTrailing"
            }
        }

        var unitPoint: UnitPoint {
            switch self {
            case .center: .center
            case .top: .top
            case .bottom: .bottom
            case .leading: .leading
            case .trailing: .trailing
            case .topLeading: .topLeading
            case .topTrailing: .topTrailing
            case .bottomLeading: .bottomLeading
            case .bottomTrailing: .bottomTrailing
            }
        }
    }

    enum GradientState: ShowcaseState {
        case centeredSpot, offsetTop, wideGlow, tightCore

        var caption: String {
            switch self {
            case .centeredSpot: "Centered Spot"
            case .offsetTop: "Offset Top"
            case .wideGlow: "Wide Glow"
            case .tightCore: "Tight Core"
            }
        }
    }

    struct GradientConfig {
        var colorCenter: Color
        var colorEdge: Color
        var centerPoint: UnitPoint
        var startRadius: Double
        var endRadius: Double
        var size: Double
    }
}

// MARK: - Sub-views
private extension RadialGradientShowcase {
    var preview: some View {
        gradientView(
            GradientConfig(
                colorCenter: colorCenter,
                colorEdge: colorEdge,
                centerPoint: centerOption.unitPoint,
                startRadius: startRadius,
                endRadius: endRadius,
                size: frameSize
            )
        )
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseColorControl("Center color", selection: $colorCenter)
        ShowcaseColorControl("Edge color", selection: $colorEdge)
        ShowcasePicker("Center", selection: $centerOption)
        ShowcaseSlider("Start radius", value: $startRadius, in: 0...150)
        ShowcaseSlider("End radius", value: $endRadius, in: 20...300)
        ShowcaseSlider("Size", value: $frameSize, in: 80...320)
    }

    @ViewBuilder
    func stateView(_ state: GradientState) -> some View {
        switch state {
        case .centeredSpot:
            gradientView(GradientConfig(
                colorCenter: .yellow,
                colorEdge: .orange,
                centerPoint: .center,
                startRadius: 0,
                endRadius: 80,
                size: 160
            ))
        case .offsetTop:
            gradientView(GradientConfig(
                colorCenter: .white,
                colorEdge: .blue,
                centerPoint: .top,
                startRadius: 0,
                endRadius: 120,
                size: 160
            ))
        case .wideGlow:
            gradientView(GradientConfig(
                colorCenter: .purple,
                colorEdge: .black,
                centerPoint: .center,
                startRadius: 0,
                endRadius: 140,
                size: 160
            ))
        case .tightCore:
            gradientView(GradientConfig(
                colorCenter: .cyan,
                colorEdge: .indigo,
                centerPoint: .center,
                startRadius: 20,
                endRadius: 80,
                size: 160
            ))
        }
    }

    func gradientView(_ config: GradientConfig) -> some View {
        RadialGradient(
            colors: [config.colorCenter, config.colorEdge],
            center: config.centerPoint,
            startRadius: config.startRadius,
            endRadius: config.endRadius
        )
        .frame(width: config.size, height: config.size)
    }
}

// MARK: - Code generation
private extension RadialGradientShowcase {
    var generatedCode: String {
        let centerArg = centerOption.label
        let start = formatDouble(startRadius)
        let end = formatDouble(endRadius)
        let dim = formatDouble(frameSize)
        let cCode = colorCode(colorCenter)
        let eCode = colorCode(colorEdge)
        return """
        RadialGradient(
            colors: [\(cCode), \(eCode)],
            center: .\(centerArg),
            startRadius: \(start),
            endRadius: \(end)
        )
        .frame(width: \(dim), height: \(dim))
        """
    }

    func colorCode(_ color: Color) -> String {
        switch color {
        case .accentColor: return ".accentColor"
        case .red: return ".red"
        case .orange: return ".orange"
        case .yellow: return ".yellow"
        case .green: return ".green"
        case .blue: return ".blue"
        case .purple: return ".purple"
        case .pink: return ".pink"
        case .cyan: return ".cyan"
        case .indigo: return ".indigo"
        case .mint: return ".mint"
        case .teal: return ".teal"
        case .primary: return ".primary"
        case .secondary: return ".secondary"
        default:
            let (red, green, blue) = colorComponents(color)
            return String(format: "Color(red: %.2f, green: %.2f, blue: %.2f)", red, green, blue)
        }
    }

    func colorComponents(_ color: Color) -> (Double, Double, Double) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        #if os(macOS)
        let resolved = NSColor(color).usingColorSpace(.sRGB) ?? NSColor(color)
        resolved.getRed(&red, green: &green, blue: &blue, alpha: nil)
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
