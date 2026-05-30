import SwiftUI

struct GestureStateShowcase: View {
    // MARK: - Nested types
    enum GestureStateType: ShowcasePickable {
        case bool
        #if !os(tvOS)
        case cgSize
        case cgFloat
        case angle
        #endif

        var label: String {
            switch self {
            case .bool: "Bool (press)"
            #if !os(tvOS)
            case .cgSize: "CGSize (drag)"
            case .cgFloat: "CGFloat (scale)"
            case .angle: "Angle (rotation)"
            #endif
            }
        }
    }

    enum GestureStateShowcaseState: ShowcaseState {
        case `default`
        case selected

        var caption: String {
            switch self {
            case .default: "Idle"
            case .selected: "Active"
            }
        }
    }

    @State private var animateReset: Bool = true
    @State private var stateType: GestureStateType = .bool
    @GestureState private var isPressing: Bool = false
    #if !os(tvOS)
    @GestureState private var dragTranslation: CGSize = .zero
    @GestureState private var pinchScale: CGFloat = 1.0
    @GestureState private var spinAngle: Angle = .zero
    @State private var committedOffset: CGSize = .zero
    @State private var committedScale: CGFloat = 1.0
    @State private var committedAngle: Angle = .zero
    #endif

    var body: some View {
        ShowcaseScreen(
            title: "Gesture State",
            summary: "A property wrapper holding transient gesture state that auto-resets when the gesture ends.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension GestureStateShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            activePreview
            resetHint
        }
    }

    @ViewBuilder var activePreview: some View {
        switch stateType {
        case .bool:
            pressPreview
        #if !os(tvOS)
        case .cgSize:
            dragPreview
        case .cgFloat:
            scalePreview
        case .angle:
            rotatePreview
        #endif
        }
    }

    var pressPreview: some View {
        Circle()
            .fill(isPressing ? Color.orange : DesignSystem.Color.accent)
            .frame(width: 100, height: 100)
            .scaleEffect(isPressing ? 1.18 : 1.0)
            .overlay(
                Text(isPressing ? "Pressing" : "Press & Hold")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.onAccent)
            )
            .gesture(
                LongPressGesture(minimumDuration: 0.0)
                    .updating($isPressing) { current, state, transaction in
                        state = current
                        if animateReset {
                            transaction.animation = .easeInOut(duration: 0.15)
                        }
                    }
            )
            .animation(.easeInOut(duration: 0.15), value: isPressing)
    }

    #if !os(tvOS)
    var dragPreview: some View {
        Circle()
            .fill(DesignSystem.Color.accent)
            .frame(width: 100, height: 100)
            .overlay(
                Image(systemName: "arrow.up.and.down.and.left.and.right")
                    .foregroundStyle(DesignSystem.Color.onAccent)
                    .font(DesignSystem.Font.title2)
            )
            .offset(
                x: committedOffset.width + dragTranslation.width,
                y: committedOffset.height + dragTranslation.height
            )
            .gesture(
                DragGesture()
                    .updating($dragTranslation) { value, state, transaction in
                        state = value.translation
                        if animateReset {
                            transaction.animation = .spring(response: 0.35, dampingFraction: 0.7)
                        }
                    }
                    .onEnded { value in
                        committedOffset.width += value.translation.width
                        committedOffset.height += value.translation.height
                    }
            )
    }

    var scalePreview: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
            .fill(DesignSystem.Color.accent)
            .frame(width: 100, height: 100)
            .scaleEffect(committedScale * pinchScale)
            .overlay(
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .foregroundStyle(DesignSystem.Color.onAccent)
                    .font(DesignSystem.Font.title2)
            )
            .gesture(
                MagnifyGesture()
                    .updating($pinchScale) { value, state, transaction in
                        state = value.magnification
                        if animateReset {
                            transaction.animation = .spring(response: 0.35, dampingFraction: 0.7)
                        }
                    }
                    .onEnded { value in
                        committedScale = max(0.3, min(3.0, committedScale * value.magnification))
                    }
            )
    }

    var rotatePreview: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
            .fill(DesignSystem.Color.accent)
            .frame(width: 100, height: 100)
            .rotationEffect(committedAngle + spinAngle)
            .overlay(
                Image(systemName: "arrow.2.circlepath")
                    .foregroundStyle(DesignSystem.Color.onAccent)
                    .font(DesignSystem.Font.title2)
            )
            .gesture(
                RotateGesture()
                    .updating($spinAngle) { value, state, transaction in
                        state = value.rotation
                        if animateReset {
                            transaction.animation = .spring(response: 0.35, dampingFraction: 0.7)
                        }
                    }
                    .onEnded { value in
                        committedAngle += value.rotation
                    }
            )
    }
    #endif

    var resetHint: some View {
        Text(animateReset ? "Spring-back on release" : "Snaps back on release")
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.secondary)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("State type", selection: $stateType)
        ShowcaseToggle("Animate reset", isOn: $animateReset)
    }

    @ViewBuilder func stateView(_ state: GestureStateShowcaseState) -> some View {
        switch state {
        case .default:
            galleryCircle(
                fill: DesignSystem.Color.accent,
                icon: "hand.draw",
                label: "Idle"
            )
        case .selected:
            galleryCircle(
                fill: Color.orange,
                icon: "arrow.up.and.down.and.left.and.right",
                label: "Active"
            )
            .scaleEffect(1.12)
            .offset(x: 10, y: -10)
        }
    }

    func galleryCircle(fill: some ShapeStyle, icon: String, label: String) -> some View {
        Circle()
            .fill(fill)
            .frame(width: 90, height: 90)
            .overlay(
                VStack(spacing: DesignSystem.Spacing.xSmall) {
                    Image(systemName: icon)
                        .font(DesignSystem.Font.callout)
                        .foregroundStyle(DesignSystem.Color.onAccent)
                    Text(label)
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.onAccent)
                }
            )
    }
}

