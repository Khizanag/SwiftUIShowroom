import SwiftUI

struct TapGestureShowcase: View {
    @State private var tapCount = 1
    @State private var attachMode: AttachMode = .gesture
    @State private var isEnabled = true
    @State private var tapFired = 0

    enum AttachMode: ShowcasePickable {
        case gesture
        case onTapGesture
        case highPriorityGesture
        case simultaneousGesture

        var label: String {
            switch self {
            case .gesture: ".gesture(_:)"
            case .onTapGesture: ".onTapGesture"
            case .highPriorityGesture: ".highPriorityGesture"
            case .simultaneousGesture: ".simultaneousGesture"
            }
        }
    }

    enum TapGestureState: ShowcaseState {
        case `default`
        case disabled
        case selected

        var caption: String {
            switch self {
            case .default: "Default"
            case .disabled: "Disabled"
            case .selected: "Selected (tapped)"
            }
        }
    }

    var body: some View {
        ShowcaseScreen(
            title: "Tap Gesture",
            summary: "Recognizes one or more taps (or clicks) and fires on completion.",
        ) {
            PreviewStage {
                preview
            }
            ShowcaseSection("Configuration") {
                controls
            }
            ShowcaseSection("States") {
                StateGallery(content: stateView)
            }
            ShowcaseSection("Generated code") {
                CodeBlock(code: generatedCode)
            }
        }
    }
}

// MARK: - Sub-views
private extension TapGestureShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            tapTarget(
                fireCount: tapFired,
                isGestureEnabled: isEnabled,
                requiredTaps: tapCount,
                mode: attachMode,
            )
            Text(tapFired == 0 ? "Tap the circle" : "Tapped \(tapFired) time\(tapFired == 1 ? "" : "s")")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }

    @ViewBuilder
    func tapTarget(
        fireCount: Int,
        isGestureEnabled: Bool,
        requiredTaps: Int,
        mode: AttachMode,
    ) -> some View {
        let hue = Double(fireCount % 6) / 6.0
        let fill = fireCount == 0
            ? AnyShapeStyle(DesignSystem.Color.accent)
            : AnyShapeStyle(Color(hue: hue, saturation: 0.7, brightness: 0.85))
        let circle = Circle()
            .fill(fill)
            .frame(width: 120, height: 120)
            .scaleEffect(fireCount > 0 ? 1.05 : 1.0)
            .animation(.spring(duration: 0.2), value: fireCount)
            .overlay(
                Text("\(requiredTaps == 1 ? "Tap" : "\(requiredTaps)×")")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.onAccent),
            )
            .accessibilityLabel("Tap target, tapped \(fireCount) times")
        attachedCircle(circle, mode: mode, requiredTaps: requiredTaps, isGestureEnabled: isGestureEnabled)
    }

    @ViewBuilder
    func attachedCircle(
        _ base: some View,
        mode: AttachMode,
        requiredTaps: Int,
        isGestureEnabled: Bool,
    ) -> some View {
        switch mode {
        case .onTapGesture:
            #if os(iOS) || os(macOS)
            base
                .onTapGesture(count: requiredTaps) {
                    guard isGestureEnabled else { return }
                    tapFired += 1
                }
                .opacity(isGestureEnabled ? 1 : 0.4)
            #else
            base
                .onTapGesture {
                    guard isGestureEnabled else { return }
                    tapFired += 1
                }
                .opacity(isGestureEnabled ? 1 : 0.4)
            #endif
        case .gesture:
            base
                .gesture(
                    TapGesture(count: requiredTaps).onEnded { tapFired += 1 },
                    isEnabled: isGestureEnabled,
                )
        case .highPriorityGesture:
            base
                .highPriorityGesture(
                    TapGesture(count: requiredTaps).onEnded { tapFired += 1 },
                    isEnabled: isGestureEnabled,
                )
        case .simultaneousGesture:
            base
                .simultaneousGesture(
                    TapGesture(count: requiredTaps).onEnded { tapFired += 1 },
                    isEnabled: isGestureEnabled,
                )
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseStepper("Required taps", value: $tapCount, in: 1...5)
        ShowcasePicker("Attach mode", selection: $attachMode)
        ShowcaseToggle("Gesture enabled", isOn: $isEnabled)
    }

    @ViewBuilder
    func stateView(_ state: TapGestureState) -> some View {
        switch state {
        case .default:
            staticTarget(fireCount: 0, isActive: false)
        case .disabled:
            staticTarget(fireCount: 0, isActive: false)
                .opacity(0.4)
        case .selected:
            staticTarget(fireCount: 3, isActive: true)
        }
    }

    func staticTarget(fireCount: Int, isActive: Bool) -> some View {
        let hue = Double(fireCount % 6) / 6.0
        let fill = fireCount == 0
            ? AnyShapeStyle(DesignSystem.Color.accent)
            : AnyShapeStyle(Color(hue: hue, saturation: 0.7, brightness: 0.85))
        return Circle()
            .fill(fill)
            .frame(width: 80, height: 80)
            .scaleEffect(isActive ? 1.05 : 1.0)
            .overlay(
                Text(fireCount == 0 ? "Tap" : "\(fireCount)×")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.onAccent),
            )
            .accessibilityLabel("Tap target")
    }
}

// MARK: - Code generation
private extension TapGestureShowcase {
    var generatedCode: String {
        switch attachMode {
        case .onTapGesture:
            return onTapGestureCode
        case .gesture:
            return explicitGestureCode(modifier: "gesture")
        case .highPriorityGesture:
            return explicitGestureCode(modifier: "highPriorityGesture")
        case .simultaneousGesture:
            return explicitGestureCode(modifier: "simultaneousGesture")
        }
    }

    var onTapGestureCode: String {
        var lines = [
            "Circle()",
            "    .fill(.blue)",
            "    .frame(width: 120, height: 120)",
        ]
        let countArg = tapCount == 1 ? "" : "count: \(tapCount)"
        let call = countArg.isEmpty ? ".onTapGesture {" : ".onTapGesture(\(countArg)) {"
        lines.append("    \(call)")
        lines.append("        tapCount += 1")
        lines.append("    }")
        if !isEnabled {
            lines.append("    .disabled(true)")
        }
        return lines.joined(separator: "\n")
    }

    func explicitGestureCode(modifier: String) -> String {
        let countArg = tapCount == 1 ? "" : "count: \(tapCount)"
        let gestureInit = countArg.isEmpty ? "TapGesture()" : "TapGesture(\(countArg))"
        return [
            "Circle()",
            "    .fill(.blue)",
            "    .frame(width: 120, height: 120)",
            "    .\(modifier)(",
            "        \(gestureInit)",
            "            .onEnded { tapCount += 1 },",
            "        isEnabled: \(isEnabled)",
            "    )",
        ].joined(separator: "\n")
    }
}
