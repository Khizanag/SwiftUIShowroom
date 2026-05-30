import SwiftUI

struct PhaseAnimatorShowcase: View {
    @State private var animationKind: PhaseAnimationKind = .bouncy
    @State private var looping: Bool = false
    @State private var trigger: Int = 0

    var body: some View {
        ShowcaseScreen(
            title: "Phase Animator",
            summary: "Cycles a view through discrete phases, animating between each step.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension PhaseAnimatorShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            animatedHeart
            if !looping {
                Button("Trigger") {
                    trigger += 1
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(DesignSystem.Spacing.large)
    }

    @ViewBuilder
    var animatedHeart: some View {
        let phases: [Double] = [1.0, 1.3, 0.9, 1.0]
        let selectedAnimation = animationKind.animation
        if looping {
            Image(systemName: "heart.fill")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.accent)
                .phaseAnimator(phases) { content, phase in
                    content.scaleEffect(phase)
                } animation: { _ in
                    selectedAnimation
                }
        } else {
            Image(systemName: "heart.fill")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.accent)
                .phaseAnimator(phases, trigger: trigger) { content, phase in
                    content.scaleEffect(phase)
                } animation: { _ in
                    selectedAnimation
                }
        }
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Animation", selection: $animationKind)
        ShowcaseToggle("Looping (no trigger)", isOn: $looping)
        if !looping {
            ShowcaseStepper("Trigger counter", value: $trigger, in: 0...1000)
        }
    }

    @ViewBuilder func stateView(_ state: PhasePlayState) -> some View {
        PhaseGalleryCell(state: state)
    }
}

// MARK: - Code generation
private extension PhaseAnimatorShowcase {
    var generatedCode: String {
        let phases = "[1.0, 1.3, 0.9, 1.0]"
        let animCode = animationKind.codeString
        if looping {
            return [
                "Image(systemName: \"heart.fill\")",
                "    .phaseAnimator(\(phases)) { content, phase in",
                "        content.scaleEffect(phase)",
                "    } animation: { _ in",
                "        \(animCode)",
                "    }",
            ].joined(separator: "\n")
        } else {
            return [
                "Image(systemName: \"heart.fill\")",
                "    .phaseAnimator(\(phases), trigger: trigger) { content, phase in",
                "        content.scaleEffect(phase)",
                "    } animation: { _ in",
                "        \(animCode)",
                "    }",
            ].joined(separator: "\n")
        }
    }
}

// MARK: - Nested types
extension PhaseAnimatorShowcase {
    fileprivate enum PhaseAnimationKind: String, ShowcasePickable, CaseIterable {
        case `default`
        case easeInOut
        case linear
        case spring
        case bouncy
        case smooth
        case snappy

        var label: String {
            switch self {
            case .default: ".default"
            case .easeInOut: ".easeInOut"
            case .linear: ".linear"
            case .spring: ".spring"
            case .bouncy: ".bouncy"
            case .smooth: ".smooth"
            case .snappy: ".snappy"
            }
        }

        var animation: Animation {
            switch self {
            case .default: return .default
            case .easeInOut: return .easeInOut
            case .linear: return .linear
            case .spring: return .spring
            case .bouncy: return .bouncy
            case .smooth: return .smooth
            case .snappy: return .snappy
            }
        }

        var codeString: String {
            switch self {
            case .default: return ".default"
            case .easeInOut: return ".easeInOut"
            case .linear: return ".linear"
            case .spring: return ".spring"
            case .bouncy: return ".bouncy"
            case .smooth: return ".smooth"
            case .snappy: return ".snappy"
            }
        }
    }

    fileprivate enum PhasePlayState: CaseIterable, ShowcaseState {
        case triggered
        case looping
        case multiStep

        var caption: String {
            switch self {
            case .triggered: "Triggered (one cycle)"
            case .looping: "Looping (continuous)"
            case .multiStep: "Multi-step phases"
            }
        }
    }
}

// MARK: - PhaseGalleryCell
private struct PhaseGalleryCell: View {
    let state: PhaseAnimatorShowcase.PhasePlayState
    @State private var trigger: Int = 0

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            phaseView
            if state == .triggered {
                Button("Fire") { trigger += 1 }
                    .font(DesignSystem.Font.caption)
            }
        }
    }

    @ViewBuilder
    private var phaseView: some View {
        switch state {
        case .triggered:
            triggeredView
        case .looping:
            loopingView
        case .multiStep:
            multiStepView
        }
    }

    private var triggeredView: some View {
        Image(systemName: "star.fill")
            .font(DesignSystem.Font.title)
            .foregroundStyle(Color.accentColor)
            .phaseAnimator([1.0, 1.4, 1.0], trigger: trigger) { content, phase in
                content.scaleEffect(phase)
            } animation: { _ in
                .bouncy
            }
    }

    private var loopingView: some View {
        Image(systemName: "heart.fill")
            .font(DesignSystem.Font.title)
            .foregroundStyle(Color.accentColor)
            .phaseAnimator([1.0, 1.3, 1.0]) { content, phase in
                content.scaleEffect(phase)
            } animation: { _ in
                .smooth(duration: 0.6, extraBounce: 0)
            }
    }

    private var multiStepView: some View {
        Image(systemName: "bolt.fill")
            .font(DesignSystem.Font.title)
            .foregroundStyle(Color.accentColor)
            .phaseAnimator([0.0, 45.0, -45.0, 0.0]) { content, phase in
                content.rotationEffect(.degrees(phase))
            } animation: { _ in
                .snappy(duration: 0.25, extraBounce: 0.1)
            }
    }
}
