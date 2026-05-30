import SwiftUI

struct AccessibilityLabelShowcase: View {
    @State private var labelText = "Favorite"
    @State private var labelEnabled = true
    @State private var targetContent: TargetContent = .iconButton

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Label",
            summary: "Overrides the short, localized name VoiceOver reads for an element.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityLabelShowcase {
    var preview: some View {
        labeledContent(
            label: labelText,
            labelEnabled: labelEnabled,
            target: targetContent,
        )
    }

    @ViewBuilder var controls: some View {
        ShowcaseTextControl("Label", text: $labelText)
        ShowcaseToggle("Apply label", isOn: $labelEnabled)
        ShowcasePicker("Target content", selection: $targetContent)
    }

    @ViewBuilder func stateView(_ state: LabelState) -> some View {
        labeledContent(
            label: state.label,
            labelEnabled: state.labelEnabled,
            target: .iconButton,
        )
    }

    @ViewBuilder func labeledContent(
        label: String,
        labelEnabled: Bool,
        target: TargetContent,
    ) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            targetView(target, label: label, labelEnabled: labelEnabled)
            Text(labelEnabled ? "Label: \"\(label)\"" : "Label: inferred")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(DesignSystem.Spacing.medium)
    }

    @ViewBuilder func targetView(
        _ target: TargetContent,
        label: String,
        labelEnabled: Bool,
    ) -> some View {
        switch target {
        case .iconButton:
            iconButton(label: label, labelEnabled: labelEnabled)
        case .decorativeImage:
            decorativeImage(label: label, labelEnabled: labelEnabled)
        case .textGlyph:
            textGlyph(label: label, labelEnabled: labelEnabled)
        case .chart:
            chartBar(label: label, labelEnabled: labelEnabled)
        }
    }

    @ViewBuilder func iconButton(label: String, labelEnabled: Bool) -> some View {
        Button {
        } label: {
            Image(systemName: "heart.fill")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.accent)
        }
        .buttonStyle(.plain)
        .modifier(ConditionalAccessibilityLabel(label: label, apply: labelEnabled))
    }

    @ViewBuilder func decorativeImage(label: String, labelEnabled: Bool) -> some View {
        Image(systemName: "photo.fill")
            .font(DesignSystem.Font.title2)
            .foregroundStyle(DesignSystem.Color.secondary)
            .modifier(ConditionalAccessibilityLabel(label: label, apply: labelEnabled))
    }

    @ViewBuilder func textGlyph(label: String, labelEnabled: Bool) -> some View {
        Text("★★★★☆")
            .font(DesignSystem.Font.title2)
            .modifier(ConditionalAccessibilityLabel(label: label, apply: labelEnabled))
    }

    @ViewBuilder func chartBar(label: String, labelEnabled: Bool) -> some View {
        chartBars
            .modifier(ConditionalAccessibilityLabel(label: label, apply: labelEnabled))
    }

    var chartBars: some View {
        HStack(alignment: .bottom, spacing: DesignSystem.Spacing.xSmall) {
            ForEach([0.4, 0.7, 0.5, 0.9, 0.6], id: \.self) { fraction in
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .fill(DesignSystem.Color.accent)
                    .frame(width: 14, height: 60 * fraction)
            }
        }
        .frame(height: 60)
    }
}

// MARK: - Code generation
private extension AccessibilityLabelShowcase {
    var generatedCode: String {
        if labelEnabled {
            return """
            Image(systemName: "heart.fill")
                .accessibilityLabel("\(labelText)")
            """
        } else {
            return """
            Image(systemName: "heart.fill")
                // No .accessibilityLabel — system infers from content
            """
        }
    }
}

// MARK: - Modifier
private struct ConditionalAccessibilityLabel: ViewModifier {
    let label: String
    let apply: Bool

    func body(content: Content) -> some View {
        if apply {
            content.accessibilityLabel(label)
        } else {
            content
        }
    }
}

// MARK: - Nested types
extension AccessibilityLabelShowcase {
    fileprivate enum TargetContent: ShowcasePickable {
        case iconButton
        case decorativeImage
        case textGlyph
        case chart

        var label: String {
            switch self {
            case .iconButton: "Icon-only button"
            case .decorativeImage: "Decorative image"
            case .textGlyph: "Text glyph"
            case .chart: "Chart"
            }
        }
    }

    fileprivate enum LabelState: ShowcaseState {
        case `default`
        case labelOff
        case longLabel

        var caption: String {
            switch self {
            case .default: "Default"
            case .labelOff: "No custom label"
            case .longLabel: "Long label"
            }
        }

        var label: String {
            switch self {
            case .default: "Favorite"
            case .labelOff: "Favorite"
            case .longLabel: "Add this item to your favorites list"
            }
        }

        var labelEnabled: Bool {
            switch self {
            case .default, .longLabel: true
            case .labelOff: false
            }
        }
    }
}
