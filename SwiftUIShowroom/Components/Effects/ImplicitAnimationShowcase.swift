import SwiftUI

struct ImplicitAnimationShowcase: View {
    @State private var animationKind: AnimationKind = .default
    @State private var duration: Double = 0.35
    @State private var counter: Int = 0
    @State private var isBig: Bool = false

    var body: some View {
        ShowcaseScreen(
            title: "Implicit Animation",
            summary: "Animates view changes implicitly whenever a specified equatable value changes.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ImplicitAnimationShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            Circle()
                .fill(DesignSystem.Color.accent)
                .frame(
                    width: isBig ? DesignSystem.Size.Icon.xLarge * 2.5 : DesignSystem.Size.Icon.xLarge,
                    height: isBig ? DesignSystem.Size.Icon.xLarge * 2.5 : DesignSystem.Size.Icon.xLarge
                )
                .animation(resolvedAnimation, value: isBig)
            Button("Toggle") {
                isBig.toggle()
                counter += 1
            }
            .font(DesignSystem.Font.headline)
        }
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Animation", selection: $animationKind)
        if animationKind.usesDuration {
            ShowcaseSlider("Duration", value: $duration, in: 0.1...3.0, step: 0.05)
        }
        ShowcaseStepper("Trigger counter", value: $counter, in: 0...1000)
    }

    @ViewBuilder func stateView(_ state: EnabledState) -> some View {
        let anim: Animation? = state == .disabled ? nil : .default
        Circle()
            .fill(DesignSystem.Color.accent)
            .frame(width: DesignSystem.Size.Icon.large, height: DesignSystem.Size.Icon.large)
            .scaleEffect(state == .enabled ? 1.4 : 1.0)
            .animation(anim, value: state == .enabled)
    }
}

// MARK: - Code generation
private extension ImplicitAnimationShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("Circle()")
        lines.append("    .scaleEffect(isBig ? 1.5 : 1.0)")
        let animLine = animationKind.codeString(duration: duration)
        lines.append("    .animation(\(animLine), value: isBig)")
        return lines.joined(separator: "\n")
    }

    var resolvedAnimation: Animation? {
        animationKind.animation(duration: duration)
    }
}

// MARK: - Nested types
extension ImplicitAnimationShowcase {
    fileprivate enum AnimationKind: String, ShowcasePickable, CaseIterable {
        case `default`
        case easeInOut
        case easeIn
        case easeOut
        case linear
        case spring
        case bouncy
        case smooth
        case snappy
        case interpolatingSpring
        case none

        var label: String {
            switch self {
            case .default: "default"
            case .easeInOut: "easeInOut"
            case .easeIn: "easeIn"
            case .easeOut: "easeOut"
            case .linear: "linear"
            case .spring: "spring"
            case .bouncy: "bouncy"
            case .smooth: "smooth"
            case .snappy: "snappy"
            case .interpolatingSpring: "interpolatingSpring"
            case .none: "nil"
            }
        }

        var usesDuration: Bool {
            switch self {
            case .easeInOut, .easeIn, .easeOut, .linear:
                return true
            default:
                return false
            }
        }

        func animation(duration: Double) -> Animation? {
            switch self {
            case .default: return .default
            case .easeInOut: return .easeInOut(duration: duration)
            case .easeIn: return .easeIn(duration: duration)
            case .easeOut: return .easeOut(duration: duration)
            case .linear: return .linear(duration: duration)
            case .spring: return .spring
            case .bouncy: return .bouncy
            case .smooth: return .smooth
            case .snappy: return .snappy
            case .interpolatingSpring: return .interpolatingSpring
            case .none: return nil
            }
        }

        func codeString(duration: Double) -> String {
            let secs = duration.formatted(.number.precision(.fractionLength(0...2)))
            switch self {
            case .default: return ".default"
            case .easeInOut: return ".easeInOut(duration: \(secs))"
            case .easeIn: return ".easeIn(duration: \(secs))"
            case .easeOut: return ".easeOut(duration: \(secs))"
            case .linear: return ".linear(duration: \(secs))"
            case .spring: return ".spring"
            case .bouncy: return ".bouncy"
            case .smooth: return ".smooth"
            case .snappy: return ".snappy"
            case .interpolatingSpring: return ".interpolatingSpring"
            case .none: return "nil"
            }
        }
    }
}
