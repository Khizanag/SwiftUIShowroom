import SwiftUI

struct TabSectionShowcase: View {
    enum TabSectionState: ShowcaseState {
        case defaultState
        case selected
        case longContent
        var caption: String {
            switch self {
            case .defaultState: "Default"
            case .selected: "Selected tab"
            case .longContent: "Many children"
            }
        }
    }

    @State private var header = "Library"
    @State private var childCount = 3
    @State private var customizationID = "com.app.library"

    var body: some View {
        ShowcaseScreen(
            title: "TabSection",
            summary: "Groups secondary tabs into a labeled section for the sidebarAdaptable TabView style.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension TabSectionShowcase {
    var preview: some View {
        tabSectionDemo(
            header: header,
            childCount: childCount,
            selectedIndex: 0,
        )
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Header", text: $header, prompt: "Library")
        ShowcaseStepper("Child tabs", value: $childCount, in: 1...6)
        ShowcaseTextControl("Customization ID", text: $customizationID, prompt: "com.app.library")
    }

    @ViewBuilder
    func stateView(_ state: TabSectionState) -> some View {
        switch state {
        case .defaultState:
            tabSectionDemo(header: "Library", childCount: 3, selectedIndex: 0)
        case .selected:
            tabSectionDemo(header: "Library", childCount: 3, selectedIndex: 1)
        case .longContent:
            tabSectionDemo(header: "More", childCount: 6, selectedIndex: 0)
        }
    }

    func tabSectionDemo(
        header: String,
        childCount: Int,
        selectedIndex: Int,
    ) -> some View {
        #if !os(tvOS)
        TabSectionDemoView(
            header: header,
            childCount: childCount,
            selectedIndex: selectedIndex,
        )
        #else
        tvOSFallback(header: header, childCount: childCount)
        #endif
    }

    func tvOSFallback(header: String, childCount: Int) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text(header)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.secondary)
            ForEach(0..<childCount, id: \.self) { index in
                Label(sectionTabTitle(at: index), systemImage: sectionTabIcon(at: index))
                    .font(DesignSystem.Font.body)
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .frame(maxWidth: 280)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Code generation
private extension TabSectionShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("TabView {")
        lines.append("    Tab(\"Home\", systemImage: \"house\", value: 0) { Text(\"Home\") }")
        lines.append("        .customizationID(\"tab.home\")")
        lines.append("    TabSection(\"\(header)\") {")
        for index in 0..<childCount {
            let title = sectionTabTitle(at: index)
            let icon = sectionTabIcon(at: index)
            let valueIndex = index + 10
            let tabLine = "        Tab(\"\(title)\", systemImage: \"\(icon)\", value: \(valueIndex)) {"
            lines.append(tabLine)
            lines.append("            Text(\"\(title)\")")
            lines.append("        }")
        }
        lines.append("    }")
        lines.append("    .customizationID(\"\(customizationID)\")")
        lines.append("}")
        lines.append(".tabViewStyle(.sidebarAdaptable)")
        return lines.joined(separator: "\n")
    }
}

// MARK: - Shared helpers
private extension TabSectionShowcase {
    func sectionTabTitle(at index: Int) -> String {
        let titles = ["Recently Added", "Artists", "Albums", "Playlists", "Podcasts", "Radio"]
        return index < titles.count ? titles[index] : "Tab \(index + 1)"
    }

    func sectionTabIcon(at index: Int) -> String {
        let icons = [
            "clock", "music.mic", "square.stack",
            "music.note.list", "mic", "antenna.radiowaves.left.and.right",
        ]
        return index < icons.count ? icons[index] : "square"
    }
}

#if !os(tvOS)
// MARK: - Demo view (non-tvOS)
private struct TabSectionDemoView: View {
    let header: String
    let childCount: Int
    let selectedIndex: Int

    @State private var selection: Int = 0
    @State private var customization = TabViewCustomization()

    var body: some View {
        TabView(selection: $selection) {
            Tab("Home", systemImage: "house", value: 0) {
                Text("Home")
            }
            .customizationID("demo.tab.home")
            TabSection(header) {
                ForEach(0..<childCount, id: \.self) { index in
                    Tab(
                        tabTitle(at: index),
                        systemImage: tabIcon(at: index),
                        value: index + 10,
                    ) {
                        Text(tabTitle(at: index))
                    }
                    .customizationID("demo.tab.section.\(index)")
                }
            }
            .customizationID("demo.section.library")
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabViewCustomization($customization)
        .frame(maxWidth: 300, minHeight: 200)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
        .onAppear {
            selection = selectedIndex == 0 ? 0 : selectedIndex + 10
        }
    }

    private func tabTitle(at index: Int) -> String {
        let titles = ["Recently Added", "Artists", "Albums", "Playlists", "Podcasts", "Radio"]
        return index < titles.count ? titles[index] : "Tab \(index + 1)"
    }

    private func tabIcon(at index: Int) -> String {
        let icons = [
            "clock", "music.mic", "square.stack", "music.note.list", "mic",
            "antenna.radiowaves.left.and.right",
        ]
        return index < icons.count ? icons[index] : "square"
    }
}
#endif
