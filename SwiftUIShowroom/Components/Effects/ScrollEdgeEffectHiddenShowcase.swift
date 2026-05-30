import SwiftUI

struct ScrollEdgeEffectHiddenShowcase: View {
    @State private var isHidden = true
    @State private var edges: EdgeSetOption = .top

    var body: some View {
        ShowcaseScreen(
            title: "Scroll Edge Effect Hidden",
            summary: "Hides the scroll edge blur-fade effect on specified edges.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ScrollEdgeEffectHiddenShowcase {
    var preview: some View {
        scrollContent(isHidden: isHidden, edges: edges.edgeSet)
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("Hidden", isOn: $isHidden)
        ShowcasePicker("Edges", selection: $edges)
    }

    @ViewBuilder func stateView(_ state: HiddenState) -> some View {
        scrollContent(isHidden: state.isHidden, edges: .top)
    }

    func scrollContent(isHidden: Bool, edges: Edge.Set) -> some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xSmall) {
                ForEach(0..<12, id: \.self) { index in
                    Text("Row \(index + 1)")
                        .font(DesignSystem.Font.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, DesignSystem.Spacing.medium)
                        .padding(.vertical, DesignSystem.Spacing.small)
                        .background(DesignSystem.Color.cardBackground)
                        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.small))
                }
            }
            .padding(DesignSystem.Spacing.small)
        }
        .frame(height: 200)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
        .scrollEdgeEffectHidden(isHidden, for: edges)
    }
}

// MARK: - Code generation
private extension ScrollEdgeEffectHiddenShowcase {
    var generatedCode: String {
        [
            "ScrollView { /* content */ }",
            "    .scrollEdgeEffectHidden(\(isHidden), for: .\(edges.label))",
        ].joined(separator: "\n")
    }
}

// MARK: - Nested types
extension ScrollEdgeEffectHiddenShowcase {
    enum EdgeSetOption: ShowcasePickable {
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

    enum HiddenState: ShowcaseState {
        case visible, hidden

        var caption: String {
            switch self {
            case .visible: "Effect visible"
            case .hidden: "Effect hidden"
            }
        }

        var isHidden: Bool {
            switch self {
            case .visible: false
            case .hidden: true
            }
        }
    }
}
