import SwiftUI

struct AppstorageShowcase: View {
    enum StoredValueType: ShowcasePickable {
        case bool, int, double, string, url, data, rawRepresentableInt, rawRepresentableString, optional

        var label: String {
            switch self {
            case .bool: "Bool"
            case .int: "Int"
            case .double: "Double"
            case .string: "String"
            case .url: "URL"
            case .data: "Data"
            case .rawRepresentableInt: "RawRepresentable<Int>"
            case .rawRepresentableString: "RawRepresentable<String>"
            case .optional: "Optional"
            }
        }

        var typeName: String {
            switch self {
            case .bool: "Bool"
            case .int: "Int"
            case .double: "Double"
            case .string: "String"
            case .url: "URL?"
            case .data: "Data"
            case .rawRepresentableInt: "Theme"
            case .rawRepresentableString: "Language"
            case .optional: "String?"
            }
        }

        var defaultExpression: String {
            switch self {
            case .bool: "false"
            case .int: "0"
            case .double: "0.0"
            case .string: "\"\""
            case .url: "nil"
            case .data: "Data()"
            case .rawRepresentableInt: ".light"
            case .rawRepresentableString: ".en"
            case .optional: "nil"
            }
        }
    }

    enum StoreOption: ShowcasePickable {
        case standard, appGroupSuite, custom

        var label: String {
            switch self {
            case .standard: ".standard"
            case .appGroupSuite: "App Group suite"
            case .custom: "Custom suite"
            }
        }

        var storeExpression: String {
            switch self {
            case .standard: ""
            case .appGroupSuite: "UserDefaults(suiteName: \"group.com.example.app\")"
            case .custom: "UserDefaults(suiteName: \"com.example.custom\")"
            }
        }
    }

    enum StorageState: ShowcaseState {
        case keyPresent, keyAbsent

        var caption: String {
            switch self {
            case .keyPresent: "Key present"
            case .keyAbsent: "Key absent (default)"
            }
        }
    }

    @State private var storageKey = "hasSeenOnboarding"
    @State private var valueType: StoredValueType = .bool
    @State private var storeOption: StoreOption = .standard
    @State private var boolValue = false
    @State private var intValue = 0
    @State private var doubleValue = 0.0
    @State private var stringValue = "Hello"

    var body: some View {
        ShowcaseScreen(
            title: "@AppStorage",
            summary: "Reads and writes a UserDefaults value, re-rendering the view when that default changes.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AppstorageShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            persistenceBadge
            activeControl
            keyLabel
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var persistenceBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: "internaldrive")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.accent)
            Text("Persisted to UserDefaults")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }

    @ViewBuilder
    var activeControl: some View {
        switch valueType {
        case .bool:
            Toggle("Stored bool", isOn: $boolValue)
                .tint(DesignSystem.Color.accent)
        case .int:
            Stepper("Count: \(intValue)", value: $intValue, in: 0...100)
        case .double:
            doubleControl
        case .string:
            TextField("Stored string", text: $stringValue)
                .textFieldStyle(.roundedBorder)
        case .url:
            urlPreview
        case .data:
            dataPreview
        case .rawRepresentableInt:
            rawRepresentableIntPreview
        case .rawRepresentableString:
            rawRepresentableStringPreview
        case .optional:
            optionalPreview
        }
    }

    var doubleControl: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("Value: \(doubleValue, specifier: "%.2f")")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            Slider(value: $doubleValue, in: 0.0...1.0)
                .tint(DesignSystem.Color.accent)
        }
    }

    var urlPreview: some View {
        infoCard(
            code: "@AppStorage(\"\(storageKey)\") var url: URL?",
            note: "Stores a URL via absoluteString in UserDefaults",
        )
    }

    var dataPreview: some View {
        infoCard(
            code: "@AppStorage(\"\(storageKey)\") var blob: Data = Data()",
            note: "Stores raw Data bytes in UserDefaults",
        )
    }

    var rawRepresentableIntPreview: some View {
        infoCard(
            code: "@AppStorage(\"\(storageKey)\") var theme: Theme = .light",
            note: "enum Theme: Int { case light = 0, dark = 1 }",
        )
    }

    var rawRepresentableStringPreview: some View {
        infoCard(
            code: "@AppStorage(\"\(storageKey)\") var lang: Language = .en",
            note: "enum Language: String { case en, ka, de }",
        )
    }

    var optionalPreview: some View {
        infoCard(
            code: "@AppStorage(\"\(storageKey)\") var value: String?",
            note: "nil when the key has never been set",
        )
    }

    func infoCard(code: String, note: String) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text(code)
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.primary)
            Text(note)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    var keyLabel: some View {
        Text("key: \"\(storageKey)\"")
            .font(DesignSystem.Font.caption2)
            .foregroundStyle(DesignSystem.Color.secondary)
            .padding(.horizontal, DesignSystem.Spacing.small)
            .padding(.vertical, DesignSystem.Spacing.hairline)
            .background(DesignSystem.Color.cardBackground)
            .clipShape(Capsule())
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Key", text: $storageKey, prompt: "e.g. hasSeenOnboarding")
        ShowcasePicker("Value type", selection: $valueType)
        ShowcasePicker("Store", selection: $storeOption)
    }

    @ViewBuilder
    func stateView(_ state: StorageState) -> some View {
        switch state {
        case .keyPresent:
            stateCard(
                note: "Key present — value read from UserDefaults",
                value: true,
            )
        case .keyAbsent:
            stateCard(
                note: "Key absent — falls back to default value",
                value: false,
            )
        }
    }

    func stateCard(note: String, value: Bool) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text(note)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            Toggle("hasSeenOnboarding", isOn: .constant(value))
                .tint(DesignSystem.Color.accent)
                .allowsHitTesting(false)
        }
        .padding(DesignSystem.Spacing.small)
    }
}

