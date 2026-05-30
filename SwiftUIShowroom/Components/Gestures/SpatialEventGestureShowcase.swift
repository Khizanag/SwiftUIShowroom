import SwiftUI

struct SpatialEventGestureShowcase: View {
    @State private var coordinateSpace: CoordinateSpaceOption = .local
    @State private var isEnabled: Bool = true

    var body: some View {
        ShowcaseScreen(
            title: "Spatial Event Gesture",
            summary: "Tracks multiple simultaneous spatial events with per-event identity and phase.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension SpatialEventGestureShowcase {
    fileprivate enum CoordinateSpaceOption: ShowcasePickable {
        case local, global

        var label: String {
            switch self {
            case .local: ".local"
            case .global: ".global"
            }
        }

        var codeLabel: String {
            switch self {
            case .local: ".local"
            case .global: ".global"
            }
        }
    }

    fileprivate enum GalleryState: ShowcaseState {
        case `default`, disabled, multiTouch

        var caption: String {
            switch self {
            case .default: "Default"
            case .disabled: "Disabled"
            case .multiTouch: "Multi-touch"
            }
        }
    }
}

// MARK: - Sub-views
private extension SpatialEventGestureShowcase {
    var preview: some View {
        #if os(visionOS)
        liveCanvas
        #else
        platformUnavailableView
        #endif
    }

    var platformUnavailableView: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(DesignSystem.Color.cardBackground)
            .frame(width: 280, height: 200)
            .overlay(
                Text("SpatialEventGesture requires visionOS")
                    .font(DesignSystem.Font.callout)
                    .foregroundStyle(DesignSystem.Color.secondary),
            )
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Coordinate space", selection: $coordinateSpace)
        ShowcaseToggle("Enabled", isOn: $isEnabled)
    }

    @ViewBuilder
    func stateView(_ state: GalleryState) -> some View {
        switch state {
        case .default:
            touchCanvas(points: [], isDisabled: false)
        case .disabled:
            touchCanvas(points: [], isDisabled: true)
        case .multiTouch:
            touchCanvas(
                points: [
                    CGPoint(x: 40, y: 60),
                    CGPoint(x: 100, y: 40),
                    CGPoint(x: 70, y: 100),
                ],
                isDisabled: false,
            )
        }
    }

    func touchCanvas(points: [CGPoint], isDisabled: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(
                    isDisabled
                        ? DesignSystem.Color.cardBackground.opacity(0.5)
                        : DesignSystem.Color.accent.opacity(0.08),
                )
                .frame(width: 160, height: 120)
            if points.isEmpty {
                Text(isDisabled ? "Disabled" : "Touch here")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(
                        isDisabled
                            ? DesignSystem.Color.secondary.opacity(0.5)
                            : DesignSystem.Color.secondary,
                    )
            } else {
                ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                    Circle()
                        .fill(DesignSystem.Color.accent)
                        .frame(width: 16, height: 16)
                        .position(point)
                }
            }
        }
        .frame(width: 160, height: 120)
        .clipped()
    }
}

// MARK: - Live canvas (visionOS only)
#if os(visionOS)
private extension SpatialEventGestureShowcase {
    var liveCanvas: some View {
        LiveSpatialCanvas(
            coordinateSpace: coordinateSpace,
            isEnabled: isEnabled,
        )
    }
}

private struct LiveSpatialCanvas: View {
    let coordinateSpace: SpatialEventGestureShowcase.CoordinateSpaceOption
    let isEnabled: Bool

    @State private var points: [SpatialEventCollection.Event.ID: CGPoint] = [:]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(DesignSystem.Color.accent.opacity(points.isEmpty ? 0.08 : 0.15))
                .frame(width: 280, height: 200)
            if points.isEmpty {
                Text(isEnabled ? "Touch the canvas" : "Gesture disabled")
                    .font(DesignSystem.Font.callout)
                    .foregroundStyle(DesignSystem.Color.secondary)
            } else {
                Canvas { context, _ in
                    for point in points.values {
                        let rect = CGRect(
                            x: point.x - 12,
                            y: point.y - 12,
                            width: 24,
                            height: 24,
                        )
                        context.fill(
                            Path(ellipseIn: rect),
                            with: .color(DesignSystem.Color.accent),
                        )
                    }
                }
                .frame(width: 280, height: 200)
            }
        }
        .frame(width: 280, height: 200)
        .clipped()
        .gesture(
            SpatialEventGesture(coordinateSpace: resolvedCoordinateSpace)
                .onChanged { events in
                    for event in events {
                        switch event.phase {
                        case .active:
                            points[event.id] = event.location
                        default:
                            points.removeValue(forKey: event.id)
                        }
                    }
                }
                .onEnded { _ in
                    points.removeAll()
                },
            isEnabled: isEnabled,
        )
    }

    private var resolvedCoordinateSpace: CoordinateSpace {
        switch coordinateSpace {
        case .local: .local
        case .global: .global
        }
    }
}
#endif

// MARK: - Code generation
private extension SpatialEventGestureShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("// SpatialEventGesture is available on visionOS only.")
        lines.append("@State private var points: [SpatialEventCollection.Event.ID: CGPoint] = [:]")
        lines.append("")
        lines.append("Canvas { context, _ in")
        lines.append("    for point in points.values {")
        lines.append("        context.fill(")
        lines.append("            Path(ellipseIn: CGRect(x: point.x - 8, y: point.y - 8, width: 16, height: 16)),")
        lines.append("            with: .color(.blue),")
        lines.append("        )")
        lines.append("    }")
        lines.append("}")
        lines.append(".gesture(")
        lines.append("    SpatialEventGesture(coordinateSpace: \(coordinateSpace.codeLabel))")
        lines.append("        .onChanged { events in")
        lines.append("            for event in events {")
        lines.append("                switch event.phase {")
        lines.append("                case .active:")
        lines.append("                    points[event.id] = event.location")
        lines.append("                default:")
        lines.append("                    points.removeValue(forKey: event.id)")
        lines.append("                }")
        lines.append("            }")
        lines.append("        }")
        lines.append("        .onEnded { _ in points.removeAll() },")
        if !isEnabled {
            lines.append("    isEnabled: false,")
        }
        lines.append(")")
        return lines.joined(separator: "\n")
    }
}
