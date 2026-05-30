import SwiftUI

struct HandGestureShortcutShowcase: View {
    @State private var gestureKind: GestureKind = .tap
    @State private var isEnabled: Bool = true
    @State private var tapCount: Int = 1
    @State private var activationCount: Int = 0
    @State private var isHighlighted: Bool = false

    var body: some View {
        ShowcaseScreen(
            title: "Hand Gesture Shortcut",
            summary: "Maps tap, long-press, and drag gestures to a control action.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension HandGestureShortcutShowcase {
    fileprivate enum GestureKind: ShowcasePickable {
        case tap
        case longPress
        case drag

        var label: String {
            switch self {
            case .tap: "Tap"
            case .longPress: "Long Press"
            case .drag: "Drag"
            }
        }
    }

    fileprivate enum GestureState: ShowcaseState {
        case idle
        case highlighted
        case triggered
        case disabled

        var caption: String {
            switch self {
            case .idle: "Idle"
            case .highlighted: "Highlighted"
            case .triggered: "Triggered"
            case .disabled: "Disabled"
            }
        }
    }
}

// MARK: - Sub-views
private extension HandGestureShortcutShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            gestureTarget
            feedbackLabel
        }
    }

    var gestureTarget: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .fill(isHighlighted ? DesignSystem.Color.accent : DesignSystem.Color.cardBackground)
                .frame(width: 160, height: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                        .stroke(DesignSystem.Color.accent, lineWidth: 2),
                )
            VStack(spacing: DesignSystem.Spacing.xSmall) {
                Image(systemName: gestureIconName)
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(
                        isHighlighted ? DesignSystem.Color.onAccent : DesignSystem.Color.accent,
                    )
                Text(gestureKind.label)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(
                        isHighlighted ? DesignSystem.Color.onAccent : DesignSystem.Color.secondary,
                    )
            }
        }
        .opacity(isEnabled ? 1.0 : 0.4)
        .animation(.spring(duration: 0.25), value: isHighlighted)
        .modifier(
            GestureModifier(
                kind: gestureKind,
                tapCount: tapCount,
                isEnabled: isEnabled,
                onHighlight: { isHighlighted = true },
                onTrigger: {
                    isHighlighted = false
                    activationCount += 1
                },
            ),
        )
        .accessibilityLabel("\(gestureKind.label) gesture target")
        .accessibilityHint(isEnabled ? "Perform \(gestureKind.label.lowercased()) to activate" : "Disabled")
    }

    var feedbackLabel: some View {
        Text(activationCount == 0 ? "No activations yet" : "Activated \(activationCount) time(s)")
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.secondary)
    }

    var gestureIconName: String {
        switch gestureKind {
        case .tap: "hand.tap"
        case .longPress: "hand.point.up.left"
        case .drag: "hand.draw"
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Gesture", selection: $gestureKind)
        ShowcaseToggle("Enabled", isOn: $isEnabled)
        if gestureKind == .tap {
            ShowcaseStepper("Tap count", value: $tapCount, in: 1...3)
        }
    }

    @ViewBuilder
    func stateView(_ state: GestureState) -> some View {
        staticGestureTarget(state: state)
    }

    func staticGestureTarget(state: GestureState) -> some View {
        let highlighted = state == .highlighted || state == .triggered
        let opacity: Double = state == .disabled ? 0.4 : 1.0
        return ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(highlighted ? DesignSystem.Color.accent : DesignSystem.Color.cardBackground)
                .frame(width: 120, height: 72)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .stroke(DesignSystem.Color.accent, lineWidth: 1.5),
                )
            Image(systemName: "hand.tap")
                .font(DesignSystem.Font.title3)
                .foregroundStyle(
                    highlighted ? DesignSystem.Color.onAccent : DesignSystem.Color.accent,
                )
        }
        .opacity(opacity)
        .accessibilityLabel("Gesture target \(state.caption)")
    }
}

// MARK: - Code generation
private extension HandGestureShortcutShowcase {
    var generatedCode: String {
        switch gestureKind {
        case .tap:
            return tapCode
        case .longPress:
            return longPressCode
        case .drag:
            return dragCode
        }
    }

    var tapCode: String {
        let countArg = tapCount > 1 ? "count: \(tapCount)" : ""
        let inner = countArg.isEmpty ? "onTapGesture {" : "onTapGesture(\(countArg)) {"
        return [
            "view",
            "    .\(inner)",
            "        handleAction()",
            "    }",
            "    .disabled(\(!isEnabled))",
        ].joined(separator: "\n")
    }

    var longPressCode: String {
        [
            "view",
            "    .onLongPressGesture {",
            "        handleAction()",
            "    }",
            "    .disabled(\(!isEnabled))",
        ].joined(separator: "\n")
    }

    var dragCode: String {
        [
            "view",
            "    .gesture(",
            "        DragGesture()",
            "            .onEnded { _ in handleAction() }",
            "    )",
            "    .disabled(\(!isEnabled))",
        ].joined(separator: "\n")
    }
}

// MARK: - Gesture modifier
private struct GestureModifier: ViewModifier {
    let kind: HandGestureShortcutShowcase.GestureKind
    let tapCount: Int
    let isEnabled: Bool
    let onHighlight: () -> Void
    let onTrigger: () -> Void

    func body(content: Content) -> some View {
        switch kind {
        case .tap:
            content
                .onTapGesture(count: tapCount) {
                    guard isEnabled else { return }
                    onHighlight()
                    onTrigger()
                }
        case .longPress:
            content
                .onLongPressGesture(minimumDuration: 0.5) {
                    guard isEnabled else { return }
                    onHighlight()
                    onTrigger()
                }
        case .drag:
            content
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onChanged { _ in
                            guard isEnabled else { return }
                            onHighlight()
                        }
                        .onEnded { _ in
                            guard isEnabled else { return }
                            onTrigger()
                        },
                )
        }
    }
}
