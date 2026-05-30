import Accessibility
import SwiftUI

struct AccessibilityCustomContentShowcase: View {
    enum ImportancePick: ShowcasePickable {
        case `default`
        case high

        var label: String {
            switch self {
            case .default: "default"
            case .high: "high"
            }
        }

        var resolved: AXCustomContent.Importance {
            switch self {
            case .default: .default
            case .high: .high
            }
        }
    }

    enum ContentState: ShowcaseState {
        case defaultImportance
        case highImportance

        var caption: String {
            switch self {
            case .defaultImportance: "importance: .default"
            case .highImportance: "importance: .high"
            }
        }

        var importance: AXCustomContent.Importance {
            switch self {
            case .defaultImportance: .default
            case .highImportance: .high
            }
        }
    }

    @State private var labelText = "Departure"
    @State private var valueText = "9:45 AM"
    @State private var importance: ImportancePick = .default

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Custom Content",
            summary: "Attaches extra label/value pairs VoiceOver users can expand via the More Content rotor.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityCustomContentShowcase {
    var preview: some View {
        flightRow(
            label: labelText,
            value: valueText,
            importance: importance.resolved,
        )
    }

    @ViewBuilder var controls: some View {
        ShowcaseTextControl("Label", text: $labelText, prompt: "e.g. Departure")
        ShowcaseTextControl("Value", text: $valueText, prompt: "e.g. 9:45 AM")
        ShowcasePicker("Importance", selection: $importance)
    }

    @ViewBuilder func stateView(_ state: ContentState) -> some View {
        flightRow(
            label: "Departure",
            value: "9:45 AM",
            importance: state.importance,
        )
    }

    func flightRow(
        label: String,
        value: String,
        importance: AXCustomContent.Importance,
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            HStack(spacing: DesignSystem.Spacing.small) {
                Image(systemName: "airplane")
                    .foregroundStyle(DesignSystem.Color.accent)
                    .font(DesignSystem.Font.title3)
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.hairline) {
                    Text("Flight AA 101")
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.primary)
                    Text("New York → London")
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.secondary)
                }
            }
            importanceBadge(importance: importance, label: label, value: value)
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .accessibilityElement(children: .combine)
        .accessibilityCustomContent(Text(label), Text(value), importance: importance)
    }

    func importanceBadge(
        importance: AXCustomContent.Importance,
        label: String,
        value: String,
    ) -> some View {
        let isHigh = importance == .high
        return HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: isHigh ? "speaker.wave.2" : "speaker")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(isHigh ? DesignSystem.Color.accent : DesignSystem.Color.secondary)
            Text(isHigh ? "\(label): \(value) (spoken automatically)" : "\(label): \(value) (on demand)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
                .lineLimit(2)
        }
    }
}

// MARK: - Code generation
private extension AccessibilityCustomContentShowcase {
    var generatedCode: String {
        let importanceArg = importance == .default ? "default" : "high"
        return """
        FlightRow(flight: flight)
            .accessibilityElement(children: .combine)
            .accessibilityCustomContent("\(labelText)", "\(valueText)", importance: .\(importanceArg))
        """
    }
}
