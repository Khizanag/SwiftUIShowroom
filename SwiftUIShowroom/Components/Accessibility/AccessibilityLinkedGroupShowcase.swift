import SwiftUI

struct AccessibilityLinkedGroupShowcase: View {
    @Namespace private var linkNS
    @State private var groupID = "product-9"

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Linked Group",
            summary: "Links far-apart accessibility elements so users can jump between them via the rotor.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityLinkedGroupShowcase {
    var preview: some View {
        linkedLayout(groupID: groupID, namespace: linkNS)
    }

    @ViewBuilder var controls: some View {
        ShowcaseTextControl("Group ID", text: $groupID, prompt: "e.g. product-9")
    }

    @ViewBuilder func stateView(_ state: LinkedGroupState) -> some View {
        state.makeView()
    }

    func linkedLayout(groupID: String, namespace: Namespace.ID) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.medium) {
            listColumn(groupID: groupID, namespace: namespace)
            detailColumn(groupID: groupID, namespace: namespace)
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    func listColumn(groupID: String, namespace: Namespace.ID) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            columnHeader("List")
            listRow(groupID: groupID, namespace: namespace)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func detailColumn(groupID: String, namespace: Namespace.ID) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            columnHeader("Detail")
            detailCard(groupID: groupID, namespace: namespace)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func columnHeader(_ title: String) -> some View {
        Text(title)
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.secondary)
            .textCase(.uppercase)
    }

    func listRow(groupID: String, namespace: Namespace.ID) -> some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "cube.box")
                .foregroundStyle(DesignSystem.Color.accent)
                .font(DesignSystem.Font.body)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.hairline) {
                Text("Trail Runner Pro")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.primary)
                Text("$149")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
        .padding(DesignSystem.Spacing.small)
        .background(
            DesignSystem.Color.accent.opacity(0.10),
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Trail Runner Pro, $149")
        .accessibilityLinkedGroup(id: groupID, in: namespace)
    }

    func detailCard(groupID: String, namespace: Namespace.ID) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("Trail Runner Pro")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.primary)
            Text("All-terrain shoe. Size 9–13. Available in 4 colors.")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
                .lineLimit(3)
            linkBadge()
        }
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Color.background, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .strokeBorder(DesignSystem.Color.accent.opacity(0.35), lineWidth: 1)
        )
        .accessibilityLinkedGroup(id: groupID, in: namespace)
    }

    func linkBadge() -> some View {
        HStack(spacing: DesignSystem.Spacing.hairline) {
            Image(systemName: "link")
                .font(DesignSystem.Font.caption2)
            Text("linked")
                .font(DesignSystem.Font.caption2)
        }
        .foregroundStyle(DesignSystem.Color.accent)
    }
}

// MARK: - Code generation
private extension AccessibilityLinkedGroupShowcase {
    var generatedCode: String {
        """
        @Namespace private var linkNS

        var body: some View {
            HStack {
                ListColumn()
                    .accessibilityLinkedGroup(id: "\(groupID)", in: linkNS)
                DetailColumn()
                    .accessibilityLinkedGroup(id: "\(groupID)", in: linkNS)
            }
        }
        """
    }
}

// MARK: - Nested types
extension AccessibilityLinkedGroupShowcase {
    fileprivate enum LinkedGroupState: ShowcaseState {
        case linked
        case unlinked

        var caption: String {
            switch self {
            case .linked: "Linked (same id + namespace)"
            case .unlinked: "Unlinked (no modifier)"
            }
        }

        @ViewBuilder func makeView() -> some View {
            switch self {
            case .linked: LinkedGroupState.linkedPreview
            case .unlinked: LinkedGroupState.unlinkedPreview
            }
        }

        private static var linkedPreview: some View {
            LinkedPreviewContainer()
        }

        private static var unlinkedPreview: some View {
            UnlinkedPreviewContainer()
        }
    }
}

// MARK: - State preview helpers
private struct LinkedPreviewContainer: View {
    @Namespace private var stateNS

    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.medium) {
            stateListRow(namespace: stateNS)
            stateDetailCard(namespace: stateNS)
        }
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    private func stateListRow(namespace: Namespace.ID) -> some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: "cube.box")
                .foregroundStyle(DesignSystem.Color.accent)
                .font(DesignSystem.Font.caption)
            Text("Item A")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.primary)
        }
        .padding(DesignSystem.Spacing.xSmall)
        .background(
            DesignSystem.Color.accent.opacity(0.10),
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLinkedGroup(id: "item-a", in: namespace)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func stateDetailCard(namespace: Namespace.ID) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.hairline) {
            Text("Item A — detail")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.primary)
            HStack(spacing: DesignSystem.Spacing.hairline) {
                Image(systemName: "link")
                    .font(DesignSystem.Font.caption2)
                Text("linked")
                    .font(DesignSystem.Font.caption2)
            }
            .foregroundStyle(DesignSystem.Color.accent)
        }
        .padding(DesignSystem.Spacing.xSmall)
        .background(DesignSystem.Color.background, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .strokeBorder(DesignSystem.Color.accent.opacity(0.35), lineWidth: 1)
        )
        .accessibilityLinkedGroup(id: "item-a", in: namespace)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct UnlinkedPreviewContainer: View {
    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.medium) {
            unlinkedRow
            unlinkedDetail
        }
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    private var unlinkedRow: some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: "cube.box")
                .foregroundStyle(DesignSystem.Color.secondary)
                .font(DesignSystem.Font.caption)
            Text("Item A")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.primary)
        }
        .padding(DesignSystem.Spacing.xSmall)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var unlinkedDetail: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.hairline) {
            Text("Item A — detail")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.primary)
            HStack(spacing: DesignSystem.Spacing.hairline) {
                Image(systemName: "link.badge.plus")
                    .font(DesignSystem.Font.caption2)
                Text("no link")
                    .font(DesignSystem.Font.caption2)
            }
            .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(DesignSystem.Spacing.xSmall)
        .background(DesignSystem.Color.background, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .strokeBorder(DesignSystem.Color.separator, lineWidth: 1)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
