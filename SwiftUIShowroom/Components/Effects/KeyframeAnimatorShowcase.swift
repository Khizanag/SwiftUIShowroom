import SwiftUI

struct KeyframeAnimatorShowcase: View {
    @State private var isRepeating: Bool = false
    @State private var keyframeType: KeyframeKind = .spring
    @State private var trigger: Int = 0
    @State private var duration: Double = 1.0

    var body: some View {
        ShowcaseScreen(
            title: "Keyframe Animator",
            summary: "Drives complex multi-track animations over time using independent keyframe tracks.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension KeyframeAnimatorShowcase {
    fileprivate struct AnimationValues {
        var scale: CGFloat = 1.0
        var rotation: Angle = .zero
        var offsetY: CGFloat = 0
    }

    fileprivate enum KeyframeKind: String, ShowcasePickable, CaseIterable {
        case linear = "LinearKeyframe"
        case cubic = "CubicKeyframe"
        case spring = "SpringKeyframe"
        case move = "MoveKeyframe"

        var label: String {
            switch self {
            case .linear: "LinearKeyframe"
            case .cubic: "CubicKeyframe"
            case .spring: "SpringKeyframe"
            case .move: "MoveKeyframe"
            }
        }
    }

    fileprivate enum AnimatorState: ShowcaseState {
        case triggered
        case repeating

        var caption: String {
            switch self {
            case .triggered: "Triggered"
            case .repeating: "Repeating"
            }
        }
    }
}

// MARK: - Sub-views
private extension KeyframeAnimatorShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.xLarge) {
            KeyframeStarView(
                repeating: isRepeating,
                keyframe: keyframeType,
                duration: duration,
                trigger: trigger,
            )
            Button("Trigger") { trigger += 1 }
                .buttonStyle(.borderedProminent)
                .disabled(isRepeating)
        }
        .padding(DesignSystem.Spacing.large)
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("Repeating", isOn: $isRepeating)
        ShowcasePicker("Keyframe type", selection: $keyframeType)
        ShowcaseSlider("Duration", value: $duration, in: 0.2...4.0, step: 0.1)
    }

    @ViewBuilder func stateView(_ state: AnimatorState) -> some View {
        switch state {
        case .triggered:
            KeyframeStarView(repeating: false, keyframe: .spring, duration: 0.8, trigger: 0)
        case .repeating:
            KeyframeStarView(repeating: true, keyframe: .cubic, duration: 1.0, trigger: 0)
        }
    }
}

// MARK: - KeyframeStarView
private struct KeyframeStarView: View {
    let repeating: Bool
    let keyframe: KeyframeAnimatorShowcase.KeyframeKind
    let duration: Double
    let trigger: Int

    var body: some View {
        switch keyframe {
        case .spring:
            springView
        case .cubic:
            cubicView
        case .linear:
            linearView
        case .move:
            moveView
        }
    }
}

// MARK: - KeyframeStarView spring
private extension KeyframeStarView {
    @ViewBuilder var springView: some View {
        let starImage = Image(systemName: "star.fill")
            .font(DesignSystem.Font.largeTitle)
            .foregroundStyle(DesignSystem.Color.accent)
        if repeating {
            starImage
                .keyframeAnimator(
                    initialValue: KeyframeAnimatorShowcase.AnimationValues(),
                    repeating: true,
                ) { content, values in
                    animatedContent(content, values: values)
                } keyframes: { _ in
                    KeyframeTrack(\.scale) {
                        SpringKeyframe(1.4, duration: duration * 0.5)
                        SpringKeyframe(1.0, duration: duration * 0.5)
                    }
                    KeyframeTrack(\.rotation) {
                        SpringKeyframe(.degrees(20), duration: duration * 0.4)
                        SpringKeyframe(.degrees(-20), duration: duration * 0.3)
                        SpringKeyframe(.zero, duration: duration * 0.3)
                    }
                    KeyframeTrack(\.offsetY) {
                        SpringKeyframe(-20, duration: duration * 0.5)
                        SpringKeyframe(0, duration: duration * 0.5)
                    }
                }
        } else {
            starImage
                .keyframeAnimator(
                    initialValue: KeyframeAnimatorShowcase.AnimationValues(),
                    trigger: trigger,
                ) { content, values in
                    animatedContent(content, values: values)
                } keyframes: { _ in
                    KeyframeTrack(\.scale) {
                        SpringKeyframe(1.4, duration: duration * 0.5)
                        SpringKeyframe(1.0, duration: duration * 0.5)
                    }
                    KeyframeTrack(\.rotation) {
                        SpringKeyframe(.degrees(20), duration: duration * 0.4)
                        SpringKeyframe(.degrees(-20), duration: duration * 0.3)
                        SpringKeyframe(.zero, duration: duration * 0.3)
                    }
                    KeyframeTrack(\.offsetY) {
                        SpringKeyframe(-20, duration: duration * 0.5)
                        SpringKeyframe(0, duration: duration * 0.5)
                    }
                }
        }
    }

