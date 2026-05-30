import SwiftUI

struct AccessibilityDirectTouchShowcase: View {
    @State private var isDirectTouchArea: Bool = true
    @State private var options: DirectTouchOption = .requiresActivation

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Direct Touch",
            summary: "Lets VoiceOver pass touches straight through to a region (e.g. a piano keyboard).",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityDirectTouchShowcase {
    var preview: some View {
        pianoCanvas(isEnabled: isDirectTouchArea, option: options)
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("Direct touch enabled", isOn: $isDirectTouchArea)
        ShowcasePicker("Options", selection: $options)
    }

    @ViewBuilder func stateView(_ state: DirectTouchState) -> some View {
        switch state {
        case .default:
            pianoCanvas(isEnabled: true, option: .requiresActivation)
        case .silentMode:
            pianoCanvas(isEnabled: true, option: .silentOnTouch)
        case .directTouchOff:
            pianoCanvas(isEnabled: false, option: .requiresActivation)
        }
    }
}

// MARK: - Piano canvas
private extension AccessibilityDirectTouchShowcase {
    func pianoCanvas(isEnabled: Bool, option: DirectTouchOption) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            keyboardView(isEnabled: isEnabled, option: option)
            captionRow(isEnabled: isEnabled, option: option)
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    func keyboardView(isEnabled: Bool, option: DirectTouchOption) -> some View {
        HStack(spacing: DesignSystem.Spacing.hairline) {
            ForEach(KeyNote.allCases) { note in
                pianoKey(note: note)
            }
        }
        .frame(height: 100)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        .accessibilityLabel("Piano keyboard")
        .modifier(DirectTouchModifier(isEnabled: isEnabled, option: option))
    }

    func pianoKey(note: KeyNote) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(note.isBlack ? Color.black : Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(DesignSystem.Color.separator, lineWidth: 1)
            )
            .frame(maxWidth: .infinity)
    }

    func captionRow(isEnabled: Bool, option: DirectTouchOption) -> some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: isEnabled ? "hand.tap.fill" : "hand.tap")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(isEnabled ? DesignSystem.Color.accent : DesignSystem.Color.secondary)
            Text(isEnabled ? option.statusLabel : "Direct touch off")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Cross-platform modifier
private struct DirectTouchModifier: ViewModifier {
    let isEnabled: Bool
    let option: AccessibilityDirectTouchShowcase.DirectTouchOption

    func body(content: Content) -> some View {
        #if os(iOS)
        content
            .accessibilityDirectTouch(isEnabled, options: option.accessibilityOptions)
        #else
        content
            .overlay(alignment: .topTrailing) {
                Text("iOS only")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.secondary)
                    .padding(DesignSystem.Spacing.xSmall)
            }
        #endif
    }
}

// MARK: - Code generation
private extension AccessibilityDirectTouchShowcase {
    var generatedCode: String {
        let directTouchLine: String
        #if os(iOS)
        directTouchLine = "    .accessibilityDirectTouch(\(isDirectTouchArea), options: \(options.codeLiteral))"
        #else
        directTouchLine = "    // .accessibilityDirectTouch — iOS only"
        #endif
        return """
        PianoKeyboardView()
            .accessibilityLabel("Piano keyboard")
        \(directTouchLine)
        """
    }
}

// MARK: - Nested types
extension AccessibilityDirectTouchShowcase {
    fileprivate enum DirectTouchOption: ShowcasePickable {
        case requiresActivation
        case silentOnTouch

        var label: String {
            switch self {
            case .requiresActivation: ".requiresActivation"
            case .silentOnTouch: ".silentOnTouch"
            }
        }

        var statusLabel: String {
            switch self {
            case .requiresActivation: "Requires activation"
            case .silentOnTouch: "Silent on touch"
            }
        }

        var codeLiteral: String {
            switch self {
            case .requiresActivation: ".requiresActivation"
            case .silentOnTouch: ".silentOnTouch"
            }
        }

        #if os(iOS)
        var accessibilityOptions: AccessibilityDirectTouchOptions {
            switch self {
            case .requiresActivation: .requiresActivation
            case .silentOnTouch: .silentOnTouch
            }
        }
        #endif
    }

    fileprivate enum DirectTouchState: ShowcaseState {
        case `default`
        case silentMode
        case directTouchOff

        var caption: String {
            switch self {
            case .default: "Requires activation"
            case .silentMode: "Silent on touch"
            case .directTouchOff: "Direct touch off"
            }
        }
    }

    fileprivate enum KeyNote: Int, CaseIterable, Identifiable {
        case cNatural, dNatural, eNatural, fNatural, gNatural, aNatural, bNatural

        var id: Int { rawValue }

        var isBlack: Bool { false }
    }
}
