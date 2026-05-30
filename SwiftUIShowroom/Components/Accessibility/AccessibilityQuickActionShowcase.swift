import SwiftUI

struct AccessibilityQuickActionShowcase: View {
    @State private var style: QuickActionStyle = .prompt
    @State private var isActive = true
    @State private var contentKind: ContentKind = .buttons

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Quick Action",
            summary: "Surfaces a quick action assistive-tech users can trigger contextually (watchOS 9+).",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityQuickActionShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            editorCard(style: style, isActive: isActive, contentKind: contentKind)
            platformNote
        }
        .padding(DesignSystem.Spacing.medium)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Style", selection: $style)
        ShowcaseToggle("isActive", isOn: $isActive)
        ShowcasePicker("Content", selection: $contentKind)
    }

    @ViewBuilder func stateView(_ state: QuickActionState) -> some View {
        editorCard(
            style: state.style,
            isActive: state.active,
            contentKind: .buttons,
        )
    }
}

// MARK: - Card builder
private extension AccessibilityQuickActionShowcase {
    func editorCard(
        style: QuickActionStyle,
        isActive: Bool,
        contentKind: ContentKind,
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            cardHeader(style: style, isActive: isActive)
            cardBody(contentKind: contentKind)
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .overlay(styleIndicator(style: style, isActive: isActive))
        .opacity(isActive ? 1 : 0.5)
    }

    func cardHeader(style: QuickActionStyle, isActive: Bool) -> some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "pencil.and.outline")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.accent)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.hairline) {
                Text("Editor View")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.primary)
                Text(isActive ? "Quick action: .\(style.rawValue)" : "Quick action inactive")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
            Spacer()
        }
    }

    func cardBody(contentKind: ContentKind) -> some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            switch contentKind {
            case .buttons:
                quickActionButton(label: "Format", icon: "textformat")
                quickActionButton(label: "Share", icon: "square.and.arrow.up")
            case .menu:
                quickActionButton(label: "Actions Menu", icon: "ellipsis.circle")
            }
        }
    }

    func quickActionButton(label: String, icon: String) -> some View {
        Label(label, systemImage: icon)
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.accent)
            .padding(.horizontal, DesignSystem.Spacing.small)
            .padding(.vertical, DesignSystem.Spacing.xSmall)
            .background(DesignSystem.Color.accent.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
    }

    @ViewBuilder
    func styleIndicator(style: QuickActionStyle, isActive: Bool) -> some View {
        if isActive && style == .outline {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .strokeBorder(DesignSystem.Color.accent, lineWidth: 2)
        }
    }

    var platformNote: some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: "applewatch")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            Text("accessibilityQuickAction is watchOS 9+ only.")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }
}

// MARK: - Code generation
private extension AccessibilityQuickActionShowcase {
    var generatedCode: String {
        let contentLines: String
        switch contentKind {
        case .buttons:
            contentLines = """
                    Button("Format") { format() }
                    Button("Share") { share() }
            """
        case .menu:
            contentLines = """
                    Menu("Actions") {
                        Button("Format") { format() }
                        Button("Share") { share() }
                    }
            """
        }
        return """
        EditorView()
            .accessibilityQuickAction(style: .\(style.rawValue), isActive: \(isActive)) {
        \(contentLines)
            }
        """
    }
}

// MARK: - Nested types
extension AccessibilityQuickActionShowcase {
    fileprivate enum QuickActionStyle: String, ShowcasePickable {
        case prompt
        case outline

        var label: String {
            switch self {
            case .prompt: ".prompt"
            case .outline: ".outline"
            }
        }
    }

    fileprivate enum ContentKind: String, ShowcasePickable {
        case buttons
        case menu

        var label: String {
            switch self {
            case .buttons: "Buttons"
            case .menu: "Menu"
            }
        }
    }

    fileprivate enum QuickActionState: ShowcaseState {
        case `default`
        case disabled

        var caption: String {
            switch self {
            case .default: "Active"
            case .disabled: "Inactive"
            }
        }

        var style: QuickActionStyle {
            switch self {
            case .default: .prompt
            case .disabled: .prompt
            }
        }

        var active: Bool {
            switch self {
            case .default: true
            case .disabled: false
            }
        }
    }
}
