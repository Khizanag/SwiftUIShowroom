import SwiftUI

struct BackgroundExtensionEffectShowcase: View {
    @State private var isEnabled = true

    var body: some View {
        ShowcaseScreen(
            title: "Background Extension Effect",
            summary: "Mirrors and blurs a view into surrounding safe-area regions for an immersive backdrop.",
        ) {
            PreviewStage(backdrop: .colorful) {
                preview
            }
            ShowcaseSection("Configuration") {
                controls
            }
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
private extension BackgroundExtensionEffectShowcase {
    var preview: some View {
        sampleBanner(effectEnabled: isEnabled)
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("isEnabled", isOn: $isEnabled)
    }

    @ViewBuilder func stateView(_ state: EnabledState) -> some View {
        sampleBanner(effectEnabled: state == .enabled)
    }

    func sampleBanner(effectEnabled: Bool) -> some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .fill(
                    LinearGradient(
                        colors: [.indigo, .purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing,
                    )
                )
                .frame(height: 120)
                .backgroundExtensionEffect(isEnabled: effectEnabled)

            Text(effectEnabled ? "Effect On" : "Effect Off")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(.white)
                .padding(.bottom, DesignSystem.Spacing.small)
        }
        .frame(maxWidth: .infinity)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.large))
    }
}

// MARK: - Code generation
private extension BackgroundExtensionEffectShowcase {
    var generatedCode: String {
        """
        Image("banner")
            .resizable()
            .scaledToFill()
            .backgroundExtensionEffect(isEnabled: \(isEnabled))
        """
    }
}
