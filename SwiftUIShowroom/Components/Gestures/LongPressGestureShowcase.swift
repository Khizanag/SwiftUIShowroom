import SwiftUI

struct LongPressGestureShowcase: View {
    fileprivate enum LongPressShowcaseState: ShowcaseState {
        case `default`, pressing, focused, selected, disabled

        var caption: String {
            switch self {
            case .default: "Default"
            case .pressing: "Pressing"
            case .focused: "Focused"
            case .selected: "Completed"
            case .disabled: "Disabled"
            }
        }
    }

    @State private var minimumDuration: Double = 0.5
    @State private var maximumDistance: Double = 10
    @State private var usePressingChanged: Bool = true
    @State private var isEnabled: Bool = true

    @GestureState private var isPressing: Bool = false
    @State private var isCompleted: Bool = false

    var body: some View {
        ShowcaseScreen(
            title: "Long Press Gesture",
            summary: "Succeeds when the user presses and holds for at least a minimum duration.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension LongPressGestureShowcase {
    var preview: some View {
        let gesture = LongPressGesture(
            minimumDuration: minimumDuration,
            maximumDistance: maximumDistance
        )
        .updating($isPressing) { current, state, _ in
            guard usePressingChanged else { return }
            state = current
        }
        .onEnded { finished in
            isCompleted = finished
        }

        return Circle()
            .fill(previewFill)
            .frame(width: 120, height: 120)
            .scaleEffect(isPressing ? 1.15 : 1.0)
            .overlay(previewLabel)
            .gesture(gesture)
            .disabled(!isEnabled)
            .animation(.easeInOut(duration: 0.2), value: isPressing)
            .animation(.easeInOut(duration: 0.2), value: isCompleted)
            .onTapGesture {
                isCompleted = false
            }
    }

    var previewFill: Color {
        if isCompleted { return DesignSystem.Color.accent }
        if isPressing { return .orange }
        return DesignSystem.Color.accent.opacity(0.5)
    }

    var previewLabel: some View {
        Text(isCompleted ? "Done" : (isPressing ? "Holding…" : "Hold"))
            .font(DesignSystem.Font.headline)
            .foregroundStyle(DesignSystem.Color.onAccent)
    }

    @ViewBuilder var controls: some View {
        ShowcaseSlider(
            "Minimum duration",
            value: $minimumDuration,
            in: 0.1...5.0,
            step: 0.1
        )
        ShowcaseSlider(
            "Maximum distance",
            value: $maximumDistance,
            in: 0...100,
            step: 1
        )
        ShowcaseToggle("Show pressing changed", isOn: $usePressingChanged)
        ShowcaseToggle("Enabled", isOn: $isEnabled)
    }

    @ViewBuilder
    func stateView(_ state: LongPressShowcaseState) -> some View {
        switch state {
        case .default:
            staticCircle(fill: DesignSystem.Color.accent.opacity(0.5), label: "Hold")
        case .disabled:
            staticCircle(fill: DesignSystem.Color.secondary.opacity(0.3), label: "Hold")
                .disabled(true)
        case .pressing:
            staticCircle(fill: .orange, label: "Holding…")
                .scaleEffect(1.15)
        case .focused:
            staticCircle(fill: DesignSystem.Color.accent.opacity(0.7), label: "Hold")
                .overlay(
                    Circle()
                        .strokeBorder(DesignSystem.Color.accent, lineWidth: 3)
                )
        case .selected:
            staticCircle(fill: DesignSystem.Color.accent, label: "Done")
        }
    }

    func staticCircle(fill: Color, label: String) -> some View {
        Circle()
            .fill(fill)
            .frame(width: 100, height: 100)
            .overlay(
                Text(label)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.onAccent)
            )
    }
}

// MARK: - Code generation
private extension LongPressGestureShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("@GestureState private var isPressing = false")
        lines.append("@State private var completed = false")
        lines.append("")
        lines.append("Circle()")
        lines.append("    .fill(completed ? .green : (isPressing ? .orange : .blue))")
        lines.append("    .frame(width: 120, height: 120)")
        lines.append("    .scaleEffect(isPressing ? 1.15 : 1.0)")
        lines.append("    .gesture(")
        lines.append("        LongPressGesture(")
        lines.append("            minimumDuration: \(formattedDuration),")
        lines.append("            maximumDistance: \(formattedDistance)")
        lines.append("        )")
        if usePressingChanged {
            lines.append("        .updating($isPressing) { current, state, _ in state = current }")
        }
        lines.append("        .onEnded { finished in completed = finished }")
        lines.append("    )")
        if !isEnabled {
            lines.append("    .disabled(true)")
        }
        lines.append("    .animation(.easeInOut, value: isPressing)")
        return lines.joined(separator: "\n")
    }

    var formattedDuration: String {
        String(format: "%.1f", (minimumDuration * 10).rounded() / 10)
    }

    var formattedDistance: String {
        let value = maximumDistance.rounded()
        return "\(Int(value))"
    }
}
