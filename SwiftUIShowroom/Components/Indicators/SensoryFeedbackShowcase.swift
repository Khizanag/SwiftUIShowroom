import SwiftUI

struct SensoryFeedbackShowcase: View {

    // MARK: - Nested types
    enum FeedbackOption: String, ShowcasePickable {
        case success
        case warning
        case error
        case selection
        case increase
        case decrease
        case start
        case stop
        case alignment
        case levelChange
        case impact
        case impactWeightIntensity = "impact(weight:intensity:)"
        case impactFlexibilityIntensity = "impact(flexibility:intensity:)"

        var label: String { rawValue }

        var isImpactVariant: Bool {
            self == .impact || self == .impactWeightIntensity || self == .impactFlexibilityIntensity
        }
    }

    enum ImpactWeightOption: String, ShowcasePickable {
        case light
        case medium
        case heavy

        var label: String { rawValue }
    }

    enum TriggerState: ShowcaseState {
        case idle
        case triggered

        var caption: String {
            switch self {
            case .idle: "Idle"
            case .triggered: "Triggered"
            }
        }
    }

    // MARK: - State
    @State private var feedback: FeedbackOption = .selection
    @State private var impactWeight: ImpactWeightOption = .medium
    @State private var impactIntensity: Double = 1.0
    @State private var useCondition = false
    @State private var triggerCount = 0

    // MARK: - Body
    var body: some View {
        ShowcaseScreen(
            title: "Sensory Feedback",
            summary: "Plays haptic/audio feedback when a monitored Equatable value changes.",
        ) {
            PreviewStage {
                preview
            }
            ShowcaseSection("Configuration") {
                controls
            }
            ShowcaseSection("States") {
                StateGallery(content: stateView)
            }
            ShowcaseSection("Generated code") {
                CodeBlock(code: generatedCode)
            }
        }
    }
}

// MARK: - Sub-views
private extension SensoryFeedbackShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            feedbackStatusBadge
            fireButton
        }
    }

    var feedbackStatusBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: triggerCount == 0 ? "wave.3.right" : "checkmark.circle.fill")
                .foregroundStyle(
                    triggerCount == 0 ? DesignSystem.Color.secondary : DesignSystem.Color.accent
                )
            Text(triggerCount == 0 ? "Tap to fire feedback" : "Fired \(triggerCount)×")
                .font(DesignSystem.Font.callout)
                .foregroundStyle(DesignSystem.Color.secondary)
                .contentTransition(.numericText())
                .animation(.default, value: triggerCount)
        }
        .padding(.horizontal, DesignSystem.Spacing.small)
        .padding(.vertical, DesignSystem.Spacing.xSmall)
        .background(DesignSystem.Color.cardBackground, in: .capsule)
    }

    var fireButton: some View {
        Button {
            triggerCount += 1
        } label: {
            Label("Fire \(feedback.label)", systemImage: symbolForFeedback)
        }
        .buttonStyle(.borderedProminent)
        .withSensoryFeedback(
            feedback: feedback,
            weight: impactWeight,
            intensity: impactIntensity,
            condition: useCondition,
            trigger: triggerCount,
        )
    }

    var symbolForFeedback: String {
        switch feedback {
        case .success: "checkmark.circle"
        case .warning: "exclamationmark.triangle"
        case .error: "xmark.circle"
        case .selection: "hand.tap"
        case .increase: "arrow.up.circle"
        case .decrease: "arrow.down.circle"
        case .start: "play.circle"
        case .stop: "stop.circle"
        case .alignment: "align.horizontal.center"
        case .levelChange: "dial.medium"
        case .impact, .impactWeightIntensity, .impactFlexibilityIntensity: "bolt.circle"
        }
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Feedback type", selection: $feedback)
        if feedback.isImpactVariant {
            ShowcasePicker("Impact weight", selection: $impactWeight)
            #if !os(tvOS)
            ShowcaseSlider("Intensity", value: $impactIntensity, in: 0...1, step: 0.05)
            #endif
        }
        ShowcaseToggle("Gate with condition (new > old)", isOn: $useCondition)
    }

    @ViewBuilder
    func stateView(_ state: TriggerState) -> some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: state == .triggered ? "waveform" : "minus.circle")
                .foregroundStyle(
                    state == .triggered ? DesignSystem.Color.accent : DesignSystem.Color.secondary
                )
            Text(state.caption)
                .font(DesignSystem.Font.callout)
                .foregroundStyle(DesignSystem.Color.primary)
        }
        .padding(DesignSystem.Spacing.small)
        .frame(maxWidth: .infinity)
        .background(
            DesignSystem.Color.cardBackground,
            in: .rect(cornerRadius: DesignSystem.CornerRadius.medium),
        )
    }
}

