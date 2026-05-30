import SwiftUI

struct HstackShowcase: View {
    @State private var alignment: AlignmentOption = .center
    @State private var spacingValue: Double = 8
    @State private var useCustomSpacing = false

    var body: some View {
        ShowcaseScreen(
            title: "HStack",
            summary: "A view that arranges its subviews in a horizontal line.",
        ) {
            PreviewStage {
                preview
            }
            ShowcaseSection("Configuration") {
                controls
            }
            ShowcaseSection("States") {
                StateGallery(content: stateView)
            }
            ShowcaseSection("Generated code") {
                CodeBlock(code: generatedCode)
            }
        }
    }
}

// MARK: - Sub-views
private extension HstackShowcase {
    var preview: some View {
        HStack(
            alignment: alignment.verticalAlignment,
            spacing: useCustomSpacing ? spacingValue : nil,
        ) {
            sampleItems
        }
        .padding(DesignSystem.Spacing.medium)
    }

    @ViewBuilder
    var sampleItems: some View {
        sampleChip(label: "Leading", systemImage: "arrow.left")
        Spacer()
        sampleChip(label: "Center", systemImage: "dot.circle")
        Spacer()
        sampleChip(label: "Trailing", systemImage: "arrow.right")
    }

    func sampleChip(label: String, systemImage: String) -> some View {
        Label(label, systemImage: systemImage)
            .font(DesignSystem.Font.footnote)
            .padding(.horizontal, DesignSystem.Spacing.small)
            .padding(.vertical, DesignSystem.Spacing.xSmall)
            .background(DesignSystem.Color.cardBackground, in: .capsule)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Alignment", selection: $alignment)
        ShowcaseToggle("Custom spacing", isOn: $useCustomSpacing)
        if useCustomSpacing {
            ShowcaseSlider("Spacing", value: $spacingValue, in: 0...64, step: 1)
        }
    }

    @ViewBuilder
    func stateView(_ state: HstackState) -> some View {
        switch state {
        case .default:
            HStack(spacing: DesignSystem.Spacing.small) {
                Label("One", systemImage: "1.circle.fill")
                Label("Two", systemImage: "2.circle.fill")
            }
            .font(DesignSystem.Font.footnote)
        case .longContent:
            HStack(spacing: DesignSystem.Spacing.xSmall) {
                ForEach(["Mon", "Tue", "Wed", "Thu", "Fri"], id: \.self) { day in
                    Text(day)
                        .font(DesignSystem.Font.caption)
                        .padding(.horizontal, DesignSystem.Spacing.xSmall)
                        .padding(.vertical, DesignSystem.Spacing.hairline)
                        .background(DesignSystem.Color.accent.opacity(0.15), in: .capsule)
                }
            }
        }
    }
}

// MARK: - Code generation
private extension HstackShowcase {
    var generatedCode: String {
        let spacingArg = useCustomSpacing ? spacingValue.formatted(.number.precision(.fractionLength(0...1))) : "nil"
        return """
        HStack(alignment: .\(alignment.label), spacing: \(spacingArg)) {
            Text("Leading")
            Spacer()
            Text("Trailing")
        }
        """
    }
}

// MARK: - Supporting types
private extension HstackShowcase {
    fileprivate enum AlignmentOption: ShowcasePickable {
        case top
        case center
        case bottom
        case firstTextBaseline
        case lastTextBaseline

        var label: String {
            switch self {
            case .top: "top"
            case .center: "center"
            case .bottom: "bottom"
            case .firstTextBaseline: "firstTextBaseline"
            case .lastTextBaseline: "lastTextBaseline"
            }
        }

        var verticalAlignment: VerticalAlignment {
            switch self {
            case .top: .top
            case .center: .center
            case .bottom: .bottom
            case .firstTextBaseline: .firstTextBaseline
            case .lastTextBaseline: .lastTextBaseline
            }
        }
    }

    fileprivate enum HstackState: ShowcaseState {
        case `default`
        case longContent

        var caption: String {
            switch self {
            case .default: "Default"
            case .longContent: "Long content"
            }
        }
    }
}
