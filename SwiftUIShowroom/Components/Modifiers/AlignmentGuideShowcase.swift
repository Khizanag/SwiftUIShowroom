import SwiftUI

struct AlignmentGuideShowcase: View {
    @State private var alignmentOption: AlignmentOption = .leading
    @State private var guideOffset: Double = 0

    var body: some View {
        ShowcaseScreen(
            title: "Alignment Guide",
            summary: "Overrides a view's named alignment guide to enable custom cross-stack alignment.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension AlignmentGuideShowcase {
    fileprivate enum AlignmentOption: ShowcasePickable {
        case leading, center, trailing, top, bottom, firstTextBaseline, lastTextBaseline

        var label: String {
            switch self {
            case .leading: "leading"
            case .center: "center"
            case .trailing: "trailing"
            case .top: "top"
            case .bottom: "bottom"
            case .firstTextBaseline: "firstTextBaseline"
            case .lastTextBaseline: "lastTextBaseline"
            }
        }

        var isHorizontal: Bool {
            switch self {
            case .leading, .center, .trailing: true
            case .top, .bottom, .firstTextBaseline, .lastTextBaseline: false
            }
        }

        var horizontalAlignment: HorizontalAlignment {
            switch self {
            case .leading: .leading
            case .center: .center
            case .trailing: .trailing
            case .top, .bottom, .firstTextBaseline, .lastTextBaseline: .center
            }
        }

        var verticalAlignment: VerticalAlignment {
            switch self {
            case .top: .top
            case .bottom: .bottom
            case .firstTextBaseline: .firstTextBaseline
            case .lastTextBaseline: .lastTextBaseline
            case .leading, .center, .trailing: .center
            }
        }
    }

    fileprivate enum DemoState: ShowcaseState {
        case noOffset, positiveOffset, negativeOffset

        var caption: String {
            switch self {
            case .noOffset: "No offset"
            case .positiveOffset: "+20 offset"
            case .negativeOffset: "-20 offset"
            }
        }
    }
}

// MARK: - Sub-views
private extension AlignmentGuideShowcase {
    var preview: some View {
        alignmentDemo(option: alignmentOption, offset: CGFloat(guideOffset))
    }

    @ViewBuilder
    func alignmentDemo(option: AlignmentOption, offset: CGFloat) -> some View {
        if option.isHorizontal {
            horizontalDemo(alignment: option.horizontalAlignment, offset: offset)
        } else {
            verticalDemo(alignment: option.verticalAlignment, offset: offset)
        }
    }

    func horizontalDemo(
        alignment: HorizontalAlignment,
        offset: CGFloat
    ) -> some View {
        VStack(alignment: alignment, spacing: DesignSystem.Spacing.small) {
            Text("Aligned")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.accent)
                .padding(.horizontal, DesignSystem.Spacing.medium)
                .padding(.vertical, DesignSystem.Spacing.xSmall)
                .background(DesignSystem.Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
                .alignmentGuide(alignment) { dim in dim[alignment] + offset }
            Text("Reference")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.primary)
                .padding(.horizontal, DesignSystem.Spacing.large)
                .padding(.vertical, DesignSystem.Spacing.xSmall)
                .background(DesignSystem.Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
            Text("Another reference")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
                .padding(.horizontal, DesignSystem.Spacing.small)
                .padding(.vertical, DesignSystem.Spacing.xSmall)
                .background(DesignSystem.Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        }
    }

    func verticalDemo(
        alignment: VerticalAlignment,
        offset: CGFloat
    ) -> some View {
        HStack(alignment: alignment, spacing: DesignSystem.Spacing.small) {
            Text("Aligned")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.accent)
                .padding(.horizontal, DesignSystem.Spacing.medium)
                .padding(.vertical, DesignSystem.Spacing.xSmall)
                .background(DesignSystem.Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
                .alignmentGuide(alignment) { dim in dim[alignment] + offset }
            VStack(spacing: DesignSystem.Spacing.xSmall) {
                Text("Reference")
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.primary)
                Text("tall")
                    .font(DesignSystem.Font.footnote)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
            .padding(DesignSystem.Spacing.small)
            .background(DesignSystem.Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Alignment", selection: $alignmentOption)
        ShowcaseSlider("Guide offset", value: $guideOffset, in: -50...50, step: 1)
    }

    @ViewBuilder
    func stateView(_ state: DemoState) -> some View {
        switch state {
        case .noOffset:
            horizontalDemo(alignment: .leading, offset: 0)
        case .positiveOffset:
            horizontalDemo(alignment: .leading, offset: 20)
        case .negativeOffset:
            horizontalDemo(alignment: .leading, offset: -20)
        }
    }
}

// MARK: - Code generation
private extension AlignmentGuideShowcase {
    var generatedCode: String {
        let offsetValue = guideOffset == guideOffset.rounded()
            ? String(Int(guideOffset))
            : String(format: "%.1f", guideOffset)
        let offsetSuffix = guideOffset == 0
            ? ""
            : " + \(offsetValue)"
        let guideLabel = alignmentOption.label
        let containerType = alignmentOption.isHorizontal ? "VStack" : "HStack"
        let lines = [
            "\(containerType)(alignment: .\(guideLabel)) {",
            "    Text(\"Aligned\")",
            "        .alignmentGuide(.\(guideLabel)) { d in d[.\(guideLabel)]\(offsetSuffix) }",
            "    Text(\"Reference\")",
            "}",
        ]
        return lines.joined(separator: "\n")
    }
}
