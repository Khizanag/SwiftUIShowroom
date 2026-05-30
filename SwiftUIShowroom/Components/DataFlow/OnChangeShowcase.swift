import SwiftUI

struct OnChangeShowcase: View {
    @State private var observedText = "Hello"
    @State private var fireInitial = false
    @State private var closureShape: ClosureShapeOption = .oldNew
    @State private var changeLog: [String] = []

    var body: some View {
        ShowcaseScreen(
            title: "onChange(of:initial:_:)",
            summary: "Runs an action when an Equatable value changes; optionally fires on first appear.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension OnChangeShowcase {
    fileprivate enum ClosureShapeOption: ShowcasePickable {
        case noParams, oldNew

        var label: String {
            switch self {
            case .noParams: "No params"
            case .oldNew: "oldValue, newValue"
            }
        }
    }

    fileprivate enum DemoState: ShowcaseState {
        case `default`

        var caption: String {
            switch self {
            case .default: "Default"
            }
        }
    }
}

// MARK: - Sub-views
private extension OnChangeShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            inputField
            logList
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var inputField: some View {
        TextField("Type something…", text: $observedText)
            .textFieldStyle(.roundedBorder)
            .onChange(of: observedText, initial: fireInitial) { oldValue, newValue in
                let entry = closureShape == .oldNew
                    ? "\"\(oldValue)\" → \"\(newValue)\""
                    : "changed"
                changeLog.insert(entry, at: 0)
                if changeLog.count > 5 {
                    changeLog = Array(changeLog.prefix(5))
                }
            }
    }

    var logList: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundStyle(DesignSystem.Color.accent)
                    .font(DesignSystem.Font.caption)
                Text("Change log")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
                Spacer()
                if !changeLog.isEmpty {
                    Button("Clear") {
                        changeLog = []
                    }
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.accent)
                }
            }
            if changeLog.isEmpty {
                Text("No changes yet — type above")
                    .font(DesignSystem.Font.footnote)
                    .foregroundStyle(DesignSystem.Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(changeLog, id: \.self) { entry in
                    Text(entry)
                        .font(DesignSystem.Font.codeInline)
                        .foregroundStyle(DesignSystem.Color.primary)
                        .lineLimit(1)
                }
            }
        }
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl(
            "Observed value",
            text: $observedText,
            prompt: "Type to trigger onChange",
        )
        ShowcaseToggle("initial: fires on appear", isOn: $fireInitial)
        ShowcasePicker("Closure shape", selection: $closureShape)
    }

    @ViewBuilder
    func stateView(_ state: DemoState) -> some View {
        switch state {
        case .default:
            defaultStateView
        }
    }

    var defaultStateView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("TextField(\"Query\", text: $query)")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.primary)
            Text("    .onChange(of: query, initial: false) { old, new in")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.secondary)
            Text("        performSearch()")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.secondary)
            Text("    }")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Code generation
private extension OnChangeShowcase {
    var generatedCode: String {
        let initialFlag = fireInitial ? "true" : "false"
        let closureSignature = closureShape == .oldNew
            ? "oldValue, newValue in"
            : ""
        let lines: [String]
        if closureShape == .oldNew {
            lines = [
                "TextField(\"Query\", text: $query)",
                "    .onChange(of: query, initial: \(initialFlag)) { \(closureSignature)",
                "        performSearch()",
                "    }",
            ]
        } else {
            lines = [
                "TextField(\"Query\", text: $query)",
                "    .onChange(of: query, initial: \(initialFlag)) {",
                "        performSearch()",
                "    }",
            ]
        }
        return lines.joined(separator: "\n")
    }
}
