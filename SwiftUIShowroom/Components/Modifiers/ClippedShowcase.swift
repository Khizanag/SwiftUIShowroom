import SwiftUI

struct ClippedShowcase: View {
    fileprivate enum ClipState: ShowcaseState {
        case `default`
        case longContent

        var caption: String {
            switch self {
            case .default: "Default"
            case .longContent: "Overflow clipped"
            }
        }
    }

    @State private var antialiased: Bool = false

    var body: some View {
        ShowcaseScreen(
            title: "Clipped",
            summary: "Clips a view to its bounding rectangle, hiding content that overflows the frame.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ClippedShowcase {
    var preview: some View {
        clippedSwatch(scale: 1.6, isAntialiased: antialiased)
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("Antialiased", isOn: $antialiased)
    }

    @ViewBuilder func stateView(_ state: ClipState) -> some View {
        switch state {
        case .default:
            clippedSwatch(scale: 1.0, isAntialiased: antialiased)
        case .longContent:
            clippedSwatch(scale: 2.0, isAntialiased: antialiased)
        }
    }

    func clippedSwatch(scale: CGFloat, isAntialiased: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(DesignSystem.Color.accent.opacity(0.15))
                .frame(width: 120, height: 80)
            Circle()
                .fill(DesignSystem.Color.accent)
                .frame(
                    width: 80 * scale,
                    height: 80 * scale,
                )
        }
        .frame(width: 120, height: 80)
        .clipped(antialiased: isAntialiased)
    }
}

// MARK: - Code generation
private extension ClippedShowcase {
    var generatedCode: String {
        """
        Image("photo")
            .resizable()
            .scaledToFill()
            .frame(width: 100, height: 100)
            .clipped(antialiased: \(antialiased))
        """
    }
}
