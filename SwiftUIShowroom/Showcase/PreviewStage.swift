import SwiftUI

/// The backdrop a live preview can be shown against, so contrast-sensitive
/// components (glass, materials, shadows) read correctly.
enum PreviewBackdrop: String, ShowcaseState {
    case standard
    case dark
    case colorful

    var caption: String {
        switch self {
        case .standard: "Standard"
        case .dark: "Dark"
        case .colorful: "Colorful"
        }
    }
}

/// The hero area at the top of every showcase: the real component, centered on a
/// configurable backdrop, with a stable minimum height so the layout never jumps.
struct PreviewStage<Content: View>: View {
    var backdrop: PreviewBackdrop = .standard
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: DesignSystem.Size.Preview.maxStageWidth)
            .frame(maxWidth: .infinity, minHeight: DesignSystem.Size.Preview.minStageHeight)
            .padding(DesignSystem.Spacing.large)
            .background(background)
            .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.large))
    }
}

// MARK: - Sub-views
private extension PreviewStage {
    @ViewBuilder
    var background: some View {
        switch backdrop {
        case .standard:
            DesignSystem.Color.cardBackground
        case .dark:
            Color.black.opacity(0.9)
        case .colorful:
            LinearGradient(
                colors: [.purple, .blue, .teal],
                startPoint: .topLeading,
                endPoint: .bottomTrailing,
            )
        }
    }
}
