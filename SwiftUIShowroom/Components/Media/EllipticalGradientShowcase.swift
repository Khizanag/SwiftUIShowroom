import SwiftUI

struct EllipticalGradientShowcase: View {
    enum CenterOption: ShowcasePickable {
        case center, top, bottom, leading, trailing

        var label: String {
            switch self {
            case .center: "center"
            case .top: "top"
            case .bottom: "bottom"
            case .leading: "leading"
            case .trailing: "trailing"
            }
        }

        var unitPoint: UnitPoint {
            switch self {
            case .center: .center
            case .top: .top
            case .bottom: .bottom
            case .leading: .leading
            case .trailing: .trailing
            }
        }
    }

    enum GradientState: ShowcaseState {
        case centeredGlow, wideSpread, offCenter, narrowCore

        var caption: String {
            switch self {
            case .centeredGlow: "Centered glow"
            case .wideSpread: "Wide spread"
            case .offCenter: "Off-center"
            case .narrowCore: "Narrow core"
            }
        }
    }

    @State private var colorCenter: Color = .teal
    @State private var colorEdge: Color = .indigo
    @State private var centerOption: CenterOption = .center
    @State private var startRadiusFraction: Double = 0
    @State private var endRadiusFraction: Double = 0.5
    @State private var frameWidth: Double = 260
    @State private var frameHeight: Double = 160

    var body: some View {
        ShowcaseScreen(
            title: "EllipticalGradient",
            summary: "A radial-style gradient whose rings are elliptical, matching a non-square frame.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension EllipticalGradientShowcase {
    var preview: some View {
        gradientView(
            config: GradientConfig(
                centerColor: colorCenter,
                edgeColor: colorEdge,
                centerPoint: centerOption.unitPoint,
                startFraction: startRadiusFraction,
                endFraction: endRadiusFraction
            ),
            width: frameWidth,
            height: frameHeight
        )
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseColorControl("Center color", selection: $colorCenter)
        ShowcaseColorControl("Edge color", selection: $colorEdge)
        ShowcasePicker("Center", selection: $centerOption)
        ShowcaseSlider("Start radius fraction", value: $startRadiusFraction, in: 0...1, step: 0.05)
        ShowcaseSlider("End radius fraction", value: $endRadiusFraction, in: 0.1...1, step: 0.05)
        ShowcaseSlider("Width", value: $frameWidth, in: 80...320)
        ShowcaseSlider("Height", value: $frameHeight, in: 60...320)
    }

    @ViewBuilder
    func stateView(_ state: GradientState) -> some View {
        switch state {
        case .centeredGlow:
            gradientView(
                config: GradientConfig(
                    centerColor: .teal,
                    edgeColor: .indigo,
                    centerPoint: .center,
                    startFraction: 0,
                    endFraction: 0.5
                ),
                width: 200,
                height: 120
            )
        case .wideSpread:
            gradientView(
                config: GradientConfig(
                    centerColor: .orange,
                    edgeColor: .purple,
                    centerPoint: .center,
                    startFraction: 0,
                    endFraction: 1
                ),
                width: 200,
                height: 120
            )
        case .offCenter:
            gradientView(
                config: GradientConfig(
                    centerColor: .pink,
                    edgeColor: .blue,
                    centerPoint: .topLeading,
                    startFraction: 0,
                    endFraction: 0.6
                ),
                width: 200,
                height: 120
            )
        case .narrowCore:
            gradientView(
                config: GradientConfig(
                    centerColor: .yellow,
                    edgeColor: .red,
                    centerPoint: .center,
                    startFraction: 0.2,
                    endFraction: 0.5
                ),
                width: 200,
                height: 120
            )
        }
    }

    struct GradientConfig {
        var centerColor: Color
        var edgeColor: Color
        var centerPoint: UnitPoint
        var startFraction: Double
        var endFraction: Double
    }

    func gradientView(config: GradientConfig, width: Double, height: Double) -> some View {
        EllipticalGradient(
            colors: [config.centerColor, config.edgeColor],
            center: config.centerPoint,
            startRadiusFraction: config.startFraction,
            endRadiusFraction: config.endFraction
        )
        .frame(width: width, height: height)
    }
}

// MARK: - Code generation
private extension EllipticalGradientShowcase {
    var generatedCode: String {
        [
            "EllipticalGradient(",
            "    colors: [\(colorCode(colorCenter)), \(colorCode(colorEdge))],",
            "    center: .\(centerOption.label),",
            "    startRadiusFraction: \(formatDouble(startRadiusFraction)),",
            "    endRadiusFraction: \(formatDouble(endRadiusFraction))",
            ")",
            ".frame(width: \(formatDouble(frameWidth)), height: \(formatDouble(frameHeight)))",
        ]
        .joined(separator: "\n")
    }

    func colorCode(_ color: Color) -> String {
        switch color {
        case .accentColor: return ".accentColor"
        case .red: return ".red"
        case .orange: return ".orange"
        case .yellow: return ".yellow"
        case .green: return ".green"
        case .teal: return ".teal"
        case .blue: return ".blue"
        case .indigo: return ".indigo"
        case .purple: return ".purple"
        case .pink: return ".pink"
        case .primary: return ".primary"
        case .secondary: return ".secondary"
        default: return rgbCode(color)
        }
    }

    func rgbCode(_ color: Color) -> String {
        let (red, green, blue) = resolvedRGB(color)
        return String(format: "Color(red: %.2f, green: %.2f, blue: %.2f)", red, green, blue)
    }

    func resolvedRGB(_ color: Color) -> (Double, Double, Double) {
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
