import SwiftUI

struct FixedSizeShowcase: View {
    enum ContentState: ShowcaseState {
        case `default`
        case longContent
        var caption: String {
            switch self {
            case .default: "Default"
            case .longContent: "Long content"
            }
        }
    }

    @State private var horizontal: Bool = true
    @State private var vertical: Bool = false

    var body: some View {
        ShowcaseScreen(
            title: "Fixed Size",
            summary: "Fixes a view at its ideal size on chosen axes, overriding the parent's proposed size.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}
// MARK: - Sub-views
private extension FixedSizeShowcase {
    var preview: some View {
        demoText(long: false)
            .fixedSize(horizontal: horizontal, vertical: vertical)
            .padding(DesignSystem.Spacing.medium)
            .background(
                DesignSystem.Color.cardBackground,
                in: .rect(cornerRadius: DesignSystem.CornerRadius.medium),
            )
            .frame(maxWidth: 280)
    }
    @ViewBuilder var controls: some View {
        ShowcaseToggle("Horizontal", isOn: $horizontal)
        ShowcaseToggle("Vertical", isOn: $vertical)
    }
    @ViewBuilder func stateView(_ state: ContentState) -> some View {
        switch state {
        case .default:
            demoText(long: false)
                .fixedSize(horizontal: horizontal, vertical: vertical)
                .padding(DesignSystem.Spacing.small)
                .background(
                    DesignSystem.Color.cardBackground,
                    in: .rect(cornerRadius: DesignSystem.CornerRadius.small),
                )
                .frame(maxWidth: 200)
        case .longContent:
            demoText(long: true)
                .fixedSize(horizontal: horizontal, vertical: vertical)
                .padding(DesignSystem.Spacing.small)
                .background(
                    DesignSystem.Color.cardBackground,
                    in: .rect(cornerRadius: DesignSystem.CornerRadius.small),
                )
                .frame(maxWidth: 200)
        }
    }
    func demoText(long: Bool) -> some View {
        Text(long
            ? "A very long line of text that would otherwise truncate inside its container"
            : "Sample text")
            .font(DesignSystem.Font.body)
            .foregroundStyle(DesignSystem.Color.primary)
    }
}
// MARK: - Code generation
private extension FixedSizeShowcase {
    var generatedCode: String {
        """
        Text("A very long line of text that would otherwise truncate")
            .fixedSize(horizontal: \(horizontal), vertical: \(vertical))
        """
    }
}
