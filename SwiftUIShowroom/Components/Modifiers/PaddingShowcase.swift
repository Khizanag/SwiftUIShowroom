import SwiftUI

struct PaddingShowcase: View {
    @State private var edges: EdgeSetOption = .all
    @State private var useCustomLength = true
    @State private var length: Double = 16

    var body: some View {
        ShowcaseScreen(
            title: "Padding",
            summary: "Adds space around the view along the chosen edges; omit length to use the system default.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension PaddingShowcase {
    var preview: some View {
        paddedSwatch(edges: edges.value, length: resolvedLength)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Edges", selection: $edges)
        ShowcaseToggle("Custom length", isOn: $useCustomLength)
        if useCustomLength {
            ShowcaseSlider("Length", value: $length, in: 0...64, step: 1)
        }
    }

    @ViewBuilder func stateView(_ state: PaddingState) -> some View {
        paddedSwatch(edges: state.edgeSet, length: state.length)
    }

    func paddedSwatch(edges: Edge.Set, length: CGFloat?) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(DesignSystem.Color.accent.opacity(0.15))
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .fill(DesignSystem.Color.accent)
                .padding(edges, length)
        }
        .frame(width: 140, height: 80)
    }

    var resolvedLength: CGFloat? {
        useCustomLength ? CGFloat(length) : nil
    }
}

// MARK: - Code generation
private extension PaddingShowcase {
    var generatedCode: String {
        if let len = resolvedLength {
            return "Text(\"Padded\")\n    .padding(.\(edges.label), \(Int(len)))"
        } else {
            return "Text(\"Padded\")\n    .padding(.\(edges.label))"
        }
    }
}

// MARK: - Nested types
extension PaddingShowcase {
    enum EdgeSetOption: ShowcasePickable {
        case all, horizontal, vertical, top, bottom, leading, trailing

        var label: String {
            switch self {
            case .all: "all"
            case .horizontal: "horizontal"
            case .vertical: "vertical"
            case .top: "top"
            case .bottom: "bottom"
            case .leading: "leading"
            case .trailing: "trailing"
            }
        }

        var value: Edge.Set {
            switch self {
            case .all: .all
            case .horizontal: .horizontal
            case .vertical: .vertical
            case .top: .top
            case .bottom: .bottom
            case .leading: .leading
            case .trailing: .trailing
            }
        }
    }

    enum PaddingState: ShowcaseState {
        case allDefault
        case horizontal
        case vertical
        case topOnly
        case large

        var caption: String {
            switch self {
            case .allDefault: "All (system)"
            case .horizontal: "Horizontal 16"
            case .vertical: "Vertical 16"
            case .topOnly: "Top 8"
            case .large: "All 32"
            }
        }

        var edgeSet: Edge.Set {
            switch self {
            case .allDefault: .all
            case .horizontal: .horizontal
            case .vertical: .vertical
            case .topOnly: .top
            case .large: .all
            }
        }

        var length: CGFloat? {
            switch self {
            case .allDefault: nil
            case .horizontal: 16
            case .vertical: 16
            case .topOnly: 8
            case .large: 32
            }
        }
    }
}
