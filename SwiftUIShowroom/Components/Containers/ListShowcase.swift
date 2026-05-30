import SwiftUI

struct ListShowcase: View {
    @State private var style: ListStyleOption = .automatic
    @State private var selectionMode: SelectionModeOption = .none
    @State private var editModeActive = false
    @State private var separatorVisibility: SeparatorVisibilityOption = .automatic
    @State private var separatorTint: Color = .accentColor
    @State private var showSeparatorTint = false
    @State private var rowSpacingValue: Double = 0
    @State private var useRowSpacing = false
    @State private var sectionSpacing: SectionSpacingOption = .default
    @State private var rowBackground: Color = .accentColor
    @State private var showRowBackground = false
    @State private var singleSelection: Int?
    @State private var multiSelection: Set<Int> = []
    #if os(iOS)
    @State private var swipeActionsEnabled = false
    #endif

    var body: some View {
        ShowcaseScreen(
            title: "List",
            summary: "Rows of data in a scrollable column with native separators, selection, and editing.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension ListShowcase {
    enum ListStyleOption: ShowcasePickable {
        case automatic, plain, inset, sidebar
        #if os(macOS)
        case bordered
        #else
        case grouped, insetGrouped
        #endif

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .plain: "plain"
            case .inset: "inset"
            case .sidebar: "sidebar"
            #if os(macOS)
            case .bordered: "bordered"
            #else
            case .grouped: "grouped"
            case .insetGrouped: "insetGrouped"
            #endif
            }
        }
    }

    enum SelectionModeOption: ShowcasePickable {
        case none, single, multiple

        var label: String {
            switch self {
            case .none: "none"
            case .single: "single"
            case .multiple: "multiple"
            }
        }
    }

    enum SeparatorVisibilityOption: ShowcasePickable {
        case automatic, visible, hidden

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .visible: "visible"
            case .hidden: "hidden"
            }
        }

        var visibility: Visibility {
            switch self {
            case .automatic: .automatic
            case .visible: .visible
            case .hidden: .hidden
            }
        }
    }

    enum SectionSpacingOption: ShowcasePickable {
        case `default`, compact

        var label: String {
            switch self {
            case .default: "default"
            case .compact: "compact"
            }
        }

        var spacing: ListSectionSpacing {
            switch self {
            case .default: .default
            case .compact: .compact
            }
        }
    }

    enum ListState: ShowcaseState {
        case defaultState, empty, loading, selected, longContent, error

        var caption: String {
            switch self {
            case .defaultState: "Default"
            case .empty: "Empty"
            case .loading: "Loading"
            case .selected: "Selected"
            case .longContent: "Long content"
            case .error: "Error"
            }
        }
    }
}

// MARK: - Sample data
private extension ListShowcase {
    struct ListItem: Identifiable {
        let id: Int
        let title: String
        let subtitle: String
        let systemImage: String
    }

    static let shortItems: [ListItem] = [
        ListItem(id: 1, title: "Inbox", subtitle: "3 unread", systemImage: "tray.fill"),
        ListItem(id: 2, title: "Drafts", subtitle: "1 draft", systemImage: "doc.fill"),
        ListItem(id: 3, title: "Sent", subtitle: "12 sent", systemImage: "paperplane.fill"),
    ]

    static let longItems: [ListItem] = (1...20).map { index in
        ListItem(
            id: index,
            title: "Item \(index)",
            subtitle: "\(index) messages",
            systemImage: "envelope.fill",
        )
    }
}

// MARK: - Sub-views
private extension ListShowcase {
    var preview: some View {
        listView(items: Self.shortItems)
            .frame(maxHeight: 260)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Style", selection: $style)
        ShowcasePicker("Selection", selection: $selectionMode)
        ShowcaseToggle("Edit mode", isOn: $editModeActive)
        ShowcasePicker("Row separator", selection: $separatorVisibility)
        ShowcaseToggle("Custom separator tint", isOn: $showSeparatorTint)
        if showSeparatorTint {
            ShowcaseColorControl("Separator tint", selection: $separatorTint, supportsOpacity: false)
        }
        ShowcaseToggle("Custom row spacing", isOn: $useRowSpacing)
        if useRowSpacing {
            ShowcaseSlider("Row spacing", value: $rowSpacingValue, in: 0...40, step: 1)
        }
        ShowcasePicker("Section spacing", selection: $sectionSpacing)
        ShowcaseToggle("Custom row background", isOn: $showRowBackground)
        if showRowBackground {
            ShowcaseColorControl("Row background", selection: $rowBackground, supportsOpacity: true)
        }
        #if !os(macOS)
        ShowcaseToggle("Swipe actions", isOn: $swipeActionsEnabled)
        #endif
    }

    @ViewBuilder
    func stateView(_ state: ListState) -> some View {
        switch state {
        case .defaultState:
            listView(items: Self.shortItems)
                .frame(maxHeight: 180)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        case .empty:
            List {
                ContentUnavailableView(
                    "No Items",
                    systemImage: "tray.fill",
                    description: Text("Nothing to show here."),
                )
            }
            .frame(maxHeight: 180)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        case .loading:
            List {
                ForEach(0..<3, id: \.self) { _ in
                    skeletonRow
                }
            }
            .frame(maxHeight: 180)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        case .selected:
            selectedStateList
        case .longContent:
            listView(items: Self.longItems)
                .frame(maxHeight: 180)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        case .error:
            List {
                ContentUnavailableView(
                    "Something went wrong",
                    systemImage: "exclamationmark.triangle.fill",
                    description: Text("Pull to refresh and try again."),
                )
            }
            .frame(maxHeight: 180)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        }
    }