// MARK: - Code generation
private extension AppstorageShowcase {
    var generatedCode: String {
        let keyArg = "\"\(storageKey)\""
        let storeArg = storeOption == .standard ? "" : ", store: \(storeOption.storeExpression)"
        let varDecl = "private var value: \(valueType.typeName) = \(valueType.defaultExpression)"
        let declaration = "@AppStorage(\(keyArg)\(storeArg)) \(varDecl)"
        var lines = [
            "struct AppStorageDemo: View {",
            "    \(declaration)",
            "",
            "    var body: some View {",
        ]
        lines.append(contentsOf: controlLines)
        lines.append("    }")
        lines.append("}")
        return lines.joined(separator: "\n")
    }

    var controlLines: [String] {
        switch valueType {
        case .bool:
            return ["        Toggle(\"Persisted\", isOn: $value)"]
        case .int:
            return ["        Stepper(\"Count \\(value)\", value: $value, in: 0...100)"]
        case .double:
            return ["        Slider(value: $value, in: 0.0...1.0)"]
        case .string:
            return ["        TextField(\"Stored text\", text: $value)"]
        case .url:
            return urlLines
        case .data:
            return ["        Text(\"\\(value.count) bytes stored\")"]
        case .rawRepresentableInt:
            return rawRepresentableIntLines
        case .rawRepresentableString:
            return rawRepresentableStringLines
        case .optional:
            return optionalLines
        }
    }

    var urlLines: [String] {
        [
            "        if let url = value {",
            "            Text(url.absoluteString)",
            "        }",
        ]
    }

    var rawRepresentableIntLines: [String] {
        [
            "        Picker(\"Theme\", selection: $value) {",
            "            Text(\"Light\").tag(0)",
            "            Text(\"Dark\").tag(1)",
            "        }",
        ]
    }

    var rawRepresentableStringLines: [String] {
        [
            "        Picker(\"Language\", selection: $value) {",
            "            Text(\"English\").tag(\"en\")",
            "            Text(\"Georgian\").tag(\"ka\")",
            "        }",
        ]
    }

    var optionalLines: [String] {
        [
            "        if let unwrapped = value {",
            "            Text(unwrapped)",
            "        } else {",
            "            Text(\"Not set yet\")",
            "        }",
        ]
    }
}
