import SwiftUI

struct TableRowShowcase: View {
    @State private var itemLabel = "Espresso"
    @State private var itemPrice: Double = 3.50
    @State private var itemCategory = "Beverage"

    var body: some View {
        ShowcaseScreen(
            title: "TableRow",
            summary: "A row representing a single value in a Table built from static, hand-listed rows.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension TableRowShowcase {
    var preview: some View {
        #if os(tvOS)
        unavailableView
        #else
        tablePreview
        #endif
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Item label", text: $itemLabel, prompt: "Row name")
        ShowcaseSlider("Price", value: $itemPrice, in: 0.5...50, step: 0.5)
        ShowcaseTextControl("Category", text: $itemCategory, prompt: "Category text")
    }

    @ViewBuilder
    func stateView(_ state: RowGalleryState) -> some View {
        #if os(tvOS)
        unavailableView
            .frame(height: 80)
        #else
        galleryTable(for: state)
        #endif
    }
}

// MARK: - Platform views
private extension TableRowShowcase {
    var unavailableView: some View {
        ContentUnavailableView(
            "Not Available",
            systemImage: "tablecells",
            description: Text("TableRow is not supported on tvOS."),
        )
        .frame(maxWidth: .infinity)
    }

    #if !os(tvOS)
    var tablePreview: some View {
        staticTable(
            rows: [
                Purchase(name: itemLabel, price: itemPrice, category: itemCategory),
                Purchase(name: "Croissant", price: 2.75, category: "Food"),
                Purchase(name: "Cold Brew", price: 4.25, category: "Beverage"),
            ],
        )
        .frame(minHeight: 140)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ViewBuilder
    func galleryTable(for state: RowGalleryState) -> some View {
        switch state {
        case .default:
            staticTable(rows: Purchase.samples)
                .frame(minHeight: 120)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        case .selected:
            selectedTable
                .frame(minHeight: 120)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        }
    }

    func staticTable(rows: [Purchase]) -> some View {
        Table(of: Purchase.self) {
            TableColumn("Item") { row in
                Text(row.name)
                    .font(DesignSystem.Font.body)
            }
            TableColumn("Category") { row in
                Text(row.category)
                    .font(DesignSystem.Font.footnote)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
            TableColumn("Price") { row in
                Text(row.price, format: .currency(code: "USD"))
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
        } rows: {
            ForEach(rows) { row in
                TableRow(row)
            }
        }
        .tableStyle(.automatic)
    }

    var selectedTable: some View {
        SelectedTableContainer(rows: Purchase.samples)
    }
    #endif
}

// MARK: - Code generation
private extension TableRowShowcase {
    var generatedCode: String {
        let priceFormatted = String(format: "%.2f", itemPrice)
        return """
        struct Purchase: Identifiable {
            let id: UUID
            var name: String
            var price: Double
            var category: String
        }

        Table(of: Purchase.self) {
            TableColumn("Item") { Text($0.name) }
            TableColumn("Category") { Text($0.category) }
            TableColumn("Price") {
                Text($0.price, format: .currency(code: "USD"))
            }
        } rows: {
            TableRow(Purchase(name: "\(itemLabel)", price: \(priceFormatted), category: "\(itemCategory)"))
            TableRow(Purchase(name: "Croissant", price: 2.75, category: "Food"))
            TableRow(Purchase(name: "Cold Brew", price: 4.25, category: "Beverage"))
        }
        """
    }
}

// MARK: - Nested types
extension TableRowShowcase {
    fileprivate struct Purchase: Identifiable {
        let id: UUID
        let name: String
        let price: Double
        let category: String

        init(name: String, price: Double, category: String) {
            self.id = UUID()
            self.name = name
            self.price = price
            self.category = category
        }

        static let samples: [Purchase] = [
            Purchase(name: "Espresso", price: 3.50, category: "Beverage"),
            Purchase(name: "Croissant", price: 2.75, category: "Food"),
            Purchase(name: "Cold Brew", price: 4.25, category: "Beverage"),
            Purchase(name: "Muffin", price: 3.00, category: "Food"),
        ]
    }

    enum RowGalleryState: ShowcaseState {
        case `default`
        case selected

        var caption: String {
            switch self {
            case .default: "Default"
            case .selected: "Row selected"
            }
        }
    }
}

// MARK: - Table container helpers
#if !os(tvOS)
private struct SelectedTableContainer: View {
    let rows: [TableRowShowcase.Purchase]

    @State private var selection: TableRowShowcase.Purchase.ID?

    init(rows: [TableRowShowcase.Purchase]) {
        self.rows = rows
        self._selection = State(initialValue: rows.first?.id)
    }

    var body: some View {
        Table(of: TableRowShowcase.Purchase.self, selection: $selection) {
            TableColumn("Item") { row in Text(row.name) }
            TableColumn("Price") { row in
                Text(row.price, format: .currency(code: "USD"))
                    .foregroundStyle(DesignSystem.Color.accent)
            }
        } rows: {
            ForEach(rows) { row in
                TableRow(row)
            }
        }
        .tableStyle(.automatic)
    }
}
#endif
