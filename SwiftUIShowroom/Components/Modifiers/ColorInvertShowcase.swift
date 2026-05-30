import SwiftUI

struct ColorInvertShowcase: View {
    @State private var enabled: Bool = false

    var body: some View {
        ShowcaseScreen(
            title: "Color Invert",
            summary: "Inverts each color channel of the view's content.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }

    fileprivate enum InvertState: ShowcaseState {
        case normal
        case inverted

        var caption: String {
            switch self {
            case .normal: return "colorInvert() not applied"
            case .inverted: return "colorInvert() applied"
            }
        }
    }
}

// MARK: - Sub-views
private extension ColorInvertShowcase {
    @ViewBuilder var preview: some View {
        if enabled {
            swatchBase.colorInvert()
        } else {
            swatchBase
        }
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("Invert Colors", isOn: $enabled)
    }

    @ViewBuilder func stateView(_ state: InvertState) -> some View {
        switch state {
        case .normal:
            swatchBase
        case .inverted:
            swatchBase.colorInvert()
        }
    }

    var swatchBase: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "paintpalette.fill")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.accent)
            Text("Color Invert")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.primary)
            Text("Each channel flipped")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(DesignSystem.Spacing.large)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }
}

// MARK: - Code generation
private extension ColorInvertShowcase {
    var generatedCode: String {
        if enabled {
            return "Image(\"photo\")\n    .colorInvert()"
        } else {
            return "Image(\"photo\")\n    // .colorInvert() — currently off"
        }
    }
}
