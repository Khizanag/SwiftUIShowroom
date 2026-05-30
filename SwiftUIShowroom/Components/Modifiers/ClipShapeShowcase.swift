import SwiftUI

struct ClipShapeShowcase: View {
    @State private var shape: ShapeOption = .roundedRectangle
    @State private var useEvenOdd = false

    var body: some View {
        ShowcaseScreen(
            title: "Clip Shape",
            summary: "Clips a view to any Shape's outline, hiding content outside the shape's path.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ClipShapeShowcase {
    var preview: some View {
        clippedSwatch(shape: shape, useEvenOdd: useEvenOdd)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Shape", selection: $shape)
        ShowcaseToggle("Even-odd fill rule", isOn: $useEvenOdd)
    }

    @ViewBuilder func stateView(_ state: ClipShapeState) -> some View {
        clippedSwatch(shape: state.shape, useEvenOdd: false)
    }

    func clippedSwatch(shape: ShapeOption, useEvenOdd: Bool) -> some View {
        let fillStyle = FillStyle(eoFill: useEvenOdd, antialiased: true)
        return ZStack {
            LinearGradient(
                colors: [DesignSystem.Color.accent, DesignSystem.Color.accent.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing,
            )
            Image(systemName: "photo.fill")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(width: 120, height: 120)
        .modifier(ClipShapeModifier(option: shape, fillStyle: fillStyle))
    }
}

// MARK: - Code generation
private extension ClipShapeShowcase {
    var generatedCode: String {
        let fillArg = useEvenOdd ? ", style: FillStyle(eoFill: true)" : ""
        return """
        Image("photo")
            .resizable()
            .scaledToFill()
            .frame(width: 120, height: 120)
            .clipShape(\(shape.codeLabel)\(fillArg))
        """
    }
}

// MARK: - Clip shape modifier (cross-platform shape dispatch)
private struct ClipShapeModifier: ViewModifier {
    let option: ClipShapeShowcase.ShapeOption
    let fillStyle: FillStyle

    func body(content: Content) -> some View {
        switch option {
        case .circle:
            content.clipShape(Circle(), style: fillStyle)
        case .capsule:
            content.clipShape(Capsule(), style: fillStyle)
        case .roundedRectangle:
            content.clipShape(RoundedRectangle(cornerRadius: 16), style: fillStyle)
        case .rect:
            content.clipShape(.rect(cornerRadius: 16), style: fillStyle)
        case .ellipse:
            content.clipShape(Ellipse(), style: fillStyle)
        case .asymmetric:
            content.clipShape(
                .rect(topLeadingRadius: 16, bottomTrailingRadius: 16),
                style: fillStyle,
            )
        }
    }
}

// MARK: - Nested types
extension ClipShapeShowcase {
    enum ShapeOption: ShowcasePickable {
        case circle
        case capsule
        case roundedRectangle
        case rect
        case ellipse
        case asymmetric

        var label: String {
            switch self {
            case .circle: "Circle"
            case .capsule: "Capsule"
            case .roundedRectangle: "RoundedRectangle(r: 16)"
            case .rect: ".rect(r: 16)"
            case .ellipse: "Ellipse"
            case .asymmetric: "Asymmetric corners"
            }
        }

        var codeLabel: String {
            switch self {
            case .circle: "Circle()"
            case .capsule: "Capsule()"
            case .roundedRectangle: "RoundedRectangle(cornerRadius: 16)"
            case .rect: ".rect(cornerRadius: 16)"
            case .ellipse: "Ellipse()"
            case .asymmetric: ".rect(topLeadingRadius: 16, bottomTrailingRadius: 16)"
            }
        }
    }

    enum ClipShapeState: ShowcaseState {
        case circle
        case capsule
        case roundedRectangle
        case ellipse
        case asymmetric

        var caption: String {
            switch self {
            case .circle: "Circle"
            case .capsule: "Capsule"
            case .roundedRectangle: "RoundedRect r:16"
            case .ellipse: "Ellipse"
            case .asymmetric: "Asymmetric"
            }
        }

        var shape: ShapeOption {
            switch self {
            case .circle: .circle
            case .capsule: .capsule
            case .roundedRectangle: .roundedRectangle
            case .ellipse: .ellipse
            case .asymmetric: .asymmetric
            }
        }
    }
}
