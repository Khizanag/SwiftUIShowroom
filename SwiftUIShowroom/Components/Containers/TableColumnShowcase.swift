import SwiftUI

struct TableColumnShowcase: View {
    @State private var columnTitle = "Name"
    @State private var widthEnabled = false
    @State private var columnWidth: Double = 150
    @State private var visibility: VisibilityOption = .automatic
    @State private var sortable = true

    var body: some View {
        ShowcaseScreen(
            title: "TableColumn",
            summary: "Displays a value or custom cell per Table row, with optional sorting and width control.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension TableColumnShowcase {
    var preview: some View {
        #if os(tvOS)
        unavailableView
        #else
        tablePreview
        #endif
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Column title", text: $columnTitle, prompt: "Column header text")
        ShowcaseToggle("Custom width", isOn: $widthEnabled)
        if widthEnabled {
            ShowcaseSlider("Width", value: $columnWidth, in: 40...400, step: 1)
        }
        ShowcasePicker("Default visibility", selection: $visibility)
        ShowcaseToggle("Sortable (value key path)", isOn: $sortable)
    }

    @ViewBuilder
    func stateView(_ state: TableColumnState) -> some View {
        #if os(tvOS)
        unavailableView
            .frame(height: 80)
        #else
        switch state {
        case .default:
            miniTableDefault
        case .selected:
            miniTableSelected
        }
        #endif
    }
}

// MARK: - Platform views
private extension TableColumnShowcase {
    var unavailableView: some View {
        ContentUnavailableView(
            "Not Available",
            systemImage: "table",
            description: Text("TableColumn requires iOS 16, iPadOS 16, or macOS 12."),
        )
    }

    #if !os(tvOS)
    var tablePreview: some View {
        buildTable
            .frame(minHeight: 160)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    var miniTableSelected: some View {
        miniSampleTable
            .overlay(alignment: .topLeading) {
                Text("Row 1 selected")
                    .font(DesignSystem.Font.caption2)
                    .padding(.horizontal, DesignSystem.Spacing.xSmall)
                    .padding(.vertical, DesignSystem.Spacing.hairline)
                    .background(DesignSystem.Color.accent.opacity(0.18), in: .capsule)
                    .padding(DesignSystem.Spacing.xSmall)
            }
    }

    var miniTableDefault: some View {
        miniSampleTable
    }

    var miniSampleTable: some View {
        Table(SamplePerson.samples) {
            TableColumn("Name", value: \.name)
            TableColumn("Role", value: \.role)
        }
        .frame(minHeight: 100)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
    }

    @ViewBuilder
    var buildTable: some View {
        if sortable {
            sortableTable
        } else {
            staticTable
        }
    }

    var sortableTable: some View {
        SortableTableContainer(
            title: columnTitle,
            widthEnabled: widthEnabled,
            columnWidth: columnWidth,
        )
    }

    var staticTable: some View {
        StaticTableContainer(
            title: columnTitle,
            widthEnabled: widthEnabled,
            columnWidth: columnWidth,
        )
    }

    #endif
}

// MARK: - Code generation
private extension TableColumnShowcase {
    var generatedCode: String {
        var lines: [String] = []
        let titleArg = "\"\(columnTitle)\""
        if sortable {
            lines.append("TableColumn(\(titleArg), value: \\.name) { row in")
        } else {
            lines.append("TableColumn(\(titleArg)) { row in")
        }
        lines.append("    Text(row.name)")
        lines.append("}")
        if widthEnabled {
            let widthInt = Int(columnWidth)
            lines.append(".width(\(widthInt))")
        }
        if visibility != .automatic {
            lines.append(".defaultVisibility(.\(visibility.label))")
        }
        return lines.joined(separator: "\n")
    }
}

// MARK: - Supporting types
extension TableColumnShowcase {
    enum VisibilityOption: ShowcasePickable {
        case automatic
        case visible
        case hidden

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .visible: "visible"
            case .hidden: "hidden"
            }
        }
    }

    enum TableColumnState: ShowcaseState {
        case `default`
        case selected

        var caption: String {
            switch self {
            case .default: "Default"
            case .selected: "With selection"
            }
        }
    }

    struct SamplePerson: Identifiable {
        let id: UUID
        let name: String
        let role: String

        static let samples: [SamplePerson] = [
            SamplePerson(id: UUID(), name: "Alice", role: "Engineer"),
            SamplePerson(id: UUID(), name: "Bob", role: "Designer"),
            SamplePerson(id: UUID(), name: "Carol", role: "Manager"),
            SamplePerson(id: UUID(), name: "Dave", role: "Analyst"),
        ]
    }
}

// MARK: - Table container helpers
#if !os(tvOS)
private struct SortableTableContainer: View {
    let title: String
    let widthEnabled: Bool
    let columnWidth: Double

    @State private var sortOrder: [KeyPathComparator<TableColumnShowcase.SamplePerson>] = []
    @State private var people = TableColumnShowcase.SamplePerson.samples

    var body: some View {
        Table(people, sortOrder: $sortOrder) {
            if widthEnabled {
                TableColumn(title, value: \.name)
                    .width(columnWidth)
            } else {
                TableColumn(title, value: \.name)
            }
            TableColumn("Role", value: \.role)
        }
        .onChange(of: sortOrder) { _, newOrder in
            people.sort(using: newOrder)
        }
    }
}

private struct StaticTableContainer: View {
    let title: String
    let widthEnabled: Bool
    let columnWidth: Double

    var body: some View {
        Table(TableColumnShowcase.SamplePerson.samples) {
            if widthEnabled {
                TableColumn(title) { row in
                    Text(row.name)
                }
                .width(columnWidth)
            } else {
                TableColumn(title) { row in
                    Text(row.name)
                }
            }
            TableColumn("Role") { row in
                Text(row.role)
            }
        }
    }
}
#endif