    @ViewBuilder var cubicView: some View {
        let starImage = Image(systemName: "star.fill")
            .font(DesignSystem.Font.largeTitle)
            .foregroundStyle(DesignSystem.Color.accent)
        if repeating {
            starImage
                .keyframeAnimator(
                    initialValue: KeyframeAnimatorShowcase.AnimationValues(),
                    repeating: true,
                ) { content, values in
                    animatedContent(content, values: values)
                } keyframes: { _ in
                    KeyframeTrack(\.scale) {
                        CubicKeyframe(1.4, duration: duration * 0.5)
                        CubicKeyframe(1.0, duration: duration * 0.5)
                    }
                    KeyframeTrack(\.rotation) {
                        CubicKeyframe(.degrees(20), duration: duration * 0.4)
                        CubicKeyframe(.degrees(-20), duration: duration * 0.3)
                        CubicKeyframe(.zero, duration: duration * 0.3)
                    }
                    KeyframeTrack(\.offsetY) {
                        CubicKeyframe(-20, duration: duration * 0.5)
                        CubicKeyframe(0, duration: duration * 0.5)
                    }
                }
        } else {
            starImage
                .keyframeAnimator(
                    initialValue: KeyframeAnimatorShowcase.AnimationValues(),
                    trigger: trigger,
                ) { content, values in
                    animatedContent(content, values: values)
                } keyframes: { _ in
                    KeyframeTrack(\.scale) {
                        CubicKeyframe(1.4, duration: duration * 0.5)
                        CubicKeyframe(1.0, duration: duration * 0.5)
                    }
                    KeyframeTrack(\.rotation) {
                        CubicKeyframe(.degrees(20), duration: duration * 0.4)
                        CubicKeyframe(.degrees(-20), duration: duration * 0.3)
                        CubicKeyframe(.zero, duration: duration * 0.3)
                    }
                    KeyframeTrack(\.offsetY) {
                        CubicKeyframe(-20, duration: duration * 0.5)
                        CubicKeyframe(0, duration: duration * 0.5)
                    }
                }
        }
    }

    @ViewBuilder var linearView: some View {
        let starImage = Image(systemName: "star.fill")
            .font(DesignSystem.Font.largeTitle)
            .foregroundStyle(DesignSystem.Color.accent)
        if repeating {
            starImage
                .keyframeAnimator(
                    initialValue: KeyframeAnimatorShowcase.AnimationValues(),
                    repeating: true,
                ) { content, values in
                    animatedContent(content, values: values)
                } keyframes: { _ in
                    KeyframeTrack(\.scale) {
                        LinearKeyframe(1.4, duration: duration * 0.5)
                        LinearKeyframe(1.0, duration: duration * 0.5)
                    }
                    KeyframeTrack(\.rotation) {
                        LinearKeyframe(.degrees(20), duration: duration * 0.4)
                        LinearKeyframe(.degrees(-20), duration: duration * 0.3)
                        LinearKeyframe(.zero, duration: duration * 0.3)
                    }
                    KeyframeTrack(\.offsetY) {
                        LinearKeyframe(-20, duration: duration * 0.5)
                        LinearKeyframe(0, duration: duration * 0.5)
                    }
                }
        } else {
            starImage
                .keyframeAnimator(
                    initialValue: KeyframeAnimatorShowcase.AnimationValues(),
                    trigger: trigger,
                ) { content, values in
                    animatedContent(content, values: values)
                } keyframes: { _ in
                    KeyframeTrack(\.scale) {
                        LinearKeyframe(1.4, duration: duration * 0.5)
                        LinearKeyframe(1.0, duration: duration * 0.5)
                    }
                    KeyframeTrack(\.rotation) {
                        LinearKeyframe(.degrees(20), duration: duration * 0.4)
                        LinearKeyframe(.degrees(-20), duration: duration * 0.3)
                        LinearKeyframe(.zero, duration: duration * 0.3)
                    }
                    KeyframeTrack(\.offsetY) {
                        LinearKeyframe(-20, duration: duration * 0.5)
                        LinearKeyframe(0, duration: duration * 0.5)
                    }
                }
        }
    }

