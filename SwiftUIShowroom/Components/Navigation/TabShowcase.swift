import SwiftUI

struct TabShowcase: View {
    @State private var tabTitle = "Home"
    @State private var systemImage = "house"
    @State private var role: TabRoleOption = .none
    @State private var badge = 0
    @State private var customizationID = "com.app.home"
    @State private var selectedTab = 0

    var body: some View {
        ShowcaseScreen(
            title: "Tab",
            summary: "Declarative tab item for TabView with a label, optional value, and role.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
fileprivate extension TabShowcase {
    enum TabRoleOption: ShowcasePickable {
        case none
        case search

        var label: String {
            switch self {
            case .none: "none"
            case .search: "search"
            }
        }
    }

    enum TabState: ShowcaseState {
        case defaultState
        case selected
        case disabled

        var caption: String {
            switch self {
            case .defaultState: "Default"
            case .selected: "Selected"
            case .disabled: "Disabled"
            }
        }
    }

    struct TabConfig {
        var activeTab: Int
        var badge: Int
        var title: String
        var image: String
        var role: TabRoleOption
        var isDisabled: Bool
        var customizationID: String
    }
}

// MARK: - Sub-views
private extension TabShowcase {
    var preview: some View {
        let config = TabConfig(
            activeTab: selectedTab,
            badge: badge,
            title: tabTitle,
            image: systemImage,
            role: role,
            isDisabled: false,
            customizationID: customizationID,
        )
        return tabContainer(config: config)
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Title", text: $tabTitle, prompt: "Home")
        ShowcaseTextControl("SF Symbol", text: $systemImage, prompt: "house")
        ShowcasePicker("Role", selection: $role)
        ShowcaseStepper("Badge", value: $badge, in: 0...99)
        ShowcaseTextControl("Customization ID", text: $customizationID, prompt: "com.app.home")
        ShowcaseStepper("Selected tab", value: $selectedTab, in: 0...2)
    }

    @ViewBuilder
    func stateView(_ state: TabState) -> some View {
        switch state {
        case .defaultState:
            tabContainer(config: TabConfig(
                activeTab: 1,
                badge: 0,
                title: tabTitle,
                image: systemImage,
                role: .none,
                isDisabled: false,
                customizationID: customizationID,
            ))
        case .selected:
            tabContainer(config: TabConfig(
                activeTab: 0,
                badge: badge,
                title: tabTitle,
                image: systemImage,
                role: .none,
                isDisabled: false,
                customizationID: customizationID,
            ))
        case .disabled:
            tabContainer(config: TabConfig(
                activeTab: 1,
                badge: 0,
                title: tabTitle,
                image: systemImage,
                role: .none,
                isDisabled: true,
                customizationID: customizationID,
            ))
        }
    }

    func tabContainer(config: TabConfig) -> some View {
        tabViewBody(config: config)
            .frame(maxWidth: 320, minHeight: 200)
            .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ViewBuilder
    func tabViewBody(config: TabConfig) -> some View {
        if config.role == .search {
            searchRoleTabView(config: config)
        } else {
            standardTabView(config: config)
        }
    }

    func standardTabView(config: TabConfig) -> some View {
        TabView(selection: .constant(config.activeTab)) {
            Tab(config.title, systemImage: config.image, value: 0) {
                Text("\(config.title) content")
            }
            .badge(config.badge)
            .customizationID(config.customizationID)
            .disabled(config.isDisabled)

            Tab("Browse", systemImage: "square.grid.2x2", value: 1) {
                Text("Browse content")
            }

            Tab("Profile", systemImage: "person.crop.circle", value: 2) {
                Text("Profile content")
            }
        }
    }

    func searchRoleTabView(config: TabConfig) -> some View {
        TabView(selection: .constant(config.activeTab)) {
            Tab("Home", systemImage: "house", value: 0) {
                Text("Home content")
            }
            Tab("Browse", systemImage: "square.grid.2x2", value: 1) {
                Text("Browse content")
            }

        }
    }
}

// MARK: - Code generation
private extension TabShowcase {
    var generatedCode: String {
        var lines: [String] = []
        if role == .search {
            lines.append("Tab(role: .search) {")
            lines.append("    Text(\"Search content\")")
            lines.append("}")
        } else {
            lines.append("Tab(\"\(tabTitle)\", systemImage: \"\(systemImage)\", value: 0) {")
            lines.append("    Text(\"\(tabTitle) content\")")
            lines.append("}")
            if badge > 0 {
                lines.append(".badge(\(badge))")
            }
            if !customizationID.isEmpty {
                lines.append(".customizationID(\"\(customizationID)\")")
            }
        }
        return lines.joined(separator: "\n")
    }
}
