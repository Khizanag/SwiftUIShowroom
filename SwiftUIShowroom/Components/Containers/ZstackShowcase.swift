import SwiftUI

struct ZstackShowcase: View {
    @State private var alignment: AlignmentOption = .center

    var body: some View {
        ShowcaseScreen(
            title: "ZStack",
            summary: "A view that overlays its subviews, aligning them on both axes.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ZstackShowcase {
    var preview: some View {
        ZStack(alignment: alignment.value) {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .fill(Color.accentColor.opacity(0.25))
                .frame(width: 200, height: 200)
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(Color.accentColor.opacity(0.55))
                .frame(width: 120, height: 120)
            Text("On top")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(Color.accentColor)
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Alignment", selection: $alignment)
    }

    @ViewBuilder
    func stateView(_ state: LayeringState) -> some View {
        if state == .manyLayers {
            multiLayerExample
        } else {
            twoLayerExample(state: state)
        }
    }

    private var multiLayerExample: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(Color.accentColor.opacity(0.15))
                .frame(width: 110, height: 110)
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(Color.accentColor.opacity(0.30))
                .frame(width: 80, height: 80)
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .fill(Color.accentColor.opacity(0.55))
                .frame(width: 50, height: 50)
            Circle()
                .fill(Color.accentColor)
                .frame(width: 22, height: 22)
        }
        .frame(width: 110, height: 110)
    }

    private func twoLayerExample(state: LayeringState) -> some View {
        ZStack(alignment: state.alignment) {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(state.backdropColor)
                .frame(width: 110, height: 110)
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .fill(state.overlayColor)
                .frame(width: 60, height: 60)
        }
        .frame(width: 110, height: 110)
    }
}

// MARK: - Code generation
private extension ZstackShowcase {
    var generatedCode: String {
        """
        ZStack(alignment: .\(alignment.label)) {
            Color.accentColor
            Text("On top")
        }
        """
    }
}

// MARK: - Nested types
extension ZstackShowcase {
    enum AlignmentOption: ShowcasePickable {
        case topLeading
        case top
        case topTrailing
        case leading
        case center
        case trailing
        case bottomLeading
        case bottom
        case bottomTrailing

        var label: String {
            switch self {
            case .topLeading: "topLeading"
            case .top: "top"
            case .topTrailing: "topTrailing"
            case .leading: "leading"
            case .center: "center"
            case .trailing: "trailing"
            case .bottomLeading: "bottomLeading"
            case .bottom: "bottom"
            case .bottomTrailing: "bottomTrailing"
            }
        }

        var value: Alignment {
            switch self {
            case .topLeading: .topLeading
            case .top: .top
            case .topTrailing: .topTrailing
            case .leading: .leading
            case .center: .center
            case .trailing: .trailing
            case .bottomLeading: .bottomLeading
            case .bottom: .bottom
            case .bottomTrailing: .bottomTrailing
            }
        }
    }

    enum LayeringState: ShowcaseState {
        case centerAligned
        case topLeadingAligned
        case bottomTrailingAligned
        case manyLayers

        var caption: String {
            switch self {
            case .centerAligned: "center"
            case .topLeadingAligned: "topLeading"
            case .bottomTrailingAligned: "bottomTrailing"
            case .manyLayers: "Multi-layer"
            }
        }

        var alignment: Alignment {
            switch self {
            case .centerAligned: .center
            case .topLeadingAligned: .topLeading
            case .bottomTrailingAligned: .bottomTrailing
            case .manyLayers: .center
            }
        }

        var backdropColor: Color {
            switch self {
            case .centerAligned: Color.accentColor.opacity(0.2)
            case .topLeadingAligned: Color.accentColor.opacity(0.2)
            case .bottomTrailingAligned: Color.accentColor.opacity(0.2)
            case .manyLayers: Color.accentColor.opacity(0.15)
            }
        }

        var overlayColor: Color {
            switch self {
            case .centerAligned: Color.accentColor.opacity(0.6)
            case .topLeadingAligned: Color.accentColor.opacity(0.6)
            case .bottomTrailingAligned: Color.accentColor.opacity(0.6)
            case .manyLayers: Color.accentColor.opacity(0.5)
            }
        }
    }
}