    @ViewBuilder var moveView: some View {
        let starImage = Image(systemName: "star.fill")
            .font(DesignSystem.Font.largeTitle)
            .foregroundStyle(DesignSystem.Color.accent)
        if repeating {
            starImage
                .keyframeAnimator(
                    initialValue: KeyframeAnimatorShowcase.AnimationValues(),
                    repeating: true,
                ) { content, values in
                    animatedContent(content, values: values)
                } keyframes: { _ in
                    KeyframeTrack(\.scale) {
                        MoveKeyframe(1.0)
                        SpringKeyframe(1.4, duration: duration * 0.5)
                        SpringKeyframe(1.0, duration: duration * 0.5)
                    }
                    KeyframeTrack(\.rotation) {
                        MoveKeyframe(.zero)
                        SpringKeyframe(.degrees(20), duration: duration * 0.4)
                        SpringKeyframe(.degrees(-20), duration: duration * 0.3)
                        SpringKeyframe(.zero, duration: duration * 0.3)
                    }
                    KeyframeTrack(\.offsetY) {
                        MoveKeyframe(0)
                        SpringKeyframe(-20, duration: duration * 0.5)
                        SpringKeyframe(0, duration: duration * 0.5)
                    }
                }
        } else {
            starImage
                .keyframeAnimator(
                    initialValue: KeyframeAnimatorShowcase.AnimationValues(),
                    trigger: trigger,
                ) { content, values in
                    animatedContent(content, values: values)
                } keyframes: { _ in
                    KeyframeTrack(\.scale) {
                        MoveKeyframe(1.0)
                        SpringKeyframe(1.4, duration: duration * 0.5)
                        SpringKeyframe(1.0, duration: duration * 0.5)
                    }
                    KeyframeTrack(\.rotation) {
                        MoveKeyframe(.zero)
                        SpringKeyframe(.degrees(20), duration: duration * 0.4)
                        SpringKeyframe(.degrees(-20), duration: duration * 0.3)
                        SpringKeyframe(.zero, duration: duration * 0.3)
                    }
                    KeyframeTrack(\.offsetY) {
                        MoveKeyframe(0)
                        SpringKeyframe(-20, duration: duration * 0.5)
                        SpringKeyframe(0, duration: duration * 0.5)
                    }
                }
        }
    }

    nonisolated func animatedContent(
        _ content: some View,
        values: KeyframeAnimatorShowcase.AnimationValues
    ) -> some View {
        content
            .scaleEffect(values.scale)
            .rotationEffect(values.rotation)
            .offset(y: values.offsetY)
    }
}

// MARK: - Code generation
private extension KeyframeAnimatorShowcase {
    var generatedCode: String {
        let halfDuration = String(format: "%.1f", duration * 0.5)
        let keyframeName = keyframeType.label
        let triggerOrRepeating = isRepeating
            ? "initialValue: AnimationValues(), repeating: true"
            : "initialValue: AnimationValues(), trigger: trigger"

        return [
            "struct AnimationValues {",
            "    var scale: CGFloat = 1.0",
            "    var rotation: Angle = .zero",
            "    var offsetY: CGFloat = 0",
            "}",
            "",
            "Image(systemName: \"star.fill\")",
            "    .keyframeAnimator(\(triggerOrRepeating)) { content, values in",
            "        content",
            "            .scaleEffect(values.scale)",
            "            .rotationEffect(values.rotation)",
            "            .offset(y: values.offsetY)",
            "    } keyframes: { _ in",
            "        KeyframeTrack(\\.scale) {",
            "            \(keyframeName)(1.4, duration: \(halfDuration))",
            "            \(keyframeName)(1.0, duration: \(halfDuration))",
            "        }",
            "        KeyframeTrack(\\.rotation) {",
            "            \(keyframeName)(.degrees(20), duration: \(halfDuration))",
            "            \(keyframeName)(.zero, duration: \(halfDuration))",
            "        }",
            "    }",
        ].joined(separator: "\n")
    }
}
