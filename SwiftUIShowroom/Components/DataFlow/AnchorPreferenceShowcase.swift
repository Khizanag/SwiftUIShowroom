import SwiftUI

struct AnchorPreferenceShowcase: View {
    @State private var anchorSource: AnchorSourceOption = .bounds
    @State private var selectedIndex = 1
    @State private var showHighlight = true

    var body: some View {
        ShowcaseScreen(
            title: "anchorPreference",
            summary: "Reports a geometric Anchor up the view tree via a PreferenceKey for overlay alignment.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension AnchorPreferenceShowcase {
    fileprivate enum AnchorSourceOption: ShowcasePickable {
        case bounds
        case center
        case topLeading
        case bottomTrailing

        var label: String {
            switch self {
            case .bounds: ".bounds"
            case .center: ".center"
            case .topLeading: ".topLeading"
            case .bottomTrailing: ".bottomTrailing"
            }
        }
    }

    fileprivate enum AnchorDemoState: ShowcaseState {
        case singleItem
        case multipleItems
        case noSelection

        var caption: String {
            switch self {
            case .singleItem: "Single item"
            case .multipleItems: "Multiple items"
            case .noSelection: "No selection"
            }
        }
    }

    fileprivate struct BoundsAnchorKey: PreferenceKey {
        static let defaultValue: [Int: Anchor<CGRect>] = [:]
        static func reduce(
            value: inout [Int: Anchor<CGRect>],
            nextValue: () -> [Int: Anchor<CGRect>]
        ) {
            value.merge(nextValue()) { _, new in new }
        }
    }
}

// MARK: - Sub-views
private extension AnchorPreferenceShowcase {
    var preview: some View {
        itemList(
            count: 3,
            highlightedIndex: showHighlight ? selectedIndex : -1,
            source: anchorSource,
        )
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Anchor source", selection: $anchorSource)
        ShowcaseStepper("Selected index", value: $selectedIndex, in: 0 ... 2)
        ShowcaseToggle("Show highlight overlay", isOn: $showHighlight)
    }

    @ViewBuilder
    func stateView(_ state: AnchorDemoState) -> some View {
        switch state {
        case .singleItem:
            itemList(count: 1, highlightedIndex: 0, source: .bounds)
        case .multipleItems:
            itemList(count: 4, highlightedIndex: 2, source: .bounds)
        case .noSelection:
            itemList(count: 3, highlightedIndex: -1, source: .bounds)
        }
    }

    func itemList(
        count: Int,
        highlightedIndex: Int,
        source: AnchorSourceOption
    ) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            ForEach(0 ..< count, id: \.self) { index in
                rowView(index: index)
                    .anchorPreference(key: BoundsAnchorKey.self, value: .bounds) { anchor in
                        [index: anchor]
                    }
            }
        }
        .overlayPreferenceValue(BoundsAnchorKey.self) { anchors in
            highlightOverlay(
                anchors: anchors,
                highlightedIndex: highlightedIndex,
                source: source,
            )
        }
    }

    func rowView(index: Int) -> some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(
                    width: DesignSystem.Size.Icon.small,
                    height: DesignSystem.Size.Icon.small,
                )
            Text("Item \(index + 1)")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.primary)
            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.medium)
        .padding(.vertical, DesignSystem.Spacing.small)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
    }

    @ViewBuilder
    func highlightOverlay(
        anchors: [Int: Anchor<CGRect>],
        highlightedIndex: Int,
        source: AnchorSourceOption
    ) -> some View {
        if let anchor = anchors[highlightedIndex] {
            GeometryReader { proxy in
                let rect = resolvedRect(proxy: proxy, anchor: anchor, source: source)
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .stroke(DesignSystem.Color.accent, lineWidth: 2)
                    .frame(width: rect.width, height: rect.height)
                    .offset(x: rect.minX, y: rect.minY)
                    .animation(.spring, value: highlightedIndex)
            }
        }
    }

    func resolvedRect(
        proxy: GeometryProxy,
        anchor: Anchor<CGRect>,
        source: AnchorSourceOption
    ) -> CGRect {
        let fullRect = proxy[anchor]
        switch source {
        case .bounds:
            return fullRect
        case .center:
            let size = CGSize(width: 8, height: 8)
            return CGRect(
                x: fullRect.midX - 4,
                y: fullRect.midY - 4,
                width: size.width,
                height: size.height,
            )
        case .topLeading:
            return CGRect(
                x: fullRect.minX,
                y: fullRect.minY,
                width: 12,
                height: 12,
            )
        case .bottomTrailing:
            return CGRect(
                x: fullRect.maxX - 12,
                y: fullRect.maxY - 12,
                width: 12,
                height: 12,
            )
        }
    }
}

// MARK: - Code generation
private extension AnchorPreferenceShowcase {
    var generatedCode: String {
        let highlightedIndexLiteral = showHighlight ? "\(selectedIndex)" : "-1"
        let lines: [String] = [
            "struct BoundsAnchorKey: PreferenceKey {",
            "    static let defaultValue: [Int: Anchor<CGRect>] = [:]",
            "    static func reduce(",
            "        value: inout [Int: Anchor<CGRect>],",
            "        nextValue: () -> [Int: Anchor<CGRect>]",
            "    ) {",
            "        value.merge(nextValue()) { _, new in new }",
            "    }",
            "}",
            "",
            "VStack {",
            "    ForEach(items.indices, id: \\.self) { index in",
            "        rowView(index: index)",
            "            .anchorPreference(key: BoundsAnchorKey.self, value: .bounds) { anchor in",
            "                [index: anchor]",
            "            }",
            "    }",
            "}",
            ".overlayPreferenceValue(BoundsAnchorKey.self) { anchors in",
            "    GeometryReader { proxy in",
            "        if let anchor = anchors[\(highlightedIndexLiteral)] {",
            "            let rect = proxy[anchor]",
            "            RoundedRectangle(cornerRadius: 8)",
            "                .stroke(Color.accentColor, lineWidth: 2)",
            "                .frame(width: rect.width, height: rect.height)",
            "                .offset(x: rect.minX, y: rect.minY)",
            "        }",
            "    }",
            "}",
        ]
        return lines.joined(separator: "\n")
    }
}
