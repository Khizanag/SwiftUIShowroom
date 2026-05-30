import SwiftUI

struct NavigationSplitViewShowcase: View {
    @State private var columnCount: ColumnCountOption = .two
    @State private var style: SplitStyleOption = .automatic
    @State private var columnVisibility: VisibilityOption = .automatic
    @State private var preferredCompactColumn: CompactColumnOption = .detail
    @State private var sidebarColumnWidth: Double = 250
    @State private var sidebarTitle = "Categories"

    var body: some View {
        ShowcaseScreen(
            title: "NavigationSplitView",
            summary: "Two- or three-column container; leading selections drive subsequent columns.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension NavigationSplitViewShowcase {
    enum ColumnCountOption: ShowcasePickable {
        case two
        case three

        var label: String {
            switch self {
            case .two: "two"
            case .three: "three"
            }
        }
    }

    enum SplitStyleOption: ShowcasePickable {
        case automatic
        case balanced
        case prominentDetail

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .balanced: "balanced"
            case .prominentDetail: "prominentDetail"
            }
        }
    }

    enum VisibilityOption: ShowcasePickable {
        case automatic
        case all
        case doubleColumn
        case detailOnly

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .all: "all"
            case .doubleColumn: "doubleColumn"
            case .detailOnly: "detailOnly"
            }
        }

        var value: NavigationSplitViewVisibility {
            switch self {
            case .automatic: .automatic
            case .all: .all
            case .doubleColumn: .doubleColumn
            case .detailOnly: .detailOnly
            }
        }
    }

    enum CompactColumnOption: ShowcasePickable {
        case sidebar
        case content
        case detail

        var label: String {
            switch self {
            case .sidebar: "sidebar"
            case .content: "content"
            case .detail: "detail"
            }
        }

        var value: NavigationSplitViewColumn {
            switch self {
            case .sidebar: .sidebar
            case .content: .content
            case .detail: .detail
            }
        }
    }

    enum SplitState: ShowcaseState {
        case defaultState
        case empty
        case selected
        case longContent

        var caption: String {
            switch self {
            case .defaultState: "Default"
            case .empty: "No selection"
            case .selected: "Item selected"
            case .longContent: "Long list"
            }
        }
    }
}

// MARK: - Sub-views
private extension NavigationSplitViewShowcase {
    var preview: some View {
        splitDemo(
            columnCount: columnCount,
            selection: 2,
            sidebarTitle: sidebarTitle,
            columnWidth: CGFloat(sidebarColumnWidth),
            isLong: false,
        )
        .frame(maxWidth: 400, minHeight: 220)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Columns", selection: $columnCount)
        ShowcasePicker("Style", selection: $style)
        ShowcasePicker("Column visibility", selection: $columnVisibility)
        #if !os(tvOS)
        ShowcasePicker("Preferred compact column", selection: $preferredCompactColumn)
        #endif
        ShowcaseSlider("Sidebar width", value: $sidebarColumnWidth, in: 180...420, step: 10)
        ShowcaseTextControl("Sidebar title", text: $sidebarTitle, prompt: "Categories")
    }

    @ViewBuilder
    func stateView(_ state: SplitState) -> some View {
        switch state {
        case .defaultState:
            splitDemo(
                columnCount: .two,
                selection: nil,
                sidebarTitle: "Categories",
                columnWidth: 200,
                isLong: false,
            )
        case .empty:
            splitDemo(
                columnCount: .two,
                selection: nil,
                sidebarTitle: "Empty",
                columnWidth: 200,
                isLong: false,
            )
        case .selected:
            splitDemo(
                columnCount: .two,
                selection: 3,
                sidebarTitle: "Categories",
                columnWidth: 200,
                isLong: false,
            )
        case .longContent:
            splitDemo(
                columnCount: .two,
                selection: nil,
                sidebarTitle: "Categories",
                columnWidth: 200,
                isLong: true,
            )
        }
    }

