import SwiftUI

struct RotateGesture3dShowcase: View {
    fileprivate enum AxisOption: ShowcasePickable {
        case free, xAxis, yAxis, zAxis

        var label: String {
            switch self {
            case .free: "nil (free)"
            case .xAxis: ".x"
            case .yAxis: ".y"
            case .zAxis: ".z"
            }
        }

        var codeValue: String {
            switch self {
            case .free: "nil"
            case .xAxis: ".x"
            case .yAxis: ".y"
            case .zAxis: ".z"
            }
        }
    }

    fileprivate enum GestureAvailabilityState: ShowcaseState {
        case visionOSOnly, disabled

        var caption: String {
            switch self {
            case .visionOSOnly: "visionOS only"
            case .disabled: "Disabled"
            }
        }
    }

    @State private var axisOption: AxisOption = .free
    @State private var minimumAngleDelta: Double = 1
    @State private var isAnimating = false

    var body: some View {
        ShowcaseScreen(
            title: "Rotate Gesture 3D",
            summary: "Recognizes 3D rotation, tracking angle and axis, optionally constrained to one axis.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension RotateGesture3dShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            simulatedCube
            unavailableBadge
        }
    }

    var simulatedCube: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(
                    LinearGradient(
                        colors: [.blue.opacity(0.8), .purple.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing,
                    )
                )
                .frame(width: 120, height: 120)
                .rotation3DEffect(
                    .degrees(isAnimating ? 360 : 0),
                    axis: rotationAxis,
                )
                .animation(
                    .linear(duration: 4).repeatForever(autoreverses: false),
                    value: isAnimating,
                )
            Image(systemName: "rotate.3d")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(.white)
        }
        .onAppear { isAnimating = true }
        .onDisappear { isAnimating = false }
    }

    var unavailableBadge: some View {
        Label("visionOS only — simulated preview", systemImage: "visionpro")
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.secondary)
            .padding(.horizontal, DesignSystem.Spacing.small)
            .padding(.vertical, DesignSystem.Spacing.xSmall)
            .background(DesignSystem.Color.cardBackground, in: Capsule())
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Constrained axis", selection: $axisOption)
        ShowcaseSlider(
            "Minimum angle delta (°)",
            value: $minimumAngleDelta,
            in: 0...30,
            step: 1,
        )
    }

    @ViewBuilder
    func stateView(_ state: GestureAvailabilityState) -> some View {
        switch state {
        case .visionOSOnly:
            visionOSOnlyCard
        case .disabled:
            disabledCard
        }
    }

    var visionOSOnlyCard: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "visionpro")
                .font(DesignSystem.Font.title)
                .foregroundStyle(DesignSystem.Color.accent)
            Text("RotateGesture3D is available on visionOS 1.0+")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.medium)
        .frame(maxWidth: .infinity)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium),
        )
    }

    var disabledCard: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "hand.raised.slash")
                .font(DesignSystem.Font.title)
                .foregroundStyle(DesignSystem.Color.secondary)
            Text("Gesture disabled — recognition paused")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.medium)
        .frame(maxWidth: .infinity)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium),
        )
    }

    var rotationAxis: (CGFloat, CGFloat, CGFloat) {
        switch axisOption {
        case .free: (1, 1, 0)
        case .xAxis: (1, 0, 0)
        case .yAxis: (0, 1, 0)
        case .zAxis: (0, 0, 1)
        }
    }
}

// MARK: - Code generation
private extension RotateGesture3dShowcase {
    var generatedCode: String {
        let angleLine = minimumAngleDelta == 1
            ? ".degrees(1)"
            : ".degrees(\(Int(minimumAngleDelta)))"
        let axisArg = axisOption == .free
            ? ""
            : "constrainedToAxis: \(axisOption.codeValue), "
        return """
        #if os(visionOS)
        struct Rotate3DDemo: View {
            @State private var rotation = Rotation3D.identity

            var body: some View {
                Model3D(named: "Object")
                    .gesture(
                        RotateGesture3D(\(axisArg)minimumAngleDelta: \(angleLine))
                            .onChanged { value in rotation = value.rotation }
                    )
            }
        }
        #endif
        """
    }
}
