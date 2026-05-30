import SwiftUI

struct AccessibilityChildrenSyntheticShowcase: View {
    enum ChildrenKind: ShowcasePickable {
        case perBarChart
        case perSegment
        case canvasRegion

        var label: String {
            switch self {
            case .perBarChart: "Per-bar chart elements"
            case .perSegment: "Per-segment elements"
            case .canvasRegion: "Canvas region elements"
            }
        }

        var bars: [CGFloat] {
            switch self {
            case .perBarChart: [0.45, 0.70, 0.55, 0.85, 0.60]
            case .perSegment: [0.25, 0.35, 0.40]
            case .canvasRegion: [0.60, 0.80, 0.50, 0.70]
            }
        }

        var canvasLabel: String {
            switch self {
            case .perBarChart: "Weekly lines of code"
            case .perSegment: "Market share by segment"
            case .canvasRegion: "Sensor readings by region"
            }
        }

        var elementNoun: String {
            switch self {
            case .perBarChart: "bars"
            case .perSegment: "segments"
            case .canvasRegion: "regions"
            }
        }

        func childLabel(index: Int) -> String {
            switch self {
            case .perBarChart:
                let days = ["Mon", "Tue", "Wed", "Thu", "Fri"]
                return index < days.count ? days[index] : "Day \(index + 1)"
            case .perSegment:
                let names = ["Alpha", "Beta", "Gamma"]
                return index < names.count ? names[index] : "Segment \(index + 1)"
            case .canvasRegion:
                let regions = ["North", "East", "South", "West"]
                return index < regions.count ? regions[index] : "Region \(index + 1)"
            }
        }

        var codeChildrenBody: String {
            switch self {
            case .perBarChart:
                return """
                    ForEach(days) { day in
                        Text(day.label)
                            .accessibilityValue("\\(day.value) lines")
                    }
                """
            case .perSegment:
                return """
                    ForEach(segments) { segment in
                        Text(segment.name)
                            .accessibilityValue("\\(segment.percent) percent")
                    }
                """
            case .canvasRegion:
                return """
                    ForEach(regions) { region in
                        Text(region.name)
                            .accessibilityValue(region.reading)
                    }
                """
            }
        }
    }

    enum ChildrenState: ShowcaseState {
        case perBarChart
        case perSegment
        case canvasRegion

        var caption: String {
            switch self {
            case .perBarChart: "Per-bar chart"
            case .perSegment: "Per-segment"
            case .canvasRegion: "Canvas regions"
            }
        }

        var kind: ChildrenKind {
            switch self {
            case .perBarChart: .perBarChart
            case .perSegment: .perSegment
            case .canvasRegion: .canvasRegion
            }
        }
    }

    @State private var childrenKind: ChildrenKind = .perBarChart

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Children Synthetic",
            summary: "Replaces an element's children with synthetic, non-visual accessibility elements.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityChildrenSyntheticShowcase {
    var preview: some View {
        canvasCard(kind: childrenKind)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Children kind", selection: $childrenKind)
    }

    @ViewBuilder func stateView(_ state: ChildrenState) -> some View {
        canvasCard(kind: state.kind)
    }

    @ViewBuilder func canvasCard(kind: ChildrenKind) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            barChartCanvas(kind: kind)
            syntheticNote(kind: kind)
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ViewBuilder func barChartCanvas(kind: ChildrenKind) -> some View {
        let bars = kind.bars
        Canvas { context, size in
            let barCount = bars.count
            guard barCount > 0 else { return }
            let spacing: CGFloat = 8
            let totalSpacing = spacing * CGFloat(barCount - 1)
            let barWidth = (size.width - totalSpacing) / CGFloat(barCount)
            for (idx, fraction) in bars.enumerated() {
                let barHeight = size.height * fraction
                let xPos = CGFloat(idx) * (barWidth + spacing)
                let rect = CGRect(
                    x: xPos,
                    y: size.height - barHeight,
                    width: barWidth,
                    height: barHeight,
                )
                let path = Path(roundedRect: rect, cornerRadius: 4)
                context.fill(path, with: .color(DesignSystem.Color.accent))
            }
        }
        .frame(height: 80)
        .accessibilityLabel(kind.canvasLabel)
        .accessibilityChildren {
            syntheticChildren(for: kind)
        }
    }

    @ViewBuilder func syntheticChildren(for kind: ChildrenKind) -> some View {
        ForEach(Array(kind.bars.enumerated()), id: \.offset) { idx, fraction in
            let percent = Int(fraction * 100)
            Text(kind.childLabel(index: idx))
                .accessibilityLabel(kind.childLabel(index: idx))
                .accessibilityValue("\(percent) percent")
        }
    }

    func syntheticNote(kind: ChildrenKind) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: "accessibility")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.accent)
            Text("\(kind.bars.count) synthetic \(kind.elementNoun) — VoiceOver navigates each independently.")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }
}

// MARK: - Code generation
private extension AccessibilityChildrenSyntheticShowcase {
    var generatedCode: String {
        let childrenBody = childrenKind.codeChildrenBody
        return """
        Canvas { context, size in
            // draw \(childrenKind.label.lowercased())
        }
        .accessibilityLabel("\(childrenKind.canvasLabel)")
        .accessibilityChildren {
        \(childrenBody)
        }
        """
    }
}
