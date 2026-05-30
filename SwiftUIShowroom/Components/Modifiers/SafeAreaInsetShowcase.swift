import SwiftUI

struct SafeAreaInsetShowcase: View {
    @State private var edge: EdgeOption = .bottom
    @State private var alignment: AlignmentOption = .center
    @State private var spacing: Double = 0

    var body: some View {
        ShowcaseScreen(
            title: "Safe Area Inset",
            summary: "Insets the safe area by an auxiliary view pinned to an edge (e.g. a floating bar).",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension SafeAreaInsetShowcase {
    fileprivate enum EdgeOption: ShowcasePickable {
        case top, bottom, leading, trailing

        var label: String {
            switch self {
            case .top: "top"
            case .bottom: "bottom"
            case .leading: "leading"
            case .trailing: "trailing"
            }
        }

        var isVertical: Bool {
            self == .top || self == .bottom
        }
    }

    fileprivate enum AlignmentOption: ShowcasePickable {
        case center, leading, trailing, top, bottom

        var label: String {
            switch self {
            case .center: "center"
            case .leading: "leading"
            case .trailing: "trailing"
            case .top: "top"
            case .bottom: "bottom"
            }
        }
    }

    fileprivate enum InsetState: ShowcaseState {
        case withBar, noBar

        var caption: String {
            switch self {
            case .withBar: "With inset bar"
            case .noBar: "No inset (baseline)"
            }
        }
    }
}

// MARK: - Sub-views
private extension SafeAreaInsetShowcase {
    var preview: some View {
        scrollContent
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
    }

    var scrollContent: some View {
        ZStack {
            applyInset(to: rowList)
        }
    }

    @ViewBuilder
    func applyInset<Content: View>(to content: Content) -> some View {
        if edge.isVertical {
            applyVerticalInset(to: content)
        } else {
            applyHorizontalInset(to: content)
        }
    }

    @ViewBuilder
    func applyVerticalInset<Content: View>(to content: Content) -> some View {
        let verticalEdge: VerticalEdge = edge == .top ? .top : .bottom
        let horizontalAlignment: HorizontalAlignment = {
            switch alignment {
            case .leading: return .leading
            case .trailing: return .trailing
            default: return .center
            }
        }()
        content
            .safeAreaInset(
                edge: verticalEdge,
                alignment: horizontalAlignment,
                spacing: CGFloat(spacing),
            ) {
                floatingBar
            }
    }

    @ViewBuilder
    func applyHorizontalInset<Content: View>(to content: Content) -> some View {
        let horizontalEdge: HorizontalEdge = edge == .leading ? .leading : .trailing
        let verticalAlignment: VerticalAlignment = {
            switch alignment {
            case .top: return .top
            case .bottom: return .bottom
            default: return .center
            }
        }()
        content
            .safeAreaInset(
                edge: horizontalEdge,
                alignment: verticalAlignment,
                spacing: CGFloat(spacing),
            ) {
                floatingBar
            }
    }

    var rowList: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xSmall) {
                ForEach(1...8, id: \.self) { index in
                    rowCell(index: index)
                }
            }
            .padding(DesignSystem.Spacing.small)
        }
        .background(DesignSystem.Color.background)
    }

    func rowCell(index: Int) -> some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "doc.text")
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(width: DesignSystem.Size.Icon.small, height: DesignSystem.Size.Icon.small)
            Text("Row \(index)")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.primary)
            Spacer()
        }
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    var floatingBar: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(DesignSystem.Color.onAccent)
                .font(DesignSystem.Font.headline)
            Text("Floating Bar")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.onAccent)
        }
        .padding(.horizontal, DesignSystem.Spacing.medium)
        .padding(.vertical, DesignSystem.Spacing.small)
        .background(DesignSystem.Color.accent)
        .clipShape(Capsule())
        .padding(DesignSystem.Spacing.small)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Edge", selection: $edge)
        ShowcasePicker("Alignment", selection: $alignment)
        ShowcaseSlider("Spacing", value: $spacing, in: 0...32, step: 1)
    }

    @ViewBuilder
    func stateView(_ state: InsetState) -> some View {
        switch state {
        case .withBar:
            withBarStateView
        case .noBar:
            noBarStateView
        }
    }

    var withBarStateView: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xSmall) {
                ForEach(1...4, id: \.self) { index in
                    rowCell(index: index)
                }
            }
            .padding(DesignSystem.Spacing.small)
        }
        .frame(height: 160)
        .background(DesignSystem.Color.background)
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 0) {
            floatingBar
        }
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    var noBarStateView: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xSmall) {
                ForEach(1...4, id: \.self) { index in
                    rowCell(index: index)
                }
            }
            .padding(DesignSystem.Spacing.small)
        }
        .frame(height: 160)
        .background(DesignSystem.Color.background)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Code generation
private extension SafeAreaInsetShowcase {
    var generatedCode: String {
        let edgeStr = edge.label
        let spacingStr = spacing == 0 ? "0" : String(format: "%.0f", spacing)
        if edge.isVertical {
            let alignmentStr = verticalEdgeAlignmentLabel
            return [
                "ScrollView {",
                "    contentRows",
                "}",
                ".safeAreaInset(edge: .\(edgeStr), alignment: .\(alignmentStr), spacing: \(spacingStr)) {",
                "    FloatingBar()",
                "}",
            ].joined(separator: "\n")
        } else {
            let alignmentStr = horizontalEdgeAlignmentLabel
            return [
                "ScrollView {",
                "    contentRows",
                "}",
                ".safeAreaInset(edge: .\(edgeStr), alignment: .\(alignmentStr), spacing: \(spacingStr)) {",
                "    SideBar()",
                "}",
            ].joined(separator: "\n")
        }
    }

    var verticalEdgeAlignmentLabel: String {
        switch alignment {
        case .leading: "leading"
        case .trailing: "trailing"
        default: "center"
        }
    }

    var horizontalEdgeAlignmentLabel: String {
        switch alignment {
        case .top: "top"
        case .bottom: "bottom"
        default: "center"
        }
    }
}
