import SwiftUI

struct GridItemShowcase: View {
    enum SizingOption: ShowcasePickable {
        case flexible
        case adaptive
        case fixed

        var label: String {
            switch self {
            case .flexible: "flexible"
            case .adaptive: "adaptive"
            case .fixed: "fixed"
            }
        }

        var gridItemSize: GridItem.Size {
            switch self {
            case .flexible: .flexible()
            case .adaptive: .adaptive(minimum: 80)
            case .fixed: .fixed(120)
            }
        }

        var gridItemSizeCode: String {
            switch self {
            case .flexible: "flexible()"
            case .adaptive: "adaptive(minimum: 80)"
            case .fixed: "fixed(120)"
            }
        }
    }

    enum AlignmentOption: ShowcasePickable {
        case defaultAlignment
        case leading
        case center
        case trailing
        case top
        case bottom

        var label: String {
            switch self {
            case .defaultAlignment: "default"
            case .leading: "leading"
            case .center: "center"
            case .trailing: "trailing"
            case .top: "top"
            case .bottom: "bottom"
            }
        }

        var alignment: Alignment? {
            switch self {
            case .defaultAlignment: nil
            case .leading: .leading
            case .center: .center
            case .trailing: .trailing
            case .top: .top
            case .bottom: .bottom
            }
        }

        var alignmentCode: String {
            switch self {
            case .defaultAlignment: "nil"
            case .leading: ".leading"
            case .center: ".center"
            case .trailing: ".trailing"
            case .top: ".top"
            case .bottom: ".bottom"
            }
        }
    }

    enum GridItemState: ShowcaseState {
        case flexible
        case adaptive
        case fixed

        var caption: String {
            switch self {
            case .flexible: "flexible"
            case .adaptive: "adaptive(minimum: 80)"
            case .fixed: "fixed(120)"
            }
        }

        var gridItemSize: GridItem.Size {
            switch self {
            case .flexible: .flexible()
            case .adaptive: .adaptive(minimum: 80)
            case .fixed: .fixed(120)
            }
        }
    }

    @State private var sizingOption: SizingOption = .flexible
    @State private var spacing: Double = 8
    @State private var alignmentOption: AlignmentOption = .defaultAlignment

    var body: some View {
        ShowcaseScreen(
            title: "GridItem",
            summary: "A description of a single column (or row) sizing rule for a lazy grid.",
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
private extension GridItemShowcase {
    var preview: some View {
        ScrollView {
            LazyVGrid(
                columns: [makeGridItem(sizing: sizingOption, align: alignmentOption)],
                spacing: spacing,
            ) {
                ForEach(0..<6, id: \.self) { index in
                    sampleCell(index: index)
                }
            }
            .padding(DesignSystem.Spacing.medium)
        }
        .frame(maxHeight: 280)
    }

    func sampleCell(index: Int) -> some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
            .fill(DesignSystem.Color.accent.opacity(0.15))
            .overlay(
                Text("Item \(index + 1)")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.primary),
            )
            .frame(height: 56)
    }

    func makeGridItem(sizing: SizingOption, align: AlignmentOption) -> GridItem {
        GridItem(
            sizing.gridItemSize,
            spacing: spacing,
            alignment: align.alignment,
        )
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Size", selection: $sizingOption)
        ShowcaseSlider("Spacing", value: $spacing, in: 0...32, step: 1)
        ShowcasePicker("Alignment", selection: $alignmentOption)
    }

    @ViewBuilder
    func stateView(_ state: GridItemState) -> some View {
        ScrollView(.horizontal) {
            LazyHGrid(
                rows: [GridItem(state.gridItemSize, spacing: 8)],
                spacing: 8,
            ) {
                ForEach(0..<4, id: \.self) { index in
                    sampleCell(index: index)
                        .frame(width: 80)
                }
            }
            .padding(DesignSystem.Spacing.small)
        }
        .frame(height: 80)
    }
}

// MARK: - Code generation
private extension GridItemShowcase {
    var generatedCode: String {
        let spacingArg = "spacing: \(Int(spacing))"
        let alignArg = "alignment: \(alignmentOption.alignmentCode)"
        return "GridItem(.\(sizingOption.gridItemSizeCode), \(spacingArg), \(alignArg))"
    }
}
