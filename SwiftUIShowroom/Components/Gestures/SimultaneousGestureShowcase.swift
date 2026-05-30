import SwiftUI

struct SimultaneousGestureShowcase: View {
    @State private var isEnabled: Bool = true

    @State private var scale: CGFloat = 1.0
    @State private var angle: Angle = .zero

    #if !os(tvOS)
    @GestureState private var liveScale: CGFloat = 1.0
    @GestureState private var liveAngle: Angle = .zero
    #endif

    enum SimultaneousShowcaseState: ShowcaseState {
        case `default`, disabled, transformed

        var caption: String {
            switch self {
            case .default: "Default"
            case .disabled: "Disabled"
            case .transformed: "Transformed"
            }
        }
    }

    var body: some View {
        ShowcaseScreen(
            title: "Simultaneous Gesture",
            summary: "Combines two gestures so both can recognize and update at the same time.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension SimultaneousGestureShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            previewShape
            resetButton
        }
    }

    @ViewBuilder
    var previewShape: some View {
        #if os(tvOS)
        tvOSPreviewShape
        #else
        interactivePreviewShape
        #endif
    }

    #if os(tvOS)
    var tvOSPreviewShape: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
            .fill(
                LinearGradient(
                    colors: [DesignSystem.Color.accent, DesignSystem.Color.accent.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing,
                )
            )
            .frame(width: 160, height: 160)
            .overlay(
                Text("Pinch & rotate\nnot available on tvOS")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.onAccent)
                    .multilineTextAlignment(.center)
            )
            .accessibilityLabel("Simultaneous gesture not available on tvOS")
    }
    #else
    var interactivePreviewShape: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
            .fill(
                LinearGradient(
                    colors: [DesignSystem.Color.accent, DesignSystem.Color.accent.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing,
                )
            )
            .frame(width: 160, height: 160)
            .scaleEffect(scale * liveScale)
            .rotationEffect(angle + liveAngle)
            .overlay(previewLabel)
            .gesture(
                composedGesture,
                isEnabled: isEnabled,
            )
            .animation(.spring(response: 0.3), value: liveScale)
            .animation(.spring(response: 0.3), value: liveAngle)
            .accessibilityLabel(
                "Gesture target, scale \(String(format: "%.1f", scale)), rotation \(Int(angle.degrees)) degrees"
            )
    }

    var composedGesture: some Gesture {
        MagnifyGesture()
            .updating($liveScale) { value, state, _ in state = value.magnification }
            .onEnded { value in scale *= value.magnification }
            .simultaneously(
                with: RotateGesture()
                    .updating($liveAngle) { value, state, _ in state = value.rotation }
                    .onEnded { value in angle += value.rotation }
            )
    }
    #endif

    var previewLabel: some View {
        VStack(spacing: DesignSystem.Spacing.xSmall) {
            Text(String(format: "%.1f×", scale))
                .font(DesignSystem.Font.headline)
            Text("\(Int(angle.degrees))°")
                .font(DesignSystem.Font.caption)
        }
        .foregroundStyle(DesignSystem.Color.onAccent)
    }

    var resetButton: some View {
        Button("Reset") {
            withAnimation(.spring(response: 0.4)) {
                scale = 1.0
                angle = .zero
            }
        }
        .buttonStyle(.bordered)
        .font(DesignSystem.Font.callout)
        .disabled(scale == 1.0 && angle == .zero)
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("Enabled", isOn: $isEnabled)
    }

    @ViewBuilder
    func stateView(_ state: SimultaneousShowcaseState) -> some View {
        switch state {
        case .default:
            galleryShape(scale: 1.0, angle: .zero, isDisabled: false)
        case .disabled:
            galleryShape(scale: 1.0, angle: .zero, isDisabled: true)
        case .transformed:
            galleryShape(scale: 1.35, angle: .degrees(20), isDisabled: false)
        }
    }

    func galleryShape(scale: CGFloat, angle: Angle, isDisabled: Bool) -> some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(
                isDisabled
                    ? DesignSystem.Color.secondary.opacity(0.25)
                    : DesignSystem.Color.accent.opacity(0.8)
            )
            .frame(width: 80, height: 80)
            .scaleEffect(scale)
            .rotationEffect(angle)
            .overlay(
                VStack(spacing: DesignSystem.Spacing.xSmall) {
                    Text(String(format: "%.1f×", scale))
                        .font(DesignSystem.Font.caption2)
                    Text("\(Int(angle.degrees))°")
                        .font(DesignSystem.Font.caption2)
                }
                .foregroundStyle(
                    isDisabled ? DesignSystem.Color.secondary : DesignSystem.Color.onAccent
                )
            )
            .disabled(isDisabled)
    }
}

// MARK: - Code generation
private extension SimultaneousGestureShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("@State private var scale: CGFloat = 1")
        lines.append("@State private var angle: Angle = .zero")
        lines.append("@GestureState private var liveScale: CGFloat = 1.0")
        lines.append("@GestureState private var liveAngle: Angle = .zero")
        lines.append("")
        lines.append("RoundedRectangle(cornerRadius: 16)")
        lines.append("    .fill(.blue)")
        lines.append("    .frame(width: 160, height: 160)")
        lines.append("    .scaleEffect(scale * liveScale)")
        lines.append("    .rotationEffect(angle + liveAngle)")
        lines.append("    .gesture(")
        lines.append("        MagnifyGesture()")
        lines.append("            .updating($liveScale) { value, state, _ in")
        lines.append("                state = value.magnification")
        lines.append("            }")
        lines.append("            .onEnded { value in scale *= value.magnification }")
        lines.append("            .simultaneously(")
        lines.append("                with: RotateGesture()")
        lines.append("                    .updating($liveAngle) { value, state, _ in")
        lines.append("                        state = value.rotation")
        lines.append("                    }")
        lines.append("                    .onEnded { value in angle += value.rotation }")
        lines.append("            )")
        if !isEnabled {
            lines.append("        ,")
            lines.append("        isEnabled: false,")
        }
        lines.append("    )")
        return lines.joined(separator: "\n")
    }
}
