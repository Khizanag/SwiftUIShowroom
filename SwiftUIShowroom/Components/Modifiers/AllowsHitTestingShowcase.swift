import SwiftUI

struct AllowsHitTestingShowcase: View {
    @State private var allowsHitTesting: Bool = true
    @State private var tapCount: Int = 0

    enum HitTestingState: ShowcaseState {
        case active
        case passThrough

        var caption: String {
            switch self {
            case .active: "Hit testing on"
            case .passThrough: "Hit testing off"
            }
        }
    }

    var body: some View {
        ShowcaseScreen(
            title: "Allows Hit Testing",
            summary: "Controls whether the view participates in hit testing; false lets touches pass through.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AllowsHitTestingShowcase {
    var preview: some View {
        ZStack {
            backgroundButton
            overlayBadge
                .allowsHitTesting(allowsHitTesting)
        }
    }

    var backgroundButton: some View {
        Button {
            tapCount += 1
        } label: {
            VStack(spacing: DesignSystem.Spacing.xSmall) {
                Image(systemName: "hand.tap.fill")
                    .font(DesignSystem.Font.title)
                    .foregroundStyle(DesignSystem.Color.accent)
                Text("Tap me")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.primary)
                Text("Taps: \(tapCount)")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
            .frame(width: 200, height: 120)
            .background(
                DesignSystem.Color.cardBackground,
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium),
            )
        }
        .buttonStyle(.plain)
    }

    var overlayBadge: some View {
        let overlayText = allowsHitTesting ? "Overlay (blocks taps)" : "Pass-through"
        return RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(DesignSystem.Color.accent.opacity(allowsHitTesting ? 0.6 : 0.2))
            .frame(width: 200, height: 120)
            .overlay(
                Text(overlayText)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.onAccent),
            )
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("Allows Hit Testing", isOn: $allowsHitTesting)
    }

    @ViewBuilder func stateView(_ state: HitTestingState) -> some View {
        switch state {
        case .active:
            demoCard(
                blocking: true,
                label: "Overlay receives taps",
                iconName: "hand.raised.fill",
            )
        case .passThrough:
            demoCard(
                blocking: false,
                label: "Taps reach view below",
                iconName: "arrow.down.to.line",
            )
        }
    }

    func demoCard(blocking: Bool, label: String, iconName: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(DesignSystem.Color.cardBackground)
                .frame(width: 180, height: 90)
            VStack(spacing: DesignSystem.Spacing.xSmall) {
                Image(systemName: iconName)
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.accent)
                Text(label)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
                    .multilineTextAlignment(.center)
            }
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(DesignSystem.Color.accent.opacity(blocking ? 0.55 : 0.15))
                .frame(width: 180, height: 90)
                .allowsHitTesting(blocking)
        }
    }
}

// MARK: - Code generation
private extension AllowsHitTestingShowcase {
    var generatedCode: String {
        """
        decorativeOverlay
            .allowsHitTesting(\(allowsHitTesting))
        """
    }
}
