import SwiftUI

struct NavigationTitleShowcase: View {
    @State private var titleText = "Title"
    @State private var displayMode: DisplayModeOption = .automatic
    @State private var subtitleText = ""
    @State private var editable = false
    @State private var showTitleMenu = false
    @State private var editableTitle = "Title"

    var body: some View {
        ShowcaseScreen(
            title: "Navigation title",
            summary: "Sets the navigation container title with display modes, subtitle, and title menu.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension NavigationTitleShowcase {
    enum DisplayModeOption: ShowcasePickable {
        case automatic
        case inline
        case large

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .inline: "inline"
            case .large: "large"
            }
        }
    }

    enum TitleState: ShowcaseState {
        case defaultState
        case longContent

        var caption: String {
            switch self {
            case .defaultState: "Default"
            case .longContent: "Long title"
            }
        }
    }

    struct TitleConfig {
        var title: String
        var displayMode: DisplayModeOption
        var subtitle: String
        var editable: Bool
        var showMenu: Bool
    }
}

// MARK: - Sub-views
private extension NavigationTitleShowcase {
    var preview: some View {
        let config = TitleConfig(
            title: editable ? editableTitle : titleText,
            displayMode: displayMode,
            subtitle: subtitleText,
            editable: editable,
            showMenu: showTitleMenu,
        )
        return titleDemo(config: config)
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Title", text: $titleText, prompt: "Title")
        #if os(iOS)
        ShowcasePicker("Display mode", selection: $displayMode)
        #endif
        #if !os(tvOS)
        ShowcaseTextControl("Subtitle (macOS)", text: $subtitleText, prompt: "Optional subtitle")
        #endif
        ShowcaseToggle("Editable title", isOn: $editable)
        ShowcaseToggle("Title menu", isOn: $showTitleMenu)
    }

    @ViewBuilder
    func stateView(_ state: TitleState) -> some View {
        switch state {
        case .defaultState:
            titleDemo(config: TitleConfig(
                title: "Title",
                displayMode: .automatic,
                subtitle: "",
                editable: false,
                showMenu: false,
            ))
        case .longContent:
            titleDemo(config: TitleConfig(
                title: "A Very Long Navigation Title That Truncates",
                displayMode: .inline,
                subtitle: "With a subtitle line",
                editable: false,
                showMenu: false,
            ))
        }
    }

    func titleDemo(config: TitleConfig) -> some View {
        NavigationStack {
            demoContent(config: config)
        }
        .frame(maxWidth: 320, minHeight: 220)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ViewBuilder
    func demoContent(config: TitleConfig) -> some View {
        let rows = ["First row", "Second row", "Third row", "Fourth row", "Fifth row"]
        List(rows, id: \.self) { row in
            Text(row)
        }
        .modifier(
            TitleModifier(
                config: config,
                editableBinding: $editableTitle,
            )
        )
    }
}

// MARK: - TitleModifier
private struct TitleModifier: ViewModifier {
    let config: NavigationTitleShowcase.TitleConfig
    @Binding var editableBinding: String

    func body(content: Content) -> some View {
        if config.editable {
            content
                .navigationTitle($editableBinding)
                #if os(iOS)
                .navigationBarTitleDisplayMode(config.displayMode.barMode)
                #endif
                #if !os(tvOS)
                .modifier(SubtitleModifier(subtitle: config.subtitle))
                #endif
                .modifier(TitleMenuModifier(showMenu: config.showMenu))
        } else {
            content
                .navigationTitle(config.title)
                #if os(iOS)
                .navigationBarTitleDisplayMode(config.displayMode.barMode)
                #endif
                #if !os(tvOS)
                .modifier(SubtitleModifier(subtitle: config.subtitle))
                #endif
                .modifier(TitleMenuModifier(showMenu: config.showMenu))
        }
    }
}

// MARK: - SubtitleModifier
private struct SubtitleModifier: ViewModifier {
    let subtitle: String

    func body(content: Content) -> some View {
        #if os(macOS)
        if subtitle.isEmpty {
            content
        } else {
            content.navigationSubtitle(subtitle)
        }
        #else
        content
        #endif
    }
}

// MARK: - TitleMenuModifier
private struct TitleMenuModifier: ViewModifier {
    let showMenu: Bool

    func body(content: Content) -> some View {
        #if !os(tvOS)
        if showMenu {
            content.toolbarTitleMenu {
                Button("Rename") {}
                Button("Duplicate") {}
                Button("Move") {}
            }
        } else {
            content
        }
        #else
        content
        #endif
    }
}

// MARK: - Code generation
private extension NavigationTitleShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("Text(\"Content\")")
        if editable {
            lines.append("    .navigationTitle($title)")
        } else {
            lines.append("    .navigationTitle(\"\(titleText)\")")
        }
        #if os(iOS)
        lines.append("    .navigationBarTitleDisplayMode(.\(displayMode.label))")
        #endif
        if !subtitleText.isEmpty {
            lines.append("    .navigationSubtitle(\"\(subtitleText)\")")
        }
        if showTitleMenu {
            lines.append("    .toolbarTitleMenu {")
            lines.append("        Button(\"Rename\") {}")
            lines.append("        Button(\"Duplicate\") {}")
            lines.append("        Button(\"Move\") {}")
            lines.append("    }")
        }
        return lines.joined(separator: "\n")
    }
}

// MARK: - DisplayModeOption convenience
extension NavigationTitleShowcase.DisplayModeOption {
    #if os(iOS)
    var barMode: NavigationBarItem.TitleDisplayMode {
        switch self {
        case .automatic: .automatic
        case .inline: .inline
        case .large: .large
        }
    }
    #endif
}
