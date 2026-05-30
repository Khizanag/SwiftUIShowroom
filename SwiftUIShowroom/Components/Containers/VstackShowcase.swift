import SwiftUI

struct VstackShowcase: View {
    private enum AlignmentOption: ShowcasePickable {
        case leading, center, trailing

        var label: String {
            switch self {
            case .leading: "leading"
            case .center: "center"
            case .trailing: "trailing"
            }
        }

        var value: HorizontalAlignment {
            switch self {
            case .leading: .leading
            case .center: .center
            case .trailing: .trailing
            }
        }
    }

    enum VstackState: ShowcaseState {
        case defaultState, leading, trailing, tightSpacing, wideSpacing

        var caption: String {
            switch self {
            case .defaultState: "Default"
            case .leading: "Leading"
            case .trailing: "Trailing"
            case .tightSpacing: "Tight spacing"
            case .wideSpacing: "Wide spacing"
            }
        }
    }

    @State private var alignment: AlignmentOption = .center
    @State private var spacingEnabled = false
    @State private var spacing: Double = 8

    var body: some View {
        ShowcaseScreen(
            title: "VStack",
            summary: "A view that arranges its subviews in a vertical line.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension VstackShowcase {
    var preview: some View {
        stackView(alignment: alignment.value, spacing: resolvedSpacing)
    }

    func stackView(alignment: HorizontalAlignment, spacing: CGFloat?) -> some View {
        VStack(alignment: alignment, spacing: spacing) {
            sampleCard(label: "Top", systemImage: "star.fill")
            sampleCard(label: "Middle", systemImage: "heart.fill")
            sampleCard(label: "Bottom", systemImage: "bolt.fill")
        }
    }

    func sampleCard(label: String, systemImage: String) -> some View {
        Label(label, systemImage: systemImage)
            .font(DesignSystem.Font.body)
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .padding(.vertical, DesignSystem.Spacing.small)
            .background(
                DesignSystem.Color.cardBackground,
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium),
            )
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Alignment", selection: $alignment)
        ShowcaseToggle("Custom spacing", isOn: $spacingEnabled)
        if spacingEnabled {
            ShowcaseSlider("Spacing", value: $spacing, in: 0...64, step: 1)
        }
    }

    @ViewBuilder
    func stateView(_ state: VstackState) -> some View {
        switch state {
        case .defaultState:
            stackView(alignment: .center, spacing: nil)
        case .leading:
            stackView(alignment: .leading, spacing: nil)
        case .trailing:
            stackView(alignment: .trailing, spacing: nil)
        case .tightSpacing:
            stackView(alignment: .center, spacing: 2)
        case .wideSpacing:
            stackView(alignment: .center, spacing: 32)
        }
    }
}

// MARK: - Code generation
private extension VstackShowcase {
    var resolvedSpacing: CGFloat? {
        spacingEnabled ? CGFloat(spacing) : nil
    }

    var generatedCode: String {
        let alignArg = "alignment: .\(alignment.label)"
        let spacingArg = spacingEnabled ? ", spacing: \(Int(spacing))" : ", spacing: nil"
        return """
        VStack(\(alignArg)\(spacingArg)) {
            Text("Top")
            Text("Middle")
            Text("Bottom")
        }
        """
    }
}