    func splitDemo(
        columnCount: ColumnCountOption,
        selection: Int?,
        sidebarTitle: String,
        columnWidth: CGFloat,
        isLong: Bool,
    ) -> some View {
        SplitDemoContainer(
            columnCount: columnCount,
            style: style,
            columnVisibility: columnVisibility,
            preferredCompactColumn: preferredCompactColumn,
            sidebarTitle: sidebarTitle,
            columnWidth: columnWidth,
            isLong: isLong,
            initialSelection: selection,
        )
        .frame(maxWidth: 360, minHeight: 200)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - SplitDemoContainer
private struct SplitDemoContainer: View {
    let columnCount: NavigationSplitViewShowcase.ColumnCountOption
    let style: NavigationSplitViewShowcase.SplitStyleOption
    let columnVisibility: NavigationSplitViewShowcase.VisibilityOption
    let preferredCompactColumn: NavigationSplitViewShowcase.CompactColumnOption
    let sidebarTitle: String
    let columnWidth: CGFloat
    let isLong: Bool
    let initialSelection: Int?

    @State private var selectedItem: Int?
    @State private var visibility: NavigationSplitViewVisibility = .automatic
    #if !os(tvOS)
    @State private var compactColumn: NavigationSplitViewColumn = .detail
    #endif

    var body: some View {
        splitView
            .onAppear {
                selectedItem = initialSelection
                visibility = columnVisibility.value
                #if !os(tvOS)
                compactColumn = preferredCompactColumn.value
                #endif
            }
    }

    @ViewBuilder
    private var splitView: some View {
        switch style {
        case .automatic:
            baseSplitView.navigationSplitViewStyle(.automatic)
        case .balanced:
            baseSplitView.navigationSplitViewStyle(.balanced)
        case .prominentDetail:
            baseSplitView.navigationSplitViewStyle(.prominentDetail)
        }
    }

    @ViewBuilder
    private var baseSplitView: some View {
        if columnCount == .three {
            threeColumnSplit
        } else {
            twoColumnSplit
        }
    }

    private var twoColumnSplit: some View {
        #if !os(tvOS)
        NavigationSplitView(
            columnVisibility: $visibility,
            preferredCompactColumn: $compactColumn,
        ) {
            sidebarContent
        } detail: {
            detailContent
        }
        #else
        NavigationSplitView(columnVisibility: $visibility) {
            sidebarContent
        } detail: {
            detailContent
        }
        #endif
    }

    private var threeColumnSplit: some View {
        #if !os(tvOS)
        NavigationSplitView(
            columnVisibility: $visibility,
            preferredCompactColumn: $compactColumn,
        ) {
            sidebarContent
        } content: {
            contentColumn
        } detail: {
            detailContent
        }
        #else
        NavigationSplitView(columnVisibility: $visibility) {
            sidebarContent
        } content: {
            contentColumn
        } detail: {
            detailContent
        }
        #endif
    }

    private var rowCount: Int { isLong ? 20 : 6 }

    private var sidebarContent: some View {
        List(0..<rowCount, id: \.self, selection: $selectedItem) { index in
            Text("Item \(index)")
        }
        .navigationSplitViewColumnWidth(columnWidth)
        .navigationTitle(sidebarTitle)
    }

    private var contentColumn: some View {
        List(0..<4, id: \.self) { index in
            Text("Sub-item \(index)")
        }
        .navigationTitle("Content")
    }

    @ViewBuilder
    private var detailContent: some View {
        if let selected = selectedItem {
            VStack(spacing: DesignSystem.Spacing.medium) {
                Image(systemName: "doc.text.fill")
                    .font(DesignSystem.Font.largeTitle)
                    .foregroundStyle(DesignSystem.Color.accent)
                Text("Detail \(selected)")
                    .font(DesignSystem.Font.title3)
            }
        } else {
            ContentUnavailableView(
                "Select an item",
                systemImage: "sidebar.left",
                description: Text("Choose an item from the list."),
            )
        }
    }
}

// MARK: - Code generation
private extension NavigationSplitViewShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("struct NavigationSplitViewDemo: View {")
        let visibilityLine = "    @State private var columnVisibility = "
            + "NavigationSplitViewVisibility.\(columnVisibility.label)"
        lines.append(visibilityLine)
        #if !os(tvOS)
        let compactLine = "    @State private var preferredColumn = "
            + "NavigationSplitViewColumn.\(preferredCompactColumn.label)"
        lines.append(compactLine)
        #endif
        lines.append("    @State private var selection: Int?")
        lines.append("")
        lines.append("    var body: some View {")
        lines.append("        \(splitViewInit) {")
        lines.append("            List(0..<8, id: \\.self, selection: $selection) { Text(\"Item \\($0)\") }")
        lines.append("                .navigationSplitViewColumnWidth(\(Int(sidebarColumnWidth)))")
        lines.append("                .navigationTitle(\"\(sidebarTitle)\")")
        lines.append("        } \(contentClosureLines)")
        lines.append("        .navigationSplitViewStyle(.\(style.label))")
        lines.append("    }")
        lines.append("}")
        return lines.joined(separator: "\n")
    }

    var splitViewInit: String {
        #if !os(tvOS)
        "NavigationSplitView(columnVisibility: $columnVisibility, preferredCompactColumn: $preferredColumn)"
        #else
        "NavigationSplitView(columnVisibility: $columnVisibility)"
        #endif
    }

    var contentClosureLines: String {
        if columnCount == .three {
            return """
            content: {
                List(0..<4, id: \\.self) { Text("Sub-item \\($0)") }
                    .navigationTitle("Content")
            } detail: {
                if let selection { Text("Detail \\(selection)") } else { Text("Select an item") }
            }
            """
        } else {
            return """
            detail: {
                if let selection { Text("Detail \\(selection)") } else { Text("Select an item") }
            }
            """
        }
    }
}
