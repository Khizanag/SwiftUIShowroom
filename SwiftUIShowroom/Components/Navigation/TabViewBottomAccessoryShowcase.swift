import SwiftUI

struct TabViewBottomAccessoryShowcase: View {
    @State private var accessoryEnabled = true
    @State private var labelText = "Now Playing"
    @State private var selectedTab = 0

    var body: some View {
        ShowcaseScreen(
            title: "TabView bottom accessory",
            summary: "Attaches a persistent accessory view above the Liquid Glass tab bar.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension TabViewBottomAccessoryShowcase {
    enum AccessoryState: ShowcaseState {
        case defaultState
        case longContent

        var caption: String {
            switch self {
            case .defaultState: "Default"
            case .longContent: "Long label"
            }
        }
    }
}

// MARK: - Sub-views
private extension TabViewBottomAccessoryShowcase {
    var preview: some View {
        accessoryTabView(
            enabled: accessoryEnabled,
            label: labelText,
            selectedTab: selectedTab,
        )
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseToggle("Accessory enabled", isOn: $accessoryEnabled)
        ShowcaseTextControl("Label", text: $labelText, prompt: "Now Playing")
    }

    @ViewBuilder
    func stateView(_ state: AccessoryState) -> some View {
        switch state {
        case .defaultState:
            accessoryTabView(
                enabled: true,
                label: "Now Playing",
                selectedTab: 0,
            )
        case .longContent:
            accessoryTabView(
                enabled: true,
                label: "An extremely long now-playing label that may overflow",
                selectedTab: 0,
            )
        }
    }

    func accessoryTabView(
        enabled: Bool,
        label: String,
        selectedTab: Int,
    ) -> some View {
        #if os(iOS)
        TabView(selection: .constant(selectedTab)) {
            Tab("Home", systemImage: "house", value: 0) {
                ZStack {
                    Color.clear
                    Text("Home")
                        .font(DesignSystem.Font.body)
                }
            }
            Tab("Library", systemImage: "books.vertical", value: 1) {
                ZStack {
                    Color.clear
                    Text("Library")
                        .font(DesignSystem.Font.body)
                }
            }
        }
        .tabViewBottomAccessory {
            if enabled {
                accessoryBar(label: label)
            }
        }
        .frame(height: 320)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        #else
        unavailablePlaceholder(label: label, enabled: enabled)
        #endif
    }

    #if os(iOS)
    func accessoryBar(label: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "play.fill")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(label)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.primary)
                .lineLimit(1)
            Spacer()
            Button {
            } label: {
                Image(systemName: "forward.fill")
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.medium)
        .padding(.vertical, DesignSystem.Spacing.small)
    }
    #endif

    func unavailablePlaceholder(label: String, enabled: Bool) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "iphone")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.secondary)
            Text("tabViewBottomAccessory")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.primary)
            Text("iOS 26 / iPadOS 26 only")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            if enabled {
                HStack(spacing: DesignSystem.Spacing.xSmall) {
                    Image(systemName: "play.fill")
                    Text(label)
                        .lineLimit(1)
                }
                .font(DesignSystem.Font.callout)
                .foregroundStyle(DesignSystem.Color.accent)
                .padding(.top, DesignSystem.Spacing.xSmall)
            }
        }
        .padding(DesignSystem.Spacing.large)
    }
}

// MARK: - Code generation
private extension TabViewBottomAccessoryShowcase {
    var generatedCode: String {
        let accessoryBody = accessoryEnabled
            ? "    HStack {\n        Image(systemName: \"play.fill\")\n        Text(\"\(labelText)\")\n    }"
            : "    // accessory hidden"
        return """
        TabView {
            Tab("Home", systemImage: "house") { Text("Home") }
            Tab("Library", systemImage: "books.vertical") { Text("Library") }
        }
        .tabViewBottomAccessory {
        \(accessoryBody)
        }
        """
    }
}
