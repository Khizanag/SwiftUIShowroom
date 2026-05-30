import SwiftUI

struct AccessibilityHeadingShowcase: View {
    enum HeadingLevel: ShowcasePickable {
        case unspecified, level1, level2, level3, level4, level5, level6

        var label: String {
            switch self {
            case .unspecified: "unspecified"
            case .level1: "h1"
            case .level2: "h2"
            case .level3: "h3"
            case .level4: "h4"
            case .level5: "h5"
            case .level6: "h6"
            }
        }

        var headingLevel: AccessibilityHeadingLevel {
            switch self {
            case .unspecified: .unspecified
            case .level1: .h1
            case .level2: .h2
            case .level3: .h3
            case .level4: .h4
            case .level5: .h5
            case .level6: .h6
            }
        }

        var displayFont: Font {
            switch self {
            case .unspecified: DesignSystem.Font.body
            case .level1: DesignSystem.Font.largeTitle
            case .level2: DesignSystem.Font.title
            case .level3: DesignSystem.Font.title2
            case .level4: DesignSystem.Font.title3
            case .level5: DesignSystem.Font.headline
            case .level6: DesignSystem.Font.subheadline
            }
        }
    }

    enum HeadingLevelState: ShowcaseState {
        case pageTitle, sectionTitle, subsectionTitle

        var caption: String {
            switch self {
            case .pageTitle: "h1 — Page title"
            case .sectionTitle: "h2 — Section title"
            case .subsectionTitle: "h3 — Subsection title"
            }
        }

        var sampleText: String {
            switch self {
            case .pageTitle: "Inbox"
            case .sectionTitle: "Today"
            case .subsectionTitle: "Morning"
            }
        }

        var level: HeadingLevel {
            switch self {
            case .pageTitle: .level1
            case .sectionTitle: .level2
            case .subsectionTitle: .level3
            }
        }
    }

    @State private var headingLevel: HeadingLevel = .level1
    @State private var headingText = "Today"

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Heading",
            summary: "Marks an element as a heading so VoiceOver's heading rotor can navigate.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}
// MARK: - Sub-views
private extension AccessibilityHeadingShowcase {
    var preview: some View {
        headingCard(text: headingText, level: headingLevel)
    }

    @ViewBuilder var controls: some View {
        ShowcaseTextControl("Heading text", text: $headingText, prompt: "e.g. Today")
        ShowcasePicker("Level", selection: $headingLevel)
    }

    @ViewBuilder func stateView(_ state: HeadingLevelState) -> some View {
        headingCard(text: state.sampleText, level: state.level)
    }

    func headingCard(text: String, level: HeadingLevel) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text(text)
                .font(level.displayFont)
                .foregroundStyle(DesignSystem.Color.primary)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(level.headingLevel)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: DesignSystem.Spacing.xSmall) {
                Image(systemName: "text.alignleft")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.accent)
                Text(".\(level.label)")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}
// MARK: - Code generation
private extension AccessibilityHeadingShowcase {
    var generatedCode: String {
        """
        Text("\(headingText)")
            .accessibilityAddTraits(.isHeader)
            .accessibilityHeading(.\(headingLevel.label))
        """
    }
}
