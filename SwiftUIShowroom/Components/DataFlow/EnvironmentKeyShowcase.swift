import SwiftUI

struct EnvironmentKeyShowcase: View {
    enum ValueTypeOption: ShowcasePickable {
        case bool, int, string, double, color

        var label: String {
            switch self {
            case .bool: "Bool"
            case .int: "Int"
            case .string: "String"
            case .double: "Double"
            case .color: "Color"
            }
        }

        var typeName: String { label }

        var defaultExpression: String {
            switch self {
            case .bool: "false"
            case .int: "0"
            case .string: "\"\""
            case .double: "0.0"
            case .color: ".accentColor"
            }
        }
    }

    enum KeyDemoState: ShowcaseState {
        case manualKey, entryMacro, injection, reading

        var caption: String {
            switch self {
            case .manualKey: "Manual key"
            case .entryMacro: "@Entry equivalent"
            case .injection: "Injection"
            case .reading: "Reading"
            }
        }
    }

    @State private var accessorName = "isPremium"
    @State private var valueType: ValueTypeOption = .bool
    @State private var defaultValue = "false"
    @State private var useEntryMacro = false

    var body: some View {
        ShowcaseScreen(
            title: "EnvironmentKey",
            summary: "Protocol defining a custom environment value's default — the manual alternative to @Entry.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension EnvironmentKeyShowcase {
    var preview: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            definitionCard
            usageCard
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var definitionCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("Key definition")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            Text(keyDefinitionPreview)
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.primary)
        }
        .padding(DesignSystem.Spacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    var usageCard: some View {
        let resolvedName = accessorName.isEmpty ? "isPremium" : accessorName
        return VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("Read in a child view")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            Text("@Environment(\\.\(resolvedName)) private var value")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.primary)
        }
        .padding(DesignSystem.Spacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    var keyDefinitionPreview: String {
        let keyName = keyTypeName
        let type = valueType.typeName
        let def = defaultValue.isEmpty ? valueType.defaultExpression : defaultValue
        return "struct \(keyName): EnvironmentKey { static let defaultValue: \(type) = \(def) }"
    }

    var keyTypeName: String {
        let name = accessorName.isEmpty ? "isPremium" : accessorName
        let capitalized = name.prefix(1).uppercased() + name.dropFirst()
        return "\(capitalized)Key"
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl(
            "Accessor name",
            text: $accessorName,
            prompt: "e.g. isPremium",
        )
        ShowcasePicker("Value type", selection: $valueType)
            .onChange(of: valueType) { _, newValue in
                defaultValue = newValue.defaultExpression
            }
        ShowcaseTextControl(
            "Default value",
            text: $defaultValue,
            prompt: "e.g. false",
        )
        ShowcaseToggle("Show @Entry equivalent", isOn: $useEntryMacro)
    }

    @ViewBuilder
    func stateView(_ state: KeyDemoState) -> some View {
        switch state {
        case .manualKey:
            manualKeyDemo
        case .entryMacro:
            entryMacroDemo
        case .injection:
            injectionDemo
        case .reading:
            readingDemo
        }
    }

    var manualKeyDemo: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("Manual EnvironmentKey")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            Group {
                Text("private struct IsPremiumKey: EnvironmentKey {")
                Text("    static let defaultValue: Bool = false")
                Text("}")
            }
            .font(DesignSystem.Font.codeInline)
            .foregroundStyle(DesignSystem.Color.primary)
        }
        .padding(DesignSystem.Spacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var entryMacroDemo: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("@Entry equivalent (fewer lines)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            Group {
                Text("extension EnvironmentValues {")
                Text("    @Entry var isPremium: Bool = false")
                Text("}")
            }
            .font(DesignSystem.Font.codeInline)
            .foregroundStyle(DesignSystem.Color.primary)
        }
        .padding(DesignSystem.Spacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var injectionDemo: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("Inject at parent")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            Group {
                Text("ContentView()")
                Text("    .environment(\\.isPremium, true)")
            }
            .font(DesignSystem.Font.codeInline)
            .foregroundStyle(DesignSystem.Color.primary)
        }
        .padding(DesignSystem.Spacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var readingDemo: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("Read in child view")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            Group {
                Text("struct BadgeView: View {")
                Text("    @Environment(\\.isPremium) private var isPremium")
                Text("    var body: some View {")
                Text("        if isPremium { PremiumBadge() }")
                Text("    }")
                Text("}")
            }
            .font(DesignSystem.Font.codeInline)
            .foregroundStyle(DesignSystem.Color.primary)
        }
        .padding(DesignSystem.Spacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Code generation
private extension EnvironmentKeyShowcase {
    var generatedCode: String {
        let name = accessorName.isEmpty ? "isPremium" : accessorName
        let type = valueType.typeName
        let def = defaultValue.isEmpty ? valueType.defaultExpression : defaultValue
        if useEntryMacro {
            return entryMacroCode(name: name, type: type, def: def)
        }
        return manualKeyCode(name: name, keyName: keyTypeName, type: type, def: def)
    }

    func manualKeyCode(name: String, keyName: String, type: String, def: String) -> String {
        [
            "private struct \(keyName): EnvironmentKey {",
            "    static let defaultValue: \(type) = \(def)",
            "}",
            "",
            "extension EnvironmentValues {",
            "    var \(name): \(type) {",
            "        get { self[\(keyName).self] }",
            "        set { self[\(keyName).self] = newValue }",
            "    }",
            "}",
            "",
            "// Inject:",
            "// ContentView().environment(\\.\(name), \(def))",
            "",
            "// Read:",
            "// @Environment(\\.\(name)) private var \(name)",
        ].joined(separator: "\n")
    }

    func entryMacroCode(name: String, type: String, def: String) -> String {
        [
            "extension EnvironmentValues {",
            "    @Entry var \(name): \(type) = \(def)",
            "}",
            "",
            "// Inject:",
            "// ContentView().environment(\\.\(name), \(def))",
            "",
            "// Read:",
            "// @Environment(\\.\(name)) private var \(name)",
        ].joined(separator: "\n")
    }
}
