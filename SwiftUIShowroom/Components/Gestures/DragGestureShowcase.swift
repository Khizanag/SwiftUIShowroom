import SwiftUI

struct DragGestureShowcase: View {
    @State private var minimumDistance: Double = 10
    @State private var coordinateSpace: CoordinateSpaceOption = .local
    @State private var trackingMode: TrackingMode = .updating
    @State private var showVelocity = false
    @State private var isEnabled = true

    @GestureState private var liveTranslation: CGSize = .zero
    @State private var committedOffset: CGSize = .zero
    @State private var lastVelocity: CGSize = .zero
    @State private var lastPredicted: CGSize = .zero

    var body: some View {
        ShowcaseScreen(
            title: "Drag Gesture",
            summary: "Tracks a continuous dragging motion, reporting translation, location, and velocity.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension DragGestureShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            gestureTarget
            if showVelocity {
                velocityReadout
            }
        }
    }

    @ViewBuilder var gestureTarget: some View {
        #if os(tvOS)
        unavailableNotice
        #else
        attachedCard
        #endif
    }

    #if !os(tvOS)
    @ViewBuilder var attachedCard: some View {
        let offsetX = committedOffset.width + (trackingMode != .onChanged ? liveTranslation.width : 0)
        let offsetY = committedOffset.height + (trackingMode != .onChanged ? liveTranslation.height : 0)
        switch trackingMode {
        case .updating:
            baseCard
                .offset(x: offsetX, y: offsetY)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: liveTranslation)
                .gesture(
                    DragGesture(minimumDistance: minimumDistance)
                        .updating($liveTranslation) { value, state, _ in
                            state = value.translation
                        }
                        .onEnded { value in
                            recordVelocity(from: value)
                        },
                    isEnabled: isEnabled
                )
        case .onChanged:
            baseCard
                .offset(x: offsetX, y: offsetY)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: committedOffset)
                .gesture(
                    DragGesture(minimumDistance: minimumDistance)
                        .onChanged { value in
                            committedOffset = value.translation
                            recordVelocity(from: value)
                        }
                        .onEnded { value in
                            committedOffset = value.translation
                            recordVelocity(from: value)
                        },
                    isEnabled: isEnabled
                )
        case .both:
            baseCard
                .offset(x: offsetX, y: offsetY)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: liveTranslation)
                .gesture(
                    DragGesture(minimumDistance: minimumDistance)
                        .updating($liveTranslation) { value, state, _ in
                            state = value.translation
                        }
                        .onChanged { value in
                            recordVelocity(from: value)
                        }
                        .onEnded { value in
                            committedOffset.width += value.translation.width
                            committedOffset.height += value.translation.height
                            recordVelocity(from: value)
                        },
                    isEnabled: isEnabled
                )
        }
    }

    func recordVelocity(from value: DragGesture.Value) {
        lastVelocity = value.velocity
        lastPredicted = value.predictedEndTranslation
    }
    #endif

    var baseCard: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
            .fill(isEnabled ? AnyShapeStyle(DesignSystem.Color.accent) : AnyShapeStyle(DesignSystem.Color.secondary))
            .frame(width: 100, height: 100)
            .overlay(
                Image(systemName: "arrow.up.and.down.and.left.and.right")
                    .foregroundStyle(.white)
                    .font(DesignSystem.Font.title2)
            )
    }

    var velocityReadout: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("velocity: (\(Int(lastVelocity.width)), \(Int(lastVelocity.height)))")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            Text("predicted: (\(Int(lastPredicted.width)), \(Int(lastPredicted.height)))")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var unavailableNotice: some View {
        Text("DragGesture is not available on tvOS")
            .font(DesignSystem.Font.callout)
            .foregroundStyle(DesignSystem.Color.secondary)
            .padding(DesignSystem.Spacing.large)
    }

    @ViewBuilder var controls: some View {
        ShowcaseSlider("Minimum distance", value: $minimumDistance, in: 0...100, step: 1)
        ShowcasePicker("Coordinate space", selection: $coordinateSpace)
        ShowcasePicker("Tracking mode", selection: $trackingMode)
        ShowcaseToggle("Show velocity", isOn: $showVelocity)
        ShowcaseToggle("Enabled", isOn: $isEnabled)
    }

    @ViewBuilder func stateView(_ state: DragGestureState) -> some View {
        switch state {
        case .default:
            staticCard(fill: AnyShapeStyle(DesignSystem.Color.accent), label: "Drag me")
        case .disabled:
            staticCard(fill: AnyShapeStyle(DesignSystem.Color.secondary), label: "Disabled")
                .opacity(0.5)
        case .selected:
            staticCard(fill: AnyShapeStyle(Color.green), label: "Dragging")
                .offset(x: 12, y: -12)
                .shadow(radius: 8)
        case .longContent:
            VStack(spacing: DesignSystem.Spacing.xSmall) {
                staticCard(fill: AnyShapeStyle(DesignSystem.Color.accent), label: "Drag list")
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .fill(DesignSystem.Color.cardBackground)
                        .frame(height: 32)
                        .opacity(1.0 - Double(index) * 0.25)
                }
            }
        }
    }

    func staticCard(fill: AnyShapeStyle, label: String) -> some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
            .fill(fill)
            .frame(width: 80, height: 80)
            .overlay(
                Text(label)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(.white)
            )
    }
}

