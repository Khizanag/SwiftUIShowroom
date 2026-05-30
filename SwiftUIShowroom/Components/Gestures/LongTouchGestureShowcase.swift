import SwiftUI

struct LongTouchGestureShowcase: View {
    fileprivate enum LongTouchShowcaseState: ShowcaseState {
        case tvOSOnly, focused, selected

        var caption: String {
            switch self {
            case .tvOSOnly: "tvOS only"
            case .focused: "Touching"
            case .selected: "Completed"
            }
        }
    }

    @State private var minimumDuration: Double = 0.5
    @State private var useTouchingChanged: Bool = true
    @State private var isAnimating: Bool = false

    var body: some View {
        ShowcaseScreen(
            title: "Long Touch Gesture",
            summary: "Recognizes a long touch on the tvOS Siri Remote surface without an actual click.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension LongTouchGestureShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            simulatedRemote
            unavailableBadge
        }
    }

    var simulatedRemote: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .fill(
                    LinearGradient(
                        colors: [.gray.opacity(0.6), .gray.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing,
                    )
                )
                .frame(width: 80, height: 140)
            VStack(spacing: DesignSystem.Spacing.small) {
                Circle()
                    .fill(
                        isAnimating
                            ? DesignSystem.Color.accent.opacity(0.9)
                            : DesignSystem.Color.accent.opacity(0.4)
                    )
                    .frame(width: 52, height: 52)
                    .overlay(
                        Image(systemName: "hand.point.up.fill")
                            .font(DesignSystem.Font.title3)
                            .foregroundStyle(.white)
                    )
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                        value: isAnimating,
                    )
            }
        }
        .onAppear { isAnimating = true }
        .onDisappear { isAnimating = false }
    }

    var unavailableBadge: some View {
        Label("tvOS only — simulated preview", systemImage: "appletv")
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.secondary)
            .padding(.horizontal, DesignSystem.Spacing.small)
            .padding(.vertical, DesignSystem.Spacing.xSmall)
            .background(DesignSystem.Color.cardBackground, in: Capsule())
    }

    @ViewBuilder var controls: some View {
        ShowcaseSlider(
            "Minimum duration",
            value: $minimumDuration,
            in: 0.1...5.0,
            step: 0.1,
        )
        ShowcaseToggle("Wire onTouchingChanged", isOn: $useTouchingChanged)
    }

    @ViewBuilder
    func stateView(_ state: LongTouchShowcaseState) -> some View {
        switch state {
        case .tvOSOnly:
            tvOSOnlyCard
        case .focused:
            focusedCard
        case .selected:
            selectedCard
        }
    }

    var tvOSOnlyCard: some View {
        platformCard(
            icon: "appletv",
            message: "onLongTouchGesture is available on tvOS 16.0+",
            iconColor: DesignSystem.Color.accent,
        )
    }

    var focusedCard: some View {
        platformCard(
            icon: "hand.point.up",
            message: "Finger resting on remote surface — holding…",
            iconColor: .orange,
        )
    }

    var selectedCard: some View {
        platformCard(
            icon: "checkmark.circle.fill",
            message: "Long touch succeeded — gesture fired",
            iconColor: .green,
        )
    }

    func platformCard(icon: String, message: String, iconColor: Color) -> some View {
        let cornerRadius = DesignSystem.CornerRadius.medium
        return VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: icon)
                .font(DesignSystem.Font.title)
                .foregroundStyle(iconColor)
            Text(message)
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.medium)
        .frame(maxWidth: .infinity)
        .background(DesignSystem.Color.cardBackground, in: RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - Code generation
private extension LongTouchGestureShowcase {
    var generatedCode: String {
        let durationStr = String(format: "%.1f", minimumDuration)
        var lines: [String] = []
        lines.append("#if os(tvOS)")
        lines.append("struct LongTouchDemo: View {")
        lines.append("    @State private var touching = false")
        lines.append("    @State private var fired = false")
        lines.append("")
        lines.append("    var body: some View {")
        lines.append("        Circle()")
        lines.append("            .fill(fired ? .green : (touching ? .orange : .blue))")
        lines.append("            .frame(width: 160, height: 160)")
        if useTouchingChanged {
            lines.append("            .onLongTouchGesture(minimumDuration: \(durationStr)) {")
            lines.append("                fired = true")
            lines.append("            } onTouchingChanged: { isTouching in")
            lines.append("                touching = isTouching")
            lines.append("            }")
        } else {
            lines.append("            .onLongTouchGesture(minimumDuration: \(durationStr)) {")
            lines.append("                fired = true")
            lines.append("            }")
        }
        lines.append("    }")
        lines.append("}")
        lines.append("#endif")
        return lines.joined(separator: "\n")
    }
}
