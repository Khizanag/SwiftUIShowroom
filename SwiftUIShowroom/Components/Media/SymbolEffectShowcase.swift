import SwiftUI

struct SymbolEffectShowcase: View {
    enum EffectOption: ShowcasePickable {
        case bounce, pulse, variableColor, scale, appear, disappear, breathe, rotate, wiggle

        var label: String {
            switch self {
            case .bounce: "bounce"
            case .pulse: "pulse"
            case .variableColor: "variableColor"
            case .scale: "scale"
            case .appear: "appear"
            case .disappear: "disappear"
            case .breathe: "breathe"
            case .rotate: "rotate"
            case .wiggle: "wiggle"
            }
        }

        var isDiscrete: Bool {
            switch self {
            case .bounce, .wiggle: true
            default: false
            }
        }
    }

    enum DirectionOption: ShowcasePickable {
        case up, down

        var label: String {
            switch self {
            case .up: "up"
            case .down: "down"
            }
        }
    }

    enum VariableColorMode: ShowcasePickable {
        case iterative, cumulative

        var label: String {
            switch self {
            case .iterative: "iterative"
            case .cumulative: "cumulative"
            }
        }
    }

    enum RotateDirectionOption: ShowcasePickable {
        case clockwise, counterClockwise

        var label: String {
            switch self {
            case .clockwise: "clockwise"
            case .counterClockwise: "counterClockwise"
            }
        }
    }

    enum EffectState: ShowcaseState {
        case inactive, active, pulsing, variableColor

        var caption: String {
            switch self {
            case .inactive: "Inactive"
            case .active: "Active (bounce)"
            case .pulsing: "Pulsing"
            case .variableColor: "Variable Color"
            }
        }
    }

    @State private var effect: EffectOption = .bounce
    @State private var isActive = true
    @State private var directionOption: DirectionOption = .up
    @State private var variableColorMode: VariableColorMode = .iterative
    @State private var variableColorReversing = true
    @State private var rotateDirection: RotateDirectionOption = .clockwise
    @State private var repeating = true
    @State private var speed: Double = 1.0
    @State private var triggerCounter = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ShowcaseScreen(
            title: "Symbol Effect",
            summary: "Animate an SF Symbol with bounce, pulse, variableColor, scale, breathe, rotate, or wiggle.",
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

// MARK: - Sub-views
private extension SymbolEffectShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            animatedSymbol
            if effect.isDiscrete {
                Button("Trigger") { triggerCounter += 1 }
                    .buttonStyle(.bordered)
            }
        }
    }

    @ViewBuilder
    var animatedSymbol: some View {
        let base = Image(systemName: previewSymbolName)
            .font(DesignSystem.Font.largeTitle)
            .imageScale(.large)
            .foregroundStyle(DesignSystem.Color.accent)

        if reduceMotion {
            base
        } else {
            base.modifier(EffectModifier(config: effectConfig))
        }
    }

    var previewSymbolName: String {
        switch effect {
        case .pulse, .breathe: "heart.fill"
        case .variableColor: "wifi"
        case .scale: "star.fill"
        case .rotate: "arrow.clockwise"
        case .wiggle: "bell.fill"
        case .appear, .disappear: "cloud.fill"
        case .bounce: "hand.thumbsup.fill"
        }
    }

    var effectConfig: EffectConfig {
        EffectConfig(
            effect: effect,
            isActive: isActive,
            directionOption: directionOption,
            variableColorMode: variableColorMode,
            variableColorReversing: variableColorReversing,
            rotateDirection: rotateDirection,
            repeating: repeating,
            speed: speed,
            triggerCounter: triggerCounter,
        )
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Effect", selection: $effect)
        ShowcaseToggle("Active / trigger value", isOn: $isActive)
        ShowcaseToggle("Repeating", isOn: $repeating)
        ShowcaseSlider("Speed", value: $speed, in: 0.25...3.0, step: 0.25)

        if effect == .bounce || effect == .scale {
            ShowcasePicker("Direction", selection: $directionOption)
        }
        if effect == .variableColor {
            ShowcasePicker("Variable color mode", selection: $variableColorMode)
            ShowcaseToggle("Reversing", isOn: $variableColorReversing)
        }
        if effect == .rotate {
            ShowcasePicker("Rotate direction", selection: $rotateDirection)
        }
    }

    @ViewBuilder
    func stateView(_ state: EffectState) -> some View {
        switch state {
        case .inactive:
            Image(systemName: "hand.thumbsup")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.accent)
        case .active:
            Image(systemName: "hand.thumbsup.fill")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.accent)
                .symbolEffect(.bounce.up.byLayer, options: .nonRepeating, value: 1)
        case .pulsing:
            Image(systemName: "heart.fill")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.accent)
                .symbolEffect(.pulse.byLayer, options: .repeating, isActive: true)
        case .variableColor:
            Image(systemName: "wifi")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.accent)
                .symbolEffect(.variableColor.iterative.reversing, options: .repeating, isActive: true)
        }
    }
}

// MARK: - Code generation
private extension SymbolEffectShowcase {
    var generatedCode: String {
        let optionsParts = repeating
            ? ".repeating.speed(\(formattedSpeed))"
            : ".nonRepeating.speed(\(formattedSpeed))"
        let lines = [
            "Image(systemName: \"\(previewSymbolName)\")",
            "    .font(.largeTitle)",
            "    .symbolEffect(",
            "        .\(effectCode),",
            "        options: \(optionsParts),",
            "        isActive: \(isActive)",
            "    )",
        ]
        return lines.joined(separator: "\n")
    }

