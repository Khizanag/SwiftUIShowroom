import SwiftUI

struct SearchableShowcase: View {
    @State private var placement: PlacementOption = .automatic
    @State private var prompt = "Search"
    @State private var showSuggestions = false
    @State private var showScopes = false
    @State private var scopeActivation: ScopeActivationOption = .automatic
    @State private var useTokens = false
    @State private var isPresented = false
    @State private var searchQuery = ""
    @State private var selectedScope = 0

    var body: some View {
        ShowcaseScreen(
            title: "searchable",
            summary: "Adds a system search field to a navigation container with placement, scopes, and tokens.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension SearchableShowcase {
    enum PlacementOption: ShowcasePickable {
        case automatic
        case toolbar
        case sidebar
        case navigationBarDrawerAlways
        case navigationBarDrawerAutomatic

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .toolbar: "toolbar"
            case .sidebar: "sidebar"
            case .navigationBarDrawerAlways: "drawerAlways"
            case .navigationBarDrawerAutomatic: "drawerAutomatic"
            }
        }

        var fieldPlacement: SearchFieldPlacement {
            switch self {
            case .automatic: .automatic
            case .toolbar: .toolbar
            case .sidebar: .sidebar
            #if os(iOS)
            case .navigationBarDrawerAlways: .navigationBarDrawer(displayMode: .always)
            case .navigationBarDrawerAutomatic: .navigationBarDrawer(displayMode: .automatic)
            #else
            case .navigationBarDrawerAlways: .toolbar
            case .navigationBarDrawerAutomatic: .toolbar
            #endif
            }
        }
    }

    enum ScopeActivationOption: ShowcasePickable {
        case automatic
        case onTextEntry
        case onSearchPresentation

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .onTextEntry: "onTextEntry"
            case .onSearchPresentation: "onSearchPresentation"
            }
        }

        var activation: SearchScopeActivation {
            switch self {
            case .automatic: .automatic
            case .onTextEntry: .onTextEntry
            case .onSearchPresentation: .onSearchPresentation
            }
        }
    }

    enum SearchableState: ShowcaseState {
        case defaultState
        case focused
        case empty
        case longContent

        var caption: String {
            switch self {
            case .defaultState: "Default"
            case .focused: "With query"
            case .empty: "Empty results"
            case .longContent: "Long + scopes"
            }
        }
    }

    struct DemoConfig {
        var query: String
        var promptText: String
        var fieldPlacement: SearchFieldPlacement
        var showsSuggestions: Bool
        var showsScopes: Bool
        var scopeValue: Int
        var activation: SearchScopeActivation
        var rowCount: Int
    }
}

// MARK: - Sub-views
private extension SearchableShowcase {
    var preview: some View {
        demoView(DemoConfig(
            query: searchQuery,
            promptText: prompt,
            fieldPlacement: placement.fieldPlacement,
            showsSuggestions: showSuggestions,
            showsScopes: showScopes,
            scopeValue: selectedScope,
            activation: scopeActivation.activation,
            rowCount: 6,
        ))
        .frame(maxWidth: 320, minHeight: 220)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Placement", selection: $placement)
        ShowcaseTextControl("Prompt", text: $prompt, prompt: "Search")
        ShowcaseToggle("Show suggestions", isOn: $showSuggestions)
        ShowcaseToggle("Show scopes", isOn: $showScopes)
        ShowcasePicker("Scope activation", selection: $scopeActivation)
        ShowcaseToggle("Use tokens", isOn: $useTokens)
        ShowcaseToggle("Is presented (programmatic)", isOn: $isPresented)
    }

