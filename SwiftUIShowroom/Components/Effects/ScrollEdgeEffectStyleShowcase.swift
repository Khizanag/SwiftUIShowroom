import SwiftUI

struct ScrollEdgeEffectStyleShowcase: View {
    enum StyleOption: ShowcasePickable {
        case automatic, soft, hard

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .soft: "soft"
            case .hard: "hard"
            }
        }
    }

    enum EdgesOption: ShowcasePickable {
        case all, top, bottom, leading, trailing, vertical, horizontal

        var label: String {
            switch self {
            case .all: "all"
            case .top: "top"
            case .bottom: "bottom"
            case .leading: "leading"
            case .trailing: "trailing"
            case .vertical: "vertical"
            case .horizontal: "horizontal"
            }
        }

        var edgeSet: Edge.Set {
            switch self {
            case .all: .all
            case .top: .top
            case .bottom: .bottom
            case .leading: .leading
            case .trailing: .trailing
            case .vertical: .vertical
            case .horizontal: .horizontal
            }
        }
    }

    enum StyleState: ShowcaseState {
        case automatic, soft, hard

        var caption: String {
            switch self {
            case .automatic: "automatic"
            case .soft: "soft"
            case .hard: "hard"
            }
        }
    }

    @State private var selectedStyle: StyleOption = .automatic
    @State private var selectedEdges: EdgesOption = .all

    var body: some View {
        ShowcaseScreen(
            title: "Scroll Edge Effect Style",
            summary: "Configures the soft/hard blur-fade on scroll content meeting an edge under floating bars.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ScrollEdgeEffectStyleShowcase {
    var preview: some View {
        scrollDemo(style: selectedStyle, edges: selectedEdges)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Style", selection: $selectedStyle)
        ShowcasePicker("Edges", selection: $selectedEdges)
    }

    @ViewBuilder
    func stateView(_ state: StyleState) -> some View {
        switch state {
        case .automatic:
            scrollDemo(style: .automatic, edges: .all)
        case .soft:
            scrollDemo(style: .soft, edges: .all)
        case .hard:
            scrollDemo(style: .hard, edges: .all)
        }
    }

    func scrollDemo(style: StyleOption, edges: EdgesOption) -> some View {
        ZStack(alignment: .top) {
            styledScrollView(style: style, edges: edges)
            floatingBar
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    func styledScrollView(style: StyleOption, edges: EdgesOption) -> some View {
        let scroll = ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.xSmall) {
                ForEach(0..<20, id: \.self) { index in
                    rowView(index: index)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .padding(.top, DesignSystem.Spacing.xxLarge)
        }
        return applyEdgeStyle(to: scroll, style: style, edgeSet: edges.edgeSet)
    }

    func applyEdgeStyle(
        to scroll: some View,
        style: StyleOption,
        edgeSet: Edge.Set
    ) -> some View {
        switch style {
        case .automatic:
            scroll.scrollEdgeEffectStyle(.automatic, for: edgeSet)
        case .soft:
            scroll.scrollEdgeEffectStyle(.soft, for: edgeSet)
        case .hard:
            scroll.scrollEdgeEffectStyle(.hard, for: edgeSet)
        }
    }

    func rowView(index: Int) -> some View {
        HStack {
            Image(systemName: "doc.text.fill")
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(width: DesignSystem.Size.Icon.small, height: DesignSystem.Size.Icon.small)
            Text("Row \(index + 1)")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.primary)
            Spacer()
        }
        .padding(DesignSystem.Spacing.small)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
        )
    }

    var floatingBar: some View {
        Text("Floating Bar")
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .padding(.vertical, DesignSystem.Spacing.xSmall)
            .background(DesignSystem.Color.accent, in: Capsule())
            .padding(.top, DesignSystem.Spacing.small)
    }
}

// MARK: - Code generation
private extension ScrollEdgeEffectStyleShowcase {
    var generatedCode: String {
        """
        ScrollView {
            LazyVStack { /* rows */ }
        }
        .scrollEdgeEffectStyle(.\(selectedStyle.label), for: .\(selectedEdges.label))
        """
    }
}
