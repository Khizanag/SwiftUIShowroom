import SwiftUI

struct SymbolEffectsRemovedShowcase: View {
    @State private var isRemoved: Bool = true

    var body: some View {
        ShowcaseScreen(
            title: "Symbol Effects Removed",
            summary: "Removes inherited symbol effects from a subtree so descendant symbols stay static.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension SymbolEffectsRemovedShowcase {
    fileprivate enum RemovedState: ShowcaseState {
        case inherited
        case removed

        var caption: String {
            switch self {
            case .inherited: "Effects inherited"
            case .removed: "Effects removed"
            }
        }
    }
}

// MARK: - Sub-views
private extension SymbolEffectsRemovedShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.xLarge) {
            HStack(spacing: DesignSystem.Spacing.xxLarge) {
                VStack(spacing: DesignSystem.Spacing.small) {
                    Image(systemName: "bell.fill")
                        .font(DesignSystem.Font.largeTitle)
                        .foregroundStyle(DesignSystem.Color.accent)
                        .symbolEffect(.pulse, options: .repeating)
                    Text("Animated")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.secondary)
                }
                VStack(spacing: DesignSystem.Spacing.small) {
                    Image(systemName: "star.fill")
                        .font(DesignSystem.Font.largeTitle)
                        .foregroundStyle(DesignSystem.Color.accent)
                        .symbolEffect(.pulse, options: .repeating)
                        .symbolEffectsRemoved(isRemoved)
                    Text(isRemoved ? "Static" : "Also animated")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.secondary)
                }
            }
            Text("Parent applies .pulse — the right symbol opts out when isRemoved is true.")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.medium)
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("isRemoved", isOn: $isRemoved)
    }

    @ViewBuilder func stateView(_ state: RemovedState) -> some View {
        let removed = state == .removed
        Image(systemName: "star.fill")
            .font(DesignSystem.Font.title)
            .foregroundStyle(DesignSystem.Color.accent)
            .symbolEffect(.pulse, options: .repeating)
            .symbolEffectsRemoved(removed)
    }
}

// MARK: - Code generation
private extension SymbolEffectsRemovedShowcase {
    var generatedCode: String {
        [
            "Image(systemName: \"star.fill\")",
            "    .symbolEffectsRemoved(\(isRemoved))",
        ].joined(separator: "\n")
    }
}
