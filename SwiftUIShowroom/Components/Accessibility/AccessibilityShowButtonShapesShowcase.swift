import SwiftUI

struct AccessibilityShowButtonShapesShowcase: View {
    enum ButtonShapesState: ShowcaseState {
        case shapesOff
        case shapesOn

        var caption: String {
            switch self {
            case .shapesOff: "Button Shapes off"
            case .shapesOn: "Button Shapes on"
            }
        }

        var showShapes: Bool {
            switch self {
            case .shapesOff: false
            case .shapesOn: true
            }
        }
    }

    @State private var showButtonShapes = false

    var body: some View {
        ShowcaseScreen(
            title: "Button Shapes / On-Off Labels",
            summary: "Read-only flag indicating the user wants visible shapes around tappable buttons.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityShowButtonShapesShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            buttonRow(showShapes: showButtonShapes)
            statusBadge(showShapes: showButtonShapes)
        }
        .padding(DesignSystem.Spacing.medium)
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("showButtonShapes (simulated)", isOn: $showButtonShapes)
    }

    @ViewBuilder func stateView(_ state: ButtonShapesState) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            buttonRow(showShapes: state.showShapes)
            statusBadge(showShapes: state.showShapes)
        }
        .padding(DesignSystem.Spacing.medium)
    }

    func buttonRow(showShapes: Bool) -> some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            plainButton(label: "Skip", showShapes: showShapes)
            plainButton(label: "Learn more", showShapes: showShapes)
            plainButton(label: "Cancel", showShapes: showShapes)
        }
    }

    func plainButton(label: String, showShapes: Bool) -> some View {
        Button(label) { }
            .font(DesignSystem.Font.callout)
            .foregroundStyle(DesignSystem.Color.accent)
            .padding(.horizontal, DesignSystem.Spacing.small)
            .padding(.vertical, DesignSystem.Spacing.xSmall)
            .background(
                showShapes
                    ? AnyShapeStyle(.quaternary)
                    : AnyShapeStyle(.clear),
                in: .capsule,
            )
            .buttonStyle(.plain)
    }

    func statusBadge(showShapes: Bool) -> some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: showShapes ? "rectangle.dashed" : "rectangle")
                .foregroundStyle(DesignSystem.Color.accent)
                .font(DesignSystem.Font.caption)
            Text(showShapes ? "Button shapes: on" : "Button shapes: off")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }
}

// MARK: - Code generation
private extension AccessibilityShowButtonShapesShowcase {
    var generatedCode: String {
        """
        @Environment(\\.accessibilityShowButtonShapes) private var showShapes

        var body: some View {
            Button("Skip") { }
                .background(
                    showShapes
                        ? AnyShapeStyle(.quaternary)
                        : AnyShapeStyle(.clear),
                    in: .capsule,
                )
        }
        """
    }
}
