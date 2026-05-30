import SwiftUI

struct SequencedGestureShowcase: View {
    @State private var isEnabled: Bool = true
    @GestureState private var isActive: Bool = false
    @State private var offset: CGSize = .zero
    @State private var phase: SequencePhase = .idle

    var body: some View {
        ShowcaseScreen(
            title: "Sequenced Gesture",
            summary: "Runs a second gesture only after the first one succeeds, in order.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension SequencedGestureShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            phaseLabel
            dragTarget
        }
    }

    var phaseLabel: some View {
        Text(phase.description)
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.secondary)
            .animation(.easeInOut(duration: 0.2), value: phase)
    }

    var dragTarget: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(targetFill)
            .frame(width: 100, height: 100)
            .overlay(targetOverlay)
            .offset(x: offset.width, y: offset.height)
            .scaleEffect(isActive ? 1.12 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isActive)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: offset)
            .gesture(
                longPressThenDrag,
                isEnabled: isEnabled
            )
    }

    var targetFill: Color {
        switch phase {
        case .idle: return DesignSystem.Color.accent.opacity(0.6)
        case .firstActive: return .orange
        case .secondActive: return DesignSystem.Color.accent
        }
    }

    var targetOverlay: some View {
        Text(phase.overlayLabel)
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .multilineTextAlignment(.center)
            .padding(DesignSystem.Spacing.xSmall)
    }

    var longPressThenDrag: some Gesture {
        LongPressGesture(minimumDuration: 0.5)
            .sequenced(before: DragGesture())
            .updating($isActive) { value, state, _ in
                switch value {
                case .second(true, _): state = true
                default: state = false
                }
            }
            .onChanged { value in
                switch value {
                case .first:
                    phase = .firstActive
                case .second(true, let drag):
                    phase = .secondActive
                    offset = drag?.translation ?? offset
                default:
                    break
                }
            }
            .onEnded { value in
                if case let .second(_, drag?) = value {
                    offset = drag.translation
                }
                phase = .idle
            }
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("Enabled", isOn: $isEnabled)
    }

    @ViewBuilder
    func stateView(_ state: SequencedGestureState) -> some View {
        switch state {
        case .idle:
            galleryCard(fill: DesignSystem.Color.accent.opacity(0.6), label: "Hold to\nactivate")
        case .firstActive:
            galleryCard(fill: .orange, label: "Holding…")
        case .secondActive:
            galleryCard(fill: DesignSystem.Color.accent, label: "Dragging")
                .scaleEffect(1.1)
        case .disabled:
            galleryCard(fill: DesignSystem.Color.secondary.opacity(0.35), label: "Disabled")
                .opacity(0.55)
        }
    }

    func galleryCard(fill: Color, label: String) -> some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(fill)
            .frame(width: 90, height: 90)
            .overlay(
                Text(label)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.onAccent)
                    .multilineTextAlignment(.center)
                    .padding(DesignSystem.Spacing.xSmall),
            )
    }
}

// MARK: - Nested types
extension SequencedGestureShowcase {
    fileprivate enum SequencePhase: Equatable {
        case idle, firstActive, secondActive

        var description: String {
            switch self {
            case .idle: return "Hold to activate, then drag"
            case .firstActive: return "First gesture active — keep holding"
            case .secondActive: return "Second gesture active — dragging"
            }
        }

        var overlayLabel: String {
            switch self {
            case .idle: return "Hold"
            case .firstActive: return "Holding…"
            case .secondActive: return "Drag"
            }
        }
    }

    fileprivate enum SequencedGestureState: ShowcaseState {
        case idle, firstActive, secondActive, disabled

        var caption: String {
            switch self {
            case .idle: "Idle"
            case .firstActive: "First Active"
            case .secondActive: "Second Active"
            case .disabled: "Disabled"
            }
        }
    }
}

// MARK: - Code generation
private extension SequencedGestureShowcase {
    var generatedCode: String {
        let lines: [String] = [
            "struct SequencedDemo: View {",
            "    @GestureState private var isActive = false",
            "    @State private var offset: CGSize = .zero",
            "",
            "    var body: some View {",
            "        RoundedRectangle(cornerRadius: 16)",
            "            .fill(isActive ? Color.green : Color.blue)",
            "            .frame(width: 100, height: 100)",
            "            .offset(x: offset.width, y: offset.height)",
            "            .scaleEffect(isActive ? 1.12 : 1.0)",
            "            .gesture(",
            "                LongPressGesture(minimumDuration: 0.5)",
            "                    .sequenced(before: DragGesture())",
            "                    .updating($isActive) { value, state, _ in",
            "                        switch value {",
            "                        case .second(true, _): state = true",
            "                        default: state = false",
            "                        }",
            "                    }",
            "                    .onEnded { value in",
            "                        if case let .second(_, drag?) = value {",
            "                            offset = drag.translation",
            "                        }",
            "                    },",
            "                isEnabled: \(isEnabled)",
            "            )",
            "    }",
            "}",
        ]
        return lines.joined(separator: "\n")
    }
}
