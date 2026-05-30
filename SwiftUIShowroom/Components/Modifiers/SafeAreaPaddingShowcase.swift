import SwiftUI

struct SafeAreaPaddingShowcase: View {
    @State private var edges: EdgeSetOption = .horizontal
    @State private var length: Double = 16

    var body: some View {
        ShowcaseScreen(
            title: "Safe Area Padding",
            summary: "Extends the safe area by a fixed amount on chosen edges without inserting an auxiliary view.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension SafeAreaPaddingShowcase {
    fileprivate enum EdgeSetOption: ShowcasePickable {
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

        var edgeSet: Edge.Set {
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

    fileprivate enum DemoState: ShowcaseState {
        case `default`

        var caption: String {
            switch self {
            case .default: "Default"
            }
        }
    }
}

// MARK: - Sub-views
private extension SafeAreaPaddingShowcase {
    var preview: some View {
        carouselDemo(edges: edges.edgeSet, length: CGFloat(length))
    }

    func carouselDemo(edges: Edge.Set, length: CGFloat) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: DesignSystem.Spacing.small) {
                ForEach(0..<6, id: \.self) { index in
                    carouselCard(index: index)
                }
            }
        }
        .safeAreaPadding(edges, length)
    }

    func carouselCard(index: Int) -> some View {
        VStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: cardSymbol(for: index))
                .font(DesignSystem.Font.title)
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(width: DesignSystem.Size.Icon.xLarge, height: DesignSystem.Size.Icon.xLarge)
            Text("Card \(index + 1)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .frame(width: 100, height: 100)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    func cardSymbol(for index: Int) -> String {
        let symbols = ["star.fill", "heart.fill", "bolt.fill", "leaf.fill", "moon.fill", "sun.max.fill"]
        return symbols[index % symbols.count]
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Edges", selection: $edges)
        ShowcaseSlider("Length", value: $length, in: 0...48, step: 1)
    }

    @ViewBuilder
    func stateView(_ state: DemoState) -> some View {
        switch state {
        case .default:
            defaultGalleryView
        }
    }

    var defaultGalleryView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: DesignSystem.Spacing.small) {
                ForEach(0..<4, id: \.self) { index in
                    carouselCard(index: index)
                }
            }
        }
        .safeAreaPadding(.horizontal, 16)
    }
}

// MARK: - Code generation
private extension SafeAreaPaddingShowcase {
    var generatedCode: String {
        let edgesLabel = edges.label
        let lengthValue = length == length.rounded() ? String(Int(length)) : String(format: "%.1f", length)
        let lines = [
            "ScrollView(.horizontal) {",
            "    LazyHStack { cards }",
            "}",
            ".safeAreaPadding(.\(edgesLabel), \(lengthValue))",
        ]
        return lines.joined(separator: "\n")
    }
}
