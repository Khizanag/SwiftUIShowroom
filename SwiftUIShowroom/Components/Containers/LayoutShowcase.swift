import SwiftUI

struct LayoutShowcase: View {
    @State private var exampleLayout: ExampleLayoutOption = .flow
    @State private var spacing: Double = 8
    @State private var animatesBetweenLayouts = false

    var body: some View {
        ShowcaseScreen(
            title: "Layout (custom layout)",
            summary: "Define custom containers via the Layout protocol: sizeThatFits + placeSubviews.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension LayoutShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            layoutLabel
            tagCloud(count: 8, useAnimation: animatesBetweenLayouts)
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var layoutLabel: some View {
        Text(exampleLayout.label)
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.secondary)
    }

    func tagCloud(count: Int, useAnimation: Bool) -> some View {
        let tags = sampleTags(count: count)
        let cgSpacing = CGFloat(spacing)
        if useAnimation {
            let layout = exampleLayout.makeAnyLayout(spacing: cgSpacing)
            return AnyView(
                layout {
                    ForEach(tags, id: \.self) { tag in
                        tagChip(tag)
                    }
                }
                .animation(.spring(duration: 0.4), value: exampleLayout.label)
            )
        } else {
            return AnyView(
                exampleLayout.makeAnyLayoutView(spacing: cgSpacing, tags: tags)
            )
        }
    }

    func tagChip(_ text: String) -> some View {
        Text(text)
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(.horizontal, DesignSystem.Spacing.small)
            .padding(.vertical, DesignSystem.Spacing.xSmall)
            .background(DesignSystem.Color.accent, in: Capsule())
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Layout", selection: $exampleLayout)
        ShowcaseSlider("Spacing", value: $spacing, in: 0...32, step: 1)
        ShowcaseToggle("Animate between layouts", isOn: $animatesBetweenLayouts)
    }

    @ViewBuilder
    func stateView(_ state: LayoutState) -> some View {
        switch state {
        case .default:
            stateTagCloud(count: 6, option: .flow)
        case .longContent:
            stateTagCloud(count: 16, option: .flow)
        }
    }

    func stateTagCloud(count: Int, option: ExampleLayoutOption) -> some View {
        let tags = sampleTags(count: count)
        return option.makeAnyLayoutView(spacing: 8, tags: tags)
            .padding(DesignSystem.Spacing.small)
    }

    func sampleTags(count: Int) -> [String] {
        let pool = [
            "SwiftUI", "Layout", "Flow", "Radial", "Custom",
            "Protocol", "HStack", "VStack", "Grid", "Subviews",
            "Proxy", "Anchor", "Place", "Size", "Proposal",
            "Cache", "iOS 16", "macOS 13", "tvOS 16",
        ]
        return Array(pool.prefix(count))
    }
}

// MARK: - Code generation
private extension LayoutShowcase {
    var generatedCode: String {
        let spacingValue = Int(spacing)
        switch exampleLayout {
        case .flow:
            return """
            struct FlowLayout: Layout {
                var spacing: CGFloat = \(spacingValue)

                func sizeThatFits(
                    proposal: ProposedViewSize,
                    subviews: Subviews,
                    cache: inout ()
                ) -> CGSize {
                    let maxWidth = proposal.width ?? .infinity
                    var currentX: CGFloat = 0
                    var currentY: CGFloat = 0
                    var rowHeight: CGFloat = 0
                    for subview in subviews {
                        let size = subview.sizeThatFits(.unspecified)
                        if currentX + size.width > maxWidth, currentX > 0 {
                            currentX = 0
                            currentY += rowHeight + spacing
                            rowHeight = 0
                        }
                        currentX += size.width + spacing
                        rowHeight = max(rowHeight, size.height)
                    }
                    return CGSize(width: maxWidth, height: currentY + rowHeight)
                }

                func placeSubviews(
                    in bounds: CGRect,
                    proposal: ProposedViewSize,
                    subviews: Subviews,
                    cache: inout ()
                ) {
                    var currentX = bounds.minX
                    var currentY = bounds.minY
                    var rowHeight: CGFloat = 0
                    for subview in subviews {
                        let size = subview.sizeThatFits(.unspecified)
                        if currentX + size.width > bounds.maxX, currentX > bounds.minX {
                            currentX = bounds.minX
                            currentY += rowHeight + spacing
                            rowHeight = 0
                        }
                        subview.place(
                            at: CGPoint(x: currentX, y: currentY),
                            anchor: .topLeading,
                            proposal: ProposedViewSize(size),
                        )
                        currentX += size.width + spacing
                        rowHeight = max(rowHeight, size.height)
                    }
                }
            }

            FlowLayout(spacing: \(spacingValue)) {
                ForEach(tags, id: \\.self) { Text($0) }
            }
            """
        case .radial:
            return """
            struct RadialLayout: Layout {
                var spacing: CGFloat = \(spacingValue)

                func sizeThatFits(
                    proposal: ProposedViewSize,
                    subviews: Subviews,
                    cache: inout ()
                ) -> CGSize {
                    let side = min(proposal.width ?? 200, proposal.height ?? 200)
                    return CGSize(width: side, height: side)
                }

                func placeSubviews(
                    in bounds: CGRect,
                    proposal: ProposedViewSize,
                    subviews: Subviews,
                    cache: inout ()
                ) {
                    let radius = min(bounds.width, bounds.height) / 2 - spacing
                    let center = CGPoint(x: bounds.midX, y: bounds.midY)
                    let angle = (2 * Double.pi) / Double(subviews.count)
                    for (index, subview) in subviews.enumerated() {
                        let theta = angle * Double(index) - Double.pi / 2
                        let point = CGPoint(
                            x: center.x + radius * cos(theta),
                            y: center.y + radius * sin(theta),
                        )
                        subview.place(
                            at: point,
                            anchor: .center,
                            proposal: .unspecified,
                        )
                    }
                }
            }

            RadialLayout(spacing: \(spacingValue)) {
                ForEach(tags, id: \\.self) { Text($0) }
            }
            """
        case .equalWidth:
            return """
            struct EqualWidthLayout: Layout {
                var spacing: CGFloat = \(spacingValue)

                func sizeThatFits(
                    proposal: ProposedViewSize,
                    subviews: Subviews,
                    cache: inout ()
                ) -> CGSize {
                    guard !subviews.isEmpty else { return .zero }
                    let maxWidth = proposal.width ?? 300
                    let itemWidth = (maxWidth - spacing * CGFloat(subviews.count - 1)) / CGFloat(subviews.count)
                    let maxHeight = subviews.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
                    return CGSize(width: maxWidth, height: maxHeight)
                }

                func placeSubviews(
                    in bounds: CGRect,
                    proposal: ProposedViewSize,
                    subviews: Subviews,
                    cache: inout ()
                ) {
                    guard !subviews.isEmpty else { return }
                    let itemWidth = (bounds.width - spacing * CGFloat(subviews.count - 1)) / CGFloat(subviews.count)
                    for (index, subview) in subviews.enumerated() {
                        let xOffset = (itemWidth + spacing) * CGFloat(index)
                        subview.place(
                            at: CGPoint(x: bounds.minX + xOffset, y: bounds.midY),
                            anchor: .leading,
                            proposal: ProposedViewSize(width: itemWidth, height: bounds.height),
                        )
                    }
                }
            }

            EqualWidthLayout(spacing: \(spacingValue)) {
                ForEach(tags, id: \\.self) { Text($0) }
            }
            """
        }
    }
}

// MARK: - Nested types
extension LayoutShowcase {
    enum ExampleLayoutOption: ShowcasePickable {
        case flow
        case radial
        case equalWidth

