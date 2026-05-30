import SwiftUI

struct NavigationSubtitleShowcase: View {
    @State private var titleText = "Inbox"
    @State private var subtitleText = "Updated just now"

    var body: some View {
        ShowcaseScreen(
            title: "Navigation subtitle",
            summary: "Adds a secondary subtitle line to the nav bar (iOS 26) or window title bar (macOS).",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension NavigationSubtitleShowcase {
    enum SubtitleState: ShowcaseState {
        case defaultState
        case longContent
        case empty

        var caption: String {
            switch self {
            case .defaultState: "Default"
            case .longContent: "Long subtitle"
            case .empty: "Empty subtitle"
            }
        }
    }
}

// MARK: - Sub-views
private extension NavigationSubtitleShowcase {
    var preview: some View {
        subtitleDemo(title: titleText, subtitle: subtitleText)
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Title", text: $titleText, prompt: "Navigation title")
        ShowcaseTextControl("Subtitle", text: $subtitleText, prompt: "Navigation subtitle")
    }

    @ViewBuilder
    func stateView(_ state: SubtitleState) -> some View {
        switch state {
        case .defaultState:
            subtitleDemo(title: "Inbox", subtitle: "Updated just now")
        case .longContent:
            subtitleDemo(
                title: "Documents",
                subtitle: "Last synced yesterday at 11:45 PM",
            )
        case .empty:
            subtitleDemo(title: "Notes", subtitle: "")
        }
    }

    func subtitleDemo(title: String, subtitle: String) -> some View {
        NavigationStack {
            List(0..<5, id: \.self) { index in
                Text("Row \(index)")
            }
            .modifier(SubtitleDemoModifier(title: title, subtitle: subtitle))
        }
        .frame(maxWidth: 320, minHeight: 220)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Code generation
private extension NavigationSubtitleShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("struct NavigationSubtitleDemo: View {")
        lines.append("    var body: some View {")
        lines.append("        NavigationStack {")
        lines.append("            List(0..<10, id: \\.self) { Text(\"Row \\($0)\") }")
        lines.append("                .navigationTitle(\"\(titleText)\")")
        if !subtitleText.isEmpty {
            lines.append("                .navigationSubtitle(\"\(subtitleText)\")")
        }
        lines.append("        }")
        lines.append("    }")
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}

// MARK: - SubtitleDemoModifier
private struct SubtitleDemoModifier: ViewModifier {
    let title: String
    let subtitle: String

    func body(content: Content) -> some View {
        #if os(tvOS)
        content
            .navigationTitle(title)
        #else
        if subtitle.isEmpty {
            content
                .navigationTitle(title)
        } else {
            content
                .navigationTitle(title)
                .navigationSubtitle(subtitle)
        }
        #endif
    }
}
