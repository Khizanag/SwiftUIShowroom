import SwiftUI

struct MagnifyGestureShowcase: View {
    @State private var minimumScaleDelta: Double = 0.01
    @State private var trackingMode: TrackingMode = .onChanged
    @State private var isEnabled: Bool = true
    @State private var committedScale: CGFloat = 1.0
#if !os(tvOS)
    @GestureState private var liveScale: CGFloat = 1.0
#endif

    var body: some View {
        ShowcaseScreen(
            title: "Magnify Gesture",
            summary: "Recognizes a pinch and tracks the magnification scale factor and anchor.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension MagnifyGestureShowcase {
    var effectiveScale: CGFloat {
#if os(tvOS)
        committedScale
#else
        switch trackingMode {
        case .updating: liveScale
        case .onChanged: committedScale
        case .both: committedScale * liveScale
        }
#endif
    }

    var preview: some View {
        previewContent
            .allowsHitTesting(isEnabled)
    }

    @ViewBuilder
    var previewContent: some View {
#if os(tvOS)
        previewImage
#else
        switch trackingMode {
        case .updating:
            previewImage
                .gesture(
                    MagnifyGesture(minimumScaleDelta: minimumScaleDelta)
                        .updating($liveScale) { value, state, _ in
                            state = value.magnification
                        }
                )
        case .onChanged:
            previewImage
                .gesture(
                    MagnifyGesture(minimumScaleDelta: minimumScaleDelta)
                        .onChanged { value in
                            committedScale = clamped(value.magnification)
                        }
                        .onEnded { value in
                            committedScale = clamped(value.magnification)
                        }
                )
        case .both:
            previewImage
                .gesture(
                    MagnifyGesture(minimumScaleDelta: minimumScaleDelta)
                        .updating($liveScale) { value, state, _ in
                            state = value.magnification
                        }
                        .onEnded { value in
                            committedScale = clamped(committedScale * value.magnification)
                        }
                )
        }
#endif
    }

    var previewImage: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .scaleEffect(effectiveScale)
                .foregroundStyle(
                    isEnabled ? DesignSystem.Color.accent : DesignSystem.Color.secondary
                )
                .padding(DesignSystem.Spacing.xLarge)
            Text(String(format: "%.2f×", effectiveScale))
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }

    func clamped(_ value: CGFloat) -> CGFloat {
        min(5.0, max(0.25, value))
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseSlider(
            "Min scale delta",
            value: $minimumScaleDelta,
            in: 0...0.5,
            step: 0.01
        )
#if !os(tvOS)
        ShowcasePicker("Tracking mode", selection: $trackingMode)
#endif
        ShowcaseToggle("Enabled", isOn: $isEnabled)
    }

    @ViewBuilder
    func stateView(_ state: GestureShowcaseState) -> some View {
        switch state {
        case .default:
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(DesignSystem.Color.accent)
        case .disabled:
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(DesignSystem.Color.secondary)
                .opacity(0.4)
        case .scaled:
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(DesignSystem.Color.accent)
                .scaleEffect(1.6)
        }
    }
}

// MARK: - Nested types
extension MagnifyGestureShowcase {
    enum TrackingMode: ShowcasePickable {
        case updating, onChanged, both

        var label: String {
            switch self {
            case .updating: "updating"
            case .onChanged: "onChanged"
            case .both: "both"
            }
        }
    }

    enum GestureShowcaseState: ShowcaseState {
        case `default`, disabled, scaled

        var caption: String {
            switch self {
            case .default: "Default"
            case .disabled: "Disabled"
            case .scaled: "Scaled"
            }
        }
    }
}

// MARK: - Code generation
private extension MagnifyGestureShowcase {
    var generatedCode: String {
        let deltaStr = String(format: "%.2f", minimumScaleDelta)
#if os(tvOS)
        let stateBlock = "    @State private var scale: CGFloat = 1.0"
        let scaleExpr = "scale"
        let trackingLines = "            .onEnded { value in scale = value.magnification }"
#else
        let stateBlock: String
        let scaleExpr: String
        let trackingLines: String
        switch trackingMode {
        case .updating:
            stateBlock = "    @State private var scale: CGFloat = 1.0\n" +
                "    @GestureState private var pinch: CGFloat = 1.0"
            scaleExpr = "scale * pinch"
            trackingLines =
                "            .updating($pinch) { value, state, _ in" +
                " state = value.magnification }\n" +
                "            .onEnded { value in scale *= value.magnification }"
        case .onChanged:
            stateBlock = "    @State private var scale: CGFloat = 1.0"
            scaleExpr = "scale"
            trackingLines =
                "            .onChanged { value in scale = value.magnification }\n" +
                "            .onEnded { value in scale = value.magnification }"
        case .both:
            stateBlock = "    @State private var scale: CGFloat = 1.0\n" +
                "    @GestureState private var pinch: CGFloat = 1.0"
            scaleExpr = "scale * pinch"
            trackingLines =
                "            .updating($pinch) { value, state, _ in" +
                " state = value.magnification }\n" +
                "            .onEnded { value in scale *= value.magnification }"
        }
#endif
        let disabledLine = isEnabled ? "" : "\n        .allowsHitTesting(false)"
        return """
        struct MagnifyDemo: View {
        \(stateBlock)

            var body: some View {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .scaleEffect(\(scaleExpr))
                    .gesture(
                        MagnifyGesture(minimumScaleDelta: \(deltaStr))
        \(trackingLines)
                    )\(disabledLine)
            }
        }
        """
    }
}
