import SwiftUI

struct CustomTransitionShowcase: View {
    @State private var rotationDegrees: Double = 90
    @State private var scaleAmount: Double = 0.5
    @State private var animationKind: TransitionAnimation = .smooth
    @State private var isShown: Bool = true

    var body: some View {
        ShowcaseScreen(
            title: "Custom Transition",
            summary: "User-defined transition via the Transition protocol for bespoke insert/remove motion.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension CustomTransitionShowcase {
    fileprivate enum TransitionAnimation: String, ShowcasePickable, CaseIterable {
        case `default`
        case easeInOut
        case spring
        case bouncy
        case smooth

        var label: String {
            switch self {
            case .default: "default"
            case .easeInOut: "easeInOut"
            case .spring: "spring"
            case .bouncy: "bouncy"
            case .smooth: "smooth"
            }
        }

        var animation: Animation {
            switch self {
            case .default: return .default
            case .easeInOut: return .easeInOut
            case .spring: return .spring
            case .bouncy: return .bouncy
            case .smooth: return .smooth
            }
        }

        var codeString: String {
            switch self {
            case .default: return "default"
            case .easeInOut: return "easeInOut"
            case .spring: return "spring"
            case .bouncy: return "bouncy"
            case .smooth: return "smooth"
            }
        }
    }

    fileprivate enum TransitionVariant: ShowcaseState, CaseIterable {
        case subtle
        case moderate
        case dramatic

        var caption: String {
            switch self {
            case .subtle: "Subtle (30°, 0.8)"
            case .moderate: "Moderate (90°, 0.5)"
            case .dramatic: "Dramatic (270°, 0.1)"
            }
        }

        var rotationDegrees: Double {
            switch self {
            case .subtle: 30
            case .moderate: 90
            case .dramatic: 270
            }
        }

        var scaleAmount: Double {
            switch self {
            case .subtle: 0.8
            case .moderate: 0.5
            case .dramatic: 0.1
            }
        }
    }
}

// MARK: - Sub-views
private extension CustomTransitionShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.xLarge) {
            ZStack {
                if isShown {
                    previewCard
                        .transition(
                            TwirlTransition(
                                rotationDegrees: rotationDegrees,
                                scaleAmount: scaleAmount,
                            ).animation(animationKind.animation)
                        )
                }
            }
            .frame(height: 120)
            Button(isShown ? "Remove" : "Insert") {
                withAnimation(animationKind.animation) {
                    isShown.toggle()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(DesignSystem.Spacing.large)
    }

    var previewCard: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(DesignSystem.Color.accent)
            .frame(width: 120, height: 80)
            .overlay(
                Image(systemName: "sparkles")
                    .font(DesignSystem.Font.title)
                    .foregroundStyle(.white)
            )
    }

    @ViewBuilder var controls: some View {
        ShowcaseSlider("Rotation (°)", value: $rotationDegrees, in: 0...360, step: 5)
        ShowcaseSlider("Scale", value: $scaleAmount, in: 0.0...1.0, step: 0.05)
        ShowcasePicker("Animation", selection: $animationKind)
    }

    @ViewBuilder func stateView(_ state: TransitionVariant) -> some View {
        TransitionVariantPreview(
            rotationDegrees: state.rotationDegrees,
            scaleAmount: state.scaleAmount,
        )
    }
}

// MARK: - Code generation
private extension CustomTransitionShowcase {
    var generatedCode: String {
        let rotStr = String(format: "%.0f", rotationDegrees)
        let scaleStr = String(format: "%.2f", scaleAmount)
        let animStr = animationKind.codeString
        return [
            "struct TwirlTransition: Transition {",
            "    var rotationDegrees: Double",
            "    var scaleAmount: Double",
            "",
            "    func body(content: Content, phase: TransitionPhase) -> some View {",
            "        content",
            "            .rotationEffect(.degrees(phase.isIdentity ? 0 : rotationDegrees))",
            "            .scaleEffect(phase.isIdentity ? 1 : scaleAmount)",
            "            .opacity(phase.isIdentity ? 1 : 0)",
            "    }",
            "}",
            "",
            "// usage:",
            "view.transition(",
            "    TwirlTransition(",
            "        rotationDegrees: \(rotStr),",
            "        scaleAmount: \(scaleStr)",
            "    ).animation(.\(animStr))",
            ")",
        ].joined(separator: "\n")
    }
}

// MARK: - TwirlTransition
private struct TwirlTransition: Transition {
    var rotationDegrees: Double
    var scaleAmount: Double

    func body(content: Content, phase: TransitionPhase) -> some View {
        content
            .rotationEffect(.degrees(phase.isIdentity ? 0 : rotationDegrees))
            .scaleEffect(phase.isIdentity ? 1 : scaleAmount)
            .opacity(phase.isIdentity ? 1 : 0)
    }
}

// MARK: - TransitionVariantPreview
private struct TransitionVariantPreview: View {
    let rotationDegrees: Double
    let scaleAmount: Double
    @State private var isVisible: Bool = false

    var body: some View {
        ZStack {
            if isVisible {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .fill(DesignSystem.Color.accent)
                    .frame(width: 64, height: 44)
                    .overlay(
                        Image(systemName: "sparkles")
                            .foregroundStyle(.white)
                    )
                    .transition(
                        TwirlTransition(
                            rotationDegrees: rotationDegrees,
                            scaleAmount: scaleAmount,
                        ).animation(.smooth)
                    )
            }
        }
        .frame(width: 80, height: 60)
        .onAppear {
            withAnimation(.smooth.delay(0.1)) {
                isVisible = true
            }
        }
    }
}
