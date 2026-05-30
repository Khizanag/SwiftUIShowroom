import SwiftUI

struct WithAnimationShowcase: View {
    @State private var animationOption: AnimationOption = .spring
    @State private var duration: Double = 0.35
    @State private var useCompletion: Bool = false
    @State private var isExpanded: Bool = false
    @State private var completionFired: Bool = false

    var body: some View {
        ShowcaseScreen(
            title: "withAnimation",
            summary: "Explicitly animates state changes performed inside its closure.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension WithAnimationShowcase {
    @ViewBuilder var preview: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            animatedShape
            triggerButton
            if useCompletion && completionFired {
                Text("Completion fired")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
                    .transition(.opacity)
            }
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var animatedShape: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
            .fill(DesignSystem.Color.accent)
            .frame(
                width: isExpanded ? 220 : 80,
                height: isExpanded ? 120 : 80,
            )
            .overlay { shapeOverlayIcon }
    }

    var shapeOverlayIcon: some View {
        let name = isExpanded
            ? "arrow.down.right.and.arrow.up.left"
            : "arrow.up.left.and.arrow.down.right"
        return Image(systemName: name)
            .font(DesignSystem.Font.title2)
            .foregroundStyle(.white)
    }

    var triggerButton: some View {
        Button(isExpanded ? "Collapse" : "Expand") {
            fireAnimation()
        }
        .buttonStyle(.bordered)
    }

    func fireAnimation() {
        let animation = resolvedAnimation
        if useCompletion {
            completionFired = false
            if #available(iOS 17.0, macOS 14.0, tvOS 17.0, *) {
                withAnimation(animation) {
                    isExpanded.toggle()
                } completion: {
                    completionFired = true
                }
            } else {
                withAnimation(animation) {
                    isExpanded.toggle()
                }
                completionFired = true
            }
        } else {
            withAnimation(animation) {
                isExpanded.toggle()
            }
        }
    }

    var resolvedAnimation: Animation? {
        switch animationOption {
        case .default: .default
        case .easeInOut: .easeInOut(duration: duration)
        case .easeIn: .easeIn(duration: duration)
        case .easeOut: .easeOut(duration: duration)
        case .linear: .linear(duration: duration)
        case .spring: .spring
        case .bouncy: .bouncy
        case .smooth: .smooth
        case .snappy: .snappy
        case .interpolatingSpring: .interpolatingSpring
        case .none: nil
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Animation", selection: $animationOption)
        if animationOption.usesDuration {
            ShowcaseSlider("Duration", value: $duration, in: 0.1...3.0, step: 0.05)
        }
        ShowcaseToggle("Use completion (iOS 17+)", isOn: $useCompletion)
    }

    @ViewBuilder
    func stateView(_ state: AnimationState) -> some View {
        stateDemo(state: state)
    }
}

// MARK: - State demo
private extension WithAnimationShowcase {
    func stateDemo(state: AnimationState) -> some View {
        StateDemoView(state: state)
    }
}

private struct StateDemoView: View {
    let state: WithAnimationShowcase.AnimationState
    @State private var toggled: Bool = false

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(Color.accentColor)
                .frame(width: toggled ? 140 : 60, height: 60)
            Button("Tap") {
                withAnimation(state.animation) {
                    toggled.toggle()
                }
            }
            .buttonStyle(.bordered)
            .disabled(state == .noAnimation)
        }
    }
}

// MARK: - Code generation
private extension WithAnimationShowcase {
    var generatedCode: String {
        let animArg = animationOption.codeLabel(duration: duration)
        var lines: [String] = []
        if useCompletion {
            lines.append("withAnimation(\(animArg)) {")
            lines.append("    isExpanded.toggle()")
            lines.append("} completion: {")
            lines.append("    // runs after the animation finishes")
            lines.append("}")
        } else {
            lines.append("withAnimation(\(animArg)) {")
            lines.append("    isExpanded.toggle()")
            lines.append("}")
        }
        return lines.joined(separator: "\n")
    }
}

// MARK: - Nested types
extension WithAnimationShowcase {
    enum AnimationOption: ShowcasePickable {
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
            case .easeInOut, .easeIn, .easeOut, .linear: true
            default: false
            }
        }

        func codeLabel(duration: Double) -> String {
            switch self {
            case .default: ".default"
            case .easeInOut: ".easeInOut(duration: \(duration))"
            case .easeIn: ".easeIn(duration: \(duration))"
            case .easeOut: ".easeOut(duration: \(duration))"
            case .linear: ".linear(duration: \(duration))"
            case .spring: ".spring"
            case .bouncy: ".bouncy"
            case .smooth: ".smooth"
            case .snappy: ".snappy"
            case .interpolatingSpring: ".interpolatingSpring"
            case .none: "nil"
            }
        }
    }

    enum AnimationState: ShowcaseState {
        case withSpring
        case withEaseInOut
        case noAnimation

        var caption: String {
            switch self {
            case .withSpring: ".spring"
            case .withEaseInOut: ".easeInOut"
            case .noAnimation: "nil (no animation)"
            }
        }

        var animation: Animation? {
            switch self {
            case .withSpring: .spring
            case .withEaseInOut: .easeInOut(duration: 0.4)
            case .noAnimation: nil
            }
        }
    }
}
