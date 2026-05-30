import SwiftUI

struct ContainerRelativeFrameShowcase: View {
    enum AxesOption: ShowcasePickable {
        case horizontal, vertical, both

        var label: String {
            switch self {
            case .horizontal: ".horizontal"
            case .vertical: ".vertical"
            case .both: "[.horizontal, .vertical]"
            }
        }

        var axes: Axis.Set {
            switch self {
            case .horizontal: .horizontal
            case .vertical: .vertical
            case .both: [.horizontal, .vertical]
            }
        }
    }

    enum AlignmentOption: ShowcasePickable {
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

        var alignment: Alignment {
            switch self {
            case .center: .center
            case .leading: .leading
            case .trailing: .trailing
            case .top: .top
            case .bottom: .bottom
            }
        }
    }

    enum CardState: ShowcaseState {
        case singleColumn, twoColumns, threeColumns

        var caption: String {
            switch self {
            case .singleColumn: "1 of 1"
            case .twoColumns: "1 of 2"
            case .threeColumns: "1 of 3"
            }
        }

        var count: Int {
            switch self {
            case .singleColumn: 1
            case .twoColumns: 2
            case .threeColumns: 3
            }
        }
    }

    @State private var axes: AxesOption = .horizontal
    @State private var count = 1
    @State private var span = 1
    @State private var spacing = 8.0
    @State private var alignment: AlignmentOption = .center

    var body: some View {
        ShowcaseScreen(
            title: "Container Relative Frame",
            summary: "Sizes a view relative to its nearest scroll container, optionally dividing into columns.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ContainerRelativeFrameShowcase {
    var preview: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: CGFloat(spacing)) {
                ForEach(0..<4, id: \.self) { index in
                    cardView(index: index, cardCount: count, cardSpan: span, cardSpacing: CGFloat(spacing))
                        .containerRelativeFrame(
                            axes.axes,
                            count: count,
                            span: span,
                            spacing: CGFloat(spacing),
                            alignment: alignment.alignment,
                        )
                }
            }
        }
        .frame(height: 140)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Axes", selection: $axes)
        ShowcaseStepper("Count", value: $count, in: 1...5)
        ShowcaseStepper("Span", value: $span, in: 1...5)
        ShowcaseSlider("Spacing", value: $spacing, in: 0...32, step: 1)
        ShowcasePicker("Alignment", selection: $alignment)
    }

    @ViewBuilder func stateView(_ state: CardState) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                ForEach(0..<state.count + 1, id: \.self) { index in
                    cardView(index: index, cardCount: state.count, cardSpan: 1, cardSpacing: 8)
                        .containerRelativeFrame(
                            .horizontal,
                            count: state.count,
                            span: 1,
                            spacing: 8,
                            alignment: .center,
                        )
                }
            }
        }
        .frame(height: 100)
    }

    func cardView(index: Int, cardCount: Int, cardSpan: Int, cardSpacing: CGFloat) -> some View {
        let palette: [Color] = [.blue, .purple, .orange, .teal, .pink]
        return ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(palette[index % palette.count].opacity(0.85))
            VStack(spacing: DesignSystem.Spacing.xSmall) {
                Text("Card \(index + 1)")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(.white)
                Text("\(cardSpan)/\(cardCount)")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }
}

// MARK: - Code generation
private extension ContainerRelativeFrameShowcase {
    var generatedCode: String {
        """
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(items) { item in
                    Card(item)
                        .containerRelativeFrame(
                            \(axes.label),
                            count: \(count),
                            span: \(span),
                            spacing: \(Int(spacing)),
                            alignment: .\(alignment.label)
                        )
                }
            }
        }
        """
    }
}
