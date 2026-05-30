import SwiftUI

struct AccessibilityElementChildrenShowcase: View {
    @State private var childBehavior: ChildBehavior = .combine

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Element Children",
            summary: "Merges a subtree into one element or controls how children are exposed to assistive tech.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityElementChildrenShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            ratingCard(behavior: childBehavior)
            behaviorAnnotation
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var behaviorAnnotation: some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: "speaker.wave.2")
                .foregroundStyle(DesignSystem.Color.accent)
                .font(DesignSystem.Font.caption)
            Text(childBehavior.description)
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("children", selection: $childBehavior)
    }

    @ViewBuilder func stateView(_ state: ElementState) -> some View {
        ratingCard(behavior: state.behavior)
    }

    func ratingCard(behavior: ChildBehavior) -> some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "star.fill")
                .foregroundStyle(DesignSystem.Color.accent)
                .font(DesignSystem.Font.headline)
            Text("Top rated")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.primary)
            Spacer()
            Text("4.9")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.accent)
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .accessibilityElement(children: behavior.childBehavior)
    }
}

// MARK: - Code generation
private extension AccessibilityElementChildrenShowcase {
    var generatedCode: String {
        """
        HStack {
            Image(systemName: "star.fill")
            Text("Top rated")
            Text("4.9")
        }
        .accessibilityElement(children: .\(childBehavior.rawValue))
        """
    }
}

// MARK: - Nested types
extension AccessibilityElementChildrenShowcase {
    fileprivate enum ChildBehavior: String, ShowcasePickable {
        case ignore
        case combine
        case contain

        var label: String {
            switch self {
            case .ignore: ".ignore"
            case .combine: ".combine"
            case .contain: ".contain"
            }
        }

        var childBehavior: AccessibilityChildBehavior {
            switch self {
            case .ignore: .ignore
            case .combine: .combine
            case .contain: .contain
            }
        }

        var description: String {
            switch self {
            case .ignore: "Single opaque element — children hidden from VoiceOver"
            case .combine: "Children merged into one swipe stop (labels + actions joined)"
            case .contain: "Children individually navigable inside a container"
            }
        }
    }

    fileprivate enum ElementState: ShowcaseState {
        case `default`
        case longContent

        var caption: String {
            switch self {
            case .default: "combine (card reads as one)"
            case .longContent: "contain (each child navigable)"
            }
        }

        var behavior: ChildBehavior {
            switch self {
            case .default: .combine
            case .longContent: .contain
            }
        }
    }
}
