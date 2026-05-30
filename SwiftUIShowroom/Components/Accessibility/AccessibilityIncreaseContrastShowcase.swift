import SwiftUI

struct AccessibilityIncreaseContrastShowcase: View {
    enum ContrastLevel: ShowcasePickable {
        case standard
        case increased

        var label: String {
            switch self {
            case .standard: return "standard"
            case .increased: return "increased"
            }
        }
    }

    enum ContrastShowcaseState: ShowcaseState {
        case standard
        case increased

        var caption: String {
            switch self {
            case .standard: return "contrast == .standard"
            case .increased: return "contrast == .increased"
            }
        }
    }

    @State private var contrastLevel = ContrastLevel.standard

    var body: some View {
        ShowcaseScreen(
            title: "Increase Contrast",
            summary: "Read-only flag reflecting the user's Increase Contrast accessibility preference.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityIncreaseContrastShowcase {
    var preview: some View {
        let isIncreased = contrastLevel == .increased
        return VStack(spacing: DesignSystem.Spacing.medium) {
            contrastCard(isIncreased: isIncreased)
            contrastBadge(isIncreased: isIncreased)
        }
        .padding(DesignSystem.Spacing.medium)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Contrast Level", selection: $contrastLevel)
    }

    @ViewBuilder func stateView(_ state: ContrastShowcaseState) -> some View {
        switch state {
        case .standard:
            stateCard(isIncreased: false)
        case .increased:
            stateCard(isIncreased: true)
        }
    }

    func contrastCard(isIncreased: Bool) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Text("Label")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(
                    isIncreased ? DesignSystem.Color.primary : DesignSystem.Color.secondary
                )
            Text("Supporting detail text below the label.")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.primary)
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .stroke(
                    isIncreased ? DesignSystem.Color.primary : DesignSystem.Color.separator,
                    lineWidth: isIncreased ? 2 : 0.5,
                )
                .frame(height: 36)
                .overlay {
                    Text("Action")
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.accent)
                }
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    func contrastBadge(isIncreased: Bool) -> some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Circle()
                .fill(isIncreased ? DesignSystem.Color.accent : DesignSystem.Color.secondary.opacity(0.4))
                .frame(width: DesignSystem.Size.Icon.small, height: DesignSystem.Size.Icon.small)
            Text(isIncreased ? "contrast == .increased" : "contrast == .standard")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }

    func stateCard(isIncreased: Bool) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            contrastCard(isIncreased: isIncreased)
            Text(isIncreased ? "Raised foreground, stronger borders applied" : "Default system appearance")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }
}

// MARK: - Code generation
private extension AccessibilityIncreaseContrastShowcase {
    var generatedCode: String {
        let contrastValue = contrastLevel == .increased ? ".increased" : ".standard"
        let foreground = contrastLevel == .increased ? ".primary" : ".secondary"
        let lines = [
            "@Environment(\\.colorSchemeContrast) private var contrast",
            "",
            "var body: some View {",
            "    Text(\"Label\")",
            "        .foregroundStyle(contrast == \(contrastValue) ? \(foreground) : .secondary)",
            "}",
        ]
        return lines.joined(separator: "\n")
    }
}
