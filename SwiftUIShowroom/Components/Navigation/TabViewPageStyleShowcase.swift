import SwiftUI

struct TabViewPageStyleShowcase: View {
    @State private var pageCount = 3
    @State private var indexDisplayMode: IndexDisplayModeOption = .automatic
    @State private var backgroundDisplayMode: BackgroundDisplayModeOption = .automatic

    var body: some View {
        ShowcaseScreen(
            title: "TabView (page style)",
            summary: "Horizontally paging TabView with a dot page indicator for onboarding and galleries.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension TabViewPageStyleShowcase {
    enum IndexDisplayModeOption: ShowcasePickable {
        case automatic
        case always
        case never

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .always: "always"
            case .never: "never"
            }
        }
    }

    enum BackgroundDisplayModeOption: ShowcasePickable {
        case automatic
        case interactive
        case always
        case never

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .interactive: "interactive"
            case .always: "always"
            case .never: "never"
            }
        }
    }

    enum PageTabState: ShowcaseState {
        case defaultState
        case selected
        case longContent

        var caption: String {
            switch self {
            case .defaultState: "Default (3 pages)"
            case .selected: "Selected (page 2)"
            case .longContent: "Many pages (8)"
            }
        }
    }
}

// MARK: - Sub-views
private extension TabViewPageStyleShowcase {
    var preview: some View {
        pageTabViewDemo(
            pageCount: pageCount,
            initialPage: 0,
            indexDisplayMode: indexDisplayMode,
            backgroundDisplayMode: backgroundDisplayMode,
        )
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseStepper("Page count", value: $pageCount, in: 2...8)
        ShowcasePicker("Index display mode", selection: $indexDisplayMode)
        ShowcasePicker("Background display mode", selection: $backgroundDisplayMode)
    }

    @ViewBuilder
    func stateView(_ state: PageTabState) -> some View {
        switch state {
        case .defaultState:
            pageTabViewDemo(
                pageCount: 3,
                initialPage: 0,
                indexDisplayMode: .automatic,
                backgroundDisplayMode: .automatic,
            )
        case .selected:
            pageTabViewDemo(
                pageCount: 3,
                initialPage: 1,
                indexDisplayMode: .always,
                backgroundDisplayMode: .always,
            )
        case .longContent:
            pageTabViewDemo(
                pageCount: 8,
                initialPage: 0,
                indexDisplayMode: .automatic,
                backgroundDisplayMode: .automatic,
            )
        }
    }

    func pageTabViewDemo(
        pageCount: Int,
        initialPage: Int,
        indexDisplayMode: IndexDisplayModeOption,
        backgroundDisplayMode: BackgroundDisplayModeOption,
    ) -> some View {
        PageTabViewContainer(
            pageCount: pageCount,
            initialPage: initialPage,
            indexDisplayMode: indexDisplayMode,
            backgroundDisplayMode: backgroundDisplayMode,
        )
        .frame(maxWidth: 320, minHeight: 180)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Code generation
private extension TabViewPageStyleShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("struct PageTabViewDemo: View {")
        lines.append("    var body: some View {")
        lines.append("        TabView {")
        lines.append("            ForEach(0..<\(pageCount), id: \\.self) { index in")
        lines.append("                Text(\"Page \\(index + 1)\")")
        lines.append("                    .frame(maxWidth: .infinity, maxHeight: .infinity)")
        lines.append("            }")
        lines.append("        }")
        lines.append("        .tabViewStyle(.page(indexDisplayMode: .\(indexDisplayMode.label)))")
        lines.append("        .indexViewStyle(.page(backgroundDisplayMode: .\(backgroundDisplayMode.label)))")
        lines.append("    }")
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}

// MARK: - PageTabViewContainer
private struct PageTabViewContainer: View {
    let pageCount: Int
    let initialPage: Int
    let indexDisplayMode: TabViewPageStyleShowcase.IndexDisplayModeOption
    let backgroundDisplayMode: TabViewPageStyleShowcase.BackgroundDisplayModeOption

