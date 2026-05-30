import SwiftUI

struct DefaultAppStorageShowcase: View {
    enum StoreOption: ShowcasePickable {
        case standard, appGroupSuite, customSuite

        var label: String {
            switch self {
            case .standard: ".standard"
            case .appGroupSuite: "App Group suite"
            case .customSuite: "Custom suite"
            }
        }
    }

    enum DefaultAppStorageState: ShowcaseState {
        case withAppGroup, withStandard, withCustom

        var caption: String {
            switch self {
            case .withAppGroup: "App Group suite"
            case .withStandard: ".standard (no modifier)"
            case .withCustom: "Custom suite name"
            }
        }
    }

    @State private var storeOption: StoreOption = .appGroupSuite
    @State private var suiteName = "group.com.example.app"

    var body: some View {
        ShowcaseScreen(
            title: "defaultAppStorage(_:)",
            summary: "Sets the UserDefaults store that @AppStorage uses by default for a view subtree.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension DefaultAppStorageShowcase {
    var preview: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            storeIndicator
            subtreePreview
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var storeIndicator: some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: "internaldrive")
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(width: DesignSystem.Size.Icon.small, height: DesignSystem.Size.Icon.small)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.hairline) {
                Text("Active store")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
                Text(storeDisplayName)
                    .font(DesignSystem.Font.callout)
                    .foregroundStyle(DesignSystem.Color.primary)
            }
        }
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
    }

    var storeDisplayName: String {
        switch storeOption {
        case .standard:
            return "UserDefaults.standard"
        case .appGroupSuite:
            return "UserDefaults(suiteName: \"\(suiteName)\")"
        case .customSuite:
            return "UserDefaults(suiteName: \"\(suiteName)\")"
        }
    }

    var subtreePreview: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("Subtree with .defaultAppStorage")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                appStorageRow(key: "hasSeenOnboarding", typeLabel: "Bool")
                appStorageRow(key: "preferredTheme", typeLabel: "String")
                appStorageRow(key: "launchCount", typeLabel: "Int")
            }
            .padding(DesignSystem.Spacing.small)
            .background(DesignSystem.Color.background)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        }
    }

    func appStorageRow(key: String, typeLabel: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: "chevron.right")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.accent)
            Text("@AppStorage(\"\(key)\") var value: \(typeLabel)")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.primary)
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Store", selection: $storeOption)
        if storeOption != .standard {
            ShowcaseTextControl(
                "Suite name",
                text: $suiteName,
                prompt: "e.g. group.com.example.app",
            )
        }
    }

    @ViewBuilder
    func stateView(_ state: DefaultAppStorageState) -> some View {
        switch state {
        case .withAppGroup:
            stateCard(
                storeLine: "UserDefaults(suiteName: \"group.com.example.app\")!",
                note: "Shared with widgets",
            )
        case .withStandard:
            stateCard(
                storeLine: nil,
                note: "Uses .standard implicitly",
            )
        case .withCustom:
            stateCard(
                storeLine: "UserDefaults(suiteName: \"com.example.custom\")!",
                note: "Scoped to a feature",
            )
        }
    }

    func stateCard(storeLine: String?, note: String) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            if let storeLine {
                Text(".defaultAppStorage(")
                    .font(DesignSystem.Font.codeInline)
                    .foregroundStyle(DesignSystem.Color.secondary)
                Text("  \(storeLine)")
                    .font(DesignSystem.Font.codeInline)
                    .foregroundStyle(DesignSystem.Color.primary)
                Text(")")
                    .font(DesignSystem.Font.codeInline)
                    .foregroundStyle(DesignSystem.Color.secondary)
            } else {
                Text("// no .defaultAppStorage")
                    .font(DesignSystem.Font.codeInline)
                    .foregroundStyle(DesignSystem.Color.secondary)
                Text("// uses .standard by default")
                    .font(DesignSystem.Font.codeInline)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
            Text(note)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.accent)
                .padding(.top, DesignSystem.Spacing.xSmall)
        }
        .padding(DesignSystem.Spacing.small)
    }
}

// MARK: - Code generation
private extension DefaultAppStorageShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("struct SettingsView: View {")
        lines.append("    @AppStorage(\"hasSeenOnboarding\") private var hasSeenOnboarding = false")
        lines.append("    @AppStorage(\"preferredTheme\") private var preferredTheme = \"system\"")
        lines.append("")
        lines.append("    var body: some View {")
        lines.append("        Form {")
        lines.append("            Toggle(\"Onboarding seen\", isOn: $hasSeenOnboarding)")
        lines.append("        }")
        lines.append("    }")
        lines.append("}")
        lines.append("")
        switch storeOption {
        case .standard:
            lines.append("// No .defaultAppStorage needed — .standard is the default.")
            lines.append("SettingsView()")
        case .appGroupSuite:
            lines.append("// Point the whole subtree at the App Group suite:")
            lines.append("SettingsView()")
            lines.append("    .defaultAppStorage(UserDefaults(suiteName: \"\(suiteName)\")!)")
        case .customSuite:
            lines.append("// Point the whole subtree at a custom suite:")
            lines.append("SettingsView()")
            lines.append("    .defaultAppStorage(UserDefaults(suiteName: \"\(suiteName)\")!)")
        }
        return lines.joined(separator: "\n")
    }
}
