import SwiftUI

struct EnvironmentValuesShowcase: View {
    @State private var valueGroup: ValueGroupOption = .appearance
    @State private var customKeyName = "MyKey"
    @State private var showCustomEntry = false

    var body: some View {
        ShowcaseScreen(
            title: "EnvironmentValues",
            summary: "The keyed store @Environment reads; inject values with .environment(_:_:) or @Entry.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension EnvironmentValuesShowcase {
    var preview: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            groupHeader
            entriesGrid
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var groupHeader: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: valueGroup.systemImage)
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(width: DesignSystem.Size.Icon.small, height: DesignSystem.Size.Icon.small)
            Text(valueGroup.label)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.primary)
        }
    }

    var entriesGrid: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            ForEach(valueGroup.entries, id: \.keyPath) { entry in
                entryRow(entry)
            }
        }
    }

    func entryRow(_ entry: EnvEntry) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.small) {
            Text(entry.keyPath)
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(minWidth: 160, alignment: .leading)
            Text(entry.valueType)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(.vertical, DesignSystem.Spacing.hairline)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Value group", selection: $valueGroup)
        ShowcaseToggle("Show custom @Entry pattern", isOn: $showCustomEntry)
        if showCustomEntry {
            ShowcaseTextControl(
                "Custom key name",
                text: $customKeyName,
                prompt: "e.g. MyKey",
            )
        }
    }

    @ViewBuilder
    func stateView(_ state: EnvValuesState) -> some View {
        switch state {
        case .builtIn:
            builtInStateView
        case .customEntry:
            customEntryStateView
        case .subscriptAccess:
            subscriptStateView
        }
    }

    var builtInStateView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("@Environment(\\.colorScheme)")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.accent)
            Text("private var scheme")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.primary)
        }
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    var customEntryStateView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("extension EnvironmentValues {")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.primary)
            Text("    @Entry var isPremium: Bool = false")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.accent)
            Text("}")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.primary)
        }
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    var subscriptStateView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("struct MyKey: EnvironmentKey {")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.primary)
            Text("    static let defaultValue = false")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.accent)
            Text("}")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.primary)
        }
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Code generation
private extension EnvironmentValuesShowcase {
    var generatedCode: String {
        if showCustomEntry {
            return customEntryCode
        }
        return inspectorModifierCode
    }

    var inspectorModifierCode: String {
        let entryLines = valueGroup.entries.map { entry in
            "    // \(entry.keyPath): \(entry.valueType)"
        }.joined(separator: "\n")
        return [
            "// Built-in \(valueGroup.label) EnvironmentValues:",
            entryLines,
            "",
            "// Read in a view:",
            "struct ExampleView: View {",
            "    @Environment(\\.colorScheme) private var colorScheme",
            "",
            "    var body: some View {",
            "        Text(colorScheme == .dark ? \"Dark\" : \"Light\")",
            "    }",
            "}",
        ].joined(separator: "\n")
    }

    var customEntryCode: String {
        let key = customKeyName.isEmpty ? "MyKey" : customKeyName
        let accessor = key.prefix(1).lowercased() + key.dropFirst()
        return [
            "// Option 1 — @Entry macro (preferred):",
            "extension EnvironmentValues {",
            "    @Entry var \(accessor): Bool = false",
            "}",
            "",
            "// Option 2 — Manual EnvironmentKey:",
            "private struct \(key): EnvironmentKey {",
            "    static let defaultValue: Bool = false",
            "}",
            "",
            "extension EnvironmentValues {",
            "    var \(accessor): Bool {",
            "        get { self[\(key).self] }",
            "        set { self[\(key).self] = newValue }",
            "    }",
            "}",
            "",
            "// Inject:",
            "ContentView()",
            "    .environment(\\.\(accessor), true)",
        ].joined(separator: "\n")
    }
}

// MARK: - Nested types
extension EnvironmentValuesShowcase {
    struct EnvEntry {
        let keyPath: String
        let valueType: String
    }