// MARK: - Code generation
private extension GestureStateShowcase {
    var generatedCode: String {
        let animLine = animateReset
            ? "transaction.animation = .spring(response: 0.35, dampingFraction: 0.7)"
            : "// no animation — snaps back instantly"
        switch stateType {
        case .bool:
            return boolCode(animLine: animLine)
        #if !os(tvOS)
        case .cgSize:
            return dragCode(animLine: animLine)
        case .cgFloat:
            return scaleCode(animLine: animLine)
        case .angle:
            return angleCode(animLine: animLine)
        #endif
        }
    }

    func boolCode(animLine: String) -> String {
        [
            "@GestureState private var isPressing: Bool = false",
            "",
            "Circle()",
            "    .fill(isPressing ? Color.orange : .blue)",
            "    .scaleEffect(isPressing ? 1.15 : 1.0)",
            "    .gesture(",
            "        LongPressGesture(minimumDuration: 0)",
            "            .updating($isPressing) { current, state, transaction in",
            "                state = current",
            "                \(animLine)",
            "            }",
            "    )",
            "    .animation(.easeInOut(duration: 0.15), value: isPressing)",
        ].joined(separator: "\n")
    }

    #if !os(tvOS)
    func dragCode(animLine: String) -> String {
        [
            "@GestureState private var translation: CGSize = .zero",
            "@State private var committed: CGSize = .zero",
            "",
            "Circle()",
            "    .fill(.blue)",
            "    .frame(width: 100, height: 100)",
            "    .offset(x: committed.width + translation.width,",
            "            y: committed.height + translation.height)",
            "    .gesture(",
            "        DragGesture()",
            "            .updating($translation) { value, state, transaction in",
            "                state = value.translation",
            "                \(animLine)",
            "            }",
            "            .onEnded { value in",
            "                committed.width += value.translation.width",
            "                committed.height += value.translation.height",
            "            }",
            "    )",
        ].joined(separator: "\n")
    }

    func scaleCode(animLine: String) -> String {
        [
            "@GestureState private var pinch: CGFloat = 1.0",
            "@State private var scale: CGFloat = 1.0",
            "",
            "RoundedRectangle(cornerRadius: 16)",
            "    .fill(.blue)",
            "    .frame(width: 120, height: 120)",
            "    .scaleEffect(scale * pinch)",
            "    .gesture(",
            "        MagnifyGesture()",
            "            .updating($pinch) { value, state, transaction in",
            "                state = value.magnification",
            "                \(animLine)",
            "            }",
            "            .onEnded { value in scale *= value.magnification }",
            "    )",
        ].joined(separator: "\n")
    }

    func angleCode(animLine: String) -> String {
        [
            "@GestureState private var spin: Angle = .zero",
            "@State private var angle: Angle = .zero",
            "",
            "Rectangle()",
            "    .fill(.blue)",
            "    .frame(width: 120, height: 120)",
            "    .rotationEffect(angle + spin)",
            "    .gesture(",
            "        RotateGesture()",
            "            .updating($spin) { value, state, transaction in",
            "                state = value.rotation",
            "                \(animLine)",
            "            }",
            "            .onEnded { value in angle += value.rotation }",
            "    )",
        ].joined(separator: "\n")
    }
    #endif
}
