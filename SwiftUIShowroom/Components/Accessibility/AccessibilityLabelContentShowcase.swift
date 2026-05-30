import SwiftUI

struct AccessibilityLabelContentShowcase: View {
    @State private var contentVariant: ContentVariant = .composedText

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Label Builder",
            summary: "Builds an element's spoken label from views instead of a string literal.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityLabelContentShowcase {
    var preview: some View {
        labeledRating(variant: contentVariant)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Label content", selection: $contentVariant)
    }

    @ViewBuilder func stateView(_ state: LabelContentState) -> some View {
        labeledRating(variant: state.variant)
    }

    func labeledRating(variant: ContentVariant) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            ratingView(variant: variant)
            Text("VoiceOver speaks: \"\(variant.spokenLabel)\"")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.medium)
    }

    func ratingView(variant: ContentVariant) -> some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: "star.fill")
                .foregroundStyle(DesignSystem.Color.accent)
                .font(DesignSystem.Font.title3)
            Text("4 of 5 stars")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.primary)
        }
        .padding(.horizontal, DesignSystem.Spacing.medium)
        .padding(.vertical, DesignSystem.Spacing.small)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .modifier(LabelContentModifier(variant: variant))
    }
}

// MARK: - Code generation
private extension AccessibilityLabelContentShowcase {
    var generatedCode: String {
        switch contentVariant {
        case .composedText:
            return """
            RatingView(stars: 4)
                .accessibilityLabel {
                    Text("Rating")
                    Text("4 of 5 stars")
                }
            """
        case .textWithSymbol:
            return """
            RatingView(stars: 4)
                .accessibilityLabel {
                    Image(systemName: "star.fill")
                        .accessibilityLabel("Star")
                    Text("4 out of 5")
                }
            """
        case .concatenated:
            return """
            RatingView(stars: 4)
                .accessibilityLabel {
                    Text("Rating:")
                    Text("\\(stars)")
                    Text("out of 5")
                }
            """
        }
    }
}

// MARK: - ViewModifier
private struct LabelContentModifier: ViewModifier {
    let variant: AccessibilityLabelContentShowcase.ContentVariant

    func body(content: Content) -> some View {
        switch variant {
        case .composedText:
            content.accessibilityLabel(Text("Rating, 4 of 5 stars"))
        case .textWithSymbol:
            content.accessibilityLabel(Text("Star, 4 out of 5"))
        case .concatenated:
            content.accessibilityLabel(Text("Rating: 4 out of 5"))
        }
    }
}

// MARK: - Nested types
extension AccessibilityLabelContentShowcase {
    fileprivate enum ContentVariant: ShowcasePickable {
        case composedText
        case textWithSymbol
        case concatenated

        var label: String {
            switch self {
            case .composedText: "Composed Text"
            case .textWithSymbol: "Text + symbol description"
            case .concatenated: "Concatenated labels"
            }
        }

        var spokenLabel: String {
            switch self {
            case .composedText: "Rating, 4 of 5 stars"
            case .textWithSymbol: "Star, 4 out of 5"
            case .concatenated: "Rating:, 4, out of 5"
            }
        }
    }

    fileprivate enum LabelContentState: ShowcaseState {
        case composedText
        case textWithSymbol
        case concatenated

        var caption: String {
            switch self {
            case .composedText: "Composed Text views"
            case .textWithSymbol: "Text + symbol description"
            case .concatenated: "Concatenated labels"
            }
        }

        var variant: ContentVariant {
            switch self {
            case .composedText: .composedText
            case .textWithSymbol: .textWithSymbol
            case .concatenated: .concatenated
            }
        }
    }
}
