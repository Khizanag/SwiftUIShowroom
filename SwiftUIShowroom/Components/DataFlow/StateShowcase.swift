import SwiftUI

struct StateShowcase: View {
    @State private var valueKind: ValueKindOption = .bool
    @State private var isPrivate = true
    @State private var initialValueExpression = "false"
    @State private var boolValue = false
    @State private var intValue = 0
    @State private var doubleValue = 0.5
    @State private var stringValue = "Hello"

    var body: some View {
        ShowcaseScreen(
            title: "@State",
            summary: "View-owned source-of-truth for transient value-type state; re-renders the view on change.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension StateShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            currentControl
            currentValueLabel
        }
        .padding(DesignSystem.Spacing.medium)
    }

    @ViewBuilder
    var currentControl: some View {
        switch valueKind {
        case .bool:
            Toggle("State value", isOn: $boolValue)
                .tint(DesignSystem.Color.accent)
        case .int:
            Stepper("Count: \(intValue)", value: $intValue, in: 0...100)
        case .double:
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                Text("Slider: \(doubleValue, specifier: "%.2f")")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
                Slider(value: $doubleValue, in: 0...1)
                    .tint(DesignSystem.Color.accent)
            }
        case .string:
            TextField("Enter text", text: $stringValue)
                .textFieldStyle(.roundedBorder)
        case .date:
            DatePicker("Date", selection: .constant(Date()), displayedComponents: .date)
                .labelsHidden()
        case .customStruct:
            customStructPreview
        }
    }

    var customStructPreview: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("struct Point { var x: Double; var y: Double }")
                .font(DesignSystem.Font.code)
                .foregroundStyle(DesignSystem.Color.secondary)
            Text("@State private var point = Point(x: 0, y: 0)")
                .font(DesignSystem.Font.code)
                .foregroundStyle(DesignSystem.Color.primary)
        }
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    var currentValueLabel: some View {
        HStack {
            Image(systemName: "arrow.triangle.2.circlepath")
                .foregroundStyle(DesignSystem.Color.accent)
            Text("Mutating this triggers re-render")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Value kind", selection: $valueKind)
            .onChange(of: valueKind) { _, newValue in
                initialValueExpression = newValue.defaultExpression
            }
        ShowcaseToggle("Private modifier", isOn: $isPrivate)
        ShowcaseTextControl(
            "Initial value expression",
            text: $initialValueExpression,
            prompt: "e.g. false",
        )
    }

    @ViewBuilder
    func stateView(_ state: StateKind) -> some View {
        switch state {
        case .singleValue:
            singleValueDemo
        case .longContent:
            longContentDemo
        }
    }

    var singleValueDemo: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("@State private var isOn = false")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.primary)
            Toggle("Toggle", isOn: .constant(true))
                .tint(DesignSystem.Color.accent)
                .disabled(false)
                .allowsHitTesting(false)
        }
        .padding(DesignSystem.Spacing.small)
    }

    var longContentDemo: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("Multiple @State properties")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            Group {
                Text("@State private var name = \"\"")
                Text("@State private var age = 0")
                Text("@State private var active = false")
            }
            .font(DesignSystem.Font.codeInline)
            .foregroundStyle(DesignSystem.Color.primary)
        }
        .padding(DesignSystem.Spacing.small)
    }
}

// MARK: - Code generation
private extension StateShowcase {
    var generatedCode: String {
        let modifier = isPrivate ? "private " : ""
        let typeName = valueKind.typeName
        let expr = initialValueExpression.isEmpty ? valueKind.defaultExpression : initialValueExpression
        var lines = [
            "struct StateDemo: View {",
            "    @State \(modifier)var value: \(typeName) = \(expr)",
            "",
            "    var body: some View {",
        ]
        lines.append(contentsOf: controlLines)
        lines.append("    }")
        lines.append("}")
        return lines.joined(separator: "\n")
    }

    var controlLines: [String] {
        switch valueKind {
        case .bool:
            return ["        Toggle(\"State value\", isOn: $value)"]
        case .int:
            return ["        Stepper(\"Count \\(value)\", value: $value)"]
        case .double:
            return ["        Slider(value: $value, in: 0...1)"]
        case .string:
            return ["        TextField(\"Text\", text: $value)"]
        case .date:
            return ["        DatePicker(\"Date\", selection: $value, displayedComponents: .date)"]
        case .customStruct:
            return [
                "        // Mutate nested properties via derived bindings:",
                "        Slider(value: $value.x, in: 0...100)",
            ]
        }
    }
}

// MARK: - Nested enums
private extension StateShowcase {
    enum ValueKindOption: ShowcasePickable {
        case bool, int, double, string, date, customStruct

        var label: String {
            switch self {
            case .bool: "Bool"
            case .int: "Int"
            case .double: "Double"
            case .string: "String"
            case .date: "Date"
            case .customStruct: "CustomStruct"
            }
        }

        var typeName: String {
            switch self {
            case .bool: "Bool"
            case .int: "Int"
            case .double: "Double"
            case .string: "String"
            case .date: "Date"
            case .customStruct: "Point"
            }
        }

        var defaultExpression: String {
            switch self {
            case .bool: "false"
            case .int: "0"
            case .double: "0.0"
            case .string: "\"\""
            case .date: "Date()"
            case .customStruct: "Point(x: 0, y: 0)"
            }
        }
    }

    enum StateKind: ShowcaseState {
        case singleValue, longContent

        var caption: String {
            switch self {
            case .singleValue: "Single value"
            case .longContent: "Multiple values"
            }
        }
    }
}
