import SwiftUI

struct RotateGestureShowcase: View {
    @State private var minimumAngleDelta: Double = 1
    @State private var trackingMode: TrackingMode = .onChanged
    @State private var isEnabled: Bool = true
    @State private var committedAngle: Angle = .zero

    var body: some View {
        ShowcaseScreen(
            title: "Rotate Gesture",
            summary: "Two-finger rotation tracking angle and anchor. Replaces the deprecated RotationGesture.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension RotateGestureShowcase {
    var preview: some View {
        #if os(tvOS)
        UnavailableGestureNotice()
        #else
        RotatingShape(
            committedAngle: $committedAngle,
            isEnabled: isEnabled,
            minimumAngleDelta: minimumAngleDelta,
            trackingMode: trackingMode
        )
        #endif
    }

    @ViewBuilder
    var controls: some View {
        #if !os(tvOS)
        ShowcaseSlider(
            "Min angle delta (°)",
            value: $minimumAngleDelta,
            in: 0...30,
            step: 1
        )
        ShowcasePicker("Tracking mode", selection: $trackingMode)
        ShowcaseToggle("Enabled", isOn: $isEnabled)
        #else
        Text("RotateGesture is unavailable on tvOS.")
            .font(DesignSystem.Font.callout)
            .foregroundStyle(DesignSystem.Color.secondary)
        #endif
    }

    @ViewBuilder
    func stateView(_ state: RotateGestureState) -> some View {
        switch state {
        case .default:
            StaticShape(angle: .zero, tinted: true, dimmed: false)
        case .disabled:
            StaticShape(angle: .zero, tinted: false, dimmed: true)
        case .selected:
            StaticShape(angle: .degrees(45), tinted: true, dimmed: false)
        }
    }
}

// MARK: - Rotating shape (iOS / macOS only)
#if !os(tvOS)
private struct RotatingShape: View {
    @Binding var committedAngle: Angle
    let isEnabled: Bool
    let minimumAngleDelta: Double
    let trackingMode: RotateGestureShowcase.TrackingMode

    @GestureState private var gestureAngle: Angle = .zero
    @State private var onChangedAngle: Angle = .zero

    private var displayAngle: Angle {
        switch trackingMode {
        case .updating:
            committedAngle + gestureAngle
        case .onChanged:
            committedAngle + onChangedAngle
        case .both:
            committedAngle + gestureAngle + onChangedAngle
        }
    }

    private var rotateGesture: some Gesture {
        RotateGesture(minimumAngleDelta: .degrees(minimumAngleDelta))
            .updating($gestureAngle) { value, state, _ in
                if trackingMode == .updating || trackingMode == .both {
                    state = value.rotation
                }
            }
            .onChanged { value in
                if trackingMode == .onChanged || trackingMode == .both {
                    onChangedAngle = value.rotation
                }
            }
            .onEnded { value in
                committedAngle += value.rotation
                onChangedAngle = .zero
            }
    }

    var body: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(isEnabled ? DesignSystem.Color.accent : DesignSystem.Color.secondary)
            .frame(width: 140, height: 140)
            .overlay(
                Image(systemName: "arrow.clockwise")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.onAccent)
            )
            .rotationEffect(displayAngle)
            .gesture(rotateGesture, isEnabled: isEnabled)
            .animation(.interactiveSpring, value: displayAngle.degrees)
    }
}
#endif

// MARK: - Static shape for gallery
private struct StaticShape: View {
    let angle: Angle
    let tinted: Bool
    let dimmed: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(tinted ? DesignSystem.Color.accent : DesignSystem.Color.secondary)
            .frame(width: 80, height: 80)
            .overlay(
                Image(systemName: "arrow.clockwise")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.onAccent)
            )
            .rotationEffect(angle)
            .opacity(dimmed ? 0.4 : 1.0)
    }
}

