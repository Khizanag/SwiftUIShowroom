import SwiftUI

struct ContentUnavailableViewShowcase: View {
    @State private var titleText = "No Content"
    @State private var systemImageName = "tray.fill"
    @State private var descriptionText = "Try again later."
    @State private var hasAction = false
    @State private var actionTitle = "Refresh"
    @State private var preset: PresetOption = .custom

    var body: some View {
        ShowcaseScreen(
            title: "Content Unavailable View",
            summary: "Empty-state placeholder with label, description, and optional action button.",
        ) {
            PreviewStage {
                preview
            }
            ShowcaseSection("Configuration") {
                controls
            }
            ShowcaseSection("States") {
                StateGallery(content: stateView)
            }
            ShowcaseSection("Generated code") {
                CodeBlock(code: generatedCode)
            }
        }
    }
}

// MARK: - Nested types
extension ContentUnavailableViewShowcase {
    enum PresetOption: String, ShowcasePickable {
        case custom
        case search
        case searchText

        var label: String {
            switch self {
            case .custom: "custom"
            case .search: "search"
            case .searchText: "search(text:)"
            }
        }
    }

    enum ContentState: ShowcaseState {
        case empty
        case error
        case noNetwork
        case longContent

        var caption: String {
            switch self {
            case .empty: "Empty"
            case .error: "Error"
            case .noNetwork: "No Network"
            case .longContent: "Long Text"
            }
        }
    }
}

// MARK: - Sub-views
private extension ContentUnavailableViewShowcase {
    var preview: some View {
        Group {
            switch preset {
            case .custom:
                customView(
                    title: titleText,
                    systemImage: systemImageName,
                    description: descriptionText,
                    hasAction: hasAction,
                    actionTitle: actionTitle,
                )
            case .search:
                ContentUnavailableView.search
            case .searchText:
                ContentUnavailableView.search(text: titleText)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Preset", selection: $preset)
        if preset == .custom {
            ShowcaseTextControl("Title", text: $titleText, prompt: "e.g. No Results")
            ShowcaseTextControl("System image", text: $systemImageName, prompt: "SF Symbol name")
            ShowcaseTextControl("Description", text: $descriptionText, prompt: "Supporting text")
            ShowcaseToggle("Show action button", isOn: $hasAction)
            if hasAction {
                ShowcaseTextControl("Action title", text: $actionTitle, prompt: "e.g. Refresh")
            }
        } else if preset == .searchText {
            ShowcaseTextControl("Search text", text: $titleText, prompt: "Query shown in message")
        }
    }

    @ViewBuilder
    func stateView(_ state: ContentState) -> some View {
        switch state {
        case .empty:
            customView(
                title: "No Items",
                systemImage: "tray.fill",
                description: "Your list is empty.",
                hasAction: false,
                actionTitle: "",
            )
        case .error:
            customView(
                title: "Something Went Wrong",
                systemImage: "exclamationmark.triangle.fill",
                description: "An error occurred. Please try again.",
                hasAction: true,
                actionTitle: "Retry",
            )
        case .noNetwork:
            customView(
                title: "No Internet Connection",
                systemImage: "wifi.slash",
                description: "Connect to the internet and try again.",
                hasAction: true,
                actionTitle: "Try Again",
            )
        case .longContent:
            customView(
                title: "Nothing Matches Your Search",
                systemImage: "magnifyingglass",
                description: "No results found for the current filter. Try adjusting or clearing your search criteria.",
                hasAction: true,
                actionTitle: "Clear Filters",
            )
        }
    }

    func customView(
        title: String,
        systemImage: String,
        description: String,
        hasAction: Bool,
        actionTitle: String,
    ) -> some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(description)
        } actions: {
            if hasAction {
                Button(actionTitle) {}
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}

// MARK: - Code generation
private extension ContentUnavailableViewShowcase {
    var generatedCode: String {
        switch preset {
        case .search:
            return "ContentUnavailableView.search"
        case .searchText:
            return "ContentUnavailableView.search(text: \"\(titleText)\")"
        case .custom:
            return buildCustomCode()
        }
    }

    func buildCustomCode() -> String {
        var lines: [String] = []
        lines.append("ContentUnavailableView {")
        lines.append("    Label(\"\(titleText)\", systemImage: \"\(systemImageName)\")")
        lines.append("} description: {")
        lines.append("    Text(\"\(descriptionText)\")")
        lines.append("} actions: {")
        if hasAction {
            lines.append("    Button(\"\(actionTitle)\") { /* recover */ }")
            lines.append("        .buttonStyle(.borderedProminent)")
        }
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}
