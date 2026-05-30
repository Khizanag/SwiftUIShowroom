import SwiftUI

struct AccessibilityDifferentiateWithoutColorShowcase: View {
    @State private var differentiate = false

    var body: some View {
        ShowcaseScreen(
            title: "Differentiate Without Color",
            summary: "Flag indicating the user needs shapes or icons — not just color — to distinguish meaning.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityDifferentiateWithoutColorShowcase {
    var preview: some View {
        statusRow(
            status: "Payment approved",
            isValid: true,
            differentiate: differentiate,
        )
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("differentiateWithoutColor", isOn: $differentiate)
    }

    @ViewBuilder func stateView(_ state: DifferentiateState) -> some View {
        statusRow(
            status: state.statusText,
            isValid: state.isValid,
            differentiate: state.forceDifferentiate,
        )
    }

    @ViewBuilder func statusRow(
        status: String,
        isValid: Bool,
        differentiate: Bool,
    ) -> some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            if differentiate {
                Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(DesignSystem.Font.body)
            }
            Text(status)
                .font(DesignSystem.Font.body)
        }
        .foregroundStyle(isValid ? Color.green : Color.red)
        .padding(DesignSystem.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(DesignSystem.Color.cardBackground)
        )
    }
}

// MARK: - Code generation
private extension AccessibilityDifferentiateWithoutColorShowcase {
    var generatedCode: String {
        """
        @Environment(\\.accessibilityDifferentiateWithoutColor) private var differentiate

        var body: some View {
            HStack {
                if differentiate { Image(systemName: isValid ? "checkmark.circle" : "xmark.circle") }
                Text(status)
            }
            .foregroundStyle(isValid ? .green : .red)
        }
        """
    }
}

// MARK: - Nested types
extension AccessibilityDifferentiateWithoutColorShowcase {
    fileprivate enum DifferentiateState: ShowcaseState {
        case `default`
        case error
        case selected

        var caption: String {
            switch self {
            case .default: "Default (color only)"
            case .error: "Error with glyph"
            case .selected: "Selected with glyph"
            }
        }

        var statusText: String {
            switch self {
            case .default: "Color only — no glyph"
            case .error: "Payment declined"
            case .selected: "Payment approved"
            }
        }

        var isValid: Bool {
            switch self {
            case .default: true
            case .error: false
            case .selected: true
            }
        }

        var forceDifferentiate: Bool {
            switch self {
            case .default: false
            case .error, .selected: true
            }
        }
    }
}
