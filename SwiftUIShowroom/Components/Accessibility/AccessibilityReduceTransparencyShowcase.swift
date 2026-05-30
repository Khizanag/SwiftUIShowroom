import SwiftUI

struct AccessibilityReduceTransparencyShowcase: View {
    @State private var reduceTransparency = false

    enum TransparencyState: ShowcaseState {
        case standard
        case reduced

        var caption: String {
            switch self {
            case .standard: return "Standard (material)"
            case .reduced: return "Reduce Transparency on"
            }
        }

        var reduceTransparency: Bool {
            switch self {
            case .standard: return false
            case .reduced: return true
            }
        }
    }

    var body: some View {
        ShowcaseScreen(
            title: "Reduce Transparency",
            summary: "Read-only flag: user prefers opaque backgrounds over translucent materials.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityReduceTransparencyShowcase {
    var preview: some View {
        AdaptiveCard(reduceTransparency: reduceTransparency)
            .padding(DesignSystem.Spacing.medium)
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("reduceTransparency", isOn: $reduceTransparency)
    }

    @ViewBuilder func stateView(_ state: TransparencyState) -> some View {
        AdaptiveCard(reduceTransparency: state.reduceTransparency)
            .padding(DesignSystem.Spacing.medium)
    }
}

// MARK: - Code generation
private extension AccessibilityReduceTransparencyShowcase {
    var generatedCode: String {
        [
            "@Environment(\\.accessibilityReduceTransparency) private var reduceTransparency",
            "",
            "var body: some View {",
            "    content",
            "        .background(",
            "            reduceTransparency",
            "                ? AnyShapeStyle(.background)",
            "                : AnyShapeStyle(.ultraThinMaterial)",
            "        )",
            "}",
        ].joined(separator: "\n")
    }
}

// MARK: - AdaptiveCard
private struct AdaptiveCard: View {
    let reduceTransparency: Bool

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: "eye.trianglebadge.exclamationmark")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(
                    width: DesignSystem.Size.Icon.large,
                    height: DesignSystem.Size.Icon.large,
                )
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                Text("Notification")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.primary)
                Text(reduceTransparency ? "Solid background" : "Translucent material")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
            Spacer()
        }
        .padding(DesignSystem.Spacing.medium)
        .background(backgroundStyle)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .strokeBorder(DesignSystem.Color.separator, lineWidth: 1),
        )
    }

    @ViewBuilder private var backgroundStyle: some View {
        if reduceTransparency {
            DesignSystem.Color.cardBackground
        } else {
            Color.clear.background(.ultraThinMaterial)
        }
    }
}