    var body: some View {
        #if os(tvOS) || os(macOS)
        unsupportedFallback
        #else
        pageTabView
        #endif
    }
}

// MARK: - Platform views
private extension PageTabViewContainer {
    #if !os(tvOS) && !os(macOS)
    var pageTabView: some View {
        PageTabViewBody(
            pageCount: pageCount,
            initialPage: initialPage,
            indexDisplayMode: indexDisplayMode,
            backgroundDisplayMode: backgroundDisplayMode,
        )
    }
    #endif

    var unsupportedFallback: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "swipe.left")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.secondary)
            Text("Page style")
                .font(DesignSystem.Font.headline)
            Text("iOS / watchOS only")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            HStack(spacing: DesignSystem.Spacing.xSmall) {
                ForEach(0..<min(pageCount, 5), id: \.self) { index in
                    Circle()
                        .frame(
                            width: index == initialPage
                                ? DesignSystem.Size.Icon.small
                                : DesignSystem.Size.Icon.small * 0.6,
                            height: index == initialPage
                                ? DesignSystem.Size.Icon.small
                                : DesignSystem.Size.Icon.small * 0.6,
                        )
                        .foregroundStyle(
                            index == initialPage
                                ? DesignSystem.Color.accent
                                : DesignSystem.Color.secondary,
                        )
                }
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Color.cardBackground)
    }
}

// MARK: - PageTabViewBody (iOS/iPadOS/watchOS only)
#if !os(tvOS) && !os(macOS)
private struct PageTabViewBody: View {
    let pageCount: Int
    let initialPage: Int
    let indexDisplayMode: TabViewPageStyleShowcase.IndexDisplayModeOption
    let backgroundDisplayMode: TabViewPageStyleShowcase.BackgroundDisplayModeOption

    @State private var selection = 0

    var body: some View {
        tabViewContent
            .applyPageStyle(indexDisplayMode: indexDisplayMode)
            .applyIndexViewStyle(backgroundDisplayMode: backgroundDisplayMode)
            .onAppear { selection = initialPage }
    }

    private var tabViewContent: some View {
        TabView(selection: $selection) {
            ForEach(0..<pageCount, id: \.self) { index in
                pageContent(at: index)
                    .tag(index)
            }
        }
    }

    private func pageContent(at index: Int) -> some View {
        let colors: [Color] = [
            .blue, .purple, .green, .orange, .red, .teal, .indigo, .pink,
        ]
        let color = colors[index % colors.count]
        return ZStack {
            color.opacity(0.18)
            VStack(spacing: DesignSystem.Spacing.small) {
                Image(systemName: pageIcon(at: index))
                    .font(DesignSystem.Font.title)
                    .foregroundStyle(color)
                Text("Page \(index + 1)")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.primary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func pageIcon(at index: Int) -> String {
        let icons = [
            "house", "magnifyingglass", "heart", "star", "bell",
            "person", "gear", "bookmark",
        ]
        return icons[index % icons.count]
    }
}

// MARK: - Style modifiers
private extension View {
    func applyPageStyle(
        indexDisplayMode: TabViewPageStyleShowcase.IndexDisplayModeOption
    ) -> some View {
        switch indexDisplayMode {
        case .automatic:
            return AnyView(self.tabViewStyle(.page(indexDisplayMode: .automatic)))
        case .always:
            return AnyView(self.tabViewStyle(.page(indexDisplayMode: .always)))
        case .never:
            return AnyView(self.tabViewStyle(.page(indexDisplayMode: .never)))
        }
    }

    func applyIndexViewStyle(
        backgroundDisplayMode: TabViewPageStyleShowcase.BackgroundDisplayModeOption
    ) -> some View {
        switch backgroundDisplayMode {
        case .automatic:
            return AnyView(self.indexViewStyle(.page(backgroundDisplayMode: .automatic)))
        case .interactive:
            return AnyView(self.indexViewStyle(.page(backgroundDisplayMode: .interactive)))
        case .always:
            return AnyView(self.indexViewStyle(.page(backgroundDisplayMode: .always)))
        case .never:
            return AnyView(self.indexViewStyle(.page(backgroundDisplayMode: .never)))
        }
    }
}
#endif
