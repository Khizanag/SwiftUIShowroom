import SwiftUI

struct AccessibilityReduceMotionShowcase: View {
    @State private var reduceMotion = false
    @State private var isExpanded = false

    fileprivate enum MotionState: ShowcaseState {
        case motionEnabled
        case motionReduced

        var caption: String {
            switch self {
            case .motionEnabled: "Full motion"
            case .motionReduced: "Reduce Motion on"
            }
        }

        var reduceMotion: Bool {
            switch self {
            case .motionEnabled: false
            case .motionReduced: true
            }
        }
    }

    var body: some View {
        ShowcaseScreen(
            title: "Reduce Motion",
            summary: "Gate motion-heavy animations behind accessibilityReduceMotion for sensitive users.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityReduceMotionShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            cardPreview(reduceMotion: reduceMotion, isExpanded: isExpanded)
            Button(isExpanded ? "Collapse" : "Expand") {
                withAnimation(reduceMotion ? nil : .spring) {
                    isExpanded.toggle()
                }
            }
            .font(DesignSystem.Font.callout)
        }
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("reduceMotion (simulated)", isOn: $reduceMotion)
    }

    @ViewBuilder func stateView(_ state: MotionState) -> some View {
        cardPreview(reduceMotion: state.reduceMotion, isExpanded: true)
    }

    @ViewBuilder func cardPreview(reduceMotion: Bool, isExpanded: Bool) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            HStack {
                Image(systemName: reduceMotion ? "figure.stand" : "figure.walk.motion")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.accent)
                Text(reduceMotion ? "Reduce Motion: on" : "Reduce Motion: off")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.primary)
            }
            if isExpanded {
                Text("Animation: \(reduceMotion ? "nil (no motion)" : ".spring (full motion)")")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
                    .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Code generation
private extension AccessibilityReduceMotionShowcase {
    var generatedCode: String {
        """
        @Environment(\\.accessibilityReduceMotion) private var reduceMotion

        var body: some View {
            CardView()
                .animation(reduceMotion ? nil : .spring, value: isExpanded)
        }
        """
    }
}
