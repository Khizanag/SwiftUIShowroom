import SwiftUI

struct GridShowcase: View {
    @State private var alignment: GridAlignmentOption = .center
    @State private var horizontalSpacing: Double = 8
    @State private var verticalSpacing: Double = 8
    @State private var useCustomHSpacing = false
    @State private var useCustomVSpacing = false

    var body: some View {
        ShowcaseScreen(
            title: "Grid",
            summary: "Arranges views in a two-dimensional layout, aligning cells across rows and columns.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension GridShowcase {
    var preview: some View {
        gridView(rowCount: 3)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Alignment", selection: $alignment)
        ShowcaseToggle("Custom horizontal spacing", isOn: $useCustomHSpacing)
        if useCustomHSpacing {
            ShowcaseSlider("Horizontal spacing", value: $horizontalSpacing, in: 0...32)
        }
        ShowcaseToggle("Custom vertical spacing", isOn: $useCustomVSpacing)
        if useCustomVSpacing {
            ShowcaseSlider("Vertical spacing", value: $verticalSpacing, in: 0...32)
        }
    }

    @ViewBuilder
    func stateView(_ state: GridState) -> some View {
        switch state {
        case .default:
            gridView(rowCount: 2)
        case .longContent:
            gridView(rowCount: 5)
        }
    }

    func gridView(rowCount: Int) -> some View {
        Grid(
            alignment: alignment.swiftUIAlignment,
            horizontalSpacing: useCustomHSpacing ? horizontalSpacing : nil,
            verticalSpacing: useCustomVSpacing ? verticalSpacing : nil,
        ) {
            ForEach(0..<rowCount, id: \.self) { row in
                GridRow {
                    cellView(label: "A\(row + 1)")
                    cellView(label: "B\(row + 1)")
                    cellView(label: "C\(row + 1)")
                }
            }
        }
    }

    func cellView(label: String) -> some View {
        Text(label)
            .font(DesignSystem.Font.headline)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .frame(minWidth: 44, minHeight: 36)
            .padding(.horizontal, DesignSystem.Spacing.small)
            .background(DesignSystem.Color.accent, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
    }
}

// MARK: - Code generation
private extension GridShowcase {
    var generatedCode: String {
        let hSpacingArg = useCustomHSpacing ? ", horizontalSpacing: \(Int(horizontalSpacing))" : ""
        let vSpacingArg = useCustomVSpacing ? ", verticalSpacing: \(Int(verticalSpacing))" : ""
        return """
        Grid(alignment: .\(alignment.label)\(hSpacingArg)\(vSpacingArg)) {
            GridRow {
                Text("A1")
                Text("B1")
                Text("C1")
            }
            GridRow {
                Text("A2")
                Text("B2")
                Text("C2")
            }
        }
        """
    }
}

// MARK: - Nested types
extension GridShowcase {
    fileprivate enum GridAlignmentOption: ShowcasePickable {
        case topLeading, top, topTrailing
        case leading, center, trailing
        case bottomLeading, bottom, bottomTrailing

        var label: String {
            switch self {
            case .topLeading: "topLeading"
            case .top: "top"
            case .topTrailing: "topTrailing"
            case .leading: "leading"
            case .center: "center"
            case .trailing: "trailing"
            case .bottomLeading: "bottomLeading"
            case .bottom: "bottom"
            case .bottomTrailing: "bottomTrailing"
            }
        }

        var swiftUIAlignment: Alignment {
            switch self {
            case .topLeading: .topLeading
            case .top: .top
            case .topTrailing: .topTrailing
            case .leading: .leading
            case .center: .center
            case .trailing: .trailing
            case .bottomLeading: .bottomLeading
            case .bottom: .bottom
            case .bottomTrailing: .bottomTrailing
            }
        }
    }

    fileprivate enum GridState: ShowcaseState {
        case `default`
        case longContent

        var caption: String {
            switch self {
            case .default: "Default (3 rows)"
            case .longContent: "Long content (5 rows)"
            }
        }
    }
}
