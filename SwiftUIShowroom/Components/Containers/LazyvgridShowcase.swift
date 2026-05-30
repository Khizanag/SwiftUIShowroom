import SwiftUI

struct LazyvgridShowcase: View {
    @State private var columnSizing: ColumnSizingOption = .adaptive
    @State private var gridItemSpacing: Double = 8
    @State private var alignment: GridAlignmentOption = .center
    @State private var spacing: Double = 8
    @State private var pinnedViews: PinnedViewsOption = .none

    var body: some View {
        ShowcaseScreen(
            title: "LazyVGrid",
            summary: "A grid that grows vertically, lazily creating items from an array of column definitions.",
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

// MARK: - Nested types
extension LazyvgridShowcase {
    enum ColumnSizingOption: ShowcasePickable {
        case adaptive
        case flexible
        case fixed
        case mixed

        var label: String {
            switch self {
            case .adaptive: "adaptive(minimum:)"
            case .flexible: "flexible()"
            case .fixed: "fixed()"
            case .mixed: "mixed"
            }
        }

        func columns(itemSpacing: CGFloat?) -> [GridItem] {
            switch self {
            case .adaptive:
                [GridItem(.adaptive(minimum: 80), spacing: itemSpacing)]
            case .flexible:
                [
                    GridItem(.flexible(), spacing: itemSpacing),
                    GridItem(.flexible(), spacing: itemSpacing),
                    GridItem(.flexible(), spacing: itemSpacing),
                ]
            case .fixed:
                [
                    GridItem(.fixed(80), spacing: itemSpacing),
                    GridItem(.fixed(80), spacing: itemSpacing),
                    GridItem(.fixed(80), spacing: itemSpacing),
                ]
            case .mixed:
                [
                    GridItem(.fixed(60), spacing: itemSpacing),
                    GridItem(.flexible(), spacing: itemSpacing),
                    GridItem(.adaptive(minimum: 60), spacing: itemSpacing),
                ]
            }
        }

        func columnsCode(itemSpacingArg: String) -> String {
            let flexible = "GridItem(.flexible()\(itemSpacingArg))"
            let fixed80 = "GridItem(.fixed(80)\(itemSpacingArg))"
            let fixed60 = "GridItem(.fixed(60)\(itemSpacingArg))"
            let adaptive60 = "GridItem(.adaptive(minimum: 60)\(itemSpacingArg))"
            switch self {
            case .adaptive:
                return "[GridItem(.adaptive(minimum: 80)\(itemSpacingArg))]"
            case .flexible:
                return "[\(flexible), \(flexible), \(flexible)]"
            case .fixed:
                return "[\(fixed80), \(fixed80), \(fixed80)]"
            case .mixed:
                return "[\(fixed60), \(flexible), \(adaptive60)]"
            }
        }
    }

    enum GridAlignmentOption: ShowcasePickable {
        case leading
        case center
        case trailing

        var label: String {
            switch self {
            case .leading: "leading"
            case .center: "center"
            case .trailing: "trailing"
            }
        }

        var value: HorizontalAlignment {
            switch self {
            case .leading: .leading
            case .center: .center
            case .trailing: .trailing
            }
        }
    }

    enum PinnedViewsOption: ShowcasePickable {
        case none
        case sectionHeaders
        case sectionFooters
        case both

        var label: String {
            switch self {
            case .none: "none"
            case .sectionHeaders: "sectionHeaders"
            case .sectionFooters: "sectionFooters"
            case .both: "sectionHeaders + sectionFooters"
            }
        }

        var value: PinnedScrollableViews {
            switch self {
            case .none: []
            case .sectionHeaders: .sectionHeaders
            case .sectionFooters: .sectionFooters
            case .both: [.sectionHeaders, .sectionFooters]
            }
        }

        var codeSnippet: String {
            switch self {
            case .none: "[]"
            case .sectionHeaders: "[.sectionHeaders]"
            case .sectionFooters: "[.sectionFooters]"
            case .both: "[.sectionHeaders, .sectionFooters]"
            }
        }
    }

    enum GridState: ShowcaseState {
        case `default`
        case empty
        case loading
        case longContent

        var caption: String {
            switch self {
            case .default: "Default"
            case .empty: "Empty"
            case .loading: "Loading"
            case .longContent: "Long Content"
            }
        }
    }
}

// MARK: - Sub-views
private extension LazyvgridShowcase {
    var preview: some View {
        ScrollView {
            LazyVGrid(
                columns: columnSizing.columns(itemSpacing: gridItemSpacing),
                alignment: alignment.value,
                spacing: spacing,
                pinnedViews: pinnedViews.value,
            ) {
                ForEach(sampleItems(count: 9), id: \.self) { index in
                    gridCell(index: index)
                }
            }
            .padding(DesignSystem.Spacing.small)
        }
        .frame(maxHeight: 260)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Column sizing", selection: $columnSizing)
        ShowcaseSlider(
            "Grid item spacing",
            value: $gridItemSpacing,
            in: 0...32,
            step: 2,
        )
        ShowcasePicker("Alignment", selection: $alignment)
        ShowcaseSlider("Row spacing", value: $spacing, in: 0...32, step: 2)
        ShowcasePicker("Pinned views", selection: $pinnedViews)
    }

    @ViewBuilder
    func stateView(_ state: GridState) -> some View {
        switch state {
        case .default:
            compactGrid(items: sampleItems(count: 6))
        case .empty:
            emptyGrid
        case .loading:
            loadingGrid
        case .longContent:
            compactGrid(items: sampleItems(count: 18))
        }
    }

    func compactGrid(items: [Int]) -> some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 48))],
                alignment: .center,
                spacing: DesignSystem.Spacing.small,
            ) {
                ForEach(items, id: \.self) { index in
                    gridCell(index: index)
                }
            }
            .padding(DesignSystem.Spacing.xSmall)
        }
        .frame(maxHeight: 160)
    }

    var emptyGrid: some View {
        ContentUnavailableView(
            "No Items",
            systemImage: "square.grid.2x2",
            description: Text("The grid has no content to display."),
        )
        .frame(maxWidth: .infinity, minHeight: 100)
    }

    var loadingGrid: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 48))],
            alignment: .center,
            spacing: DesignSystem.Spacing.small,
        ) {
            ForEach(sampleItems(count: 6), id: \.self) { _ in
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .fill(DesignSystem.Color.separator.opacity(0.4))
                    .frame(height: 48)
                    .shimmering()
            }
        }
        .padding(DesignSystem.Spacing.xSmall)
    }

    func gridCell(index: Int) -> some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
            .fill(cellColor(index: index))
            .frame(height: 56)
            .overlay(
                Text("\(index + 1)")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.onAccent),
            )
    }

    func cellColor(index: Int) -> Color {
        let palette: [Color] = [
            .accentColor,
            .accentColor.opacity(0.7),
            .accentColor.opacity(0.5),
            .accentColor.opacity(0.85),
            .accentColor.opacity(0.6),
            .accentColor.opacity(0.75),
        ]
        return palette[index % palette.count]
    }

    func sampleItems(count: Int) -> [Int] {
        Array(0..<count)
    }
}

