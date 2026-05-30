import SwiftUI

// MARK: - @Entry demo — custom EnvironmentValues entries
private extension EnvironmentValues {
    @Entry var showcaseIsPremium: Bool = false
    @Entry var showcaseThemeColor: Color = .accentColor
    @Entry var showcaseUserName: String = "Guest"
}

struct EntryMacroShowcase: View {
    @State private var targetStructure: TargetStructure = .environmentValues
    @State private var entryName: String = "isPremium"
    @State private var valueType: ValueType = .bool
    @State private var defaultValueText: String = "false"
    @State private var isPremiumDemo: Bool = false
    @State private var themeColorDemo: Color = .accentColor
    @State private var userNameDemo: String = "Alice"

    var body: some View {
        ShowcaseScreen(
            title: "@Entry",
            summary: "Adds a custom entry to EnvironmentValues, Transaction, ContainerValues, or FocusedValues.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension EntryMacroShowcase {
    var preview: some View {
        EntryDemoConsumerView(
            isPremium: isPremiumDemo,
            themeColor: themeColorDemo,
            userName: userNameDemo,
        )
        .frame(maxWidth: 340)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Target structure", selection: $targetStructure)
        ShowcaseTextControl("Property name", text: $entryName, prompt: "e.g. isPremium")
        ShowcasePicker("Value type", selection: $valueType)
        ShowcaseTextControl(
            "Default value",
            text: $defaultValueText,
            prompt: "e.g. false",
        )
        ShowcaseSection("Live demo values") {
            ShowcaseToggle("isPremium (Bool demo)", isOn: $isPremiumDemo)
            ShowcaseColorControl("themeColor (Color demo)", selection: $themeColorDemo, supportsOpacity: false)
            ShowcaseTextControl("userName (String demo)", text: $userNameDemo, prompt: "Name")
        }
    }

    @ViewBuilder func stateView(_ state: EnabledState) -> some View {
        EntryDemoConsumerView(
            isPremium: state == .enabled,
            themeColor: themeColorDemo,
            userName: userNameDemo,
        )
        .disabled(state == .disabled)
        .frame(maxWidth: 300)
    }
}

// MARK: - Code generation
private extension EntryMacroShowcase {
    var generatedCode: String {
        let resolvedType = valueType.swiftTypeName
        let resolvedDefault = defaultValueText.isEmpty ? valueType.exampleDefault : defaultValueText
        let isFocused = targetStructure == .focusedValues
        if isFocused {
            return """
            extension FocusedValues {
                @Entry var \(entryName): \(resolvedType)?
            }

            // Reading in a command or menu:
            struct DemoCommands: View {
                @FocusedValue(\\.\\(entryName)) private var value

                var body: some View {
                    Button("Action") { value?.doSomething() }
                        .disabled(value == nil)
                }
            }
            """
        } else {
            return """
            extension \(targetStructure.rawValue) {
                @Entry var \(entryName): \(resolvedType) = \(resolvedDefault)
            }

            // Injecting into a subtree:
            ContentView()
                .environment(\\.\\(entryName), \(resolvedDefault))

            // Reading in a child view:
            struct ChildView: View {
                @Environment(\\.\\(entryName)) private var \(entryName)

                var body: some View {
                    Text("\\(\\(\(entryName)))")
                }
            }
            """
        }
    }
}

// MARK: - Demo consumer view
private struct EntryDemoConsumerView: View {
    let isPremium: Bool
    let themeColor: Color
    let userName: String

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            header
            environmentRows
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground, in: .rect(cornerRadius: DesignSystem.CornerRadius.medium))
        .environment(\.showcaseIsPremium, isPremium)
        .environment(\.showcaseThemeColor, themeColor)
        .environment(\.showcaseUserName, userName)
    }
}

// MARK: - Sub-views
private extension EntryDemoConsumerView {
    var header: some View {
        Text("@Entry consumer")
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    var environmentRows: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            EntryValueRow(
                keyLabel: "isPremium",
                valueLabel: isPremium ? "true" : "false",
                accent: themeColor,
            )
            EntryValueRow(
                keyLabel: "themeColor",
                valueLabel: "Color",
                accent: themeColor,
            )
            EntryValueRow(
                keyLabel: "userName",
                valueLabel: userName,
                accent: themeColor,
            )
        }
    }
}

// MARK: - Entry value row
private struct EntryValueRow: View {
    let keyLabel: String
    let valueLabel: String
    let accent: Color

    var body: some View {
        HStack {
            Text(keyLabel)
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.primary)
            Spacer()
            Text(valueLabel)
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(accent)
                .lineLimit(1)
        }
        .padding(.horizontal, DesignSystem.Spacing.small)
        .padding(.vertical, DesignSystem.Spacing.xSmall)
        .background(DesignSystem.Color.background, in: .rect(cornerRadius: DesignSystem.CornerRadius.small))
    }
}

// MARK: - Nested enums
extension EntryMacroShowcase {
    enum TargetStructure: String, ShowcasePickable {
        case environmentValues = "EnvironmentValues"
        case transaction = "Transaction"
        case containerValues = "ContainerValues"
        case focusedValues = "FocusedValues"

        var label: String {
            switch self {
            case .environmentValues: "EnvironmentValues"
            case .transaction: "Transaction"
            case .containerValues: "ContainerValues"
            case .focusedValues: "FocusedValues"
            }
        }
    }

    enum ValueType: ShowcasePickable {
        case bool
        case int
        case double
        case string
        case color

        var label: String {
            switch self {
            case .bool: "Bool"
            case .int: "Int"
            case .double: "Double"
            case .string: "String"
            case .color: "Color"
            }
        }

        var swiftTypeName: String {
            switch self {
            case .bool: "Bool"
            case .int: "Int"
            case .double: "Double"
            case .string: "String"
            case .color: "Color"
            }
        }

        var exampleDefault: String {
            switch self {
            case .bool: "false"
            case .int: "0"
            case .double: "0.0"
            case .string: "\"\""
            case .color: ".accentColor"
            }
        }
    }
}
