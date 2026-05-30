import SwiftUI

struct GridRowShowcase: View {
    enum RowAlignmentOption: ShowcasePickable {
        case inherited, top, center, bottom, firstTextBaseline, lastTextBaseline

        var label: String {
            switch self {
            case .inherited: "nil (inherited)"
            case .top: "top"
            case .center: "center"
            case .bottom: "bottom"
            case .firstTextBaseline: "firstTextBaseline"
            case .lastTextBaseline: "lastTextBaseline"
            }
        }

        var verticalAlignment: VerticalAlignment? {
            switch self {
            case .inherited: nil
            case .top: .top
            case .center: .center
            case .bottom: .bottom
            case .firstTextBaseline: .firstTextBaseline
            case .lastTextBaseline: .lastTextBaseline
            }
        }

        var codeValue: String {
            switch self {
            case .inherited: "nil"
            case .top: ".top"
            case .center: ".center"
            case .bottom: ".bottom"
            case .firstTextBaseline: ".firstTextBaseline"
            case .lastTextBaseline: ".lastTextBaseline"
            }
        }
    }

    enum GridRowState: ShowcaseState {
        case standard, mixed, spanning

        var caption: String {
            switch self {
            case .standard: "Standard"
            case .mixed: "Mixed heights"
            case .spanning: "Column span"
            }
        }
    }

    @State private var alignment: RowAlignmentOption = .inherited
    @State private var showSpanning = false

    var body: some View {
        ShowcaseScreen(
            title: "GridRow",
            summary: "A horizontal row in a Grid container, with optional per-row vertical alignment.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension GridRowShowcase {
    var preview: some View {
        Grid(alignment: .center, horizontalSpacing: DesignSystem.Spacing.medium) {
            highlightedRow(alignment: alignment.verticalAlignment)
            baseRow(label: "Label B", icon: "circle")
            baseRow(label: "Label C", icon: "triangle")
        }
        .frame(maxWidth: 360)
        .padding(DesignSystem.Spacing.small)
    }

    func highlightedRow(alignment vertAlign: VerticalAlignment?) -> some View {
        GridRow(alignment: vertAlign) {
            cellPill("Label A", color: DesignSystem.Color.accent)
            Image(systemName: "star.fill")
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(height: 44)
        }
    }

    func baseRow(label: String, icon: String) -> some View {
        GridRow {
            cellPill(label, color: DesignSystem.Color.secondary.opacity(0.2))
            Image(systemName: icon)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }

    func cellPill(_ text: String, color: Color) -> some View {
        Text(text)
            .font(DesignSystem.Font.footnote)
            .padding(.horizontal, DesignSystem.Spacing.small)
            .padding(.vertical, DesignSystem.Spacing.xSmall)
            .background(color.opacity(0.15))
            .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.small))
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Row alignment", selection: $alignment)
        ShowcaseToggle("Show column spanning", isOn: $showSpanning)
    }

    @ViewBuilder
    func stateView(_ state: GridRowState) -> some View {
        switch state {
        case .standard:
            Grid(horizontalSpacing: DesignSystem.Spacing.small) {
                GridRow {
                    cellPill("Col A", color: DesignSystem.Color.accent)
                    Image(systemName: "star")
                }
                GridRow {
                    cellPill("Col B", color: DesignSystem.Color.secondary.opacity(0.2))
                    Image(systemName: "circle")
                }
            }
        case .mixed:
            Grid(alignment: .top, horizontalSpacing: DesignSystem.Spacing.small) {
                GridRow(alignment: .top) {
                    VStack(spacing: DesignSystem.Spacing.xSmall) {
                        cellPill("Tall", color: DesignSystem.Color.accent)
                        cellPill("Cell", color: DesignSystem.Color.accent)
                    }
                    Image(systemName: "arrow.up")
                        .foregroundStyle(DesignSystem.Color.accent)
                }
                GridRow {
                    cellPill("Short", color: DesignSystem.Color.secondary.opacity(0.2))
                    Image(systemName: "circle")
                        .foregroundStyle(DesignSystem.Color.secondary)
                }
            }
        case .spanning:
            Grid(horizontalSpacing: DesignSystem.Spacing.small) {
                GridRow {
                    cellPill("Span 2", color: DesignSystem.Color.accent)
                        .gridCellColumns(2)
                }
                GridRow {
                    cellPill("Col 1", color: DesignSystem.Color.secondary.opacity(0.2))
                    cellPill("Col 2", color: DesignSystem.Color.secondary.opacity(0.2))
                }
            }
        }
    }
}

// MARK: - Code generation
private extension GridRowShowcase {
    var generatedCode: String {
        var lines = ["Grid {"]
        if showSpanning {
            lines.append("    GridRow\(alignmentArg) {")
            lines.append("        Text(\"Spanning\")")
            lines.append("            .gridCellColumns(2)")
            lines.append("    }")
        } else {
            lines.append("    GridRow\(alignmentArg) {")
            lines.append("        Text(\"Label\")")
            lines.append("        Image(systemName: \"star\")")
            lines.append("    }")
        }
        lines.append("}")
        return lines.joined(separator: "\n")
    }

    var alignmentArg: String {
        alignment == .inherited ? "" : "(alignment: \(alignment.codeValue))"
    }
}
