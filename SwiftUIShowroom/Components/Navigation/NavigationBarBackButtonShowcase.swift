import SwiftUI

struct NavigationBarBackButtonShowcase: View {
    @State private var backButtonHidden = false
    @State private var toolbarRole: ToolbarRoleOption = .automatic
    @State private var customBackButton = false

    var body: some View {
        ShowcaseScreen(
            title: "Back button & bar items",
            summary: "Control back-button visibility, a custom back affordance, and the bar's toolbarRole.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension NavigationBarBackButtonShowcase {
    enum ToolbarRoleOption: ShowcasePickable {
        case automatic
        case navigationStack
        case editor
        case browser

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .navigationStack: "navigationStack"
            case .editor: "editor"
            case .browser: "browser"
            }
        }

        var role: ToolbarRole {
            switch self {
            case .automatic: .automatic
            case .navigationStack: .navigationStack
            case .editor: .editor
            case .browser: .browser
            }
        }
    }
}

// MARK: - Sub-views
private extension NavigationBarBackButtonShowcase {
    var preview: some View {
        backButtonStack(
            backHidden: backButtonHidden,
            role: toolbarRole,
            customBack: customBackButton,
        )
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseToggle("Hide back button", isOn: $backButtonHidden)
        ShowcasePicker("Toolbar role", selection: $toolbarRole)
        ShowcaseToggle("Custom back button (when hidden)", isOn: $customBackButton)
    }

    @ViewBuilder
    func stateView(_ state: EnabledState) -> some View {
        switch state {
        case .enabled:
            backButtonStack(backHidden: false, role: .automatic, customBack: false)
        case .disabled:
            backButtonStack(backHidden: true, role: .automatic, customBack: true)
        }
    }

    func backButtonStack(
        backHidden: Bool,
        role: ToolbarRoleOption,
        customBack: Bool,
    ) -> some View {
        NavigationStack {
            detailView(backHidden: backHidden, role: role, customBack: customBack)
                .navigationDestination(for: Int.self) { _ in
                    EmptyView()
                }
        }
        .frame(maxWidth: 320, minHeight: 180)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ViewBuilder
    func detailView(
        backHidden: Bool,
        role: ToolbarRoleOption,
        customBack: Bool,
    ) -> some View {
        NavigationLink(value: 1) {
            Text("Push to detail")
                .font(DesignSystem.Font.body)
                .padding(DesignSystem.Spacing.medium)
        }
        .navigationTitle("Root")
        .navigationDestination(for: Int.self) { _ in
            pushedDetail(backHidden: backHidden, role: role, customBack: customBack)
        }
    }

    @ViewBuilder
    func pushedDetail(
        backHidden: Bool,
        role: ToolbarRoleOption,
        customBack: Bool,
    ) -> some View {
        Text("Detail view")
            .font(DesignSystem.Font.body)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Detail")
            .navigationBarBackButtonHidden(backHidden)
            .toolbarRole(role.role)
            .toolbar {
                #if os(iOS)
                if backHidden && customBack {
                    ToolbarItem(placement: .topBarLeading) {
                        customBackButtonView
                    }
                }
                #endif
            }
    }

    var customBackButtonView: some View {
        Button {
        } label: {
            HStack(spacing: DesignSystem.Spacing.xSmall) {
                Image(systemName: "chevron.backward")
                Text("Back")
                    .font(DesignSystem.Font.body)
            }
        }
    }
}

// MARK: - Code generation
private extension NavigationBarBackButtonShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("struct BackButtonDemo: View {")
        lines.append("    @Environment(\\.dismiss) private var dismiss")
        lines.append("")
        lines.append("    var body: some View {")
        lines.append("        Text(\"Detail\")")
        lines.append("            .navigationBarBackButtonHidden(\(backButtonHidden))")
        lines.append("            .toolbarRole(.\(toolbarRole.label))")
        if backButtonHidden && customBackButton {
            lines.append("            .toolbar {")
            lines.append("                ToolbarItem(placement: .topBarLeading) {")
            lines.append("                    Button { dismiss() } label: {")
            lines.append("                        Image(systemName: \"chevron.backward\")")
            lines.append("                    }")
            lines.append("                }")
            lines.append("            }")
        }
        lines.append("    }")
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}
