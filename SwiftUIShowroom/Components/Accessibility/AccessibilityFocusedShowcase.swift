import SwiftUI

struct AccessibilityFocusedShowcase: View {
    fileprivate enum FocusField: String, ShowcasePickable, CaseIterable {
        case title
        case errorMessage
        case firstField
        case summary

        var label: String {
            switch self {
            case .title: "title"
            case .errorMessage: "errorMessage"
            case .firstField: "firstField"
            case .summary: "summary"
            }
        }
    }

    fileprivate enum FocusPhase: ShowcaseState, CaseIterable {
        case idle
        case focused
        case error

        var caption: String {
            switch self {
            case .idle: "Default (idle)"
            case .focused: "Focused"
            case .error: "Error — focus moved to field"
            }
        }
    }

    @State private var focusBool = false
    @State private var equalsValue: FocusField = .errorMessage
    @State private var hasError = false
    @AccessibilityFocusState private var boolFocus: Bool
    @AccessibilityFocusState private var enumFocus: FocusField?

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Focus State",
            summary: "Reads and programmatically moves VoiceOver focus to a specific element.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityFocusedShowcase {
    var preview: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            boolFocusRow
            Divider()
            enumFocusRow
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var boolFocusRow: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("Bool binding")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(
                    boolFocus
                        ? DesignSystem.Color.accent.opacity(0.15)
                        : DesignSystem.Color.cardBackground
                )
                .overlay(
                    Text(boolFocus ? "Focused" : "Not focused")
                        .font(DesignSystem.Font.body)
                        .foregroundStyle(
                            boolFocus ? DesignSystem.Color.accent : DesignSystem.Color.primary
                        ),
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .stroke(
                            boolFocus ? DesignSystem.Color.accent : DesignSystem.Color.separator,
                            lineWidth: boolFocus ? 2 : 1,
                        ),
                )
                .frame(height: 52)
                .accessibilityFocused($boolFocus)
            Button("Move focus here") {
                boolFocus = true
            }
            .font(DesignSystem.Font.footnote)
        }
    }

    var enumFocusRow: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("Enum binding — \(equalsValue.label)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            ForEach(FocusField.allCases) { field in
                enumFieldRow(field)
            }
            Button("Trigger error (focus \(FocusField.errorMessage.label))") {
                hasError = true
                enumFocus = .errorMessage
            }
            .font(DesignSystem.Font.footnote)
            .onChange(of: hasError) { _, newValue in
                if newValue { enumFocus = .errorMessage }
            }
        }
    }

    func enumFieldRow(_ field: FocusField) -> some View {
        let isFocused = enumFocus == field
        return RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
            .fill(
                isFocused
                    ? DesignSystem.Color.accent.opacity(0.15)
                    : DesignSystem.Color.cardBackground
            )
            .overlay(
                Text(field.label)
                    .font(DesignSystem.Font.footnote)
                    .foregroundStyle(
                        isFocused ? DesignSystem.Color.accent : DesignSystem.Color.primary
                    ),
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .stroke(
                        isFocused ? DesignSystem.Color.accent : DesignSystem.Color.separator,
                        lineWidth: isFocused ? 2 : 1,
                    ),
            )
            .frame(height: 40)
            .accessibilityFocused($enumFocus, equals: field)
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("Bool focus active", isOn: $focusBool)
            .onChange(of: focusBool) { _, newValue in
                boolFocus = newValue
            }
        ShowcasePicker("equals value", selection: $equalsValue)
        ShowcaseToggle("Trigger error focus", isOn: $hasError)
    }

    @ViewBuilder func stateView(_ state: FocusPhase) -> some View {
        switch state {
        case .idle: focusStateCard(isFocused: false, isError: false, label: "Idle")
        case .focused: focusStateCard(isFocused: true, isError: false, label: "Focused")
        case .error: focusStateCard(isFocused: true, isError: true, label: "Error field")
        }
    }

    func focusStateCard(isFocused: Bool, isError: Bool, label: String) -> some View {
        VStack(spacing: DesignSystem.Spacing.xSmall) {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(
                    isError
                        ? Color.red.opacity(0.1)
                        : isFocused
                            ? DesignSystem.Color.accent.opacity(0.15)
                            : DesignSystem.Color.cardBackground
                )
                .overlay(
                    HStack(spacing: DesignSystem.Spacing.xSmall) {
                        if isError {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundStyle(.red)
                                .font(DesignSystem.Font.footnote)
                        }
                        Text(label)
                            .font(DesignSystem.Font.footnote)
                            .foregroundStyle(
                                isError
                                    ? Color.red
                                    : isFocused
                                        ? DesignSystem.Color.accent
                                        : DesignSystem.Color.primary
                            )
                    },
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .stroke(
                            isError
                                ? Color.red
                                : isFocused
                                    ? DesignSystem.Color.accent
                                    : DesignSystem.Color.separator,
                            lineWidth: isFocused || isError ? 2 : 1,
                        ),
                )
                .frame(height: 52)
        }
        .padding(DesignSystem.Spacing.small)
    }
}

// MARK: - Code generation
private extension AccessibilityFocusedShowcase {
    var generatedCode: String {
        """
        @AccessibilityFocusState private var focus: Field?

        var body: some View {
            TextField("Email", text: $email)
                .accessibilityFocused($focus, equals: .\(equalsValue.rawValue))
                .onChange(of: hasError) { _, error in
                    if error { focus = .\(equalsValue.rawValue) }
                }
        }
        """
    }
}
