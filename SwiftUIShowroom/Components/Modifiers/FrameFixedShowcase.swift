import SwiftUI

struct FrameFixedShowcase: View {
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

    enum FrameContentState: ShowcaseState {
        case `default`
        case longContent

        var caption: String {
            switch self {
            case .default: "Default"
            case .longContent: "Long content"
            }
        }
    }

    @State private var widthValue: Double = 200
    @State private var heightValue: Double = 120
    @State private var setWidth = true
    @State private var setHeight = true
    @State private var alignment: AlignmentOption = .center

    var body: some View {
        ShowcaseScreen(
            title: "Frame (Fixed Size)",
            summary: "Proposes a fixed width and/or height to a view, positioning content via an alignment.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension FrameFixedShowcase {
    var preview: some View {
        framedContent(text: "Framed", useWidth: setWidth, useHeight: setHeight)
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseToggle("Set width", isOn: $setWidth)
        ShowcaseSlider("Width", value: $widthValue, in: 0...500, step: 1)
        ShowcaseToggle("Set height", isOn: $setHeight)
        ShowcaseSlider("Height", value: $heightValue, in: 0...500, step: 1)
        ShowcasePicker("Alignment", selection: $alignment)
    }

    @ViewBuilder
    func stateView(_ state: FrameContentState) -> some View {
        switch state {
        case .default:
            framedContent(text: "Framed", useWidth: true, useHeight: true)
        case .longContent:
            framedContent(text: "This is a long label that may overflow", useWidth: true, useHeight: true)
        }
    }

    func framedContent(text: String, useWidth: Bool, useHeight: Bool) -> some View {
        Text(text)
            .font(DesignSystem.Font.body)
            .foregroundStyle(DesignSystem.Color.primary)
            .padding(DesignSystem.Spacing.small)
            .frame(
                width: useWidth ? widthValue : nil,
                height: useHeight ? heightValue : nil,
                alignment: alignment.value,
            )
            .background(
                DesignSystem.Color.cardBackground,
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium),
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .strokeBorder(DesignSystem.Color.separator, lineWidth: 1),
            )
    }
}

// MARK: - Code generation
private extension FrameFixedShowcase {
    var generatedCode: String {
        let widthArg = setWidth ? "\(Int(widthValue))" : "nil"
        let heightArg = setHeight ? "\(Int(heightValue))" : "nil"
        return """
        Text("Framed")
            .frame(width: \(widthArg), height: \(heightArg), alignment: .\(alignment.label))
        """
    }
}
