import SwiftUI

struct TableShowcase: View {
    @State private var tableStyle: TableStyleOption = .automatic
    @State private var selectionMode: SelectionModeOption = .none
    @State private var sortingEnabled = true
    @State private var headersVisibility: ColumnHeadersOption = .automatic

    var body: some View {
        ShowcaseScreen(
            title: "Table",
            summary: "Rows of data in sortable, selectable columns. Best on macOS and regular-width iPad.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension TableShowcase {
    @ViewBuilder
    var preview: some View {
        #if os(tvOS)
        unavailableView
        #else
        TablePreviewContainer(
            tableStyle: tableStyle,
            selectionMode: selectionMode,
            sortingEnabled: sortingEnabled,
            headersVisibility: headersVisibility,
        )
        .frame(minHeight: 220)
        #endif
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Style", selection: $tableStyle)
        ShowcasePicker("Selection", selection: $selectionMode)
        ShowcaseToggle("Sort order binding", isOn: $sortingEnabled)
        ShowcasePicker("Column headers", selection: $headersVisibility)
    }

    @ViewBuilder
    func stateView(_ state: TableGalleryState) -> some View {
        #if os(tvOS)
        unavailableView
            .frame(height: 100)
        #else
        tableForGalleryState(state)
        #endif
    }

    #if os(tvOS)
    var unavailableView: some View {
        ContentUnavailableView(
            "Not Available",
            systemImage: "tablecells",
            description: Text("Table is not supported on tvOS.")
        )
        .frame(maxWidth: .infinity)
    }
    #else
    @ViewBuilder
    func tableForGalleryState(_ state: TableGalleryState) -> some View {
        switch state {
        case .default:
            SimpleTableView(rows: TablePerson.samples, selectedID: nil)
                .frame(minHeight: 160)
        case .empty:
            SimpleTableView(rows: [], selectedID: nil)
                .frame(minHeight: 100)
                .overlay(
                    Text("No data")
                        .font(DesignSystem.Font.callout)
                        .foregroundStyle(DesignSystem.Color.secondary),
                )
        case .selected:
            SimpleTableView(rows: TablePerson.samples, selectedID: TablePerson.samples.first?.id)
                .frame(minHeight: 160)
        case .longContent:
            SimpleTableView(rows: TablePerson.longSamples, selectedID: nil)
                .frame(minHeight: 220)
        }
    }
    #endif
}

// MARK: - Code generation
private extension TableShowcase {
    var generatedCode: String {
        let tableInit = tableInitSnippet
        let sortOnChange = sortingEnabled
            ? "\n.onChange(of: sortOrder) { _, order in people.sort(using: order) }"
            : ""
        return """
        \(tableInit) {
            TableColumn("Given Name", value: \\.givenName)
            TableColumn("Family Name", value: \\.familyName)
            TableColumn("E-Mail", value: \\.emailAddress)
        }
        .tableStyle(\(tableStyle.codeSnippet))
        .tableColumnHeaders(\(headersVisibility.codeSnippet))\(sortOnChange)
        """
    }

    var tableInitSnippet: String {
        let sortArg = sortingEnabled ? ", sortOrder: $sortOrder" : ""
        switch selectionMode {
        case .none:
            return "Table(people\(sortArg))"
        case .single:
            return "Table(people, selection: $singleSelection\(sortArg))"
        case .multiple:
            return "Table(people, selection: $multiSelection\(sortArg))"
        }
    }
}

// MARK: - Nested types
fileprivate extension TableShowcase {
    enum TableStyleOption: ShowcasePickable {
        case automatic, inset, bordered

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .inset: "inset"
            case .bordered: "bordered (macOS)"
            }
        }

        var codeSnippet: String {
            switch self {
            case .automatic: ".automatic"
            case .inset: ".inset(alternatesRowBackgrounds: true)"
            case .bordered: ".bordered(alternatesRowBackgrounds: true)"
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

    enum ColumnHeadersOption: ShowcasePickable {
        case automatic, visible, hidden

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .visible: "visible"
            case .hidden: "hidden"
            }
        }

        var codeSnippet: String {
            switch self {
            case .automatic: ".automatic"
            case .visible: ".visible"
            case .hidden: ".hidden"
            }
        }
    }

    enum TableGalleryState: ShowcaseState {
        case `default`, empty, selected, longContent

        var caption: String {
            switch self {
            case .default: "Default"
            case .empty: "Empty"
            case .selected: "Row selected"
            case .longContent: "Long content"
            }
        }
    }
}

// MARK: - Data model
private struct TablePerson: Identifiable {
    let id: UUID
    var givenName: String
    var familyName: String
    var emailAddress: String

    init(given: String, family: String, email: String) {
        self.id = UUID()
        self.givenName = given
        self.familyName = family
        self.emailAddress = email
    }

    static let samples: [TablePerson] = [
        TablePerson(given: "Maria", family: "Santos", email: "m.santos@example.com"),
        TablePerson(given: "James", family: "Chen", email: "j.chen@example.com"),
        TablePerson(given: "Aisha", family: "Patel", email: "a.patel@example.com"),
        TablePerson(given: "Luca", family: "Romano", email: "l.romano@example.com"),
    ]

