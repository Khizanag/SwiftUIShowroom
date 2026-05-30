import SwiftUI

struct SectionShowcase: View {
    enum ProminenceOption: ShowcasePickable {
        case standard
        case increased

        var label: String {
            switch self {
            case .standard: "standard"
            case .increased: "increased"
            }
        }

        var value: Prominence {
            switch self {
            case .standard: .standard
            case .increased: .increased
            }
        }
    }

    enum SectionState: ShowcaseState {
        case `default`
        case collapsed
        case longContent

        var caption: String {
            switch self {
            case .default: "Default — expanded with header and footer"
            case .collapsed: "Collapsed — header only"
            case .longContent: "Long content — increased prominence"
            }
        }
    }

    @State private var headerText = "Section Header"
    @State private var footerText = "Explanatory footer caption."
    @State private var showHeader = true
    @State private var showFooter = true
    @State private var isExpanded = true
    @State private var prominenceOption: ProminenceOption = .standard

    var body: some View {
        ShowcaseScreen(
            title: "Section",
            summary: "Groups content with optional header and footer inside List or Form.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension SectionShowcase {
    var preview: some View {
        List {
            Section {
                sectionRows(sampleItems)
            } header: {
                headerContent(showHeader ? headerText : nil)
            } footer: {
                footerContent(showFooter ? footerText : nil)
            }
            .headerProminence(prominenceOption.value)
        }
        .frame(maxHeight: 300)
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseToggle("Show header", isOn: $showHeader)
        if showHeader {
            ShowcaseTextControl("Header text", text: $headerText)
        }
        ShowcaseToggle("Show footer", isOn: $showFooter)
        if showFooter {
            ShowcaseTextControl("Footer text", text: $footerText)
        }
        ShowcasePicker("Header prominence", selection: $prominenceOption)
#if os(iOS)
        ShowcaseToggle("Expanded", isOn: $isExpanded)
#endif
    }

    @ViewBuilder
    func stateView(_ state: SectionState) -> some View {
        switch state {
        case .default:
            gallerySection(
                header: "Favorites",
                footer: "Your favorite items appear here.",
                items: sampleItems,
                prominence: .standard,
            )
        case .collapsed:
            gallerySection(
                header: "Advanced Options",
                footer: nil,
                items: sampleItems,
                prominence: .standard,
            )
        case .longContent:
            gallerySection(
                header: "All Items",
                footer: "Showing all available items.",
                items: longItems,
                prominence: .increased,
            )
        }
    }

    @ViewBuilder
    func headerContent(_ text: String?) -> some View {
        if let text {
            Text(text)
        }
    }

    @ViewBuilder
    func footerContent(_ text: String?) -> some View {
        if let text {
            Text(text)
        }
    }

    @ViewBuilder
    func sectionRows(_ items: [String]) -> some View {
        ForEach(items, id: \.self) { item in
            Text(item)
                .font(DesignSystem.Font.body)
        }
    }

    var sampleItems: [String] {
        ["First item", "Second item", "Third item"]
    }

    var longItems: [String] {
        (1...8).map { "Item \($0)" }
    }
}

// MARK: - Gallery helpers
private extension SectionShowcase {
    func gallerySection(
        header: String?,
        footer: String?,
        items: [String],
        prominence: Prominence,
    ) -> some View {
        List {
            Section {
                sectionRows(items)
            } header: {
                headerContent(header)
            } footer: {
                footerContent(footer)
            }
            .headerProminence(prominence)
        }
        .frame(maxHeight: 260)
    }
}

// MARK: - Code generation
private extension SectionShowcase {
    var generatedCode: String {
        var lines: [String] = []
#if os(iOS)
        lines.append("Section(isExpanded: $isExpanded) {")
#else
        lines.append("Section {")
#endif
        lines.append("    ForEach(items) { Text($0.title) }")
        lines.append("} header: {")
        if showHeader {
            lines.append("    Text(\"\(headerText)\")")
        } else {
            lines.append("    EmptyView()")
        }
        lines.append("} footer: {")
        if showFooter {
            lines.append("    Text(\"\(footerText)\")")
        } else {
            lines.append("    EmptyView()")
        }
        lines.append("}")
        lines.append(".headerProminence(.\(prominenceOption.label))")
        return lines.joined(separator: "\n")
    }
}
