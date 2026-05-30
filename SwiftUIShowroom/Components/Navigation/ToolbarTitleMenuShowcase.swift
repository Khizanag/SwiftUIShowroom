import SwiftUI

struct ToolbarTitleMenuShowcase: View {
    enum TitleMenuState: ShowcaseState {
        case defaultState
        case withItems
        case noMenu

        var caption: String {
            switch self {
            case .defaultState: "Default (empty menu)"
            case .withItems: "With custom items"
            case .noMenu: "No menu attached"
            }
        }
    }

    @State private var itemCount = 3
    @State private var useDefaultMenu = false

    var body: some View {
        ShowcaseScreen(
            title: "Toolbar Title Menu",
            summary: "Attaches a menu to the navigation title, revealed by tapping the title.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ToolbarTitleMenuShowcase {
    var preview: some View {
        demoView(itemCount: itemCount, useDefaultMenu: useDefaultMenu, attachMenu: true)
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseStepper("Item count", value: $itemCount, in: 1...6)
        ShowcaseToggle("Use default menu", isOn: $useDefaultMenu)
    }

    @ViewBuilder
    func stateView(_ state: TitleMenuState) -> some View {
        switch state {
        case .defaultState:
            demoView(itemCount: 0, useDefaultMenu: true, attachMenu: true)
        case .withItems:
            demoView(itemCount: 3, useDefaultMenu: false, attachMenu: true)
        case .noMenu:
            demoView(itemCount: 3, useDefaultMenu: false, attachMenu: false)
        }
    }

    func demoView(itemCount: Int, useDefaultMenu: Bool, attachMenu: Bool) -> some View {
        #if os(tvOS)
        Text("toolbarTitleMenu is unavailable on tvOS")
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.secondary)
            .frame(maxWidth: 320, minHeight: 220)
        #else
        NavigationStack {
            List(0..<6, id: \.self) { index in
                Text("Row \(index + 1)")
            }
            .navigationTitle("Document")
            .modifier(
                TitleMenuModifier(
                    itemCount: itemCount,
                    useDefaultMenu: useDefaultMenu,
                    attachMenu: attachMenu,
                )
            )
        }
        .frame(maxWidth: 320, minHeight: 220)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
        #endif
    }
}

// MARK: - Code generation
private extension ToolbarTitleMenuShowcase {
    var generatedCode: String {
        #if os(tvOS)
        return "// toolbarTitleMenu is unavailable on tvOS"
        #else
        var lines: [String] = []
        lines.append("NavigationStack {")
        lines.append("    Text(\"Content\")")
        lines.append("        .navigationTitle(\"Document\")")
        if useDefaultMenu {
            lines.append("        .toolbarTitleMenu {}")
        } else {
            lines.append("        .toolbarTitleMenu {")
            let allItems = TitleMenuModifier.allMenuItems
            let count = min(itemCount, allItems.count)
            for index in 0..<count {
                let (title, symbol) = allItems[index]
                lines.append("            Button {")
                lines.append("            } label: {")
                lines.append("                Label(\"\(title)\", systemImage: \"\(symbol)\")")
                lines.append("            }")
            }
            lines.append("        }")
        }
        lines.append("}")
        return lines.joined(separator: "\n")
        #endif
    }
}

// MARK: - TitleMenuModifier
#if !os(tvOS)
private struct TitleMenuModifier: ViewModifier {
    let itemCount: Int
    let useDefaultMenu: Bool
    let attachMenu: Bool

    static let allMenuItems: [(String, String)] = [
        ("Rename", "pencil"),
        ("Duplicate", "plus.square.on.square"),
        ("Move", "folder"),
        ("Print", "printer"),
        ("Share", "square.and.arrow.up"),
        ("Delete", "trash"),
    ]

    func body(content: Content) -> some View {
        if !attachMenu {
            content
        } else if useDefaultMenu {
            content.toolbarTitleMenu {}
        } else {
            content.toolbarTitleMenu {
                let count = min(itemCount, Self.allMenuItems.count)
                ForEach(0..<count, id: \.self) { index in
                    Button {
                    } label: {
                        Label(
                            Self.allMenuItems[index].0,
                            systemImage: Self.allMenuItems[index].1,
                        )
                    }
                }
            }
        }
    }
}
#endif
