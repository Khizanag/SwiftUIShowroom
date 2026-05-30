import SwiftUI

struct HiddenShowcase: View {
    enum VisibilityState: ShowcaseState {
        case visible
        case hidden

        var caption: String {
            switch self {
            case .visible: "Visible"
            case .hidden: "Hidden"
            }
        }
    }

    @State private var isHidden: Bool = true

    var body: some View {
        ShowcaseScreen(
            title: "Hidden",
            summary: "Hides the view while keeping it in the layout — it still occupies space but is not drawn.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension HiddenShowcase {
    var preview: some View {
        iconRow(middleHidden: isHidden)
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("Hidden", isOn: $isHidden)
    }

    @ViewBuilder func stateView(_ state: VisibilityState) -> some View {
        switch state {
        case .visible:
            iconRow(middleHidden: false)
        case .hidden:
            iconRow(middleHidden: true)
        }
    }

    func iconRow(middleHidden: Bool) -> some View {
        HStack(spacing: DesignSystem.Spacing.large) {
            circleIcon(systemName: "a.circle.fill", color: DesignSystem.Color.accent)
            middleIcon(hidden: middleHidden)
            circleIcon(systemName: "c.circle.fill", color: .green)
        }
        .padding(DesignSystem.Spacing.large)
        .background(DesignSystem.Color.cardBackground, in: RoundedRectangle(
            cornerRadius: DesignSystem.CornerRadius.medium
        ))
    }

    @ViewBuilder func middleIcon(hidden: Bool) -> some View {
        if hidden {
            circleIcon(systemName: "b.circle.fill", color: .orange)
                .hidden()
        } else {
            circleIcon(systemName: "b.circle.fill", color: .orange)
        }
    }

    func circleIcon(systemName: String, color: Color) -> some View {
        Image(systemName: systemName)
            .font(DesignSystem.Font.largeTitle)
            .foregroundStyle(color)
    }
}

// MARK: - Code generation
private extension HiddenShowcase {
    var generatedCode: String {
        if isHidden {
            return """
            HStack {
                Image(systemName: \"a.circle.fill\")
                Image(systemName: \"b.circle.fill\")
                    .hidden()
                Image(systemName: \"c.circle.fill\")
            }
            """
        } else {
            return """
            HStack {
                Image(systemName: \"a.circle.fill\")
                Image(systemName: \"b.circle.fill\")
                Image(systemName: \"c.circle.fill\")
            }
            """
        }
    }
}