// MARK: - Nested types
extension DragGestureShowcase {
    fileprivate enum CoordinateSpaceOption: ShowcasePickable {
        case local
        case global
        case named

        var label: String {
            switch self {
            case .local: ".local"
            case .global: ".global"
            case .named: ".named(\"canvas\")"
            }
        }

        var codeString: String { label }
    }

    fileprivate enum TrackingMode: ShowcasePickable {
        case updating
        case onChanged
        case both

        var label: String {
            switch self {
            case .updating: "updating"
            case .onChanged: "onChanged"
            case .both: "both"
            }
        }
    }

    fileprivate enum DragGestureState: ShowcaseState {
        case `default`
        case disabled
        case selected
        case longContent

        var caption: String {
            switch self {
            case .default: "Default"
            case .disabled: "Disabled"
            case .selected: "Dragging"
            case .longContent: "Scrollable content"
            }
        }
    }
}

// MARK: - Code generation
private extension DragGestureShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("@GestureState private var drag: CGSize = .zero")
        lines.append("@State private var offset: CGSize = .zero")
        lines.append("")
        lines.append("RoundedRectangle(cornerRadius: 16)")
        lines.append("    .fill(.blue)")
        lines.append("    .frame(width: 100, height: 100)")
        lines.append("    .offset(x: offset.width + drag.width, y: offset.height + drag.height)")
        lines.append("    .gesture(")
        let minDistance = Int(minimumDistance)
        let dragInit = "DragGesture(minimumDistance: \(minDistance), coordinateSpace: \(coordinateSpace.codeString))"
        lines.append("        \(dragInit)")
        appendTrackingLines(into: &lines)
        lines.append("    )")
        if !isEnabled {
            lines.append("    // note: attach with gesture(_:isEnabled: false) to disable")
        }
        return lines.joined(separator: "\n")
    }

    func appendTrackingLines(into lines: inout [String]) {
        switch trackingMode {
        case .updating:
            lines.append("            .updating($drag) { value, state, _ in state = value.translation }")
            lines.append("            .onEnded { value in")
            lines.append("                offset.width += value.translation.width")
            lines.append("                offset.height += value.translation.height")
            lines.append("            }")
        case .onChanged:
            lines.append("            .onChanged { value in offset = value.translation }")
            lines.append("            .onEnded { value in offset = value.translation }")
        case .both:
            lines.append("            .updating($drag) { value, state, _ in state = value.translation }")
            lines.append("            .onChanged { value in }")
            lines.append("            .onEnded { value in")
            lines.append("                offset.width += value.translation.width")
            lines.append("                offset.height += value.translation.height")
            lines.append("            }")
        }
        if showVelocity {
            lines.append("            // value.velocity / value.predictedEndTranslation in onChanged / onEnded")
        }
    }
}
