import SwiftUI

struct TabViewSidebarAdaptableShowcase: View {
    @State private var primaryTabCount = 2
    @State private var sectionChildCount = 3
    @State private var enableCustomization = true
    @State private var showSidebarHeader = false

    var body: some View {
        ShowcaseScreen(
            title: "TabView (sidebar adaptable)",
            summary: "Renders as a tab bar in compact widths and promotes to a sidebar on iPad and Mac.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension TabViewSidebarAdaptableShowcase {
    enum SidebarAdaptableState: ShowcaseState {
        case defaultState
        case selected
        case longContent

        var caption: String {
            switch self {
            case .defaultState: "Default"
            case .selected: "Second tab selected"
            case .longContent: "Many tabs"
            }
        }
    }
}

// MARK: - Sub-views
private extension TabViewSidebarAdaptableShowcase {
    var preview: some View {
        demoView(
            primaryTabCount: primaryTabCount,
            sectionChildCount: sectionChildCount,
            enableCustomization: enableCustomization,
            showSidebarHeader: showSidebarHeader,
            selectedPrimaryTab: 0,
        )
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseStepper("Primary tabs", value: $primaryTabCount, in: 1...4)
        ShowcaseStepper("Section children", value: $sectionChildCount, in: 1...6)
        ShowcaseToggle("Enable customization", isOn: $enableCustomization)
        ShowcaseToggle("Sidebar header", isOn: $showSidebarHeader)
    }

    @ViewBuilder
    func stateView(_ state: SidebarAdaptableState) -> some View {
        switch state {
        case .defaultState:
            demoView(
                primaryTabCount: 2,
                sectionChildCount: 3,
                enableCustomization: true,
                showSidebarHeader: false,
                selectedPrimaryTab: 0,
            )
        case .selected:
            demoView(
                primaryTabCount: 2,
                sectionChildCount: 3,
                enableCustomization: true,
                showSidebarHeader: false,
                selectedPrimaryTab: 1,
            )
        case .longContent:
            demoView(
                primaryTabCount: 4,
                sectionChildCount: 6,
                enableCustomization: true,
                showSidebarHeader: true,
                selectedPrimaryTab: 0,
            )
        }
    }

    func demoView(
        primaryTabCount: Int,
        sectionChildCount: Int,
        enableCustomization: Bool,
        showSidebarHeader: Bool,
        selectedPrimaryTab: Int,
    ) -> some View {
        #if !os(tvOS)
        SidebarAdaptableDemoView(
            primaryTabCount: primaryTabCount,
            sectionChildCount: sectionChildCount,
            enableCustomization: enableCustomization,
            showSidebarHeader: showSidebarHeader,
            initialSelection: selectedPrimaryTab,
        )
        .frame(maxWidth: 320, minHeight: 220)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
        #else
        tvOSFallback(primaryTabCount: primaryTabCount, sectionChildCount: sectionChildCount)
        #endif
    }

    #if os(tvOS)
    func tvOSFallback(primaryTabCount: Int, sectionChildCount: Int) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            ForEach(0..<primaryTabCount, id: \.self) { index in
                Label(primaryTabTitle(at: index), systemImage: primaryTabIcon(at: index))
                    .font(DesignSystem.Font.body)
            }
            Divider()
            Text("Library")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
            ForEach(0..<sectionChildCount, id: \.self) { index in
                Label(sectionTabTitle(at: index), systemImage: sectionTabIcon(at: index))
                    .font(DesignSystem.Font.body)
                    .padding(.leading, DesignSystem.Spacing.medium)
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .frame(maxWidth: 280)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }
    #endif
}

// MARK: - Code generation
private extension TabViewSidebarAdaptableShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("struct SidebarAdaptableTabDemo: View {")
        if enableCustomization {
            lines.append("    @State private var customization = TabViewCustomization()")
        }
        lines.append("")
        lines.append("    var body: some View {")
        lines.append("        TabView {")
        for index in 0..<primaryTabCount {
            let title = primaryTabTitle(at: index)
            let icon = primaryTabIcon(at: index)
            lines.append("            Tab(\"\(title)\", systemImage: \"\(icon)\") { Text(\"\(title)\") }")
            lines.append("                .customizationID(\"tab.\(title.lowercased())\")")
        }
        lines.append("            TabSection(\"Library\") {")
        for index in 0..<sectionChildCount {
            let title = sectionTabTitle(at: index)
            let icon = sectionTabIcon(at: index)
            lines.append("                Tab(\"\(title)\", systemImage: \"\(icon)\") { Text(\"\(title)\") }")
            let customID = title.lowercased().replacingOccurrences(of: " ", with: ".")
            lines.append("                    .customizationID(\"tab.\(customID)\")")
        }
        lines.append("            }")
        lines.append("            .customizationID(\"section.library\")")
        if showSidebarHeader {
            lines.append("        }")
            lines.append("        .tabViewSidebarHeader {")
            lines.append("            Text(\"My App\")")
            lines.append("                .font(.headline)")
            lines.append("        }")
        } else {
            lines.append("        }")
        }
        lines.append("        .tabViewStyle(.sidebarAdaptable)")
        if enableCustomization {
            lines.append("        .tabViewCustomization($customization)")
        }
        lines.append("    }")
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}

// MARK: - Shared helpers
private extension TabViewSidebarAdaptableShowcase {
    func primaryTabTitle(at index: Int) -> String {
        let titles = ["Home", "Browse", "Profile", "Settings"]
        return index < titles.count ? titles[index] : "Tab \(index + 1)"
    }

