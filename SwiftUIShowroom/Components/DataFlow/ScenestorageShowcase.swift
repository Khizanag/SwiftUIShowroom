import SwiftUI

struct ScenestorageShowcase: View {
    enum ValueTypeOption: ShowcasePickable {
        case int
        case string
        case bool
        case double
        case url
        case optional

        var label: String {
            switch self {
            case .int: "Int"
            case .string: "String"
            case .bool: "Bool"
            case .double: "Double"
            case .url: "URL"
            case .optional: "Int? (Optional)"
            }
        }

        var typeName: String {
            switch self {
            case .int: "Int"
            case .string: "String"
            case .bool: "Bool"
            case .double: "Double"
            case .url: "URL"
            case .optional: "Int?"
            }
        }

        var defaultExpression: String {
            switch self {
            case .int: "0"
            case .string: "\"\""
            case .bool: "false"
            case .double: "1.0"
            case .url: "URL(string: \"https://example.com\") ?? URL(string: \"about:blank\")!"
            case .optional: "nil"
            }
        }

        var controlSnippet: String {
            switch self {
            case .int:
                return "TabView(selection: $value) { /* tabs */ }"
            case .string:
                return "TextField(\"Draft\", text: $value)"
            case .bool:
                return "Toggle(\"Feature\", isOn: $value)"
            case .double:
                return "Slider(value: $value, in: 0.5...3.0)"
            case .url:
                return "// Use value as URL? for deep-link restoration"
            case .optional:
                return "// value is nil until set; cleared when scene is destroyed"
            }
        }
    }

    enum StorageState: ShowcaseState {
        case defaultValue
        case restored

        var caption: String {
            switch self {
            case .defaultValue: "Default (no stored value)"
            case .restored: "Restored after launch"
            }
        }
    }

    @State private var storageKey = "selectedTab"
    @State private var valueType: ValueTypeOption = .int
    @State private var tabIndex = 0
    @State private var draftText = "Hello, world"
    @State private var isOn = false

    var body: some View {
        ShowcaseScreen(
            title: "@SceneStorage",
            summary: "Per-scene persistence for lightweight UI restoration state across launches.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ScenestorageShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            sceneBadge
            activeControlPreview
            restorationNote
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var sceneBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: "rectangle.on.rectangle")
                .foregroundStyle(DesignSystem.Color.accent)
                .font(DesignSystem.Font.caption)
            Text("Scene-scoped storage")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }

    @ViewBuilder
    var activeControlPreview: some View {
        switch valueType {
        case .int:
            tabPreview
        case .string:
            textPreview
        case .bool:
            togglePreview
        case .double:
            sliderPreview
        case .url:
            urlPreview
        case .optional:
            optionalPreview
        }
    }

    var tabPreview: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("@SceneStorage(\"\(storageKey)\") var tab: Int = 0")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.primary)
            Picker("Tab", selection: $tabIndex) {
                Text("Home").tag(0)
                Text("Search").tag(1)
                Text("Profile").tag(2)
            }
            .pickerStyle(.segmented)
        }
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Color.cardBackground, in: .rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    var textPreview: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("@SceneStorage(\"\(storageKey)\") var draft: String = \"\"")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.primary)
            TextField("Draft", text: $draftText)
                .textFieldStyle(.roundedBorder)
        }
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Color.cardBackground, in: .rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    var togglePreview: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("@SceneStorage(\"\(storageKey)\") var flag: Bool = false")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.primary)
            Toggle("Feature flag", isOn: $isOn)
                .tint(DesignSystem.Color.accent)
        }
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Color.cardBackground, in: .rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    var sliderPreview: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("@SceneStorage(\"\(storageKey)\") var zoom: Double = 1.0")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.primary)
            Slider(value: .constant(0.6), in: 0...1)
                .tint(DesignSystem.Color.accent)
                .disabled(true)
            Text("1.6×")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Color.cardBackground, in: .rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    var urlPreview: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("@SceneStorage(\"\(storageKey)\") var lastURL: URL?")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.primary)
            Text("https://example.com/articles/42")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.accent)
        }
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Color.cardBackground, in: .rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    var optionalPreview: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("@SceneStorage(\"\(storageKey)\") var value: Int?")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.primary)
            Text("nil until first set — cleared on scene destroy")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Color.cardBackground, in: .rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    var restorationNote: some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: "arrow.clockwise")
                .foregroundStyle(DesignSystem.Color.accent)
                .font(DesignSystem.Font.caption)
            Text("Restored automatically on next launch")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Storage key", text: $storageKey, prompt: "e.g. selectedTab")
        ShowcasePicker("Value type", selection: $valueType)
    }

    @ViewBuilder
    func stateView(_ state: StorageState) -> some View {
        switch state {
        case .defaultValue:
            stateCard(
                icon: "square.dashed",
                title: "Default (no stored value)",
                declaration: "@SceneStorage(\"selectedTab\") var tab: Int = 0",
                detail: "tab → 0  (no scene data yet)",
            )
        case .restored:
            stateCard(
                icon: "arrow.clockwise.circle.fill",
                title: "Restored after launch",
                declaration: "@SceneStorage(\"selectedTab\") var tab: Int = 0",
                detail: "tab → 2  (restored from previous session)",
            )
        }
    }

    func stateCard(
        icon: String,
        title: String,
        declaration: String,
        detail: String
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            HStack(spacing: DesignSystem.Spacing.xSmall) {
                Image(systemName: icon)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .font(DesignSystem.Font.footnote)
                Text(title)
                    .font(DesignSystem.Font.footnote)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
            Text(declaration)
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.primary)
            Text(detail)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(DesignSystem.Spacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.Color.cardBackground, in: .rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Code generation
private extension ScenestorageShowcase {
    var generatedCode: String {
        let key = storageKey.isEmpty ? "selectedTab" : storageKey
        let typeName = valueType.typeName
        let defaultExpr = valueType.defaultExpression
        let controlCode = valueType.controlSnippet
        return """
        struct SceneStorageDemo: View {
            @SceneStorage("\(key)") private var value: \(typeName) = \(defaultExpr)

            var body: some View {
                \(controlCode)
            }
        }
        """
    }
}