    var skeletonRow: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .fill(DesignSystem.Color.separator.opacity(0.5))
                .frame(width: DesignSystem.Size.Icon.medium, height: DesignSystem.Size.Icon.medium)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .fill(DesignSystem.Color.separator.opacity(0.5))
                    .frame(height: 12)
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .fill(DesignSystem.Color.separator.opacity(0.3))
                    .frame(width: 80, height: 10)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.xSmall)
    }

    var selectedStateList: some View {
        List(Self.shortItems, id: \.id) { item in
            Label(item.title, systemImage: item.systemImage)
                .font(DesignSystem.Font.body)
                .foregroundStyle(item.id == 1 ? DesignSystem.Color.accent : DesignSystem.Color.primary)
                .listRowBackground(
                    item.id == 1
                        ? DesignSystem.Color.accent.opacity(0.12)
                        : Color.clear
                )
        }
        .frame(maxHeight: 180)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
    }

    @ViewBuilder
    func listView(items: [ListItem]) -> some View {
        applyListStyle(to: buildList(items: items))
    }

    @ViewBuilder
    func buildList(items: [ListItem]) -> some View {
        switch selectionMode {
        case .none:
            plainList(items: items)
        case .single:
            singleSelectionList(items: items)
        case .multiple:
            multiSelectionList(items: items)
        }
    }

    func plainList(items: [ListItem]) -> some View {
        applyModifiers(
            to: List(items, id: \.id) { item in
                rowContent(item: item)
            }
        )
    }

    func singleSelectionList(items: [ListItem]) -> some View {
        applyModifiers(
            to: List(items, id: \.id, selection: $singleSelection) { item in
                rowContent(item: item)
            }
        )
    }

    func multiSelectionList(items: [ListItem]) -> some View {
        applyModifiers(
            to: List(items, id: \.id, selection: $multiSelection) { item in
                rowContent(item: item)
            }
        )
    }

    @ViewBuilder
    func rowContent(item: ListItem) -> some View {
        #if os(macOS)
        decoratedRow(item: item)
        #else
        if swipeActionsEnabled {
            decoratedRow(item: item)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
        } else {
            decoratedRow(item: item)
        }
        #endif
    }

    func decoratedRow(item: ListItem) -> some View {
        itemLabel(item: item)
            .listRowBackground(showRowBackground ? rowBackground.opacity(0.15) : nil)
            .listRowSeparator(separatorVisibility.visibility)
            .listRowSeparatorTint(showSeparatorTint ? separatorTint : nil)
    }

    func itemLabel(item: ListItem) -> some View {
        Label {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.hairline) {
                Text(item.title)
                    .font(DesignSystem.Font.body)
                Text(item.subtitle)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        } icon: {
            Image(systemName: item.systemImage)
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }

    @ViewBuilder
    func applyModifiers(to list: some View) -> some View {
        applyRowSpacing(to: list)
            .listSectionSpacing(sectionSpacing.spacing)
            .environment(\.editMode, editModeActive ? .constant(.active) : .constant(.inactive))
    }

    @ViewBuilder
    func applyRowSpacing(to list: some View) -> some View {
        if useRowSpacing {
            list.listRowSpacing(rowSpacingValue)
        } else {
            list
        }
    }

    @ViewBuilder
    func applyListStyle(to list: some View) -> some View {
        switch style {
        case .automatic:
            list.listStyle(.automatic)
        case .plain:
            list.listStyle(.plain)
        case .inset:
            list.listStyle(.inset)
        case .sidebar:
            list.listStyle(.sidebar)
        #if os(macOS)
        case .bordered:
            list.listStyle(.bordered)
        #else
        case .grouped:
            list.listStyle(.grouped)
        case .insetGrouped:
            list.listStyle(.insetGrouped)
        #endif
        }
    }
}

// MARK: - Code generation
private extension ListShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append(selectionLine)
        lines.append("    ForEach(items) { item in")
        lines.append("        rowView(item)")
        appendRowModifiers(&lines)
        lines.append("    }")
        if editModeActive {
            lines.append("    .onMove { from, to in move(from, to) }")
            lines.append("    .onDelete { offsets in remove(offsets) }")
        }
        lines.append("}")
        lines.append(".listStyle(.\(style.label))")
        if useRowSpacing {
            lines.append(".listRowSpacing(\(Int(rowSpacingValue)))")
        }
        lines.append(".listSectionSpacing(.\(sectionSpacing.label))")
        if editModeActive {
            lines.append(".environment(\\.editMode, $editMode)")
        }
        return lines.joined(separator: "\n")
    }

    var selectionLine: String {
        switch selectionMode {
        case .none: "List {"
        case .single: "List(selection: $selection) {"
        case .multiple: "List(selection: $multiSelection) {"
        }
    }

    func appendRowModifiers(_ lines: inout [String]) {
        if showRowBackground {
            lines.append("        .listRowBackground(color.opacity(0.15))")
        }
        if separatorVisibility != .automatic {
            lines.append("        .listRowSeparator(.\(separatorVisibility.label))")
        }
        if showSeparatorTint {
            lines.append("        .listRowSeparatorTint(tintColor)")
        }
        #if !os(macOS)
        if swipeActionsEnabled {
            lines.append("        .swipeActions(edge: .trailing) {")
            lines.append("            Button(role: .destructive) { delete(item) } label: {")
            lines.append("                Label(\"Delete\", systemImage: \"trash\")")
            lines.append("            }")
            lines.append("        }")
        }
        #endif
    }
}