// MARK: - Code generation
private extension SensoryFeedbackShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("@State private var trigger = 0")
        lines.append("")
        lines.append("Button(\"Act\") { trigger += 1 }")
        if useCondition {
            lines.append("    .sensoryFeedback(\(feedbackCodeArg), trigger: trigger) { old, new in")
            lines.append("        new > old")
            lines.append("    }")
        } else {
            lines.append("    .sensoryFeedback(\(feedbackCodeArg), trigger: trigger)")
        }
        if feedback.isImpactVariant {
            lines.append("")
            lines.append("// intensity: 0.0 (none) … 1.0 (full)")
        }
        lines.append("")
        lines.append("// No haptic hardware on most macOS / tvOS devices —")
        lines.append("// the modifier compiles everywhere but is a no-op there.")
        return lines.joined(separator: "\n")
    }

    var feedbackCodeArg: String {
        switch feedback {
        case .impactWeightIntensity:
            let intensity = impactIntensity.formatted(.number.precision(.fractionLength(0...2)))
            return ".impact(weight: .\(impactWeight.rawValue), intensity: \(intensity))"
        case .impactFlexibilityIntensity:
            let intensity = impactIntensity.formatted(.number.precision(.fractionLength(0...2)))
            return ".impact(flexibility: .solid, intensity: \(intensity))"
        default:
            return ".\(feedback.rawValue)"
        }
    }
}

// MARK: - Sensory feedback helper
private extension View {
    @ViewBuilder
    func withSensoryFeedback(
        feedback: SensoryFeedbackShowcase.FeedbackOption,
        weight: SensoryFeedbackShowcase.ImpactWeightOption,
        intensity: Double,
        condition: Bool,
        trigger: Int,
    ) -> some View {
        let resolved = resolvedFeedback(feedback, weight: weight, intensity: intensity)
        if condition {
            sensoryFeedback(resolved, trigger: trigger) { old, new in new > old }
        } else {
            sensoryFeedback(resolved, trigger: trigger)
        }
    }
}

private func resolvedFeedback(
    _ option: SensoryFeedbackShowcase.FeedbackOption,
    weight: SensoryFeedbackShowcase.ImpactWeightOption,
    intensity: Double,
) -> SensoryFeedback {
    switch option {
    case .success: .success
    case .warning: .warning
    case .error: .error
    case .selection: .selection
    case .increase: .increase
    case .decrease: .decrease
    case .start: .start
    case .stop: .stop
    case .alignment: .alignment
    case .levelChange: .levelChange
    case .impact: .impact
    case .impactWeightIntensity:
        .impact(weight: nativeWeight(weight), intensity: intensity)
    case .impactFlexibilityIntensity:
        .impact(flexibility: .solid, intensity: intensity)
    }
}

private func nativeWeight(
    _ option: SensoryFeedbackShowcase.ImpactWeightOption,
) -> SensoryFeedback.Weight {
    switch option {
    case .light: .light
    case .medium: .medium
    case .heavy: .heavy
    }
}
