import SwiftUI

struct EnvironmentModifierKeypathShowcase: View {
    @State private var keyPathOption: KeyPathOption = .locale
    @State private var localeIdentifier: String = "en_US"
    @State private var colorSchemeOption: ColorSchemeOption = .light
    @State private var fontOption: FontOption = .body
    @State private var lineSpacing: Double = 4
    @State private var multilineOption: MultilineOption = .leading
    @State private var isEnabled: Bool = true
    @State private var dynamicTypeOption: DynamicTypeOption = .large

    var body: some View {
        ShowcaseScreen(
            title: "environment(_:_:) key path",
            summary: "Sets a value for a writable EnvironmentValues key path on a view's subtree.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension EnvironmentModifierKeypathShowcase {
    var preview: some View {
        subtreeView
            .padding(DesignSystem.Spacing.medium)
            .background(DesignSystem.Color.cardBackground, in: .rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    var subtreeView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            modifierLabel
            appliedContent
        }
    }

    var modifierLabel: some View {
        Text(".environment(\\\(keyPathOption.keyPathString), \(currentValueLabel))")
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder var appliedContent: some View {
        switch keyPathOption {
        case .locale:
            sampleTextBlock
                .environment(\.locale, Locale(identifier: localeIdentifier))
        case .colorScheme:
            sampleTextBlock
                .environment(\.colorScheme, colorSchemeOption.value)
        case .font:
            sampleTextBlock
                .environment(\.font, fontOption.value)
        case .lineSpacing:
            sampleTextBlock
                .environment(\.lineSpacing, lineSpacing)
        case .multilineTextAlignment:
            sampleTextBlock
                .environment(\.multilineTextAlignment, multilineOption.value)
        case .isEnabled:
            Toggle("Enabled control", isOn: .constant(true))
                .environment(\.isEnabled, isEnabled)
        case .dynamicTypeSize:
            sampleTextBlock
                .environment(\.dynamicTypeSize, dynamicTypeOption.value)
        }
    }

    var sampleTextBlock: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("Hello, SwiftUI")
                .fontWeight(.semibold)
            Text("Environment values flow down the view hierarchy and override the defaults for all descendants.")
        }
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Key path", selection: $keyPathOption)
        keyPathSpecificControls
    }

    @ViewBuilder var keyPathSpecificControls: some View {
        switch keyPathOption {
        case .locale:
            ShowcaseTextControl("Locale identifier", text: $localeIdentifier, prompt: "e.g. fr_FR")
        case .colorScheme:
            ShowcasePicker("Color scheme", selection: $colorSchemeOption)
        case .font:
            ShowcasePicker("Font", selection: $fontOption)
        case .lineSpacing:
            ShowcaseSlider("Line spacing", value: $lineSpacing, in: 0...20, step: 1)
        case .multilineTextAlignment:
            ShowcasePicker("Multiline alignment", selection: $multilineOption)
        case .isEnabled:
            ShowcaseToggle("Is enabled", isOn: $isEnabled)
        case .dynamicTypeSize:
            ShowcasePicker("Dynamic Type size", selection: $dynamicTypeOption)
        }
    }

    @ViewBuilder func stateView(_ state: KeyPathState) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("Hello, SwiftUI")
                .fontWeight(.semibold)
            Text("Environment values override descendants.")
        }
        .modifier(stateModifier(for: state))
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Color.cardBackground, in: .rect(cornerRadius: DesignSystem.CornerRadius.small))
    }

    func stateModifier(for state: KeyPathState) -> some ViewModifier {
        StateApplyingModifier(state: state)
    }
}

// MARK: - State modifier
private struct StateApplyingModifier: ViewModifier {
    let state: EnvironmentModifierKeypathShowcase.KeyPathState

    func body(content: Content) -> some View {
        switch state {
        case .localeOverride:
            content.environment(\.locale, Locale(identifier: "fr_FR"))
        case .colorSchemeDark:
            content.environment(\.colorScheme, .dark)
        case .fontTitle:
            content.environment(\.font, .title2)
        case .lineSpacingWide:
            content.environment(\.lineSpacing, 12)
        case .disabled:
            content.environment(\.isEnabled, false)
        }
    }
}

// MARK: - Code generation
private extension EnvironmentModifierKeypathShowcase {
    var generatedCode: String {
        """
        VStack {
            Text("Hello, SwiftUI")
            Text("More text here.")
        }
        .environment(\\\(keyPathOption.keyPathString), \(currentValueExpression))
        """
    }

