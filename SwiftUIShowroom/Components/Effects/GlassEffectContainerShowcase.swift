import SwiftUI

struct GlassEffectContainerShowcase: View {
    enum ContainerState: ShowcaseState {
        case `default`
        case longContent

        var caption: String {
            switch self {
            case .default: "Default (3 items)"
            case .longContent: "Long content (6 items)"
            }
        }
    }

    @State private var spacing: Double = 20

    var body: some View {
        ShowcaseScreen(
            title: "Glass Effect Container",
            summary: "Groups glass shapes so they render together and morph/blend into one another.",
        ) {
            PreviewStage(backdrop: .colorful) { preview }
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
private extension GlassEffectContainerShowcase {
    var preview: some View {
        containerView(itemCount: 3, spacing: spacing)
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseSlider("Spacing", value: $spacing, in: 0...80, step: 1)
    }

    @ViewBuilder
    func stateView(_ state: ContainerState) -> some View {
        switch state {
        case .default:
            containerView(itemCount: 3, spacing: spacing)
        case .longContent:
            containerView(itemCount: 6, spacing: spacing)
        }
    }

    func containerView(itemCount: Int, spacing: Double) -> some View {
        let icons = ["star.fill", "heart.fill", "bolt.fill", "moon.fill", "sun.max.fill", "bell.fill"]
        return GlassEffectContainer(spacing: spacing) {
            HStack(spacing: 0) {
                ForEach(0..<itemCount, id: \.self) { index in
                    Image(systemName: icons[index % icons.count])
                        .font(DesignSystem.Font.title2)
                        .padding(DesignSystem.Spacing.medium)
                        .glassEffect()
                }
            }
        }
    }
}

// MARK: - Code generation
private extension GlassEffectContainerShowcase {
    var generatedCode: String {
        let spacingValue = Int(spacing)
        return """
        GlassEffectContainer(spacing: \(spacingValue)) {
            HStack {
                Image(systemName: "star.fill").padding().glassEffect()
                Image(systemName: "heart.fill").padding().glassEffect()
            }
        }
        """
    }
}
