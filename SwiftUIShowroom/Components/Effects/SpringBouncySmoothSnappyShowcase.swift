import SwiftUI

struct SpringBouncySmoothSnappyShowcase: View {
    @State private var preset: SpringPreset = .smooth
    @State private var duration: Double = 0.5
    @State private var bounce: Double = 0.2
    @State private var isMoved = false

    var body: some View {
        ShowcaseScreen(
            title: "Spring Animations",
            summary: "Physically based spring presets with tunable duration and bounce.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension SpringBouncySmoothSnappyShowcase {
    fileprivate enum SpringPreset: String, ShowcasePickable, CaseIterable {
        case spring, bouncy, smooth, snappy, interpolatingSpring

        var label: String {
            switch self {
            case .spring: ".spring"
            case .bouncy: ".bouncy"
            case .smooth: ".smooth"
            case .snappy: ".snappy"
            case .interpolatingSpring: ".interpolatingSpring"
            }
        }

        func animation(duration: Double, bounce: Double) -> Animation {
            switch self {
            case .spring:
                return .spring(duration: duration, bounce: bounce)
            case .bouncy:
                return .bouncy(duration: duration, extraBounce: bounce)
            case .smooth:
                return .smooth(duration: duration, extraBounce: bounce)
            case .snappy:
                return .snappy(duration: duration, extraBounce: bounce)
            case .interpolatingSpring:
                return .interpolatingSpring(duration: duration, bounce: bounce)
            }
        }

        var codeCall: String {
            switch self {
            case .spring: ".spring"
            case .bouncy: ".bouncy"
            case .smooth: ".smooth"
            case .snappy: ".snappy"
            case .interpolatingSpring: ".interpolatingSpring"
            }
        }

        var bounceLabel: String {
            switch self {
            case .spring, .interpolatingSpring: "bounce"
            case .bouncy, .smooth, .snappy: "extraBounce"
            }
        }
    }

    fileprivate enum SpringState: CaseIterable, ShowcaseState {
        case smooth, snappy, bouncy, spring

        var caption: String {
            switch self {
            case .smooth: "smooth"
            case .snappy: "snappy"
            case .bouncy: "bouncy"
            case .spring: "spring"
            }
        }

        var animation: Animation {
            switch self {
            case .smooth: .smooth(duration: 0.5, extraBounce: 0)
            case .snappy: .snappy(duration: 0.4, extraBounce: 0.1)
            case .bouncy: .bouncy(duration: 0.5, extraBounce: 0.3)
            case .spring: .spring(duration: 0.5, bounce: 0.2)
            }
        }
    }
}

// MARK: - Sub-views
private extension SpringBouncySmoothSnappyShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.xLarge) {
            Circle()
                .fill(DesignSystem.Color.accent)
                .frame(
                    width: DesignSystem.Size.Icon.xLarge,
                    height: DesignSystem.Size.Icon.xLarge,
                )
                .offset(y: isMoved ? 60 : -60)
                .animation(
                    preset.animation(duration: duration, bounce: bounce),
                    value: isMoved,
                )
            Button("Trigger") {
                isMoved.toggle()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(DesignSystem.Spacing.large)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Preset", selection: $preset)
        ShowcaseSlider("Duration", value: $duration, in: 0.1...2.0, step: 0.05)
        ShowcaseSlider("Bounce", value: $bounce, in: 0.0...1.0, step: 0.05)
    }

    @ViewBuilder func stateView(_ state: SpringState) -> some View {
        SpringBallPreview(animation: state.animation)
    }
}

// MARK: - SpringBallPreview
private struct SpringBallPreview: View {
    let animation: Animation
    @State private var moved = false

    var body: some View {
        Circle()
            .fill(Color.accentColor)
            .frame(
                width: DesignSystem.Size.Icon.large,
                height: DesignSystem.Size.Icon.large,
            )
            .offset(y: moved ? 30 : -30)
            .animation(animation, value: moved)
            .onAppear { moved = true }
    }
}

// MARK: - Code generation
private extension SpringBouncySmoothSnappyShowcase {
    var generatedCode: String {
        let durationStr = String(format: "%.2f", duration)
        let bounceStr = String(format: "%.2f", bounce)
        return [
            "view",
            "    .offset(y: moved ? 120 : 0)",
            "    .animation(",
            "        \(preset.codeCall)(duration: \(durationStr), \(preset.bounceLabel): \(bounceStr)),",
            "        value: moved",
            "    )",
        ].joined(separator: "\n")
    }
}
