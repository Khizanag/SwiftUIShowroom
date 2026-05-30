import SwiftUI

struct AccessibilityInvertColorsShowcase: View {
    @State private var ignoresInvert = true
    @State private var simulateInvertColors = false

    fileprivate enum InvertState: ShowcaseState {
        case exempt
        case inverted
        case normal

        var caption: String {
            switch self {
            case .exempt: return "Smart Invert — exempt"
            case .inverted: return "Smart Invert — affected"
            case .normal: return "Invert Colors off"
            }
        }
    }

    var body: some View {
        ShowcaseScreen(
            title: "Invert Colors Handling",
            summary: "Excludes media from Smart Invert and reports whether Invert Colors is active.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityInvertColorsShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            photoCard(ignoresInvert: ignoresInvert, simulateInvert: simulateInvertColors)
            Text(statusText)
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.medium)
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("Exempt from inversion", isOn: $ignoresInvert)
        ShowcaseToggle("Simulate Invert Colors", isOn: $simulateInvertColors)
    }

    @ViewBuilder func stateView(_ state: InvertState) -> some View {
        switch state {
        case .exempt:
            stateCard(
                label: "ignoresInvert: true",
                description: "Photo stays natural under Smart Invert",
            ) {
                photoCard(ignoresInvert: true, simulateInvert: true)
            }
        case .inverted:
            stateCard(
                label: "ignoresInvert: false",
                description: "Photo inverts with the rest of the UI",
            ) {
                photoCard(ignoresInvert: false, simulateInvert: true)
            }
        case .normal:
            stateCard(
                label: "Invert Colors off",
                description: "No inversion active",
            ) {
                photoCard(ignoresInvert: true, simulateInvert: false)
            }
        }
    }

    var statusText: String {
        if simulateInvertColors && ignoresInvert {
            return "Invert Colors active — photo exempted via accessibilityIgnoresInvertColors"
        } else if simulateInvertColors {
            return "Invert Colors active — photo will be inverted"
        } else {
            return "Invert Colors off — photo renders normally"
        }
    }

    func photoCard(ignoresInvert: Bool, simulateInvert: Bool) -> some View {
        ZStack {
            photoPlaceholder(isInverted: simulateInvert && !ignoresInvert)
                .accessibilityIgnoresInvertColors(ignoresInvert)
            if simulateInvert && ignoresInvert {
                exemptBadge
            }
        }
    }

    func photoPlaceholder(isInverted: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(isInverted ? DesignSystem.Color.accent.opacity(0.15) : Color.orange.opacity(0.15))
                .frame(width: 120, height: 90)
            VStack(spacing: DesignSystem.Spacing.xSmall) {
                Image(systemName: "photo")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(isInverted ? DesignSystem.Color.accent : Color.orange)
                Text("product-photo")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
    }

    var exemptBadge: some View {
        Image(systemName: "checkmark.shield.fill")
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.accent)
            .offset(x: 44, y: -34)
            .accessibilityHidden(true)
    }

    func stateCard<Content: View>(
        label: String,
        description: String,
        @ViewBuilder content: () -> Content,
    ) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            content()
            Text(label)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.primary)
            Text(description)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Code generation
private extension AccessibilityInvertColorsShowcase {
    var generatedCode: String {
        let lines = [
            "Image(\"product-photo\")",
            "    .accessibilityIgnoresInvertColors(\(ignoresInvert))",
        ]
        return lines.joined(separator: "\n")
    }
}