    var currentValueLabel: String {
        switch keyPathOption {
        case .locale: return "Locale(\"\(localeIdentifier)\")"
        case .colorScheme: return colorSchemeOption.label
        case .font: return fontOption.label
        case .lineSpacing: return "\(Int(lineSpacing))"
        case .multilineTextAlignment: return multilineOption.label
        case .isEnabled: return isEnabled ? "true" : "false"
        case .dynamicTypeSize: return dynamicTypeOption.label
        }
    }

    var currentValueExpression: String {
        switch keyPathOption {
        case .locale: return "Locale(identifier: \"\(localeIdentifier)\")"
        case .colorScheme: return ".\(colorSchemeOption.rawValue)"
        case .font: return ".\(fontOption.rawValue)"
        case .lineSpacing: return "\(Int(lineSpacing))"
        case .multilineTextAlignment: return ".\(multilineOption.rawValue)"
        case .isEnabled: return isEnabled ? "true" : "false"
        case .dynamicTypeSize: return ".\(dynamicTypeOption.rawValue)"
        }
    }
}

// MARK: - Nested enums
extension EnvironmentModifierKeypathShowcase {
    enum KeyPathOption: ShowcasePickable {
        case locale
        case colorScheme
        case font
        case lineSpacing
        case multilineTextAlignment
        case isEnabled
        case dynamicTypeSize

        var label: String {
            switch self {
            case .locale: return "\\.locale"
            case .colorScheme: return "\\.colorScheme"
            case .font: return "\\.font"
            case .lineSpacing: return "\\.lineSpacing"
            case .multilineTextAlignment: return "\\.multilineTextAlignment"
            case .isEnabled: return "\\.isEnabled"
            case .dynamicTypeSize: return "\\.dynamicTypeSize"
            }
        }

        var keyPathString: String {
            switch self {
            case .locale: return ".locale"
            case .colorScheme: return ".colorScheme"
            case .font: return ".font"
            case .lineSpacing: return ".lineSpacing"
            case .multilineTextAlignment: return ".multilineTextAlignment"
            case .isEnabled: return ".isEnabled"
            case .dynamicTypeSize: return ".dynamicTypeSize"
            }
        }
    }

    enum ColorSchemeOption: String, ShowcasePickable {
        case light
        case dark

        var label: String {
            switch self {
            case .light: return "Light"
            case .dark: return "Dark"
            }
        }

        var value: ColorScheme {
            switch self {
            case .light: return .light
            case .dark: return .dark
            }
        }
    }

    enum FontOption: String, ShowcasePickable {
        case body
        case caption
        case headline
        case title2
        case largeTitle

        var label: String {
            switch self {
            case .body: return "Body"
            case .caption: return "Caption"
            case .headline: return "Headline"
            case .title2: return "Title 2"
            case .largeTitle: return "Large Title"
            }
        }

        var value: Font {
            switch self {
            case .body: return .body
            case .caption: return .caption
            case .headline: return .headline
            case .title2: return .title2
            case .largeTitle: return .largeTitle
            }
        }
    }

    enum MultilineOption: String, ShowcasePickable {
        case leading
        case center
        case trailing

        var label: String {
            switch self {
            case .leading: return "Leading"
            case .center: return "Center"
            case .trailing: return "Trailing"
            }
        }

        var value: TextAlignment {
            switch self {
            case .leading: return .leading
            case .center: return .center
            case .trailing: return .trailing
            }
        }
    }

    enum DynamicTypeOption: String, ShowcasePickable {
        case xSmall
        case large
        case xxLarge
        case accessibility1

        var label: String {
            switch self {
            case .xSmall: return "xSmall"
            case .large: return "Large (default)"
            case .xxLarge: return "xxLarge"
            case .accessibility1: return "Accessibility 1"
            }
        }

        var value: DynamicTypeSize {
            switch self {
            case .xSmall: return .xSmall
            case .large: return .large
            case .xxLarge: return .xxLarge
            case .accessibility1: return .accessibility1
            }
        }
    }

    enum KeyPathState: ShowcaseState {
        case localeOverride
        case colorSchemeDark
        case fontTitle
        case lineSpacingWide
        case disabled

        var caption: String {
            switch self {
            case .localeOverride: return "\\.locale (fr_FR)"
            case .colorSchemeDark: return "\\.colorScheme (.dark)"
            case .fontTitle: return "\\.font (.title2)"
            case .lineSpacingWide: return "\\.lineSpacing (12)"
            case .disabled: return "\\.isEnabled (false)"
            }
        }
    }
}