    static let longSamples: [TablePerson] = samples + [
        TablePerson(given: "Ingrid", family: "Berg", email: "i.berg@example.com"),
        TablePerson(given: "Carlos", family: "Rivera", email: "c.rivera@example.com"),
        TablePerson(given: "Yuki", family: "Tanaka", email: "y.tanaka@example.com"),
        TablePerson(given: "Fatima", family: "Al-Rashid", email: "f.alrashid@example.com"),
    ]
}

// MARK: - Platform helpers
#if !os(tvOS)
private struct TablePreviewContainer: View {
    let tableStyle: TableShowcase.TableStyleOption
    let selectionMode: TableShowcase.SelectionModeOption
    let sortingEnabled: Bool
    let headersVisibility: TableShowcase.ColumnHeadersOption

    @State private var singleSelection: TablePerson.ID?
    @State private var multiSelection: Set<TablePerson.ID> = []
    @State private var sortOrder: [KeyPathComparator<TablePerson>] = []
    @State private var people: [TablePerson] = TablePerson.samples

    var body: some View {
        headered(styled(content))
            .onChange(of: sortOrder) { _, newOrder in
                people.sort(using: newOrder)
            }
    }

    @ViewBuilder
    private var content: some View {
        switch selectionMode {
        case .none:
            if sortingEnabled {
                Table(people, sortOrder: $sortOrder) {
                    TableColumn("Given Name", sortUsing: KeyPathComparator(\.givenName)) { Text($0.givenName) }
                    TableColumn("Family Name", sortUsing: KeyPathComparator(\.familyName)) { Text($0.familyName) }
                    TableColumn("E-Mail") {
                        Text($0.emailAddress)
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.secondary)
                    }
                }
            } else {
                Table(people) {
                    TableColumn("Given Name") { Text($0.givenName) }
                    TableColumn("Family Name") { Text($0.familyName) }
                    TableColumn("E-Mail") {
                        Text($0.emailAddress)
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.secondary)
                    }
                }
            }
        case .single:
            if sortingEnabled {
                Table(people, selection: $singleSelection, sortOrder: $sortOrder) {
                    TableColumn("Given Name", sortUsing: KeyPathComparator(\.givenName)) { Text($0.givenName) }
                    TableColumn("Family Name", sortUsing: KeyPathComparator(\.familyName)) { Text($0.familyName) }
                    TableColumn("E-Mail") {
                        Text($0.emailAddress)
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.secondary)
                    }
                }
            } else {
                Table(people, selection: $singleSelection) {
                    TableColumn("Given Name") { Text($0.givenName) }
                    TableColumn("Family Name") { Text($0.familyName) }
                    TableColumn("E-Mail") {
                        Text($0.emailAddress)
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.secondary)
                    }
                }
            }
        case .multiple:
            if sortingEnabled {
                Table(people, selection: $multiSelection, sortOrder: $sortOrder) {
                    TableColumn("Given Name", sortUsing: KeyPathComparator(\.givenName)) { Text($0.givenName) }
                    TableColumn("Family Name", sortUsing: KeyPathComparator(\.familyName)) { Text($0.familyName) }
                    TableColumn("E-Mail") {
                        Text($0.emailAddress)
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.secondary)
                    }
                }
            } else {
                Table(people, selection: $multiSelection) {
                    TableColumn("Given Name") { Text($0.givenName) }
                    TableColumn("Family Name") { Text($0.familyName) }
                    TableColumn("E-Mail") {
                        Text($0.emailAddress)
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.secondary)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func styled(_ view: some View) -> some View {
        #if os(macOS)
        switch tableStyle {
        case .automatic:
            view.tableStyle(.automatic)
        case .inset:
            view.tableStyle(.inset(alternatesRowBackgrounds: true))
        case .bordered:
            view.tableStyle(.bordered(alternatesRowBackgrounds: true))
        }
        #else
        switch tableStyle {
        case .automatic:
            view.tableStyle(.automatic)
        case .inset:
            view.tableStyle(.automatic)
        case .bordered:
            view.tableStyle(.automatic)
        }
        #endif
    }

    @ViewBuilder
    private func headered(_ view: some View) -> some View {
        switch headersVisibility {
        case .automatic:
            view.tableColumnHeaders(.automatic)
        case .visible:
            view.tableColumnHeaders(.visible)
        case .hidden:
            view.tableColumnHeaders(.hidden)
        }
    }
}

private struct SimpleTableView: View {
    let rows: [TablePerson]
    let selectedID: TablePerson.ID?

    var body: some View {
        Table(rows, selection: .constant(selectedID)) {
            TableColumn("Given Name") { Text($0.givenName) }
            TableColumn("Family Name") { Text($0.familyName) }
            TableColumn("E-Mail") {
                Text($0.emailAddress)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
        .tableStyle(.automatic)
    }
}
#endif
