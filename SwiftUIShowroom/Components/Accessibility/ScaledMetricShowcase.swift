import SwiftUI

struct ScaledMetricShowcase: View {
    @State private var baseSize: Double = 44
    @State private var relativeTo: TextStyleOption = .body

    var body: some View {
        ShowcaseScreen(
            title: "ScaledMetric",
            summary: "Scales a numeric value (padding, icon size) in step with the user's Dynamic Type size.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ScaledMetricShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            scaleComparisonRow(baseSize: baseSize, textStyle: relativeTo.textStyle)
            Text("Base size: \(Int(baseSize)) pt — scales with \(relativeTo.label)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(DesignSystem.Spacing.medium)
    }

    @ViewBuilder var controls: some View {
        ShowcaseSlider("Base size", value: $baseSize, in: 8...120, step: 1)
        ShowcasePicker("Relative to", selection: $relativeTo)
    }

    @ViewBuilder func stateView(_ state: ScaledMetricState) -> some View {
        stateRow(state: state, baseSize: baseSize, textStyle: relativeTo.textStyle)
    }

    func scaleComparisonRow(baseSize: Double, textStyle: Font.TextStyle) -> some View {
        HStack(alignment: .bottom, spacing: DesignSystem.Spacing.medium) {
            ForEach(ScaledMetricState.allCases) { state in
                VStack(spacing: DesignSystem.Spacing.xSmall) {
                    ScaledIconView(baseSize: baseSize, textStyle: textStyle)
                        .environment(\.dynamicTypeSize, state.dynamicTypeSize)
                    Text(state.shortLabel)
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.secondary)
                }
            }
        }
    }

    func stateRow(
        state: ScaledMetricState,
        baseSize: Double,
        textStyle: Font.TextStyle
    ) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            ScaledIconView(baseSize: baseSize, textStyle: textStyle)
                .environment(\.dynamicTypeSize, state.dynamicTypeSize)
            Text("Base: \(Int(baseSize)) pt")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Code generation
private extension ScaledMetricShowcase {
    var generatedCode: String {
        """
        @ScaledMetric(relativeTo: .\(relativeTo.rawValue)) private var iconSize: CGFloat = \(Int(baseSize))

        var body: some View {
            Image(systemName: "bell")
                .frame(width: iconSize, height: iconSize)
        }
        """
    }
}

// MARK: - ScaledIconView
private struct ScaledIconView: View {
    let baseSize: Double
    let textStyle: Font.TextStyle

    @ScaledMetric(relativeTo: .body) private var scaledSizeBody: CGFloat = 44
    @ScaledMetric(relativeTo: .title) private var scaledSizeTitle: CGFloat = 44
    @ScaledMetric(relativeTo: .title2) private var scaledSizeTitle2: CGFloat = 44
    @ScaledMetric(relativeTo: .title3) private var scaledSizeTitle3: CGFloat = 44
    @ScaledMetric(relativeTo: .headline) private var scaledSizeHeadline: CGFloat = 44
    @ScaledMetric(relativeTo: .subheadline) private var scaledSizeSubheadline: CGFloat = 44
    @ScaledMetric(relativeTo: .callout) private var scaledSizeCallout: CGFloat = 44
    @ScaledMetric(relativeTo: .footnote) private var scaledSizeFootnote: CGFloat = 44
    @ScaledMetric(relativeTo: .caption) private var scaledSizeCaption: CGFloat = 44
    @ScaledMetric(relativeTo: .caption2) private var scaledSizeCaption2: CGFloat = 44
    @ScaledMetric(relativeTo: .largeTitle) private var scaledSizeLargeTitle: CGFloat = 44

    var body: some View {
        let scaled = scaledValue * (baseSize / 44)
        Image(systemName: "bell")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: max(scaled, 8), height: max(scaled, 8))
            .foregroundStyle(DesignSystem.Color.accent)
    }

    private var scaledValue: CGFloat {
        switch textStyle {
        case .largeTitle: scaledSizeLargeTitle
        case .title: scaledSizeTitle
        case .title2: scaledSizeTitle2
        case .title3: scaledSizeTitle3
        case .headline: scaledSizeHeadline
        case .subheadline: scaledSizeSubheadline
        case .body: scaledSizeBody
        case .callout: scaledSizeCallout
        case .footnote: scaledSizeFootnote
        case .caption: scaledSizeCaption
        case .caption2: scaledSizeCaption2
        @unknown default: scaledSizeBody
        }
    }
}

// MARK: - Nested types
extension ScaledMetricShowcase {
    fileprivate enum TextStyleOption: String, ShowcasePickable {
        case largeTitle
        case title
        case title2
        case title3
        case headline
        case subheadline
        case body
        case callout
        case footnote
        case caption
        case caption2

        var label: String {
            switch self {
            case .largeTitle: "largeTitle"
            case .title: "title"
            case .title2: "title2"
            case .title3: "title3"
            case .headline: "headline"
            case .subheadline: "subheadline"
            case .body: "body"
            case .callout: "callout"
            case .footnote: "footnote"
            case .caption: "caption"
            case .caption2: "caption2"
            }
        }

        var textStyle: Font.TextStyle {
            switch self {
            case .largeTitle: .largeTitle
            case .title: .title
            case .title2: .title2
            case .title3: .title3
            case .headline: .headline
            case .subheadline: .subheadline
            case .body: .body
            case .callout: .callout
            case .footnote: .footnote
            case .caption: .caption
            case .caption2: .caption2
            }
        }
    }

    fileprivate enum ScaledMetricState: ShowcaseState {
        case small
        case `default`
        case large
        case accessibility

        var caption: String {
            switch self {
            case .small: "xSmall"
            case .default: "Large (default)"
            case .large: "xxxLarge"
            case .accessibility: "AX5 (max)"
            }
        }

        var shortLabel: String {
            switch self {
            case .small: "xSmall"
            case .default: "Default"
            case .large: "xxxLarge"
            case .accessibility: "AX5"
            }
        }

        var dynamicTypeSize: DynamicTypeSize {
            switch self {
            case .small: .xSmall
            case .default: .large
            case .large: .xxxLarge
            case .accessibility: .accessibility5
            }
        }
    }
}
