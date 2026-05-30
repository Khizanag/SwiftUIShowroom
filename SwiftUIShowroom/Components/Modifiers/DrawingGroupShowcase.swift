import SwiftUI

struct DrawingGroupShowcase: View {
    enum ColorModeOption: ShowcasePickable {
        case nonLinear, linear, extendedLinear

        var label: String {
            switch self {
            case .nonLinear: "nonLinear"
            case .linear: "linear"
            case .extendedLinear: "extendedLinear"
            }
        }

        var renderingMode: ColorRenderingMode {
            switch self {
            case .nonLinear: .nonLinear
            case .linear: .linear
            case .extendedLinear: .extendedLinear
            }
        }
    }

    enum DrawingGroupState: ShowcaseState {
        case withoutGroup, withGroup, withGroupOpaque

        var caption: String {
            switch self {
            case .withoutGroup: "No drawingGroup"
            case .withGroup: "drawingGroup(opaque: false)"
            case .withGroupOpaque: "drawingGroup(opaque: true)"
            }
        }
    }

    @State private var opaque: Bool = false
    @State private var colorMode: ColorModeOption = .nonLinear

    var body: some View {
        ShowcaseScreen(
            title: "Drawing Group (Metal)",
            summary: "Flattens a view into an offscreen Metal-rendered image for composited effects.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}
// MARK: - Sub-views
private extension DrawingGroupShowcase {
    var preview: some View {
        compositeArtwork()
            .drawingGroup(opaque: opaque, colorMode: colorMode.renderingMode)
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("Opaque", isOn: $opaque)
        ShowcasePicker("Color Mode", selection: $colorMode)
    }

    @ViewBuilder func stateView(_ state: DrawingGroupState) -> some View {
        switch state {
        case .withoutGroup:
            compositeArtwork()
        case .withGroup:
            compositeArtwork()
                .drawingGroup(opaque: false, colorMode: .nonLinear)
        case .withGroupOpaque:
            compositeArtwork()
                .drawingGroup(opaque: true, colorMode: .nonLinear)
        }
    }

    func compositeArtwork() -> some View {
        ZStack {
            LinearGradient(
                colors: [DesignSystem.Color.accent, .purple, .pink],
                startPoint: .topLeading,
                endPoint: .bottomTrailing,
            )
            Circle()
                .fill(.white.opacity(0.15))
                .frame(width: 80, height: 80)
                .blur(radius: 8)
                .offset(x: -24, y: -16)
            Circle()
                .fill(.yellow.opacity(0.25))
                .frame(width: 56, height: 56)
                .blur(radius: 6)
                .offset(x: 32, y: 20)
            Text("Metal")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
        }
        .frame(width: 220, height: 130)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
    }
}
// MARK: - Code generation
private extension DrawingGroupShowcase {
    var generatedCode: String {
        """
        ComplexGradientArt()
            .drawingGroup(opaque: \(opaque), colorMode: .\(colorMode.label))
        """
    }
}
