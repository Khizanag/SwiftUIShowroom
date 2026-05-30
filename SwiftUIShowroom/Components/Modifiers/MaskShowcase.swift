import SwiftUI

struct MaskShowcase: View {
    @State private var alignment: AlignmentOption = .center
    @State private var maskShape: MaskShapeOption = .linearGradient

    var body: some View {
        ShowcaseScreen(
            title: "Mask",
            summary: "Uses a mask view's alpha channel to control which parts of the modified view are visible.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension MaskShowcase {
    var preview: some View {
        maskedSwatch(alignment: alignment.value, shape: maskShape)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Alignment", selection: $alignment)
        ShowcasePicker("Mask shape", selection: $maskShape)
    }

    @ViewBuilder func stateView(_ state: MaskState) -> some View {
        maskedSwatch(alignment: .center, shape: state.shape)
    }

    func maskedSwatch(alignment: Alignment, shape: MaskShapeOption) -> some View {
        gradientRect
            .mask(alignment: alignment) {
                maskContent(shape)
            }
            .frame(width: 180, height: 100)
    }

    var gradientRect: some View {
        LinearGradient(
            colors: [DesignSystem.Color.accent, .purple, .pink],
            startPoint: .leading,
            endPoint: .trailing,
        )
        .frame(width: 180, height: 100)
    }

    @ViewBuilder func maskContent(_ shape: MaskShapeOption) -> some View {
        switch shape {
        case .linearGradient:
            LinearGradient(
                colors: [.black, .clear],
                startPoint: .leading,
                endPoint: .trailing,
            )
        case .circle:
            Circle()
        case .text:
            Text("MASK")
                .font(DesignSystem.Font.title)
                .bold()
        case .roundedRectangle:
            RoundedRectangle(cornerRadius: 16)
        }
    }
}

// MARK: - Code generation
private extension MaskShowcase {
    var generatedCode: String {
        let maskSnippet = maskShape.codeSnippet
        return """
        yourView
            .mask(alignment: .\(alignment.label)) {
                \(maskSnippet)
            }
        """
    }
}

// MARK: - Nested types
extension MaskShowcase {
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

        var value: Alignment {
            switch self {
            case .center: .center
            case .leading: .leading
            case .trailing: .trailing
            case .top: .top
            case .bottom: .bottom
            }
        }
    }

    enum MaskShapeOption: ShowcasePickable {
        case linearGradient
        case circle
        case text
        case roundedRectangle

        var label: String {
            switch self {
            case .linearGradient: "LinearGradient (fade)"
            case .circle: "Circle"
            case .text: "Text"
            case .roundedRectangle: "RoundedRectangle"
            }
        }

        var codeSnippet: String {
            switch self {
            case .linearGradient:
                "LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)"
            case .circle:
                "Circle()"
            case .text:
                "Text(\"MASK\").font(.title).bold()"
            case .roundedRectangle:
                "RoundedRectangle(cornerRadius: 16)"
            }
        }
    }

    enum MaskState: ShowcaseState {
        case gradientFade
        case circleReveal
        case textReveal
        case roundedReveal

        var caption: String {
            switch self {
            case .gradientFade: "Gradient fade"
            case .circleReveal: "Circle reveal"
            case .textReveal: "Text reveal"
            case .roundedReveal: "Rounded rect"
            }
        }

        var shape: MaskShapeOption {
            switch self {
            case .gradientFade: .linearGradient
            case .circleReveal: .circle
            case .textReveal: .text
            case .roundedReveal: .roundedRectangle
            }
        }
    }
}
