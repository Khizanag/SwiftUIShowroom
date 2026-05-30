import SwiftUI

struct PencilGestureShowcase: View {
    @State private var gestureKind: GestureKind = .doubleTap
    @State private var respectPreferredAction = true
    @State private var lastEvent = "Idle"
    @State private var isActive = false

    var body: some View {
        ShowcaseScreen(
            title: "Apple Pencil Gestures",
            summary: "Responds to Pencil double-tap and squeeze, honoring the user's system preference.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension PencilGestureShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            pencilTarget(
                label: lastEvent,
                isActive: isActive,
                isEnabled: true
            )
            Text(platformHint)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
        }
    }

    var platformHint: String {
        #if os(iOS)
        return "Use Apple Pencil to trigger the gesture"
        #else
        return "Apple Pencil gestures are not available on this platform"
        #endif
    }

    @ViewBuilder
    func pencilTarget(
        label: String,
        isActive: Bool,
        isEnabled: Bool
    ) -> some View {
        let base = RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
            .fill(isActive
                ? DesignSystem.Color.accent
                : DesignSystem.Color.accent.opacity(0.15))
            .frame(width: 240, height: 160)
            .overlay(
                VStack(spacing: DesignSystem.Spacing.xSmall) {
                    Image(systemName: pencilSystemImage)
                        .font(DesignSystem.Font.title)
                        .foregroundStyle(
                            isActive
                                ? DesignSystem.Color.onAccent
                                : DesignSystem.Color.accent
                        )
                    Text(label)
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(
                            isActive
                                ? DesignSystem.Color.onAccent
                                : DesignSystem.Color.primary
                        )
                }
            )
            .opacity(isEnabled ? 1 : 0.4)
            .animation(.easeInOut(duration: 0.2), value: isActive)
            .accessibilityLabel("Pencil gesture target, last: \(label)")
        #if os(iOS)
        if #available(iOS 17.5, *) {
            base.modifier(PencilGestureModifier(
                gestureKind: gestureKind,
                respectPreferredAction: respectPreferredAction,
                onEvent: { eventLabel in
                    lastEvent = eventLabel
                    self.isActive = true
                },
                onEnd: {
                    self.isActive = false
                }
            ))
        } else {
            base
        }
        #else
        base
        #endif
    }

    var pencilSystemImage: String {
        gestureKind == .doubleTap ? "pencil.tip" : "hand.point.up.left"
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Gesture kind", selection: $gestureKind)
        ShowcaseToggle("Respect preferred action", isOn: $respectPreferredAction)
    }

    @ViewBuilder
    func stateView(_ state: PencilGestureState) -> some View {
        switch state {
        case .default:
            staticTarget(label: "Idle", isActive: false, isEnabled: true)
        case .disabled:
            staticTarget(label: "Idle", isActive: false, isEnabled: false)
        case .selected:
            staticTarget(label: "Triggered", isActive: true, isEnabled: true)
        }
    }

    func staticTarget(label: String, isActive: Bool, isEnabled: Bool) -> some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(isActive
                ? DesignSystem.Color.accent
                : DesignSystem.Color.accent.opacity(0.15))
            .frame(width: 140, height: 90)
            .overlay(
                VStack(spacing: DesignSystem.Spacing.xSmall) {
                    Image(systemName: "pencil.tip")
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(
                            isActive
                                ? DesignSystem.Color.onAccent
                                : DesignSystem.Color.accent
                        )
                    Text(label)
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(
                            isActive
                                ? DesignSystem.Color.onAccent
                                : DesignSystem.Color.primary
                        )
                }
            )
            .opacity(isEnabled ? 1 : 0.4)
    }
}

// MARK: - Nested types
extension PencilGestureShowcase {
    fileprivate enum GestureKind: ShowcasePickable {
        case doubleTap
        case squeeze

        var label: String {
            switch self {
            case .doubleTap: "Double Tap"
            case .squeeze: "Squeeze"
            }
        }
    }

    fileprivate enum PencilGestureState: ShowcaseState {
        case `default`
        case disabled
        case selected

        var caption: String {
            switch self {
            case .default: "Default (idle)"
            case .disabled: "Disabled"
            case .selected: "Triggered"
            }
        }
    }
}

// MARK: - Gesture modifier
#if os(iOS)
@available(iOS 17.5, *)
private struct PencilGestureModifier: ViewModifier {
    let gestureKind: PencilGestureShowcase.GestureKind
    let respectPreferredAction: Bool
    let onEvent: (String) -> Void
    let onEnd: () -> Void

    @Environment(\.preferredPencilDoubleTapAction) private var doubleTapAction
    @Environment(\.preferredPencilSqueezeAction) private var squeezeAction

    func body(content: Content) -> some View {
        switch gestureKind {
        case .doubleTap:
            content.onPencilDoubleTap { _ in
                if respectPreferredAction, doubleTapAction == .ignore { return }
                onEvent("Double-tapped")
                scheduleReset()
            }
        case .squeeze:
            content.onPencilSqueeze { phase in
                handleSqueezePhase(phase)
            }
        }
    }

    private func handleSqueezePhase(_ phase: PencilSqueezeGesturePhase) {
        if respectPreferredAction, squeezeAction == .ignore { return }
        switch phase {
        case .active:
            onEvent("Squeezing…")
        case .ended:
            onEvent("Squeezed")
            scheduleReset()
        case .failed:
            onEnd()
        @unknown default:
            break
        }
    }

    private func scheduleReset() {
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            onEnd()
        }
    }
}
#endif

// MARK: - Code generation
private extension PencilGestureShowcase {
    var generatedCode: String {
        switch gestureKind {
        case .doubleTap: return doubleTapCode
        case .squeeze: return squeezeCode
        }
    }

    var doubleTapCode: String {
        var lines = [
            "@Environment(\\.preferredPencilDoubleTapAction) private var preferred",
            "@State private var label = \"Idle\"",
            "",
            "RoundedRectangle(cornerRadius: 16)",
            "    .fill(.blue.opacity(0.2))",
            "    .frame(width: 240, height: 160)",
            "    .overlay(Text(label))",
            "    .onPencilDoubleTap { _ in",
        ]
        if respectPreferredAction {
            lines.append("        guard preferred != .ignore else { return }")
        }
        lines.append("        label = \"Double-tapped\"")
        lines.append("    }")
        return lines.joined(separator: "\n")
    }

    var squeezeCode: String {
        var lines = [
            "@Environment(\\.preferredPencilSqueezeAction) private var preferred",
            "@State private var label = \"Idle\"",
            "",
            "RoundedRectangle(cornerRadius: 16)",
            "    .fill(.blue.opacity(0.2))",
            "    .frame(width: 240, height: 160)",
            "    .overlay(Text(label))",
            "    .onPencilSqueeze { phase in",
        ]
        if respectPreferredAction {
            lines.append("        guard preferred != .ignore else { return }")
        }
        lines.append("        if case .ended = phase { label = \"Squeezed\" }")
        lines.append("    }")
        return lines.joined(separator: "\n")
    }
}