        var label: String {
            switch self {
            case .flow: "flow"
            case .radial: "radial"
            case .equalWidth: "equalWidth"
            }
        }

        func makeAnyLayout(spacing: CGFloat) -> AnyLayout {
            switch self {
            case .flow: AnyLayout(FlowLayout(spacing: spacing))
            case .radial: AnyLayout(RadialLayout(spacing: spacing))
            case .equalWidth: AnyLayout(EqualWidthLayout(spacing: spacing))
            }
        }

        @ViewBuilder
        func makeAnyLayoutView(spacing: CGFloat, tags: [String]) -> some View {
            switch self {
            case .flow:
                FlowLayout(spacing: spacing) {
                    ForEach(tags, id: \.self) { tag in
                        chipView(tag)
                    }
                }
            case .radial:
                RadialLayout(spacing: spacing) {
                    ForEach(tags, id: \.self) { tag in
                        chipView(tag)
                    }
                }
                .frame(width: 220, height: 220)
            case .equalWidth:
                EqualWidthLayout(spacing: spacing) {
                    ForEach(tags.prefix(4), id: \.self) { tag in
                        chipView(tag)
                    }
                }
            }
        }

        private func chipView(_ text: String) -> some View {
            Text(text)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .padding(.horizontal, DesignSystem.Spacing.small)
                .padding(.vertical, DesignSystem.Spacing.xSmall)
                .background(DesignSystem.Color.accent, in: Capsule())
        }
    }

    enum LayoutState: ShowcaseState {
        case `default`
        case longContent

        var caption: String {
            switch self {
            case .default: "Default (6 items)"
            case .longContent: "Long content (16 items)"
            }
        }
    }
}

// MARK: - FlowLayout
private struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let maxWidth = proposal.width ?? 300
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: currentY + rowHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX, currentX > bounds.minX {
                currentX = bounds.minX
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(
                at: CGPoint(x: currentX, y: currentY),
                anchor: .topLeading,
                proposal: ProposedViewSize(size),
            )
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - RadialLayout
private struct RadialLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let side = min(proposal.width ?? 200, proposal.height ?? 200)
        return CGSize(width: side, height: side)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        guard !subviews.isEmpty else { return }
        let radius = min(bounds.width, bounds.height) / 2 - spacing
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let angle = (2 * Double.pi) / Double(subviews.count)
        for (index, subview) in subviews.enumerated() {
            let theta = angle * Double(index) - Double.pi / 2
            let point = CGPoint(
                x: center.x + radius * cos(theta),
                y: center.y + radius * sin(theta),
            )
            subview.place(
                at: point,
                anchor: .center,
                proposal: .unspecified,
            )
        }
    }
}

// MARK: - EqualWidthLayout
private struct EqualWidthLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        guard !subviews.isEmpty else { return .zero }
        let maxWidth = proposal.width ?? 300
        let maxHeight = subviews.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
        return CGSize(width: maxWidth, height: maxHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        guard !subviews.isEmpty else { return }
        let count = CGFloat(subviews.count)
        let itemWidth = (bounds.width - spacing * (count - 1)) / count
        for (index, subview) in subviews.enumerated() {
            let xOffset = (itemWidth + spacing) * CGFloat(index)
            subview.place(
                at: CGPoint(x: bounds.minX + xOffset, y: bounds.midY),
                anchor: .leading,
                proposal: ProposedViewSize(width: itemWidth, height: bounds.height),
            )
        }
    }
}