    var formattedSpeed: String {
        speed == speed.rounded() ? String(Int(speed)) : String(format: "%.2f", speed)
    }

    var effectCode: String {
        switch effect {
        case .bounce:
            return directionOption == .up ? "bounce.up.byLayer" : "bounce.down.byLayer"
        case .pulse:
            return "pulse.byLayer"
        case .variableColor:
            let modeStr = variableColorMode == .cumulative ? "cumulative" : "iterative"
            let revStr = variableColorReversing ? "reversing" : "nonReversing"
            return "variableColor.\(modeStr).\(revStr)"
        case .scale:
            return directionOption == .up ? "scale.up.byLayer" : "scale.down.byLayer"
        case .appear:
            return "appear.byLayer"
        case .disappear:
            return "disappear.byLayer"
        case .breathe:
            return "breathe.byLayer"
        case .rotate:
            return rotateDirection == .clockwise
                ? "rotate.clockwise.byLayer"
                : "rotate.counterClockwise.byLayer"
        case .wiggle:
            return "wiggle.byLayer"
        }
    }
}

// MARK: - Supporting types
private struct EffectConfig {
    let effect: SymbolEffectShowcase.EffectOption
    let isActive: Bool
    let directionOption: SymbolEffectShowcase.DirectionOption
    let variableColorMode: SymbolEffectShowcase.VariableColorMode
    let variableColorReversing: Bool
    let rotateDirection: SymbolEffectShowcase.RotateDirectionOption
    let repeating: Bool
    let speed: Double
    let triggerCounter: Int

    var options: SymbolEffectOptions {
        (repeating ? SymbolEffectOptions.repeating : .nonRepeating).speed(speed)
    }
}

private struct EffectModifier: ViewModifier {
    let config: EffectConfig

    func body(content: Content) -> some View {
        let opts = config.options
        switch config.effect {
        case .bounce:
            bounceView(content: content, options: opts)
        case .pulse:
            content.symbolEffect(.pulse.byLayer, options: opts, isActive: config.isActive)
        case .variableColor:
            variableColorView(content: content, options: opts)
        case .scale:
            scaleView(content: content, options: opts)
        case .appear:
            content.symbolEffect(.appear.byLayer, options: opts, isActive: config.isActive)
        case .disappear:
            content.symbolEffect(.disappear.byLayer, options: opts, isActive: config.isActive)
        case .breathe:
            breatheView(content: content, options: opts)
        case .rotate:
            rotateView(content: content, options: opts)
        case .wiggle:
            wiggleView(content: content, options: opts)
        }
    }

    @ViewBuilder
    private func bounceView(content: Content, options: SymbolEffectOptions) -> some View {
        if config.directionOption == .up {
            content.symbolEffect(.bounce.up.byLayer, options: options, value: config.triggerCounter)
        } else {
            content.symbolEffect(.bounce.down.byLayer, options: options, value: config.triggerCounter)
        }
    }

    @ViewBuilder
    private func scaleView(content: Content, options: SymbolEffectOptions) -> some View {
        if config.directionOption == .up {
            content.symbolEffect(.scale.up.byLayer, options: options, isActive: config.isActive)
        } else {
            content.symbolEffect(.scale.down.byLayer, options: options, isActive: config.isActive)
        }
    }

    @ViewBuilder
    private func variableColorView(content: Content, options: SymbolEffectOptions) -> some View {
        if config.variableColorMode == .cumulative {
            if config.variableColorReversing {
                content.symbolEffect(
                    .variableColor.cumulative.reversing,
                    options: options,
                    isActive: config.isActive,
                )
            } else {
                content.symbolEffect(
                    .variableColor.cumulative.nonReversing,
                    options: options,
                    isActive: config.isActive,
                )
            }
        } else {
            if config.variableColorReversing {
                content.symbolEffect(
                    .variableColor.iterative.reversing,
                    options: options,
                    isActive: config.isActive,
                )
            } else {
                content.symbolEffect(
                    .variableColor.iterative.nonReversing,
                    options: options,
                    isActive: config.isActive,
                )
            }
        }
    }

    @ViewBuilder
    private func breatheView(content: Content, options: SymbolEffectOptions) -> some View {
        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, *) {
            content.symbolEffect(.breathe.byLayer, options: options, isActive: config.isActive)
        } else {
            content.symbolEffect(.pulse.byLayer, options: options, isActive: config.isActive)
        }
    }

    @ViewBuilder
    private func rotateView(content: Content, options: SymbolEffectOptions) -> some View {
        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, *) {
            if config.rotateDirection == .clockwise {
                content.symbolEffect(
                    .rotate.clockwise.byLayer,
                    options: options,
                    isActive: config.isActive,
                )
            } else {
                content.symbolEffect(
                    .rotate.counterClockwise.byLayer,
                    options: options,
                    isActive: config.isActive,
                )
            }
        } else {
            content.symbolEffect(.pulse.byLayer, options: options, isActive: config.isActive)
        }
    }

    @ViewBuilder
    private func wiggleView(content: Content, options: SymbolEffectOptions) -> some View {
        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, *) {
            content.symbolEffect(.wiggle.byLayer, options: options, value: config.triggerCounter)
        } else {
            content.symbolEffect(.bounce.up.byLayer, options: options, value: config.triggerCounter)
        }
    }
}
