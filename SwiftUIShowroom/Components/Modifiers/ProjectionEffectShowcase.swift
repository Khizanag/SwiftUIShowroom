import SwiftUI

struct ProjectionEffectShowcase: View {
    enum TransformPreset: ShowcasePickable {
        case identity
        case scaleX
        case rotate
        case skewHorizontal
        case skewVertical

        var label: String {
            switch self {
            case .identity: "Identity"
            case .scaleX: "Scale X 1.3"
            case .rotate: "Rotate 30°"
            case .skewHorizontal: "Skew Horizontal"
            case .skewVertical: "Skew Vertical"
            }
        }

        var transform: ProjectionTransform {
            switch self {
            case .identity:
                return ProjectionTransform()
            case .scaleX:
                return ProjectionTransform(CGAffineTransform(scaleX: 1.3, y: 1.0))
            case .rotate:
                return ProjectionTransform(CGAffineTransform(rotationAngle: .pi / 6))
            case .skewHorizontal:
                return ProjectionTransform(CGAffineTransform(a: 1, b: 0, c: 0.4, d: 1, tx: 0, ty: 0))
            case .skewVertical:
                return ProjectionTransform(CGAffineTransform(a: 1, b: 0.4, c: 0, d: 1, tx: 0, ty: 0))
            }
        }

        var codeString: String {
            switch self {
            case .identity:
                return "ProjectionTransform()"
            case .scaleX:
                return "ProjectionTransform(CGAffineTransform(scaleX: 1.3, y: 1.0))"
            case .rotate:
                return "ProjectionTransform(CGAffineTransform(rotationAngle: .pi / 6))"
            case .skewHorizontal:
                return "ProjectionTransform(CGAffineTransform(a: 1, b: 0, c: 0.4, d: 1, tx: 0, ty: 0))"
            case .skewVertical:
                return "ProjectionTransform(CGAffineTransform(a: 1, b: 0.4, c: 0, d: 1, tx: 0, ty: 0))"
            }
        }
    }

    enum ProjectionState: ShowcaseState {
        case identity
        case scaleX
        case rotated
        case skewed

        var caption: String {
            switch self {
            case .identity: "Identity"
            case .scaleX: "Scale X"
            case .rotated: "Rotated 30°"
            case .skewed: "Skewed"
            }
        }

        var transform: ProjectionTransform {
            switch self {
            case .identity:
                return ProjectionTransform()
            case .scaleX:
                return ProjectionTransform(CGAffineTransform(scaleX: 1.3, y: 1.0))
            case .rotated:
                return ProjectionTransform(CGAffineTransform(rotationAngle: .pi / 6))
            case .skewed:
                return ProjectionTransform(CGAffineTransform(a: 1, b: 0, c: 0.4, d: 1, tx: 0, ty: 0))
            }
        }
    }

    @State private var selectedTransform: TransformPreset = .identity

    var body: some View {
        ShowcaseScreen(
            title: "Projection Effect",
            summary: "Applies an arbitrary 3D ProjectionTransform (CATransform3D-style matrix) to the view.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}
// MARK: - Sub-views
private extension ProjectionEffectShowcase {
    var preview: some View {
        projectedLabel(transform: selectedTransform.transform)
            .animation(.easeInOut(duration: 0.3), value: selectedTransform)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Transform", selection: $selectedTransform)
    }

    @ViewBuilder func stateView(_ state: ProjectionState) -> some View {
        projectedLabel(transform: state.transform)
    }

    func projectedLabel(transform: ProjectionTransform) -> some View {
        Text("Projected")
            .font(DesignSystem.Font.headline)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .padding(.vertical, DesignSystem.Spacing.small)
            .background(
                DesignSystem.Color.accent,
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium),
            )
            .projectionEffect(transform)
    }
}
// MARK: - Code generation
private extension ProjectionEffectShowcase {
    var generatedCode: String {
        """
        Text("Projected")
            .projectionEffect(\(selectedTransform.codeString))
        """
    }
}
