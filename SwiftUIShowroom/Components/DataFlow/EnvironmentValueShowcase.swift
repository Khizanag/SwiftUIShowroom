import SwiftUI

struct EnvironmentValueShowcase: View {
    enum EnvKey: ShowcasePickable {
        case colorScheme
        case dynamicTypeSize
        case locale
        case calendar
        case timeZone
        case layoutDirection
        case isEnabled
        case accessibilityReduceMotion
        case accessibilityReduceTransparency
        case displayScale
        case scenePhase

        var label: String {
            switch self {
            case .colorScheme: return "\\.colorScheme"
            case .dynamicTypeSize: return "\\.dynamicTypeSize"
            case .locale: return "\\.locale"
            case .calendar: return "\\.calendar"
            case .timeZone: return "\\.timeZone"
            case .layoutDirection: return "\\.layoutDirection"
            case .isEnabled: return "\\.isEnabled"
            case .accessibilityReduceMotion: return "\\.accessibilityReduceMotion"
            case .accessibilityReduceTransparency: return "\\.accessibilityReduceTransparency"
            case .displayScale: return "\\.displayScale"
            case .scenePhase: return "\\.scenePhase"
            }
        }

        var keyPathString: String { label }
    }

    enum ReadMode: ShowcasePickable {
        case keyPath
        case observableType

        var label: String {
            switch self {
            case .keyPath: return "Key path"
            case .observableType: return "Observable type"
            }
        }
    }

    enum EnvDemoState: ShowcaseState {
        case readKeyPath
        case readObservableType
        case propagatedViaModifier
        case overriddenLocally

        var caption: String {
            switch self {
            case .readKeyPath: return "Read by key path"
            case .readObservableType: return "Read by observable type"
            case .propagatedViaModifier: return "Propagated via .environment"
            case .overriddenLocally: return "Overridden locally"
            }
        }
    }

    @State private var selectedKey: EnvKey = .colorScheme
    @State private var readMode: ReadMode = .keyPath
    @State private var observableTypeName: String = "DemoModel"

    var body: some View {
        ShowcaseScreen(
            title: "@Environment (key path)",
            summary: "Reads a built-in EnvironmentValues entry by key path, propagated down the hierarchy.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension EnvironmentValueShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.accent)
            EnvValueReader(selectedKey: selectedKey)
        }
        .padding(DesignSystem.Spacing.large)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Read mode", selection: $readMode)
        if readMode == .keyPath {
            ShowcasePicker("Key path", selection: $selectedKey)
        } else {
            ShowcaseTextControl("Observable type name", text: $observableTypeName)
        }
    }

    @ViewBuilder
    func stateView(_ state: EnvDemoState) -> some View {
        switch state {
        case .readKeyPath:
            keyPathDemoView
        case .readObservableType:
            observableTypeDemoView
        case .propagatedViaModifier:
            propagatedDemoView
        case .overriddenLocally:
            overriddenDemoView
        }
    }

    var keyPathDemoView: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "key.horizontal")
                .font(DesignSystem.Font.title)
                .foregroundStyle(DesignSystem.Color.accent)
            Text("@Environment(\\.colorScheme)")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.primary)
            EnvValueReader(selectedKey: .colorScheme)
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var observableTypeDemoView: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "square.3.layers.3d")
                .font(DesignSystem.Font.title)
                .foregroundStyle(DesignSystem.Color.accent)
            Text("@Environment(MyModel.self)")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.primary)
            Text("Injects an @Observable object\ninto the environment by type.")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var propagatedDemoView: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "arrow.down.to.line")
                .font(DesignSystem.Font.title)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(".environment(\\.locale, Locale(identifier: \"ka\"))")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.primary)
            EnvValueReader(selectedKey: .locale)
                .environment(\.locale, Locale(identifier: "ka"))
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var overriddenDemoView: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(DesignSystem.Font.title)
                .foregroundStyle(DesignSystem.Color.accent)
            Text("Overridden: isEnabled = false")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.primary)
            EnvValueReader(selectedKey: .isEnabled)
                .disabled(true)
            Text("(disabled propagates isEnabled = false)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.medium)
    }
}

// MARK: - Code generation
private extension EnvironmentValueShowcase {
    var generatedCode: String {
        let propertyDecl: String
        if readMode == .observableType {
            propertyDecl = "@Environment(\(observableTypeName).self) private var value"
        } else {
            propertyDecl = "@Environment(\(selectedKey.keyPathString)) private var value"
        }
        return [
            "struct EnvironmentReadDemo: View {",
            "    \(propertyDecl)",
            "",
            "    var body: some View {",
            "        Text(\"\\(String(describing: value))\")",
            "    }",
            "}",
        ].joined(separator: "\n")
    }
}

// MARK: - EnvValueReader
private struct EnvValueReader: View {
    let selectedKey: EnvironmentValueShowcase.EnvKey

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.locale) private var locale
    @Environment(\.calendar) private var calendar
    @Environment(\.timeZone) private var timeZone
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.displayScale) private var displayScale
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xSmall) {
            Text(selectedKey.keyPathString)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
            Text(currentValueDescription)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.small)
        }
    }

    private var currentValueDescription: String {
        switch selectedKey {
        case .colorScheme:
            return colorScheme == .dark ? "dark" : "light"
        case .dynamicTypeSize:
            return dynamicTypeSizeLabel
        case .locale:
            return locale.identifier
        case .calendar:
            return "\(calendar.identifier)"
        case .timeZone:
            return timeZone.identifier
        case .layoutDirection:
            return layoutDirection == .rightToLeft ? "rightToLeft" : "leftToRight"
        case .isEnabled:
            return isEnabled ? "true" : "false"
        case .accessibilityReduceMotion:
            return reduceMotion ? "true" : "false"
        case .accessibilityReduceTransparency:
            return reduceTransparency ? "true" : "false"
        case .displayScale:
            return String(format: "%.1f\u{00D7}", displayScale)
        case .scenePhase:
            return scenePhaseName
        }
    }

    private var dynamicTypeSizeLabel: String {
        let labels: [(DynamicTypeSize, String)] = [
            (.xSmall, "xSmall"),
            (.small, "small"),
            (.medium, "medium"),
            (.large, "large"),
            (.xLarge, "xLarge"),
            (.xxLarge, "xxLarge"),
            (.xxxLarge, "xxxLarge"),
            (.accessibility1, "accessibility1"),
            (.accessibility2, "accessibility2"),
            (.accessibility3, "accessibility3"),
            (.accessibility4, "accessibility4"),
            (.accessibility5, "accessibility5"),
        ]
        return labels.first(where: { $0.0 == dynamicTypeSize })?.1 ?? "unknown"
    }

    private var scenePhaseName: String {
        switch scenePhase {
        case .active: return "active"
        case .inactive: return "inactive"
        case .background: return "background"
        @unknown default: return "unknown"
        }
    }
}
