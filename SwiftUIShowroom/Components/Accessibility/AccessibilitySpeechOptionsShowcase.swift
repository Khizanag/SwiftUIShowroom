import SwiftUI

struct AccessibilitySpeechOptionsShowcase: View {
    enum SampleContent: String, ShowcasePickable {
        case confirmationCode
        case codeSnippet
        case serialNumber

        var label: String {
            switch self {
            case .confirmationCode: "Confirmation code"
            case .codeSnippet: "Code snippet"
            case .serialNumber: "Serial number"
            }
        }

        var text: String {
            switch self {
            case .confirmationCode: "AB3-K9X"
            case .codeSnippet: "func greet() { print(\"Hello!\") }"
            case .serialNumber: "SN: X4F-22Q-8RZ"
            }
        }
    }

    enum SpeechState: ShowcaseState {
        case `default`
        case spelledOut
        case highPitch
        case withPunctuation
        case queued

        var caption: String {
            switch self {
            case .default: "Default"
            case .spelledOut: "Spells out characters"
            case .highPitch: "High pitch (+0.8)"
            case .withPunctuation: "Always includes punctuation"
            case .queued: "Announcements queued"
            }
        }

        var text: String {
            switch self {
            case .default: "AB3-K9X"
            case .spelledOut: "AB3-K9X"
            case .highPitch: "Warning: low battery"
            case .withPunctuation: "func greet() { print(\"Hello!\") }"
            case .queued: "Update complete."
            }
        }

        var spellsOut: Bool {
            switch self {
            case .spelledOut: true
            default: false
            }
        }

        var pitch: Double {
            switch self {
            case .highPitch: 0.8
            default: 0.0
            }
        }

        var includesPunctuation: Bool {
            switch self {
            case .withPunctuation: true
            default: false
            }
        }

        var queued: Bool {
            switch self {
            case .queued: true
            default: false
            }
        }
    }

    @State private var spellsOutCharacters = false
    @State private var adjustedPitch = 0.0
    @State private var alwaysIncludesPunctuation = false
    @State private var announcementsQueued = false
    @State private var sampleContent: SampleContent = .confirmationCode

    var body: some View {
        ShowcaseScreen(
            title: "Speech Options",
            summary: "Fine-tunes how VoiceOver pronounces an element: spelling, pitch, punctuation, queueing.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilitySpeechOptionsShowcase {
    var preview: some View {
        speechCard(
            text: sampleContent.text,
            spellsOut: spellsOutCharacters,
            pitch: adjustedPitch,
            includesPunctuation: alwaysIncludesPunctuation,
            queued: announcementsQueued,
        )
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Sample content", selection: $sampleContent)
        ShowcaseToggle("Spells out characters", isOn: $spellsOutCharacters)
        ShowcaseSlider("Adjusted pitch", value: $adjustedPitch, in: -1.0...1.0, step: 0.1)
        ShowcaseToggle("Always includes punctuation", isOn: $alwaysIncludesPunctuation)
        ShowcaseToggle("Announcements queued", isOn: $announcementsQueued)
    }

    @ViewBuilder func stateView(_ state: SpeechState) -> some View {
        speechCard(
            text: state.text,
            spellsOut: state.spellsOut,
            pitch: state.pitch,
            includesPunctuation: state.includesPunctuation,
            queued: state.queued,
        )
    }
}

// MARK: - Card builder
private extension AccessibilitySpeechOptionsShowcase {
    func speechCard(
        text: String,
        spellsOut: Bool,
        pitch: Double,
        includesPunctuation: Bool,
        queued: Bool,
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            badgeRow(
                spellsOut: spellsOut,
                pitch: pitch,
                includesPunctuation: includesPunctuation,
                queued: queued,
            )
            Text(verbatim: text)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.primary)
                .speechSpellsOutCharacters(spellsOut)
                .speechAdjustedPitch(pitch)
                .speechAlwaysIncludesPunctuation(includesPunctuation)
                .speechAnnouncementsQueued(queued)
            Text("Activate with VoiceOver to hear the effect.")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(DesignSystem.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    func badgeRow(
        spellsOut: Bool,
        pitch: Double,
        includesPunctuation: Bool,
        queued: Bool,
    ) -> some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            if spellsOut {
                badge(icon: "textformat.abc", label: "Spell")
            }
            if pitch != 0 {
                badge(icon: "waveform", label: pitch > 0 ? "+pitch" : "-pitch")
            }
            if includesPunctuation {
                badge(icon: "ellipsis", label: "Punct.")
            }
            if queued {
                badge(icon: "list.bullet", label: "Queue")
            }
            if !spellsOut && pitch == 0 && !includesPunctuation && !queued {
                badge(icon: "speaker.wave.2", label: "Default")
            }
        }
    }

    func badge(icon: String, label: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.hairline) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption2)
            Text(label)
                .font(DesignSystem.Font.caption2)
        }
        .foregroundStyle(DesignSystem.Color.accent)
        .padding(.horizontal, DesignSystem.Spacing.xSmall)
        .padding(.vertical, DesignSystem.Spacing.hairline)
        .background(DesignSystem.Color.accent.opacity(0.12))
        .clipShape(Capsule())
    }
}

// MARK: - Code generation
private extension AccessibilitySpeechOptionsShowcase {
    var generatedCode: String {
        let pitchStr = String(format: "%.1f", adjustedPitch)
        return """
        Text(verbatim: confirmationCode)
            .speechSpellsOutCharacters(\(spellsOutCharacters))
            .speechAdjustedPitch(\(pitchStr))
            .speechAlwaysIncludesPunctuation(\(alwaysIncludesPunctuation))
            .speechAnnouncementsQueued(\(announcementsQueued))
        """
    }
}