    enum ValueGroupOption: ShowcasePickable {
        case appearance
        case accessibility
        case layout
        case localization
        case actions
        case lifecycle
        case data

        var label: String {
            switch self {
            case .appearance: "Appearance"
            case .accessibility: "Accessibility"
            case .layout: "Layout"
            case .localization: "Localization"
            case .actions: "Actions"
            case .lifecycle: "Lifecycle"
            case .data: "Data"
            }
        }

        var systemImage: String {
            switch self {
            case .appearance: "paintbrush"
            case .accessibility: "accessibility"
            case .layout: "rectangle.3.group"
            case .localization: "globe"
            case .actions: "bolt"
            case .lifecycle: "waveform.path.ecg"
            case .data: "cylinder"
            }
        }

        var entries: [EnvEntry] {
            switch self {
            case .appearance:
                return [
                    EnvEntry(keyPath: "\\.colorScheme", valueType: "ColorScheme"),
                    EnvEntry(keyPath: "\\.tint", valueType: "Color?"),
                    EnvEntry(keyPath: "\\.displayScale", valueType: "CGFloat"),
                    EnvEntry(keyPath: "\\.pixelLength", valueType: "CGFloat"),
                    EnvEntry(keyPath: "\\.colorSchemeContrast", valueType: "ColorSchemeContrast"),
                ]
            case .accessibility:
                return [
                    EnvEntry(keyPath: "\\.accessibilityReduceMotion", valueType: "Bool"),
                    EnvEntry(keyPath: "\\.accessibilityReduceTransparency", valueType: "Bool"),
                    EnvEntry(keyPath: "\\.dynamicTypeSize", valueType: "DynamicTypeSize"),
                    EnvEntry(keyPath: "\\.legibilityWeight", valueType: "LegibilityWeight?"),
                    EnvEntry(keyPath: "\\.accessibilityDifferentiateWithoutColor", valueType: "Bool"),
                ]
            case .layout:
                return [
                    EnvEntry(keyPath: "\\.horizontalSizeClass", valueType: "UserInterfaceSizeClass?"),
                    EnvEntry(keyPath: "\\.verticalSizeClass", valueType: "UserInterfaceSizeClass?"),
                    EnvEntry(keyPath: "\\.layoutDirection", valueType: "LayoutDirection"),
                    EnvEntry(keyPath: "\\.defaultMinListRowHeight", valueType: "CGFloat"),
                ]
            case .localization:
                return [
                    EnvEntry(keyPath: "\\.locale", valueType: "Locale"),
                    EnvEntry(keyPath: "\\.calendar", valueType: "Calendar"),
                    EnvEntry(keyPath: "\\.timeZone", valueType: "TimeZone"),
                ]
            case .actions:
                return [
                    EnvEntry(keyPath: "\\.dismiss", valueType: "DismissAction"),
                    EnvEntry(keyPath: "\\.openURL", valueType: "OpenURLAction"),
                    EnvEntry(keyPath: "\\.refresh", valueType: "RefreshAction?"),
                    EnvEntry(keyPath: "\\.openWindow", valueType: "OpenWindowAction"),
                ]
            case .lifecycle:
                return [
                    EnvEntry(keyPath: "\\.scenePhase", valueType: "ScenePhase"),
                    EnvEntry(keyPath: "\\.isEnabled", valueType: "Bool"),
                    EnvEntry(keyPath: "\\.isFocused", valueType: "Bool"),
                    EnvEntry(keyPath: "\\.redactionReasons", valueType: "RedactionReasons"),
                ]
            case .data:
                return [
                    EnvEntry(keyPath: "\\.modelContext", valueType: "ModelContext"),
                    EnvEntry(keyPath: "\\.managedObjectContext", valueType: "NSManagedObjectContext"),
                ]
            }
        }
    }

    enum EnvValuesState: ShowcaseState {
        case builtIn
        case customEntry
        case subscriptAccess

        var caption: String {
            switch self {
            case .builtIn: "Built-in read"
            case .customEntry: "@Entry custom"
            case .subscriptAccess: "Manual key"
            }
        }
    }
}
