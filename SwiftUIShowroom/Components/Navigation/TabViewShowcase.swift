import SwiftUI

struct TabViewShowcase: View {
    @State private var tabCount = 3
    @State private var style: TabStyleOption = .automatic
    @State private var programmaticSelection = false
    @State private var selectedTab = 0

    var body: some View {
        ShowcaseScreen(
            title: "TabView",
            summary: "Top-level container that switches between child views via a tab bar or sidebar.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension TabViewShowcase {
    enum TabStyleOption: ShowcasePickable {
        case automatic
        case page
        case sidebarAdaptable

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .page: "page"
            case .sidebarAdaptable: "sidebarAdaptable"
            }
        }

        var codeLabel: String {
            switch self {
            case .automatic: ".automatic"
            case .page: ".page"
            case .sidebarAdaptable: ".sidebarAdaptable"
            }
        }
    }

    enum TabViewState: ShowcaseState {
        case defaultState
        case secondSelected
        case manyTabs

        var caption: String {
            switch self {
            case .defaultState: "Default (3 tabs)"
            case .secondSelected: "Tab 1 selected"
            case .manyTabs: "Five tabs"
            }
        }
    }
}

// MARK: - Sub-views
private extension TabViewShowcase {
    var preview: some View {
        demoView(
            tabCount: tabCount,
            style: style,
            fixedSelection: programmaticSelection ? selectedTab : nil,
        )
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseStepper("Tab count", value: $tabCount, in: 2...5)
        ShowcasePicker("Style", selection: $style)
        ShowcaseToggle("Programmatic selection", isOn: $programmaticSelection)
        if programmaticSelection {
            ShowcaseStepper("Selected tab", value: $selectedTab, in: 0...(tabCount - 1))
        }
    }

    @ViewBuilder
    func stateView(_ state: TabViewState) -> some View {
        switch state {
        case .defaultState:
            demoView(tabCount: 3, style: .automatic, fixedSelection: nil)
        case .secondSelected:
            demoView(tabCount: 3, style: .automatic, fixedSelection: 1)
        case .manyTabs:
            demoView(tabCount: 5, style: .automatic, fixedSelection: nil)
        }
    }

    func demoView(
        tabCount: Int,
        style: TabStyleOption,
        fixedSelection: Int?,
    ) -> some View {
        TabDemoView(tabCount: tabCount, style: style, fixedSelection: fixedSelection)
            .frame(maxWidth: 320, minHeight: 200)
            .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Code generation
private extension TabViewShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("struct TabViewDemo: View {")
        if programmaticSelection {
            lines.append("    @State private var selection = \(selectedTab)")
        }
        lines.append("")
        lines.append("    var body: some View {")
        let initLine = programmaticSelection
            ? "        TabView(selection: $selection) {"
            : "        TabView {"
        lines.append(initLine)
        for index in 0..<tabCount {
            let title = itemTitle(at: index)
            let icon = itemIcon(at: index)
            lines.append("            Tab(\"\(title)\", systemImage: \"\(icon)\", value: \(index)) {")
            lines.append("                Text(\"\(title)\")")
            lines.append("            }")
        }
        lines.append("        }")
        lines.append("        .tabViewStyle(\(style.codeLabel))")
        lines.append("    }")
        lines.append("}")
        return lines.joined(separator: "\n")
    }

    func itemTitle(at index: Int) -> String {
        let titles = ["Home", "Browse", "Profile", "Settings", "More"]
        return titles[min(index, titles.count - 1)]
    }

    func itemIcon(at index: Int) -> String {
        let icons = ["house", "square.grid.2x2", "person.crop.circle", "gear", "ellipsis"]
        return icons[min(index, icons.count - 1)]
    }
}

// MARK: - TabDemoView
private struct TabDemoView: View {
    let tabCount: Int
    let style: TabViewShowcase.TabStyleOption
    let fixedSelection: Int?

    @State private var selection = 0

    var body: some View {
        Group {
            if #available(iOS 18, macOS 15, tvOS 18, *) {
                modernTabView
            } else {
                legacyTabView
            }
        }
        .onAppear { selection = fixedSelection ?? 0 }
        .onChange(of: fixedSelection) { _, newValue in selection = newValue ?? 0 }
    }
}

// MARK: - Demo variants
private extension TabDemoView {
    @available(iOS 18, macOS 15, tvOS 18, *)
    @ViewBuilder
    var modernTabView: some View {
        let tabView = TabView(selection: $selection) {
            ForEach(0..<tabCount, id: \.self) { index in
                Tab(title(at: index), systemImage: icon(at: index), value: index) {
                    tabContent(title: title(at: index), index: index)
                }
            }
        }
        switch style {
        case .automatic:
            tabView.tabViewStyle(.automatic)
        case .page:
            #if os(tvOS)
            tabView.tabViewStyle(.automatic)
            #else
            tabView.tabViewStyle(.page)
            #endif
        case .sidebarAdaptable:
            #if os(iOS) || os(macOS)
            if #available(iOS 18, macOS 15, *) {
                tabView.tabViewStyle(.sidebarAdaptable)
            } else {
                tabView.tabViewStyle(.automatic)
            }
            #else
            tabView.tabViewStyle(.automatic)
            #endif
        }
    }

    @ViewBuilder
    var legacyTabView: some View {
        TabView(selection: $selection) {
            ForEach(0..<tabCount, id: \.self) { index in
                tabContent(title: title(at: index), index: index)
                    .tabItem { Label(title(at: index), systemImage: icon(at: index)) }
                    .tag(index)
            }
        }
    }

    func tabContent(title: String, index: Int) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Text(title).font(DesignSystem.Font.headline)
            Text("Tab \(index)").font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func title(at index: Int) -> String {
        let titles = ["Home", "Browse", "Profile", "Settings", "More"]
        return titles[min(index, titles.count - 1)]
    }

    func icon(at index: Int) -> String {
        let icons = ["house", "square.grid.2x2", "person.crop.circle", "gear", "ellipsis"]
        return icons[min(index, icons.count - 1)]
    }
}