    @ViewBuilder
    func stateView(_ state: SearchableState) -> some View {
        demoView(config(for: state))
            .frame(maxWidth: 300, minHeight: 180)
            .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    func config(for state: SearchableState) -> DemoConfig {
        switch state {
        case .defaultState:
            return DemoConfig(
                query: "",
                promptText: "Search",
                fieldPlacement: .automatic,
                showsSuggestions: false,
                showsScopes: false,
                scopeValue: 0,
                activation: .automatic,
                rowCount: 5,
            )
        case .focused:
            return DemoConfig(
                query: "swift",
                promptText: "Search",
                fieldPlacement: .automatic,
                showsSuggestions: true,
                showsScopes: false,
                scopeValue: 0,
                activation: .automatic,
                rowCount: 3,
            )
        case .empty:
            return DemoConfig(
                query: "zzz",
                promptText: "Search",
                fieldPlacement: .automatic,
                showsSuggestions: false,
                showsScopes: false,
                scopeValue: 0,
                activation: .automatic,
                rowCount: 5,
            )
        case .longContent:
            return DemoConfig(
                query: "",
                promptText: "Search",
                fieldPlacement: .automatic,
                showsSuggestions: false,
                showsScopes: true,
                scopeValue: 0,
                activation: .automatic,
                rowCount: 12,
            )
        }
    }

    func demoView(_ cfg: DemoConfig) -> some View {
        SearchableDemoContainer(config: cfg)
    }
}

// MARK: - Code generation
private extension SearchableShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("struct SearchableDemo: View {")
        lines.append("    @State private var query = \"\"")
        if showScopes {
            lines.append("    @State private var scope = 0")
        }
        if useTokens {
            lines.append("    @State private var tokens: [SearchToken] = []")
        }
        lines.append("")
        lines.append("    var body: some View {")
        lines.append("        NavigationStack {")
        lines.append("            List(results, id: \\.self) { Text($0) }")
        lines.append(searchableModifierCode)
        if showScopes {
            lines.append("                .searchScopes($scope, activation: .\(scopeActivation.label)) {")
            lines.append("                    Text(\"All\").tag(0)")
            lines.append("                    Text(\"Favorites\").tag(1)")
            lines.append("                }")
        }
        if showSuggestions {
            lines.append("                .searchSuggestions {")
            lines.append("                    Text(\"Recent\").searchCompletion(\"recent\")")
            lines.append("                    Text(\"Popular\").searchCompletion(\"popular\")")
            lines.append("                }")
        }
        lines.append("        }")
        lines.append("    }")
        lines.append("")
        lines.append("    var results: [String] {")
        lines.append("        query.isEmpty ? sampleItems : sampleItems.filter {")
        lines.append("            $0.localizedCaseInsensitiveContains(query)")
        lines.append("        }")
        lines.append("    }")
        lines.append("")
        lines.append("    let sampleItems = [\"Swift\", \"SwiftUI\", \"Xcode\", \"Instruments\"]")
        lines.append("}")
        return lines.joined(separator: "\n")
    }

    var searchableModifierCode: String {
        if useTokens {
            return """
                    .searchable(
                        text: $query,
                        tokens: $tokens,
                        placement: .\(placement.label),
                        prompt: "\(prompt)"
                    ) { token in Text(token.name) }
            """
        } else if isPresented {
            return """
                    .searchable(
                        text: $query,
                        isPresented: $isSearchPresented,
                        placement: .\(placement.label),
                        prompt: "\(prompt)"
                    )
            """
        } else {
            return """
                    .searchable(
                        text: $query,
                        placement: .\(placement.label),
                        prompt: "\(prompt)"
                    )
            """
        }
    }
}

// MARK: - SearchableDemoContainer
private struct SearchableDemoContainer: View {
    @State private var query: String
    @State private var scope: Int
    private let config: SearchableShowcase.DemoConfig

    private let sampleItems = [
        "Swift", "SwiftUI", "Xcode", "Instruments",
        "Combine", "UIKit", "AppKit", "Foundation",
        "CoreData", "CloudKit", "ARKit", "RealityKit",
    ]

    init(config: SearchableShowcase.DemoConfig) {
        _query = State(initialValue: config.query)
        _scope = State(initialValue: config.scopeValue)
        self.config = config
    }

    var body: some View {
        NavigationStack {
            listContent
                .navigationTitle("Search")
                .searchableModifier(
                    query: $query,
                    promptText: config.promptText,
                    fieldPlacement: config.fieldPlacement,
                )
                .searchScopesModifier(
                    scope: $scope,
                    showsScopes: config.showsScopes,
                    activation: config.activation,
                )
                .searchSuggestionsModifier(
                    query: query,
                    showsSuggestions: config.showsSuggestions,
                )
        }
    }

    private var listContent: some View {
        let items = displayItems
        return Group {
            if items.isEmpty {
                ContentUnavailableView.search(text: query)
            } else {
                List(items, id: \.self) { Text($0) }
            }
        }
    }

    private var displayItems: [String] {
        let pool = Array(sampleItems.prefix(min(config.rowCount, sampleItems.count)))
        guard !query.isEmpty else { return pool }
        return pool.filter { $0.localizedCaseInsensitiveContains(query) }
    }
}

// MARK: - View modifiers
private extension View {
    func searchableModifier(
        query: Binding<String>,
        promptText: String,
        fieldPlacement: SearchFieldPlacement,
    ) -> some View {
        searchable(
            text: query,
            placement: fieldPlacement,
            prompt: LocalizedStringKey(promptText),
        )
    }

    func searchScopesModifier(
        scope: Binding<Int>,
        showsScopes: Bool,
        activation: SearchScopeActivation,
    ) -> some View {
        Group {
            if showsScopes {
                self.searchScopes(scope, activation: activation) {
                    Text("All").tag(0)
                    Text("Favorites").tag(1)
                    Text("Recent").tag(2)
                }
            } else {
                self
            }
        }
    }

    func searchSuggestionsModifier(
        query: String,
        showsSuggestions: Bool,
    ) -> some View {
        Group {
            if showsSuggestions {
                self.searchSuggestions {
                    Text("Recent").searchCompletion("recent")
                    Text("Popular").searchCompletion("popular")
                    if !query.isEmpty {
                        Text(query).searchCompletion(query)
                    }
                }
            } else {
                self
            }
        }
    }
}