    func primaryTabIcon(at index: Int) -> String {
        let icons = ["house", "square.grid.2x2", "person.crop.circle", "gear"]
        return index < icons.count ? icons[index] : "square"
    }

    func sectionTabTitle(at index: Int) -> String {
        let titles = ["Recently Added", "Artists", "Albums", "Playlists", "Podcasts", "Radio"]
        return index < titles.count ? titles[index] : "Tab \(index + 1)"
    }

    func sectionTabIcon(at index: Int) -> String {
        let icons = [
            "clock",
            "music.mic",
            "square.stack",
            "music.note.list",
            "mic",
            "antenna.radiowaves.left.and.right",
        ]
        return index < icons.count ? icons[index] : "square"
    }
}

#if !os(tvOS)
// MARK: - Demo view (non-tvOS)
private struct SidebarAdaptableDemoView: View {
    let primaryTabCount: Int
    let sectionChildCount: Int
    let enableCustomization: Bool
    let showSidebarHeader: Bool
    let initialSelection: Int

    @State private var selection: Int = 0
    @State private var customization = TabViewCustomization()

    var body: some View {
        if #available(iOS 18, macOS 15, *) {
            modernView
        } else {
            legacyView
        }
    }

    @available(iOS 18, macOS 15, *)
    private var modernView: some View {
        let tabView = TabView(selection: $selection) {
            ForEach(0..<primaryTabCount, id: \.self) { index in
                Tab(
                    primaryTitle(at: index),
                    systemImage: primaryIcon(at: index),
                    value: index,
                ) {
                    tabContent(title: primaryTitle(at: index))
                }
                .customizationID("demo.primary.\(index)")
            }
            TabSection("Library") {
                ForEach(0..<sectionChildCount, id: \.self) { index in
                    Tab(
                        sectionTitle(at: index),
                        systemImage: sectionIcon(at: index),
                        value: 100 + index,
                    ) {
                        tabContent(title: sectionTitle(at: index))
                    }
                    .customizationID("demo.section.\(index)")
                }
            }
            .customizationID("demo.section.library")
        }
        .tabViewStyle(.sidebarAdaptable)
        .modifier(CustomizationModifier(enabled: enableCustomization, customization: $customization))
        .modifier(SidebarHeaderModifier(show: showSidebarHeader))
        .onAppear { selection = initialSelection }

        return tabView
    }

    private var legacyView: some View {
        TabView(selection: $selection) {
            ForEach(0..<primaryTabCount, id: \.self) { index in
                tabContent(title: primaryTitle(at: index))
                    .tabItem { Label(primaryTitle(at: index), systemImage: primaryIcon(at: index)) }
                    .tag(index)
            }
        }
        .onAppear { selection = initialSelection }
    }

    private func tabContent(title: String) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Text(title)
                .font(DesignSystem.Font.headline)
            Text("Content")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func primaryTitle(at index: Int) -> String {
        let titles = ["Home", "Browse", "Profile", "Settings"]
        return index < titles.count ? titles[index] : "Tab \(index + 1)"
    }

    private func primaryIcon(at index: Int) -> String {
        let icons = ["house", "square.grid.2x2", "person.crop.circle", "gear"]
        return index < icons.count ? icons[index] : "square"
    }

    private func sectionTitle(at index: Int) -> String {
        let titles = ["Recently Added", "Artists", "Albums", "Playlists", "Podcasts", "Radio"]
        return index < titles.count ? titles[index] : "Tab \(index + 1)"
    }

    private func sectionIcon(at index: Int) -> String {
        let icons = [
            "clock",
            "music.mic",
            "square.stack",
            "music.note.list",
            "mic",
            "antenna.radiowaves.left.and.right",
        ]
        return index < icons.count ? icons[index] : "square"
    }
}

// MARK: - Customization modifier
@available(iOS 18, macOS 15, *)
private struct CustomizationModifier: ViewModifier {
    let enabled: Bool
    @Binding var customization: TabViewCustomization

    func body(content: Content) -> some View {
        if enabled {
            content.tabViewCustomization($customization)
        } else {
            content
        }
    }
}

// MARK: - Sidebar header modifier
@available(iOS 18, macOS 15, *)
private struct SidebarHeaderModifier: ViewModifier {
    let show: Bool

    func body(content: Content) -> some View {
        if show {
            content.tabViewSidebarHeader {
                Text("My App")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.primary)
            }
        } else {
            content
        }
    }
}
#endif
