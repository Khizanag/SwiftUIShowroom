import SwiftUI

struct AccessibilityTraitsShowcase: View {
    @State private var addedTrait: AddedTrait = .isButton
    @State private var removedTrait: RemovedTrait = .isImage

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Traits",
            summary: "Describes how an element behaves so assistive tech speaks the right role.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityTraitsShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            Text("Section Title")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.primary)
                .accessibilityAddTraits(addedTrait.trait)
                .accessibilityRemoveTraits(removedTrait.trait)
            VStack(spacing: DesignSystem.Spacing.xSmall) {
                traitBadge(label: "Adds: .\(addedTrait.label)", color: DesignSystem.Color.accent)
                traitBadge(label: "Removes: .\(removedTrait.label)", color: DesignSystem.Color.secondary)
            }
        }
        .padding(DesignSystem.Spacing.medium)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Added trait", selection: $addedTrait)
        ShowcasePicker("Removed trait", selection: $removedTrait)
    }

    @ViewBuilder func stateView(_ state: TraitState) -> some View {
        traitCard(
            label: state.elementLabel,
            addedTraits: state.added,
            removedTraits: state.removed,
            annotation: state.annotation,
        )
    }

    func traitBadge(label: String, color: Color) -> some View {
        Text(label)
            .font(DesignSystem.Font.caption)
            .foregroundStyle(color)
            .padding(.horizontal, DesignSystem.Spacing.small)
            .padding(.vertical, DesignSystem.Spacing.hairline)
            .background(color.opacity(0.12), in: Capsule())
    }

    func traitCard(
        label: String,
        addedTraits: AccessibilityTraits,
        removedTraits: AccessibilityTraits,
        annotation: String,
    ) -> some View {
        VStack(spacing: DesignSystem.Spacing.xSmall) {
            Text(label)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.primary)
                .accessibilityAddTraits(addedTraits)
                .accessibilityRemoveTraits(removedTraits)
            Text(annotation)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.small)
    }
}

// MARK: - Code generation
private extension AccessibilityTraitsShowcase {
    var generatedCode: String {
        """
        Text("Section Title")
            .accessibilityAddTraits(.\(addedTrait.label))
            .accessibilityRemoveTraits(.\(removedTrait.label))
        """
    }
}

// MARK: - Nested types
extension AccessibilityTraitsShowcase {
    fileprivate enum AddedTrait: ShowcasePickable {
        case isButton
        case isHeader
        case isLink
        case isImage
        case isSelected
        case isStaticText
        case isSearchField
        case isKeyboardKey
        case isToggle
        case isSummaryElement
        case updatesFrequently
        case allowsDirectInteraction
        case causesPageTurn

        var label: String {
            switch self {
            case .isButton: "isButton"
            case .isHeader: "isHeader"
            case .isLink: "isLink"
            case .isImage: "isImage"
            case .isSelected: "isSelected"
            case .isStaticText: "isStaticText"
            case .isSearchField: "isSearchField"
            case .isKeyboardKey: "isKeyboardKey"
            case .isToggle: "isToggle"
            case .isSummaryElement: "isSummaryElement"
            case .updatesFrequently: "updatesFrequently"
            case .allowsDirectInteraction: "allowsDirectInteraction"
            case .causesPageTurn: "causesPageTurn"
            }
        }

        var trait: AccessibilityTraits {
            switch self {
            case .isButton: .isButton
            case .isHeader: .isHeader
            case .isLink: .isLink
            case .isImage: .isImage
            case .isSelected: .isSelected
            case .isStaticText: .isStaticText
            case .isSearchField: .isSearchField
            case .isKeyboardKey: .isKeyboardKey
            case .isToggle: .isToggle
            case .isSummaryElement: .isSummaryElement
            case .updatesFrequently: .updatesFrequently
            case .allowsDirectInteraction: .allowsDirectInteraction
            case .causesPageTurn: .causesPageTurn
            }
        }
    }

    fileprivate enum RemovedTrait: ShowcasePickable {
        case isButton
        case isImage
        case isSelected
        case isStaticText
        case updatesFrequently

        var label: String {
            switch self {
            case .isButton: "isButton"
            case .isImage: "isImage"
            case .isSelected: "isSelected"
            case .isStaticText: "isStaticText"
            case .updatesFrequently: "updatesFrequently"
            }
        }

        var trait: AccessibilityTraits {
            switch self {
            case .isButton: .isButton
            case .isImage: .isImage
            case .isSelected: .isSelected
            case .isStaticText: .isStaticText
            case .updatesFrequently: .updatesFrequently
            }
        }
    }

    fileprivate enum TraitState: ShowcaseState {
        case `default`
        case selected

        var caption: String {
            switch self {
            case .default: "Default (isButton)"
            case .selected: "Selected (isSelected)"
            }
        }

        var elementLabel: String {
            switch self {
            case .default: "Section Title"
            case .selected: "Active Tab"
            }
        }

        var added: AccessibilityTraits {
            switch self {
            case .default: .isHeader
            case .selected: [.isButton, .isSelected]
            }
        }

        var removed: AccessibilityTraits {
            switch self {
            case .default: .isImage
            case .selected: []
            }
        }

        var annotation: String {
            switch self {
            case .default: "Adds .isHeader\nRemoves .isImage"
            case .selected: "Adds .isButton, .isSelected"
            }
        }
    }
}
