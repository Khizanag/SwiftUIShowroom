import SwiftUI

struct BadgeShowcase: View {
    @State private var kind: BadgeKind = .count
    @State private var count = 3
    @State private var labelText = "New"
    @State private var prominence: ProminenceOption = .standard

    // MARK: - Nested types
    enum BadgeKind: ShowcasePickable {
        case count
        case text
        case none

        var label: String {
            switch self {
            case .count: "count"
            case .text: "text"
            case .none: "none"
            }
        }
    }

    enum ProminenceOption: ShowcasePickable {
        case standard
        case increased
        case decreased

        var label: String {
            switch self {
            case .standard: "standard"
            case .increased: "increased"
            case .decreased: "decreased"
            }
        }

        var value: BadgeProminence {
            switch self {
            case .standard: .standard
            case .increased: .increased
            case .decreased: .decreased
            }
        }
    }

    enum BadgeState: ShowcaseState {
        case withCount
        case zeroCount
        case textLabel
        case longLabel

        var caption: String {
            switch self {
            case .withCount: "Count (3)"
            case .zeroCount: "Count (0, hidden)"
            case .textLabel: "Text label"
            case .longLabel: "Long label"
            }
        }
    }

    var body: some View {
        ShowcaseScreen(
            title: "Badge",
            summary: "Attaches a count or short text badge to list rows, tab items, and toolbar items.",
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

// MARK: - Sub-views
private extension BadgeShowcase {
    var preview: some View {
        badgeList(kind: kind, count: count, labelText: labelText, prominence: prominence)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Kind", selection: $kind)
        if kind == .count {
            ShowcaseStepper("Count", value: $count, in: 0...99)
        }
        if kind == .text {
            ShowcaseTextControl("Label", text: $labelText, prompt: "e.g. New")
        }
        ShowcasePicker("Prominence", selection: $prominence)
    }

    @ViewBuilder
    func stateView(_ state: BadgeState) -> some View {
        switch state {
        case .withCount:
            badgeList(kind: .count, count: 3, labelText: "New", prominence: .standard)
        case .zeroCount:
            badgeList(kind: .count, count: 0, labelText: "New", prominence: .standard)
        case .textLabel:
            badgeList(kind: .text, count: 3, labelText: "New", prominence: .standard)
        case .longLabel:
            badgeList(kind: .text, count: 3, labelText: "Pro", prominence: .increased)
        }
    }
}

// MARK: - Helpers
private extension BadgeShowcase {
    func badgeList(
        kind: BadgeKind,
        count: Int,
        labelText: String,
        prominence: ProminenceOption,
    ) -> some View {
        List {
            badgeRow(title: "Inbox", systemImage: "tray.fill", kind: kind, count: count, labelText: labelText)
            badgeRow(title: "Drafts", systemImage: "doc.fill", kind: .none, count: 0, labelText: "")
        }
        .frame(maxWidth: 320, minHeight: 110)
        .scrollDisabled(true)
        #if os(iOS)
        .listStyle(.insetGrouped)
        #else
        .listStyle(.inset)
        #endif
        .badgeProminence(prominence.value)
    }

    @ViewBuilder
    func badgeRow(
        title: String,
        systemImage: String,
        kind: BadgeKind,
        count: Int,
        labelText: String,
    ) -> some View {
        switch kind {
        case .count:
            Label(title, systemImage: systemImage).badge(count)
        case .text:
            Label(title, systemImage: systemImage).badge(Text(labelText))
        case .none:
            Label(title, systemImage: systemImage).badge(nil as Text?)
        }
    }
}

// MARK: - Code generation
private extension BadgeShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("List {")
        lines.append("    Label(\"Inbox\", systemImage: \"tray.fill\")")
        lines.append("        \(badgeModifier)")
        lines.append("}")
        if prominence != .standard {
            lines.append(".badgeProminence(.\(prominence.label))")
        }
        return lines.joined(separator: "\n")
    }

    var badgeModifier: String {
        switch kind {
        case .count:
            return ".badge(\(count))"
        case .text:
            return ".badge(Text(\"\(labelText)\"))"
        case .none:
            return ".badge(nil as Text?)"
        }
    }
}
