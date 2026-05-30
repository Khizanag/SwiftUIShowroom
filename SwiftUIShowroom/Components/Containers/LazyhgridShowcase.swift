import SwiftUI

struct LazyhgridShowcase: View {
    @State private var rowSizing: RowSizingOption = .fixed
    @State private var alignment: GridAlignmentOption = .center
    @State private var gridItemSpacing: Double = 8
    @State private var spacing: Double = 8
    @State private var pinnedViews: PinnedViewsOption = .none

    var body: some View {
        ShowcaseScreen(
            title: "LazyHGrid",
            summary: "A grid that grows horizontally, lazily creating items from an array of row definitions.",
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
private extension LazyhgridShowcase {
    var preview: some View {
        ScrollView(.horizontal) {
            LazyHGrid(
                rows: rowSizing.gridItems(spacing: gridItemSpacing),
                alignment: alignment.verticalAlignment,
                spacing: spacing,
                pinnedViews: pinnedViews.pinnedScrollableViews,
            ) {
                ForEach(0..<20, id: \.self) { index in
                    gridCell(index: index)
                }
            }
            .padding(DesignSystem.Spacing.medium)
        }
        .frame(height: previewHeight)
    }

    var previewHeight: CGFloat {
        switch rowSizing {
        case .adaptive: return 200
        case .flexible: return 180
        case .fixed: return 160
        case .mixed: return 200
        }
    }

    func gridCell(index: Int) -> some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(DesignSystem.Color.accent.opacity(0.15 + Double(index % 5) * 0.1))
            .overlay(
                Text("\(index + 1)")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.accent),
            )
            .frame(width: 64, height: 56)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Row sizing", selection: $rowSizing)
        ShowcasePicker("Alignment", selection: $alignment)
        ShowcaseSlider("Item spacing", value: $gridItemSpacing, in: 0...32)
        ShowcaseSlider("Column spacing", value: $spacing, in: 0...32)
        ShowcasePicker("Pinned views", selection: $pinnedViews)
    }

    @ViewBuilder
    func stateView(_ state: GridContentState) -> some View {
        ScrollView(.horizontal) {
            LazyHGrid(
                rows: [GridItem(.fixed(56))],
                alignment: .center,
                spacing: 8,
            ) {
                switch state {
                case .default:
                    ForEach(0..<8, id: \.self) { index in
                        stateCell(index: index, color: DesignSystem.Color.accent)
                    }
                case .empty:
                    EmptyView()
                case .loading:
                    ForEach(0..<6, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                            .fill(DesignSystem.Color.separator.opacity(0.4))
                            .frame(width: 64, height: 56)
                    }
                case .longContent:
                    ForEach(0..<30, id: \.self) { index in
                        stateCell(index: index, color: DesignSystem.Color.accent)
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.small)
        }
        .frame(height: 80)
    }

    func stateCell(index: Int, color: Color) -> some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(color.opacity(0.2))
            .overlay(
                Text("\(index + 1)")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(color),
            )
            .frame(width: 64, height: 56)
    }
}

// MARK: - Nested types
extension LazyhgridShowcase {
    fileprivate enum RowSizingOption: ShowcasePickable {
        case adaptive, flexible, fixed, mixed

        var label: String {
            switch self {
            case .adaptive: "adaptive(minimum:)"
            case .flexible: "flexible()"
            case .fixed: "fixed()"
            case .mixed: "mixed"
            }
        }

        func gridItems(spacing: Double) -> [GridItem] {
            let itemSpacing: CGFloat? = spacing > 0 ? spacing : nil
            switch self {
            case .adaptive:
                return [GridItem(.adaptive(minimum: 56), spacing: itemSpacing)]
            case .flexible:
                return [GridItem(.flexible(), spacing: itemSpacing), GridItem(.flexible(), spacing: itemSpacing)]
            case .fixed:
                return [GridItem(.fixed(56), spacing: itemSpacing), GridItem(.fixed(56), spacing: itemSpacing)]
            case .mixed:
                return [
                    GridItem(.fixed(56), spacing: itemSpacing),
                    GridItem(.flexible(), spacing: itemSpacing),
                ]
            }
        }

        var codeSnippet: String {
            switch self {
            case .adaptive: "GridItem(.adaptive(minimum: 56)"
            case .flexible: "GridItem(.flexible()"
            case .fixed: "GridItem(.fixed(56)"
            case .mixed: "GridItem(.fixed(56)"
            }
        }
    }

    fileprivate enum GridAlignmentOption: ShowcasePickable {
        case top, center, bottom, firstTextBaseline, lastTextBaseline

        var label: String {
            switch self {
            case .top: "top"
            case .center: "center"
            case .bottom: "bottom"
            case .firstTextBaseline: "firstTextBaseline"
            case .lastTextBaseline: "lastTextBaseline"
            }
        }

        var verticalAlignment: VerticalAlignment {
            switch self {
            case .top: .top
            case .center: .center
            case .bottom: .bottom
            case .firstTextBaseline: .firstTextBaseline
            case .lastTextBaseline: .lastTextBaseline
            }
        }
    }

    fileprivate enum PinnedViewsOption: ShowcasePickable {
        case none, sectionHeaders, sectionFooters, both

        var label: String {
            switch self {
            case .none: "none"
            case .sectionHeaders: "sectionHeaders"
            case .sectionFooters: "sectionFooters"
            case .both: "sectionHeaders + sectionFooters"
            }
        }

        var pinnedScrollableViews: PinnedScrollableViews {
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
            case .sectionHeaders: ".sectionHeaders"
            case .sectionFooters: ".sectionFooters"
            case .both: "[.sectionHeaders, .sectionFooters]"
            }
        }
    }

    fileprivate enum GridContentState: ShowcaseState {
        case `default`, empty, loading, longContent

        var caption: String {
            switch self {
            case .default: "Default"
            case .empty: "Empty"
            case .loading: "Loading"
            case .longContent: "Long content"
            }
        }
    }
}

// MARK: - Code generation
private extension LazyhgridShowcase {
    var generatedCode: String {
        let itemSpacingArg = gridItemSpacing > 0 ? ", spacing: \(Int(gridItemSpacing))" : ""
        let rowsCode = "\(rowSizing.codeSnippet)\(itemSpacingArg))"
        let spacingArg = "\(Int(spacing))"
        let pinnedArg = pinnedViews.codeSnippet

        return """
        ScrollView(.horizontal) {
            LazyHGrid(
                rows: [\(rowsCode)],
                alignment: .\(alignment.label),
                spacing: \(spacingArg),
                pinnedViews: \(pinnedArg)
            ) {
                ForEach(items) { item in
                    Color.gray.frame(width: 80)
                }
            }
        }
        """
    }
}
