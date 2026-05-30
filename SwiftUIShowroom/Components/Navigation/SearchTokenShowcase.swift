import SwiftUI

struct SearchTokenShowcase: View {
    @State private var tokenCount = 1
    @State private var editable = false
    @State private var prompt = "Filter"

    var body: some View {
        ShowcaseScreen(
            title: "Search tokens",
            summary: "Removable filter chips inside a search field, bound to an Identifiable collection.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension SearchTokenShowcase {
    struct FilterTag: Identifiable, Hashable {
        let id: UUID
        let name: String

        init(name: String) {
            self.id = UUID()
            self.name = name
        }
    }

    enum TokenState: ShowcaseState {
        case defaultState
        case focused
        case empty
        case selected

        var caption: String {
            switch self {
            case .defaultState: "Default (1 token)"
            case .focused: "Focused (field active)"
            case .empty: "Empty (no tokens)"
            case .selected: "Multiple tokens"
            }
        }
    }

    static let sampleNames = ["Swift", "SwiftUI", "Combine", "UIKit"]
}

// MARK: - Sub-views
private extension SearchTokenShowcase {
    var preview: some View {
        TokenSearchPreview(tokenCount: tokenCount, prompt: prompt)
            .frame(maxWidth: 340, minHeight: 200)
            .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseStepper("Token count", value: $tokenCount, in: 0...4)
        ShowcaseToggle("Editable tokens (code only)", isOn: $editable)
        ShowcaseTextControl("Prompt", text: $prompt, prompt: "Filter")
    }

    @ViewBuilder
    func stateView(_ state: TokenState) -> some View {
        switch state {
        case .defaultState:
            galleryPreview(tokenCount: 1, prompt: "Filter")
        case .focused:
            galleryPreview(tokenCount: 1, prompt: "Search…")
        case .empty:
            galleryPreview(tokenCount: 0, prompt: "Filter")
        case .selected:
            galleryPreview(tokenCount: 3, prompt: "Filter")
        }
    }

    func galleryPreview(tokenCount: Int, prompt: String) -> some View {
        TokenSearchPreview(tokenCount: tokenCount, prompt: prompt)
            .frame(maxWidth: 300, minHeight: 180)
            .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Code generation
private extension SearchTokenShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("struct SearchTokenDemo: View {")
        lines.append("    struct Tag: Identifiable, Hashable {")
        lines.append("        let id = UUID()")
        lines.append("        let name: String")
        lines.append("    }")
        lines.append("    @State private var query = \"\"")
        lines.append("    @State private var tokens: [Tag] = \(initialTokensCode)")
        lines.append("")
        lines.append("    var body: some View {")
        lines.append("        NavigationStack {")
        lines.append("            List { Text(\"Results\") }")
        if editable {
            lines.append("                .searchable(")
            lines.append("                    text: $query,")
            lines.append("                    editableTokens: $tokens,")
            lines.append("                    prompt: \"\(prompt)\"")
            lines.append("                ) { $token in")
            lines.append("                    Text(token.name)")
            lines.append("                }")
        } else {
            lines.append("                .searchable(")
            lines.append("                    text: $query,")
            lines.append("                    tokens: $tokens,")
            lines.append("                    prompt: \"\(prompt)\"")
            lines.append("                ) { token in")
            lines.append("                    Text(token.name)")
            lines.append("                }")
        }
        lines.append("        }")
        lines.append("    }")
        lines.append("}")
        return lines.joined(separator: "\n")
    }

    var initialTokensCode: String {
        let names = SearchTokenShowcase.sampleNames.prefix(tokenCount)
        if names.isEmpty { return "[]" }
        let items = names.map { "Tag(name: \"\($0)\")" }.joined(separator: ", ")
        return "[\(items)]"
    }
}

// MARK: - TokenSearchPreview
private struct TokenSearchPreview: View {
    let tokenCount: Int
    let prompt: String

    @State private var query = ""
    @State private var tokens: [SearchTokenShowcase.FilterTag] = []

    var body: some View {
        #if os(tvOS)
        unavailableView
        #else
        tokenSearchContent
        #endif
    }

    private var unavailableView: some View {
        Text("Search tokens unavailable on tvOS")
            .font(DesignSystem.Font.footnote)
            .foregroundStyle(DesignSystem.Color.secondary)
            .padding(DesignSystem.Spacing.medium)
    }

    #if !os(tvOS)
    private var tokenSearchContent: some View {
        NavigationStack {
            resultsList
                .searchable(
                    text: $query,
                    tokens: $tokens,
                    prompt: prompt
                ) { token in
                    Label(token.name, systemImage: "tag")
                }
                .navigationTitle("Search")
        }
        .onAppear { syncTokens() }
        .onChange(of: tokenCount) { _, _ in syncTokens() }
    }

    private var resultsList: some View {
        let items = ["Swift 6", "SwiftUI Views", "Combine Publishers", "UIKit Bridges", "CoreData"]
        return List(filteredItems(from: items), id: \.self) { item in
            Text(item)
        }
    }

    private func filteredItems(from all: [String]) -> [String] {
        guard !query.isEmpty || !tokens.isEmpty else { return all }
        return all.filter { item in
            let matchesQuery = query.isEmpty || item.localizedCaseInsensitiveContains(query)
            let matchesTokens = tokens.isEmpty
                || tokens.contains { item.localizedCaseInsensitiveContains($0.name) }
            return matchesQuery && matchesTokens
        }
    }

    private func syncTokens() {
        let names = SearchTokenShowcase.sampleNames.prefix(tokenCount)
        tokens = names.map { SearchTokenShowcase.FilterTag(name: $0) }
    }
    #endif
}
