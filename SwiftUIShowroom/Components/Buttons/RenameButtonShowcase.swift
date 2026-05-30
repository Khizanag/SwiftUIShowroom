import SwiftUI

struct RenameButtonShowcase: View {
    @State private var isEnabled = true
    @State private var context: RenameContext = .contextMenu
    @State private var itemName = "Untitled"
    @State private var isRenaming = false
    @FocusState private var fieldFocused: Bool

    var body: some View {
        ShowcaseScreen(
            title: "RenameButton",
            summary: "A button that triggers a rename action registered via the renameAction modifier.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension RenameButtonShowcase {
    enum RenameContext: ShowcasePickable {
        case contextMenu, toolbar, focusedValue

        var label: String {
            switch self {
            case .contextMenu: "contextMenu"
            case .toolbar: "toolbar"
            case .focusedValue: "focusedValue"
            }
        }

        var codeComment: String {
            switch self {
            case .contextMenu: "// in contextMenu"
            case .toolbar: "// in toolbar"
            case .focusedValue: "// via focusedValue"
            }
        }
    }
}

// MARK: - Sub-views
private extension RenameButtonShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
#if os(tvOS)
            unavailableNotice
#else
            renameableItem(
                name: $itemName,
                isRenaming: $isRenaming,
                fieldFocused: $fieldFocused,
                isEnabled: isEnabled,
                context: context,
            )
            Text("Long-press or right-click the item to rename it.")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
#endif
        }
    }

    @ViewBuilder
    var controls: some View {
#if !os(tvOS)
        ShowcasePicker("Context", selection: $context)
        ShowcaseToggle("Enabled", isOn: $isEnabled)
        ShowcaseTextControl("Item name", text: $itemName)
#else
        Text("RenameButton is not available on tvOS.")
            .font(DesignSystem.Font.footnote)
            .foregroundStyle(DesignSystem.Color.secondary)
#endif
    }

    @ViewBuilder
    func stateView(_ state: EnabledState) -> some View {
#if os(tvOS)
        unavailableNotice
#else
        renameableItemStatic(
            name: "Document",
            isEnabled: state == .enabled,
        )
#endif
    }

    var unavailableNotice: some View {
        Text("RenameButton is not available on tvOS.")
            .font(DesignSystem.Font.footnote)
            .foregroundStyle(DesignSystem.Color.secondary)
            .padding(DesignSystem.Spacing.medium)
    }
}

// MARK: - Component builders
private extension RenameButtonShowcase {
#if !os(tvOS)
    @ViewBuilder
    func renameableItem(
        name: Binding<String>,
        isRenaming: Binding<Bool>,
        fieldFocused: FocusState<Bool>.Binding,
        isEnabled: Bool,
        context: RenameContext,
    ) -> some View {
        Group {
            if isRenaming.wrappedValue {
                TextField("Name", text: name)
                    .focused(fieldFocused)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 240)
                    .onSubmit { isRenaming.wrappedValue = false }
            } else {
                itemLabel(name: name.wrappedValue)
                    .modifier(
                        RenameContextModifier(
                            context: context,
                            isEnabled: isEnabled,
                        )
                    )
                    .renameAction {
                        isRenaming.wrappedValue = true
                        fieldFocused.wrappedValue = true
                    }
            }
        }
        .animation(.default, value: isRenaming.wrappedValue)
    }

    func itemLabel(name: String) -> some View {
        Label(name, systemImage: "doc.text")
            .font(DesignSystem.Font.body)
            .foregroundStyle(DesignSystem.Color.primary)
            .padding(DesignSystem.Spacing.small)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .fill(DesignSystem.Color.cardBackground)
            )
    }

    func renameableItemStatic(name: String, isEnabled: Bool) -> some View {
        itemLabel(name: name)
            .contextMenu {
                RenameButton()
                    .disabled(!isEnabled)
            }
            .renameAction {}
    }
#endif
}

// MARK: - RenameContext modifier
#if !os(tvOS)
private struct RenameContextModifier: ViewModifier {
    let context: RenameButtonShowcase.RenameContext
    let isEnabled: Bool

    func body(content: Content) -> some View {
        switch context {
        case .contextMenu:
            content.contextMenu {
                RenameButton()
                    .disabled(!isEnabled)
            }
        case .toolbar:
            content
        case .focusedValue:
            content.contextMenu {
                RenameButton()
                    .disabled(!isEnabled)
            }
        }
    }
}
#endif

// MARK: - Code generation
private extension RenameButtonShowcase {
    var generatedCode: String {
#if os(tvOS)
        return "// RenameButton is not available on tvOS."
#else
        let disabledLine = isEnabled ? "" : "\n        .disabled(true)"
        return """
        Text(name)
            .contextMenu { \(context.codeComment)
                RenameButton()\(disabledLine)
            }
            .renameAction {
                isRenaming = true
            }
        """
#endif
    }
}
