import SwiftUI

struct FrameFlexibleShowcase: View {
    @State private var minWidth: Double = 0
    @State private var maxWidth: MaxDimension = .infinity
    @State private var minHeight: Double = 0
    @State private var maxHeight: MaxDimension = .none
    @State private var alignment: AlignmentOption = .center

    var body: some View {
        ShowcaseScreen(
            title: "Frame (Flexible)",
            summary: "Constrains a view between min and max bounds; .infinity expands to fill available space.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension FrameFlexibleShowcase {
    var preview: some View {
        framedView(text: "Flexible", alignment: alignment.value)
    }

    func framedView(text: String, alignment: Alignment) -> some View {
        Text(text)
            .font(DesignSystem.Font.body)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(DesignSystem.Spacing.small)
            .background(DesignSystem.Color.accent)
            .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.small))
            .frame(
                minWidth: minWidth > 0 ? minWidth : nil,
                maxWidth: maxWidth.cgFloat,
                minHeight: minHeight > 0 ? minHeight : nil,
                maxHeight: maxHeight.cgFloat,
                alignment: alignment,
            )
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .strokeBorder(DesignSystem.Color.separator, style: StrokeStyle(lineWidth: 1, dash: [4, 3])),
            )
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseSlider("Min width", value: $minWidth, in: 0...400, step: 4)
        ShowcasePicker("Max width", selection: $maxWidth)
        ShowcaseSlider("Min height", value: $minHeight, in: 0...400, step: 4)
        ShowcasePicker("Max height", selection: $maxHeight)
        ShowcasePicker("Alignment", selection: $alignment)
    }

    @ViewBuilder
    func stateView(_ state: FrameFlexibleState) -> some View {
        switch state {
        case .defaultState:
            framedView(text: "Flexible", alignment: .center)
                .frame(maxWidth: .infinity)
        case .longContent:
            framedView(
                text: "A much longer piece of text that exercises horizontal expansion",
                alignment: .leading,
            )
            .frame(maxWidth: .infinity)
        case .minConstrained:
            Text("Min")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .padding(DesignSystem.Spacing.small)
                .background(DesignSystem.Color.accent)
                .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.small))
                .frame(minWidth: 200, maxWidth: .infinity, minHeight: 80, alignment: .topLeading)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .strokeBorder(DesignSystem.Color.separator, style: StrokeStyle(lineWidth: 1, dash: [4, 3])),
                )
        case .capped:
            Text("Capped")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .padding(DesignSystem.Spacing.small)
                .background(DesignSystem.Color.accent)
                .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.small))
                .frame(maxWidth: 200, maxHeight: 60, alignment: .trailing)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .strokeBorder(DesignSystem.Color.separator, style: StrokeStyle(lineWidth: 1, dash: [4, 3])),
                )
        }
    }
}

// MARK: - Code generation
private extension FrameFlexibleShowcase {
    var generatedCode: String {
        var args: [String] = []
        if minWidth > 0 {
            args.append("minWidth: \(Int(minWidth))")
        }
        args.append("maxWidth: \(maxWidth.literal)")
        if minHeight > 0 {
            args.append("minHeight: \(Int(minHeight))")
        }
        if maxHeight != .none {
            args.append("maxHeight: \(maxHeight.literal)")
        }
        args.append("alignment: .\(alignment.label)")
        let argList = args.joined(separator: ", ")
        return "Text(\"Flexible\")\n    .frame(\(argList))"
    }
}

// MARK: - Nested enums
extension FrameFlexibleShowcase {
    enum MaxDimension: ShowcasePickable {
        case infinity
        case twoHundred
        case threeHundredTwenty
        case none

        var label: String {
            switch self {
            case .infinity: ".infinity"
            case .twoHundred: "200"
            case .threeHundredTwenty: "320"
            case .none: "nil"
            }
        }

        var literal: String { label }

        var cgFloat: CGFloat? {
            switch self {
            case .infinity: .infinity
            case .twoHundred: 200
            case .threeHundredTwenty: 320
            case .none: nil
            }
        }
    }

    enum AlignmentOption: ShowcasePickable {
        case center
        case leading
        case trailing
        case top
        case bottom
        case topLeading
        case topTrailing
        case bottomLeading
        case bottomTrailing

        var label: String {
            switch self {
            case .center: "center"
            case .leading: "leading"
            case .trailing: "trailing"
            case .top: "top"
            case .bottom: "bottom"
            case .topLeading: "topLeading"
            case .topTrailing: "topTrailing"
            case .bottomLeading: "bottomLeading"
            case .bottomTrailing: "bottomTrailing"
            }
        }

        var value: Alignment {
            switch self {
            case .center: .center
            case .leading: .leading
            case .trailing: .trailing
            case .top: .top
            case .bottom: .bottom
            case .topLeading: .topLeading
            case .topTrailing: .topTrailing
            case .bottomLeading: .bottomLeading
            case .bottomTrailing: .bottomTrailing
            }
        }
    }

    enum FrameFlexibleState: ShowcaseState {
        case defaultState
        case longContent
        case minConstrained
        case capped

        var caption: String {
            switch self {
            case .defaultState: "Default"
            case .longContent: "Long content"
            case .minConstrained: "Min constrained"
            case .capped: "Capped max"
            }
        }
    }
}