// MARK: - tvOS unavailability notice
private struct UnavailableGestureNotice: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "hand.raised.slash")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.secondary)
            Text("RotateGesture requires iOS 17+ or macOS 14+.\nNot available on tvOS.")
                .font(DesignSystem.Font.callout)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.large)
    }
}

// MARK: - Nested types
extension RotateGestureShowcase {
    fileprivate enum TrackingMode: ShowcasePickable {
        case updating, onChanged, both

        var label: String {
            switch self {
            case .updating: "updating"
            case .onChanged: "onChanged"
            case .both: "both"
            }
        }
    }

    fileprivate enum RotateGestureState: ShowcaseState {
        case `default`, disabled, selected

        var caption: String {
            switch self {
            case .default: "Default"
            case .disabled: "Disabled"
            case .selected: "Rotated 45°"
            }
        }
    }
}

// MARK: - Code generation
private extension RotateGestureShowcase {
    var generatedCode: String {
        let deltaArg = "minimumAngleDelta: .degrees(\(Int(minimumAngleDelta)))"
        let gestureInit = "RotateGesture(\(deltaArg))"
        var lines: [String] = ["struct RotateDemo: View {"]
        switch trackingMode {
        case .updating:
            appendUpdatingBody(into: &lines, gestureInit: gestureInit)
        case .onChanged:
            appendOnChangedBody(into: &lines, gestureInit: gestureInit)
        case .both:
            appendBothBody(into: &lines, gestureInit: gestureInit)
        }
        lines.append("}")
        return lines.joined(separator: "\n")
    }

    func appendUpdatingBody(into lines: inout [String], gestureInit: String) {
        lines.append("    @State private var angle: Angle = .zero")
        lines.append("    @GestureState private var spin: Angle = .zero")
        lines.append("")
        lines.append("    var body: some View {")
        lines.append("        Rectangle()")
        lines.append("            .fill(.blue)")
        lines.append("            .frame(width: 160, height: 160)")
        lines.append("            .rotationEffect(angle + spin)")
        lines.append("            .gesture(")
        lines.append("                \(gestureInit)")
        lines.append("                    .updating($spin) { value, state, _ in state = value.rotation }")
        lines.append("                    .onEnded { value in angle += value.rotation }")
        if !isEnabled {
            lines.append("                ,")
            lines.append("                isEnabled: false")
        }
        lines.append("            )")
        lines.append("    }")
    }

    func appendOnChangedBody(into lines: inout [String], gestureInit: String) {
        lines.append("    @State private var angle: Angle = .zero")
        lines.append("")
        lines.append("    var body: some View {")
        lines.append("        Rectangle()")
        lines.append("            .fill(.blue)")
        lines.append("            .frame(width: 160, height: 160)")
        lines.append("            .rotationEffect(angle)")
        lines.append("            .gesture(")
        lines.append("                \(gestureInit)")
        lines.append("                    .onChanged { value in angle = value.rotation }")
        lines.append("                    .onEnded { value in angle = value.rotation }")
        if !isEnabled {
            lines.append("                ,")
            lines.append("                isEnabled: false")
        }
        lines.append("            )")
        lines.append("    }")
    }

    func appendBothBody(into lines: inout [String], gestureInit: String) {
        lines.append("    @State private var angle: Angle = .zero")
        lines.append("    @GestureState private var spin: Angle = .zero")
        lines.append("")
        lines.append("    var body: some View {")
        lines.append("        Rectangle()")
        lines.append("            .fill(.blue)")
        lines.append("            .frame(width: 160, height: 160)")
        lines.append("            .rotationEffect(angle + spin)")
        lines.append("            .gesture(")
        lines.append("                \(gestureInit)")
        lines.append("                    .updating($spin) { value, state, _ in state = value.rotation }")
        lines.append("                    .onChanged { value in angle = value.rotation }")
        lines.append("                    .onEnded { value in angle += value.rotation }")
        if !isEnabled {
            lines.append("                ,")
            lines.append("                isEnabled: false")
        }
        lines.append("            )")
        lines.append("    }")
    }
}
