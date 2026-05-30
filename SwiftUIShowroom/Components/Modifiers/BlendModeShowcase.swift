import SwiftUI

struct BlendModeShowcase: View {
    @State private var selectedMode: BlendModeOption = .normal

    var body: some View {
        ShowcaseScreen(
            title: "Blend Mode",
            summary: "Sets how a view composites with the content behind it (multiply, screen, overlay, etc.).",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension BlendModeShowcase {
    enum BlendModeOption: ShowcasePickable {
        case normal
        case multiply
        case screen
        case overlay
        case darken
        case lighten
        case colorDodge
        case colorBurn
        case softLight
        case hardLight
        case difference
        case exclusion
        case hue
        case saturation
        case colorMode
        case luminosity
        case sourceAtop
        case destinationOver
        case destinationOut
        case plusDarker
        case plusLighter

        var label: String {
            let table: [(BlendModeOption, String)] = [
                (.normal, "normal"),
                (.multiply, "multiply"),
                (.screen, "screen"),
                (.overlay, "overlay"),
                (.darken, "darken"),
                (.lighten, "lighten"),
                (.colorDodge, "colorDodge"),
                (.colorBurn, "colorBurn"),
                (.softLight, "softLight"),
                (.hardLight, "hardLight"),
                (.difference, "difference"),
                (.exclusion, "exclusion"),
                (.hue, "hue"),
                (.saturation, "saturation"),
                (.colorMode, "color"),
                (.luminosity, "luminosity"),
                (.sourceAtop, "sourceAtop"),
                (.destinationOver, "destinationOver"),
                (.destinationOut, "destinationOut"),
                (.plusDarker, "plusDarker"),
                (.plusLighter, "plusLighter"),
            ]
            return table.first(where: { $0.0 == self })?.1 ?? "normal"
        }

        var blendMode: BlendMode {
            let table: [(BlendModeOption, BlendMode)] = [
                (.normal, .normal),
                (.multiply, .multiply),
                (.screen, .screen),
                (.overlay, .overlay),
                (.darken, .darken),
                (.lighten, .lighten),
                (.colorDodge, .colorDodge),
                (.colorBurn, .colorBurn),
                (.softLight, .softLight),
                (.hardLight, .hardLight),
                (.difference, .difference),
                (.exclusion, .exclusion),
                (.hue, .hue),
                (.saturation, .saturation),
                (.colorMode, .color),
                (.luminosity, .luminosity),
                (.sourceAtop, .sourceAtop),
                (.destinationOver, .destinationOver),
                (.destinationOut, .destinationOut),
                (.plusDarker, .plusDarker),
                (.plusLighter, .plusLighter),
            ]
            return table.first(where: { $0.0 == self })?.1 ?? .normal
        }
    }

    enum BlendModeState: ShowcaseState {
        case normal
        case multiply
        case screen
        case overlay
        case difference
        case exclusion

        var caption: String {
            switch self {
            case .normal: "normal"
            case .multiply: "multiply"
            case .screen: "screen"
            case .overlay: "overlay"
            case .difference: "difference"
            case .exclusion: "exclusion"
            }
        }

        var blendMode: BlendMode {
            switch self {
            case .normal: .normal
            case .multiply: .multiply
            case .screen: .screen
            case .overlay: .overlay
            case .difference: .difference
            case .exclusion: .exclusion
            }
        }
    }
}

// MARK: - Sub-views
private extension BlendModeShowcase {
    var preview: some View {
        blendSwatch(mode: selectedMode.blendMode)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Blend Mode", selection: $selectedMode)
    }

    @ViewBuilder func stateView(_ state: BlendModeState) -> some View {
        blendSwatch(mode: state.blendMode)
    }

    func blendSwatch(mode: BlendMode) -> some View {
        ZStack {
            LinearGradient(
                colors: [.purple, .pink, .orange],
                startPoint: .topLeading,
                endPoint: .bottomTrailing,
            )
            Text("BLEND")
                .font(DesignSystem.Font.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .blendMode(mode)
        }
        .frame(width: 200, height: 120)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
    }
}

// MARK: - Code generation
private extension BlendModeShowcase {
    var generatedCode: String {
        """
        Text("BLEND")
            .font(.largeTitle.bold())
            .blendMode(.\(selectedMode.label))
        """
    }
}
