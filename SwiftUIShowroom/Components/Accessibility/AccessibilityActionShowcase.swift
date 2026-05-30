import SwiftUI

struct AccessibilityActionShowcase: View {
    @State private var actionKind: ActionKind = .default
    @State private var actionName = "Delete"
    @State private var lastFired = "—"
    @State private var isDisabled = false

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Action",
            summary: "Adds default, escape, or named custom actions VoiceOver can invoke.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityActionShowcase {
    var preview: some View {
        actionRow(
            kind: actionKind,
            name: actionName,
            disabled: isDisabled,
            lastFired: $lastFired,
        )
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Kind", selection: $actionKind)
        ShowcaseTextControl("Named action label", text: $actionName, prompt: "e.g. Delete")
        ShowcaseToggle("Disabled", isOn: $isDisabled)
    }

    @ViewBuilder func stateView(_ state: ActionState) -> some View {
        actionRow(
            kind: state.kind,
            name: state.name,
            disabled: state.isDisabled,
            lastFired: .constant("—"),
        )
    }
}

// MARK: - Row builder
private extension AccessibilityActionShowcase {
    func actionRow(
        kind: ActionKind,
        name: String,
        disabled: Bool,
        lastFired: Binding<String>,
    ) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            rowCard(kind: kind, name: name, disabled: disabled, lastFired: lastFired)
            HStack(spacing: DesignSystem.Spacing.xSmall) {
                Image(systemName: "bell")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.accent)
                Text("Last fired: \(lastFired.wrappedValue)")
                    .font(DesignSystem.Font.footnote)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
        .padding(DesignSystem.Spacing.medium)
    }

    func rowCard(
        kind: ActionKind,
        name: String,
        disabled: Bool,
        lastFired: Binding<String>,
    ) -> some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: "doc.text")
                .font(DesignSystem.Font.title3)
                .foregroundStyle(DesignSystem.Color.accent)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.hairline) {
                Text("Row item")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.primary)
                Text(disabled ? "Actions disabled" : "Activate in VoiceOver")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
            Spacer()
            Image(systemName: "ellipsis")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .opacity(disabled ? 0.5 : 1)
        .accessibilityElement(children: .combine)
        .modifier(AccessibilityActionModifier(kind: kind, name: name, lastFired: lastFired))
        .disabled(disabled)
    }
}

// MARK: - Code generation
private extension AccessibilityActionShowcase {
    var generatedCode: String {
        let kindLine = "    .accessibilityAction(.\(actionKind.rawValue)) { primaryAction() }"
        let namedLine = "    .accessibilityAction(named: \"\(actionName)\") { namedAction() }"
        return """
        RowView(item: item)
        \(kindLine)
        \(namedLine)
        """
    }
}

// MARK: - Accessibility modifier
private struct AccessibilityActionModifier: ViewModifier {
    let kind: AccessibilityActionShowcase.ActionKind
    let name: String
    let lastFired: Binding<String>

    func body(content: Content) -> some View {
        content
            .accessibilityAction(kind.actionKind) {
                lastFired.wrappedValue = ".\(kind.rawValue)"
            }
            .accessibilityAction(named: Text(name)) {
                lastFired.wrappedValue = name
            }
    }
}

// MARK: - Nested types
extension AccessibilityActionShowcase {
    fileprivate enum ActionKind: String, ShowcasePickable {
        case `default`
        case escape
        #if !os(macOS)
        case magicTap
        #endif

        var label: String {
            switch self {
            case .default: ".default"
            case .escape: ".escape"
            #if !os(macOS)
            case .magicTap: ".magicTap"
            #endif
            }
        }

        var actionKind: AccessibilityActionKind {
            switch self {
            case .default: .default
            case .escape: .escape
            #if !os(macOS)
            case .magicTap: .magicTap
            #endif
            }
        }
    }

    fileprivate enum ActionState: ShowcaseState {
        case defaultEnabled
        case namedAction
        case disabled

        var caption: String {
            switch self {
            case .defaultEnabled: "Default"
            case .namedAction: "Named action"
            case .disabled: "Disabled"
            }
        }

        var kind: ActionKind {
            switch self {
            case .defaultEnabled: .default
            case .namedAction: .default
            case .disabled: .default
            }
        }

        var name: String {
            switch self {
            case .defaultEnabled: "Delete"
            case .namedAction: "Add to favourites"
            case .disabled: "Delete"
            }
        }

        var isDisabled: Bool {
            switch self {
            case .defaultEnabled: false
            case .namedAction: false
            case .disabled: true
            }
        }
    }
}
