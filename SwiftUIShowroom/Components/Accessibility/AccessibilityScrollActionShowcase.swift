import SwiftUI

struct AccessibilityScrollActionShowcase: View {
    enum ScrollActionState: ShowcaseState {
        case firstPage
        case midPage
        case lastPage

        var caption: String {
            switch self {
            case .firstPage: return "First page"
            case .midPage: return "Middle page"
            case .lastPage: return "Last page"
            }
        }
    }

    @State private var currentIndex = 0

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Scroll Action",
            summary: "Responds to VoiceOver's three-finger scroll on custom paginated content.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityScrollActionShowcase {
    var preview: some View {
        carouselCard(index: currentIndex, onScroll: handleScroll)
    }

    @ViewBuilder var controls: some View {
        ShowcaseStepper(
            "Current page",
            value: $currentIndex,
            in: 0...pageLabels.count - 1,
        )
    }

    @ViewBuilder func stateView(_ state: ScrollActionState) -> some View {
        switch state {
        case .firstPage:
            carouselCard(index: 0, onScroll: { _ in })
        case .midPage:
            carouselCard(index: 1, onScroll: { _ in })
        case .lastPage:
            carouselCard(index: pageLabels.count - 1, onScroll: { _ in })
        }
    }
}

// MARK: - Helpers
private extension AccessibilityScrollActionShowcase {
    static let dotSize: CGFloat = 8

    var pageLabels: [String] {
        ["Mountains", "Ocean", "Desert", "Forest"]
    }

    var pageIcons: [String] {
        ["mountain.2", "water.waves", "sun.dust", "tree"]
    }

    func handleScroll(edge: Edge) {
        switch edge {
        case .trailing:
            currentIndex = min(currentIndex + 1, pageLabels.count - 1)
        case .leading:
            currentIndex = max(currentIndex - 1, 0)
        case .bottom:
            currentIndex = min(currentIndex + 1, pageLabels.count - 1)
        case .top:
            currentIndex = max(currentIndex - 1, 0)
        }
    }

    func carouselCard(index: Int, onScroll: @escaping (Edge) -> Void) -> some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            pageIndicatorRow(current: index, total: pageLabels.count)
            pageContent(index: index)
        }
        .padding(DesignSystem.Spacing.large)
        .frame(maxWidth: .infinity)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(pageLabels[safe: index] ?? "")
        .accessibilityValue("Page \(index + 1) of \(pageLabels.count)")
        .accessibilityScrollAction { edge in
            onScroll(edge)
        }
    }

    func pageContent(index: Int) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: pageIcons[safe: index] ?? "photo")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(
                    width: DesignSystem.Size.Icon.xLarge,
                    height: DesignSystem.Size.Icon.xLarge,
                )
            Text(pageLabels[safe: index] ?? "")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.primary)
            Text("Swipe three fingers to scroll in VoiceOver")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
        }
    }

    func pageIndicatorRow(current: Int, total: Int) -> some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            ForEach(0..<total, id: \.self) { idx in
                Circle()
                    .fill(idx == current ? DesignSystem.Color.accent : DesignSystem.Color.separator)
                    .frame(width: Self.dotSize, height: Self.dotSize)
            }
        }
    }
}

// MARK: - Code generation
private extension AccessibilityScrollActionShowcase {
    var generatedCode: String {
        """
        CarouselView(index: $index)
            .accessibilityScrollAction { edge in
                if edge == .trailing { index += 1 }
                else if edge == .leading { index -= 1 }
            }
        """
    }
}

// MARK: - Array safe subscript
private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
