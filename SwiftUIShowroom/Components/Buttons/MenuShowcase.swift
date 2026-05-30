import SwiftUI

struct MenuShowcase: View {
    @State private var titleText = "Actions"
    @State private var symbolName = "ellipsis.circle"
    @State private var menuStyle: MenuStyleOption = .automatic
    @State private var hasPrimaryAction = false
    @State private var useSections = false
    @State private var useNestedMenu = false
    @State private var menuOrder: MenuOrderOption = .automatic
    @State private var menuIndicator: MenuIndicatorOption = .automatic
    @State private var controlSize: MenuControlSizeOption = .regular
    @State private var isEnabled = true

    var body: some View {
        ShowcaseScreen(
            title: "Menu",
            summary: "A control that presents a menu of actions, optionally with a primary action.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension MenuShowcase {
    var preview: some View {
        styledMenu(isEnabled: isEnabled)
    }

    @ViewBuilder
    func styledMenu(isEnabled: Bool) -> some View {
        let base = menuView(isEnabled: isEnabled)
        switch menuStyle {
        case .automatic:
            base.menuStyle(.automatic)
        case .button:
            base.menuStyle(.button)
        case .borderlessButton:
            base.menuStyle(.button)
        }
    }

    func menuView(isEnabled: Bool) -> some View {
        Group {
            if hasPrimaryAction {
                Menu {
                    menuContent
                } label: {
                    Label(titleText, systemImage: symbolName)
                } primaryAction: {
                }
                .menuOrder(menuOrder.value)
                .menuIndicator(menuIndicator.value)
                .controlSize(controlSize.value)
                .disabled(!isEnabled)
            } else {
                Menu {
                    menuContent
                } label: {
                    Label(titleText, systemImage: symbolName)
                }
                .menuOrder(menuOrder.value)
                .menuIndicator(menuIndicator.value)
                .controlSize(controlSize.value)
                .disabled(!isEnabled)
            }
        }
    }

    @ViewBuilder
    var menuContent: some View {
        Button("Duplicate", systemImage: "plus.square.on.square") {}
        Button("Rename", systemImage: "pencil") {}
        if useNestedMenu {
            Menu("Copy") {
                Button("Copy") {}
                Button("Copy Path") {}
            }
        }
        if useSections {
            Section {
                Button("Delete", role: .destructive) {}
            }
        } else {
            Button("Delete", role: .destructive) {}
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Title", text: $titleText)
        ShowcaseTextControl("Symbol", text: $symbolName)
        ShowcasePicker("Style", selection: $menuStyle)
        ShowcasePicker("Order", selection: $menuOrder)
        ShowcasePicker("Indicator", selection: $menuIndicator)
        ShowcasePicker("Control size", selection: $controlSize)
        ShowcaseToggle("Primary action", isOn: $hasPrimaryAction)
        ShowcaseToggle("Use sections", isOn: $useSections)
        ShowcaseToggle("Nested submenu", isOn: $useNestedMenu)
        ShowcaseToggle("Enabled", isOn: $isEnabled)
    }

    @ViewBuilder
    func stateView(_ state: MenuVisualState) -> some View {
        switch state {
        case .default:
            styledMenu(isEnabled: true)
        case .disabled:
            styledMenu(isEnabled: false)
        case .withSections:
            Menu {
                Button("Duplicate", systemImage: "plus.square.on.square") {}
                Section {
                    Button("Delete", role: .destructive) {}
                }
            } label: {
                Label("Sections", systemImage: "list.bullet")
            }
        case .withSubmenu:
            Menu {
                Button("Rename", systemImage: "pencil") {}
                Menu("Copy") {
                    Button("Copy") {}
                    Button("Copy Path") {}
                }
            } label: {
                Label("Submenu", systemImage: "chevron.right")
            }
        }
    }
}

// MARK: - State enum
extension MenuShowcase {
    enum MenuVisualState: ShowcaseState {
        case `default`, disabled, withSections, withSubmenu

        var caption: String {
            switch self {
            case .default: "Default"
            case .disabled: "Disabled"
            case .withSections: "With sections"
            case .withSubmenu: "With submenu"
            }
        }
    }
}

// MARK: - Picker enums
extension MenuShowcase {
    enum MenuStyleOption: ShowcasePickable {
        case automatic, button, borderlessButton

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .button: "button"
            case .borderlessButton: "borderlessButton"
            }
        }

        var code: String { ".\(label)" }
    }

    enum MenuOrderOption: ShowcasePickable {
        case automatic, priority, fixed

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .priority: "priority"
            case .fixed: "fixed"
            }
        }

        var value: MenuOrder {
            switch self {
            case .automatic: .automatic
            case .priority: .priority
            case .fixed: .fixed
            }
        }
    }

    enum MenuIndicatorOption: ShowcasePickable {
        case automatic, visible, hidden

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .visible: "visible"
            case .hidden: "hidden"
            }
        }

        var value: Visibility {
            switch self {
            case .automatic: .automatic
            case .visible: .visible
            case .hidden: .hidden
            }
        }
    }

    enum MenuControlSizeOption: ShowcasePickable {
        case mini, small, regular, large, extraLarge

        var label: String {
            switch self {
            case .mini: "mini"
            case .small: "small"
            case .regular: "regular"
            case .large: "large"
            case .extraLarge: "extraLarge"
            }
        }

        var value: ControlSize {
            switch self {
            case .mini: .mini
            case .small: .small
            case .regular: .regular
            case .large: .large
            case .extraLarge: .extraLarge
            }
        }
    }
}

// MARK: - Code generation
private extension MenuShowcase {
    var generatedCode: String {
        var lines: [String] = ["Menu {"]
        lines.append("    Button(\"Duplicate\", systemImage: \"plus.square.on.square\") { }")
        lines.append("    Button(\"Rename\", systemImage: \"pencil\") { }")
        if useNestedMenu {
            lines.append("    Menu(\"Copy\") {")
            lines.append("        Button(\"Copy\") { }")
            lines.append("        Button(\"Copy Path\") { }")
            lines.append("    }")
        }
        if useSections {
            lines.append("    Section {")
            lines.append("        Button(\"Delete\", role: .destructive) { }")
            lines.append("    }")
        } else {
            lines.append("    Button(\"Delete\", role: .destructive) { }")
        }
        lines.append("} label: {")
        lines.append("    Label(\"\(titleText)\", systemImage: \"\(symbolName)\")")
        if hasPrimaryAction {
            lines.append("} primaryAction: {")
            lines.append("    // primary action")
        }
        lines.append("}")
        lines.append(".menuStyle(\(menuStyle.code))")
        lines.append(".menuOrder(.\(menuOrder.label))")
        lines.append(".menuIndicator(.\(menuIndicator.label))")
        lines.append(".controlSize(.\(controlSize.label))")
        if !isEnabled {
            lines.append(".disabled(true)")
        }
        return lines.joined(separator: "\n")
    }
}
