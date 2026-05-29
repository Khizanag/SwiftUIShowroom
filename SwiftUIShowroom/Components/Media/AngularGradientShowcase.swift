import SwiftUI

struct AngularGradientShowcase: View {
    @State private var colorStart: Color = .red
    @State private var colorEnd: Color = .red
    @State private var useRainbow: Bool = true
    @State private var center: CenterOption = .center
    @State private var startAngle: Double = 0
    @State private var endAngle: Double = 360
    @State private var size: Double = 220

    var body: some View {
        ShowcaseScreen(
            title: "AngularGradient",
            summary: "A gradient that sweeps colors around a center point (conic gradient).",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AngularGradientShowcase {
    var preview: some View {
        angularGradient(
            colors: resolvedColors,
            center: center.unitPoint,
            startAngle: startAngle,
            endAngle: endAngle,
            size: CGFloat(size)
        )
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("Rainbow spectrum", isOn: $useRainbow)
        if !useRainbow {
            ShowcaseColorControl("Start color", selection: $colorStart)
            ShowcaseColorControl("End color", selection: $colorEnd)
        }
        ShowcasePicker("Center", selection: $center)
        ShowcaseSlider("Start angle", value: $startAngle, in: 0...360, step: 1)
        ShowcaseSlider("End angle", value: $endAngle, in: 0...360, step: 1)
        ShowcaseSlider("Size", value: $size, in: 80...320, step: 1)
    }

    @ViewBuilder
    func stateView(_ state: GradientState) -> some View {
        angularGradient(
            colors: state.colors,
            center: state.center,
            startAngle: state.startAngle,
            endAngle: state.endAngle,
            size: 140
        )
    }

    func angularGradient(
        colors: [Color],
        center: UnitPoint,
        startAngle: Double,
        endAngle: Double,
        size: CGFloat
    ) -> some View {
        AngularGradient(
            colors: colors,
            center: center,
            startAngle: .degrees(startAngle),
            endAngle: .degrees(endAngle)
        )
        .frame(width: size, height: size)
    }

    var resolvedColors: [Color] {
        useRainbow ? rainbowColors : [colorStart, colorEnd]
    }

    var rainbowColors: [Color] {
        [.red, .orange, .yellow, .green, .blue, .purple, .red]
    }
}

// MARK: - Code generation
private extension AngularGradientShowcase {
    var generatedCode: String {
        let colorsSnippet = useRainbow
            ? "[.red, .orange, .yellow, .green, .blue, .purple, .red]"
            : "[\(colorDescription(colorStart)), \(colorDescription(colorEnd))]"
        let sizeInt = Int(size)
        return """
        AngularGradient(
            colors: \(colorsSnippet),
            center: .\(center.label),
            startAngle: .degrees(\(formatted(startAngle))),
            endAngle: .degrees(\(formatted(endAngle)))
        )
        .frame(width: \(sizeInt), height: \(sizeInt))
        """
    }

    func colorDescription(_ color: Color) -> String {
        switch color {
        case .red: ".red"
        case .orange: ".orange"
        case .yellow: ".yellow"
        case .green: ".green"
        case .blue: ".blue"
        case .purple: ".purple"
        case .pink: ".pink"
        case .mint: ".mint"
        case .cyan: ".cyan"
        case .indigo: ".indigo"
        case .teal: ".teal"
        case .brown: ".brown"
        default: "Color(/* configured */)"
        }
    }

    func formatted(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(format: "%.1f", value)
    }
}

// MARK: - Nested enums
private extension AngularGradientShowcase {
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
        case rainbow, twoColor, halfSweep, offsetCenter

        var caption: String {
            switch self {
            case .rainbow: "Rainbow wheel"
            case .twoColor: "Two colors"
            case .halfSweep: "Half sweep"
            case .offsetCenter: "Offset center"
            }
        }

        var colors: [Color] {
            switch self {
            case .rainbow: [.red, .orange, .yellow, .green, .blue, .purple, .red]
            case .twoColor: [.blue, .purple]
            case .halfSweep: [.orange, .pink, .purple]
            case .offsetCenter: [.cyan, .indigo, .cyan]
            }
        }

        var center: UnitPoint {
            switch self {
            case .rainbow: .center
            case .twoColor: .center
            case .halfSweep: .center
            case .offsetCenter: .topLeading
            }
        }

        var startAngle: Double {
            switch self {
            case .rainbow: 0
            case .twoColor: 0
            case .halfSweep: 0
            case .offsetCenter: 0
            }
        }

        var endAngle: Double {
            switch self {
            case .rainbow: 360
            case .twoColor: 360
            case .halfSweep: 180
            case .offsetCenter: 360
            }
        }
    }
}