// MARK: - Code generation
private extension LazyvgridShowcase {
    var generatedCode: String {
        let itemSpacingArg = gridItemSpacing == 8 ? "" : ", spacing: \(Int(gridItemSpacing))"
        let rowSpacing = spacing == 8 ? "nil" : "\(Int(spacing))"
        let columnsCode = columnSizing.columnsCode(itemSpacingArg: itemSpacingArg)
        var lines: [String] = []
        lines.append("ScrollView {")
        lines.append("    LazyVGrid(")
        lines.append("        columns: \(columnsCode),")
        lines.append("        alignment: .\(alignment.label),")
        lines.append("        spacing: \(rowSpacing),")
        lines.append("        pinnedViews: \(pinnedViews.codeSnippet),")
        lines.append("    ) {")
        lines.append("        ForEach(items) { item in")
        lines.append("            Color.gray.frame(height: 80)")
        lines.append("        }")
        lines.append("    }")
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}

// MARK: - Shimmer modifier
private extension View {
    func shimmering() -> some View {
        self.overlay(
            LinearGradient(
                colors: [
                    .clear,
                    DesignSystem.Color.cardBackground.opacity(0.5),
                    .clear,
                ],
                startPoint: .leading,
                endPoint: .trailing,
            )
        )
    }
}
