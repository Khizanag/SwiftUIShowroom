import SwiftUI

struct TransformEffectShowcase: View {
    enum TransformPreset: ShowcasePickable {
        case identity
        case rotate
        case scaleX
        case skew

        var label: String {
            switch self {
            case .identity: "Identity"
            case .rotate: "Rotate (π/8)"
            case .scaleX: "Scale X 1.5×"
            case .skew: "Horizontal Skew"
            }
        }

        var transform: CGAffineTransform {
            switch self {
            case .identity: .identity
            case .rotate: CGAffineTransform(rotationAngle: .pi / 8)
            case .scaleX: CGAffineTransform(scaleX: 1.5, y: 1)
            case .skew: CGAffineTransform(a: 1, b: 0, c: 0.3, d: 1, tx: 0, ty: 0)
            }
        }

        var codeString: String {
            switch self {
            case .identity: ".identity"
            case .rotate: "CGAffineTransform(rotationAngle: .pi / 8)"
            case .scaleX: "CGAffineTransform(scaleX: 1.5, y: 1)"
            case .skew: "CGAffineTransform(a: 1, b: 0, c: 0.3, d: 1, tx: 0, ty: 0)"
            }
        }
    }

    enum TransformState: ShowcaseState {
        case none
        case rotated
        case scaled
        case skewed

        var caption: String {
            switch self {
            case .none: "Identity"
            case .rotated: "Rotated"
            case .scaled: "Scaled"
            case .skewed: "Skewed"
            }
        }

        var transform: CGAffineTransform {
            switch self {
            case .none: .identity
            case .rotated: CGAffineTransform(rotationAngle: .pi / 8)
            case .scaled: CGAffineTransform(scaleX: 1.5, y: 1)
            case .skewed: CGAffineTransform(a: 1, b: 0, c: 0.3, d: 1, tx: 0, ty: 0)
            }
        }
    }

    @State private var selectedTransform: TransformPreset = .identity

    var body: some View {
        ShowcaseScreen(
            title: "Transform Effect",
            summary: "Applies a 2D affine transform (translate, scale, rotate, skew) to a view.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension TransformEffectShowcase {
    var preview: some View {
        Text(selectedTransform.label)
            .font(DesignSystem.Font.headline)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .padding(.vertical, DesignSystem.Spacing.small)
            .background(
                DesignSystem.Color.accent,
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium),
            )
            .transformEffect(selectedTransform.transform)
            .frame(height: 160)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Transform", selection: $selectedTransform)
    }

    @ViewBuilder func stateView(_ state: TransformState) -> some View {
        Text("View")
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(.horizontal, DesignSystem.Spacing.small)
            .padding(.vertical, DesignSystem.Spacing.xSmall)
            .background(
                DesignSystem.Color.accent,
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small),
            )
            .transformEffect(state.transform)
            .frame(width: 100, height: 60)
    }
}

// MARK: - Code generation
private extension TransformEffectShowcase {
    var generatedCode: String {
        """
        Text("Hello")
            .transformEffect(\(selectedTransform.codeString))
        """
    }
}
