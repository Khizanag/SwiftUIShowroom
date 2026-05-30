import SwiftUI

struct GestureModifierShowcase: View {
    enum GesturePriorityOption: ShowcasePickable {
        case gesture
        case highPriorityGesture
        case simultaneousGesture

        var label: String {
            switch self {
            case .gesture: ".gesture"
            case .highPriorityGesture: ".highPriorityGesture"
            case .simultaneousGesture: ".simultaneousGesture"
            }
        }

        var modifierName: String {
            switch self {
            case .gesture: "gesture"
            case .highPriorityGesture: "highPriorityGesture"
            case .simultaneousGesture: "simultaneousGesture"
            }
        }

        var priorityDescription: String {
            switch self {
            case .gesture: "Child wins ties"
            case .highPriorityGesture: "This view wins"
            case .simultaneousGesture: "Both recognize"
            }
        }
    }

    enum GestureMaskOption: ShowcasePickable {
        case all
        case gestureOnly
        case subviewsOnly
        case none

        var label: String {
            switch self {
            case .all: ".all"
            case .gestureOnly: ".gesture"
            case .subviewsOnly: ".subviews"
            case .none: ".none"
            }
        }

        var swiftValue: GestureMask {
            switch self {
            case .all: .all
            case .gestureOnly: .gesture
            case .subviewsOnly: .subviews
            case .none: .none
            }
        }

        var codeLabel: String {
            switch self {
            case .all: ".all"
            case .gestureOnly: ".gesture"
            case .subviewsOnly: ".subviews"
            case .none: ".none"
            }
        }
    }

    @State private var priority: GesturePriorityOption = .gesture
    @State private var mask: GestureMaskOption = .all
    @State private var isEnabled: Bool = true
    @State private var tapCount: Int = 0

    var body: some View {
        ShowcaseScreen(
            title: "Gesture Attach Modifiers",
            summary: "Attach gestures and control priority relative to child view gestures.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension GestureModifierShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            attachedTarget
            statusLabel
        }
    }

    @ViewBuilder
    var attachedTarget: some View {
        if mask.swiftValue != .all {
            previewBox.modifier(MaskGestureModifier(
                priority: priority,
                mask: mask.swiftValue,
                tapCount: $tapCount,
            ))
        } else {
            previewBox.modifier(EnabledGestureModifier(
                priority: priority,
                isEnabled: isEnabled,
                tapCount: $tapCount,
            ))
        }
    }

    var previewBox: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
            .fill(tapCount > 0 ? DesignSystem.Color.accent : DesignSystem.Color.accent.opacity(0.35))
            .frame(width: 200, height: 140)
            .overlay(
                VStack(spacing: DesignSystem.Spacing.xSmall) {
                    Text(tapCount == 0 ? "Tap me" : "\(tapCount)")
                        .font(DesignSystem.Font.title2)
                        .foregroundStyle(DesignSystem.Color.onAccent)
                    Text(priority.priorityDescription)
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.onAccent.opacity(0.8))
                },
            )
            .animation(.spring(duration: 0.2), value: tapCount)
            .accessibilityLabel("Tap target, tapped \(tapCount) times")
    }

    var statusLabel: some View {
        Text(isEnabled ? "Gesture active" : "Gesture disabled")
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.secondary)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Priority modifier", selection: $priority)
        ShowcasePicker("Mask (including:)", selection: $mask)
        ShowcaseToggle("Gesture enabled", isOn: $isEnabled)
    }

    @ViewBuilder
    func stateView(_ state: EnabledState) -> some View {
        switch state {
        case .enabled:
            staticBox(label: "Tap me", dimmed: false)
        case .disabled:
            staticBox(label: "Disabled", dimmed: true)
        }
    }

    func staticBox(label: String, dimmed: Bool) -> some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(DesignSystem.Color.accent.opacity(0.4))
            .frame(width: 120, height: 80)
            .overlay(
                Text(label)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.onAccent),
            )
            .opacity(dimmed ? 0.4 : 1.0)
            .accessibilityLabel(label)
    }
}

// MARK: - Gesture view modifiers
private struct MaskGestureModifier: ViewModifier {
    let priority: GestureModifierShowcase.GesturePriorityOption
    let mask: GestureMask
    @Binding var tapCount: Int

    @ViewBuilder
    func body(content: Content) -> some View {
        let gesture = TapGesture().onEnded { tapCount += 1 }
        switch priority {
        case .gesture:
            content.gesture(gesture, including: mask)
        case .highPriorityGesture:
            content.highPriorityGesture(gesture, including: mask)
        case .simultaneousGesture:
            content.simultaneousGesture(gesture, including: mask)
        }
    }
}
private struct EnabledGestureModifier: ViewModifier {
    let priority: GestureModifierShowcase.GesturePriorityOption
    let isEnabled: Bool
    @Binding var tapCount: Int

    @ViewBuilder
    func body(content: Content) -> some View {
        let gesture = TapGesture().onEnded { tapCount += 1 }
        switch priority {
        case .gesture:
            content.gesture(gesture, isEnabled: isEnabled)
        case .highPriorityGesture:
            content.highPriorityGesture(gesture, isEnabled: isEnabled)
        case .simultaneousGesture:
            content.simultaneousGesture(gesture, isEnabled: isEnabled)
        }
    }
}

// MARK: - Code generation
private extension GestureModifierShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("@State private var taps = 0")
        lines.append("")
        lines.append("Rectangle()")
        lines.append("    .fill(.blue.opacity(0.3))")
        lines.append("    .frame(width: 200, height: 140)")
        lines.append("    .overlay(Text(\"\\(taps)\"))")
        lines.append("    .\(priority.modifierName)(")
        lines.append("        TapGesture().onEnded { taps += 1 },")
        if mask.swiftValue != .all {
            lines.append("        including: \(mask.codeLabel),")
        } else {
            lines.append("        isEnabled: \(isEnabled),")
        }
        lines.append("    )")
        return lines.joined(separator: "\n")
    }
}
