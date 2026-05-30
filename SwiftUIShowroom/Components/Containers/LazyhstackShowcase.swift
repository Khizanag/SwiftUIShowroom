import SwiftUI

struct LazyhstackShowcase: View {
    @State private var alignment: AlignmentOption = .center
    @State private var spacingValue: Double = 12
    @State private var useCustomSpacing = false
    @State private var pinnedViews: PinnedOption = .none
    @State private var itemCount: Int = 20

    var body: some View {
        ShowcaseScreen(
            title: "LazyHStack",
            summary: "A horizontal stack that lazily creates its subviews as they scroll into view.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension LazyhstackShowcase {
    var preview: some View {
        ScrollView(.horizontal) {
            LazyHStack(
                alignment: alignment.verticalAlignment,
                spacing: useCustomSpacing ? spacingValue : nil,
                pinnedViews: pinnedViews.pinnedScrollableViews,
            ) {
                ForEach(0..<itemCount, id: \.self) { index in
                    itemCard(index: index)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.medium)
        }
    }

    func itemCard(index: Int) -> some View {
        VStack(spacing: DesignSystem.Spacing.xSmall) {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(DesignSystem.Color.accent.opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay(
                    Text("\(index + 1)")
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.accent),
                )
            Text("Item \(index + 1)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Alignment", selection: $alignment)
        ShowcaseToggle("Custom spacing", isOn: $useCustomSpacing)
        if useCustomSpacing {
            ShowcaseSlider("Spacing", value: $spacingValue, in: 0...48, step: 1)
        }
        ShowcasePicker("Pinned views", selection: $pinnedViews)
        ShowcaseStepper("Item count", value: $itemCount, in: 0...60)
    }

    @ViewBuilder
    func stateView(_ state: ContentState) -> some View {
        switch state {
        case .default:
            defaultStateView
        case .empty:
            emptyStateView
        case .longContent:
            longContentStateView
        }
    }

    var defaultStateView: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: DesignSystem.Spacing.small) {
                ForEach(0..<6, id: \.self) { index in
                    miniCard(index: index, highlighted: false)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.small)
        }
    }

    var emptyStateView: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                EmptyView()
            }
        }
        .overlay(
            Text("No items")
                .font(DesignSystem.Font.callout)
                .foregroundStyle(DesignSystem.Color.secondary),
        )
        .frame(height: 60)
    }

    var longContentStateView: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: DesignSystem.Spacing.small) {
                ForEach(0..<40, id: \.self) { index in
                    miniCard(index: index, highlighted: index < 5)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.small)
        }
    }

    func miniCard(index: Int, highlighted: Bool) -> some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
            .fill(highlighted ? DesignSystem.Color.accent.opacity(0.3) : DesignSystem.Color.cardBackground)
            .frame(width: 48, height: 48)
            .overlay(
                Text("\(index + 1)")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.secondary),
            )
    }
}

// MARK: - Code generation
private extension LazyhstackShowcase {
    var generatedCode: String {
        let spacingArg = useCustomSpacing ? "\(Int(spacingValue))" : "nil"
        let pinnedArg = pinnedViews.codeString
        var lines: [String] = []
        lines.append("ScrollView(.horizontal) {")
        lines.append("    LazyHStack(")
        lines.append("        alignment: .\(alignment.label),")
        lines.append("        spacing: \(spacingArg),")
        lines.append("        pinnedViews: \(pinnedArg),")
        lines.append("    ) {")
        lines.append("        ForEach(items) { item in")
        lines.append("            CardView(item)")
        lines.append("        }")
        lines.append("    }")
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}

// MARK: - Nested types
private extension LazyhstackShowcase {
    enum AlignmentOption: ShowcasePickable {
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

    enum PinnedOption: ShowcasePickable {
        case none, sectionHeaders, sectionFooters, both

        var label: String {
            switch self {
            case .none: "none"
            case .sectionHeaders: "sectionHeaders"
            case .sectionFooters: "sectionFooters"
            case .both: "sectionHeaders + sectionFooters"
            }
        }

        var codeString: String {
            switch self {
            case .none: "[]"
            case .sectionHeaders: "[.sectionHeaders]"
            case .sectionFooters: "[.sectionFooters]"
            case .both: "[.sectionHeaders, .sectionFooters]"
            }
        }

        var pinnedScrollableViews: PinnedScrollableViews {
            switch self {
            case .none: []
            case .sectionHeaders: [.sectionHeaders]
            case .sectionFooters: [.sectionFooters]
            case .both: [.sectionHeaders, .sectionFooters]
            }
        }
    }

    enum ContentState: ShowcaseState {
        case `default`, empty, longContent

        var caption: String {
            switch self {
            case .default: "Default"
            case .empty: "Empty"
            case .longContent: "Long content"
            }
        }
    }
}
