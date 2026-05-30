import SwiftUI

struct AccessibilityLabeledPairShowcase: View {
    enum PairRole: ShowcasePickable {
        case both
        case labelOnly
        case contentOnly

        var label: String {
            switch self {
            case .both: "Both sides paired"
            case .labelOnly: "Label side only"
            case .contentOnly: "Content side only"
            }
        }
    }

    enum PairedState: ShowcaseState {
        case singlePair
        case multiPair

        var caption: String {
            switch self {
            case .singlePair: "Single label–content pair"
            case .multiPair: "Multiple pairs in one namespace"
            }
        }
    }

    @Namespace private var pairNamespace
    @State private var pairID = "price"
    @State private var selectedRole: PairRole = .both

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Labeled Pair",
            summary: "Associates a label view with its content so VoiceOver reads them as a pair.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityLabeledPairShowcase {
    var preview: some View {
        pairGrid(
            pairID: resolvedID,
            namespace: pairNamespace,
            role: selectedRole,
        )
    }

    @ViewBuilder var controls: some View {
        ShowcaseTextControl("Pair ID", text: $pairID, prompt: "price")
        ShowcasePicker("Role applied", selection: $selectedRole)
    }

    @ViewBuilder func stateView(_ state: PairedState) -> some View {
        StatePairView(state: state)
    }
}

// MARK: - Helpers
private extension AccessibilityLabeledPairShowcase {
    var resolvedID: String {
        pairID.isEmpty ? "price" : pairID
    }

    func pairGrid(
        pairID: String,
        namespace: Namespace.ID,
        role: PairRole,
    ) -> some View {
        Grid(horizontalSpacing: DesignSystem.Spacing.large, verticalSpacing: DesignSystem.Spacing.medium) {
            GridRow {
                labelCell(pairID: pairID, namespace: namespace, role: role)
                contentCell(pairID: pairID, namespace: namespace, role: role)
            }
            GridRow {
                Text("Label view")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
                Text("Content view")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
        .padding(DesignSystem.Spacing.medium)
    }

    func labelCell(
        pairID: String,
        namespace: Namespace.ID,
        role: PairRole,
    ) -> some View {
        Text("Price")
            .font(DesignSystem.Font.headline)
            .foregroundStyle(DesignSystem.Color.primary)
            .padding(DesignSystem.Spacing.small)
            .background(
                DesignSystem.Color.cardBackground,
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
            )
            .applyLabelPair(role: role, pairID: pairID, namespace: namespace, side: .label)
    }

    func contentCell(
        pairID: String,
        namespace: Namespace.ID,
        role: PairRole,
    ) -> some View {
        Text("$9.99")
            .font(DesignSystem.Font.headline)
            .foregroundStyle(DesignSystem.Color.accent)
            .padding(DesignSystem.Spacing.small)
            .background(
                DesignSystem.Color.cardBackground,
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
            )
            .applyLabelPair(role: role, pairID: pairID, namespace: namespace, side: .content)
    }
}

// MARK: - Code generation
private extension AccessibilityLabeledPairShowcase {
    var generatedCode: String {
        let idLit = resolvedID
        return """
        @Namespace private var pairNS

        var body: some View {
            Grid {
                GridRow {
                    Text("Price")
                        .accessibilityLabeledPair(role: .label, id: "\(idLit)", in: pairNS)
                    Text("$9.99")
                        .accessibilityLabeledPair(role: .content, id: "\(idLit)", in: pairNS)
                }
            }
        }
        """
    }
}

// MARK: - applyLabelPair
private extension View {
    @ViewBuilder func applyLabelPair(
        role: AccessibilityLabeledPairShowcase.PairRole,
        pairID: String,
        namespace: Namespace.ID,
        side: AccessibilityLabeledPairRole,
    ) -> some View {
        switch role {
        case .both:
            self.accessibilityLabeledPair(role: side, id: pairID, in: namespace)
        case .labelOnly:
            if side == .label {
                self.accessibilityLabeledPair(role: side, id: pairID, in: namespace)
            } else {
                self
            }
        case .contentOnly:
            if side == .content {
                self.accessibilityLabeledPair(role: side, id: pairID, in: namespace)
            } else {
                self
            }
        }
    }
}

// MARK: - StatePairView
private struct StatePairView: View {
    @Namespace private var stateNamespace
    let state: AccessibilityLabeledPairShowcase.PairedState

    var body: some View {
        switch state {
        case .singlePair:
            singlePairContent
        case .multiPair:
            multiPairContent
        }
    }

    private var singlePairContent: some View {
        Grid(
            horizontalSpacing: DesignSystem.Spacing.large,
            verticalSpacing: DesignSystem.Spacing.xSmall,
        ) {
            GridRow {
                Text("Price")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.primary)
                    .accessibilityLabeledPair(role: .label, id: "price", in: stateNamespace)
                Text("$9.99")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .accessibilityLabeledPair(role: .content, id: "price", in: stateNamespace)
            }
        }
        .padding(DesignSystem.Spacing.small)
    }

    private var multiPairContent: some View {
        Grid(
            horizontalSpacing: DesignSystem.Spacing.large,
            verticalSpacing: DesignSystem.Spacing.xSmall,
        ) {
            GridRow {
                Text("Price")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.primary)
                    .accessibilityLabeledPair(role: .label, id: "price", in: stateNamespace)
                Text("$9.99")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .accessibilityLabeledPair(role: .content, id: "price", in: stateNamespace)
            }
            GridRow {
                Text("Quantity")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.primary)
                    .accessibilityLabeledPair(role: .label, id: "quantity", in: stateNamespace)
                Text("2 items")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.secondary)
                    .accessibilityLabeledPair(role: .content, id: "quantity", in: stateNamespace)
            }
        }
        .padding(DesignSystem.Spacing.small)
    }
}
