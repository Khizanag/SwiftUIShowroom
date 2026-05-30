import SwiftUI

struct GeometryVisualEffectShowcase: View {
    enum EffectOption: ShowcasePickable {
        case offset
        case scaleEffect
        case blur
        case opacity
        case hueRotation

        var label: String {
            switch self {
            case .offset: "offset"
            case .scaleEffect: "scaleEffect"
            case .blur: "blur"
            case .opacity: "opacity"
            case .hueRotation: "hueRotation"
            }
        }
    }

    enum SourceMetric: ShowcasePickable {
        case minY
        case midY
        case width
        case height

        var label: String {
            switch self {
            case .minY: "minY"
            case .midY: "midY"
            case .width: "width"
            case .height: "height"
            }
        }
    }

    enum EffectState: ShowcaseState {
        case parallaxOffset
        case scalePulse
        case distanceFade
        case hueShift

        var caption: String {
            switch self {
            case .parallaxOffset: "Parallax offset"
            case .scalePulse: "Scale pulse"
            case .distanceFade: "Distance fade"
            case .hueShift: "Hue shift"
            }
        }
    }

    @State private var selectedEffect: EffectOption = .scaleEffect
    @State private var selectedMetric: SourceMetric = .minY
    @State private var magnitude: Double = 0.5

    var body: some View {
        ShowcaseScreen(
            title: "Geometry Visual Effect",
            summary: "Drive non-layout visual effects from a view's GeometryProxy without GeometryReader.",
        ) {
            PreviewStage(backdrop: .colorful) { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension GeometryVisualEffectShowcase {
    var preview: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.medium) {
                ForEach(0..<6, id: \.self) { index in
                    sampleCard(index: index)
                        .visualEffect { [selectedEffect, selectedMetric, magnitude] effect, proxy in
                            let raw = rawMetric(proxy: proxy, metric: selectedMetric)
                            return buildEffect(
                                effect,
                                kind: selectedEffect,
                                raw: raw,
                                magnitude: magnitude,
                            )
                        }
                }
            }
            .padding(DesignSystem.Spacing.medium)
        }
        .frame(height: 280)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Effect", selection: $selectedEffect)
        ShowcasePicker("Source metric", selection: $selectedMetric)
        ShowcaseSlider("Magnitude", value: $magnitude, in: 0.0...1.0, step: 0.05)
    }

    @ViewBuilder
    func stateView(_ state: EffectState) -> some View {
        sampleCard(index: 0)
            .visualEffect { effect, proxy in
                let frame = proxy.frame(in: .global)
                return buildStateEffect(effect, frame: frame, state: state)
            }
            .frame(height: 60)
    }

    func sampleCard(index: Int) -> some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .fill(DesignSystem.Color.accent)
                .frame(
                    width: DesignSystem.Size.Icon.medium,
                    height: DesignSystem.Size.Icon.medium,
                )
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.hairline) {
                Text("Card \(index + 1)")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.primary)
                Text("Geometry-driven effect")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
            Spacer()
        }
        .padding(DesignSystem.Spacing.small)
        .background(
            DesignSystem.Color.cardBackground,
            in: .rect(cornerRadius: DesignSystem.CornerRadius.medium),
        )
    }
}

// MARK: - Effect helpers
private extension GeometryVisualEffectShowcase {
    nonisolated func rawMetric(proxy: GeometryProxy, metric: SourceMetric) -> CGFloat {
        let frame = proxy.frame(in: .global)
        switch metric {
        case .minY: return frame.minY
        case .midY: return frame.midY
        case .width: return frame.width
        case .height: return frame.height
        }
    }

    nonisolated func buildEffect(
        _ base: EmptyVisualEffect,
        kind: EffectOption,
        raw: CGFloat,
        magnitude: Double,
    ) -> some VisualEffect {
        let offsetY: CGFloat = kind == .offset ? raw * magnitude * 0.1 : 0
        let scale: CGFloat = kind == .scaleEffect
            ? max(0.5, min(1.5, 1.0 + raw / 1000.0 * magnitude))
            : 1.0
        let blurRadius: CGFloat = kind == .blur
            ? abs(raw) / 200.0 * magnitude * 10.0
            : 0
        let opacityValue: Double = kind == .opacity
            ? max(0.2, min(1.0, 1.0 - abs(raw) / 500.0 * magnitude))
            : 1.0
        let hueDeg: Double = kind == .hueRotation ? raw * magnitude * 0.2 : 0
        return base
            .offset(y: offsetY)
            .scaleEffect(scale)
            .blur(radius: blurRadius)
            .opacity(opacityValue)
            .hueRotation(.degrees(hueDeg))
    }

    nonisolated func buildStateEffect(
        _ base: EmptyVisualEffect,
        frame: CGRect,
        state: EffectState,
    ) -> some VisualEffect {
        let offsetY: CGFloat = state == .parallaxOffset ? frame.minY * 0.05 : 0
        let scale: CGFloat = state == .scalePulse
            ? max(0.8, min(1.2, 1.0 + frame.midY / 1000.0))
            : 1.0
        let alphaValue: Double = state == .distanceFade
            ? max(0.3, min(1.0, 1.0 - abs(frame.minY) / 500.0))
            : 1.0
        let hueDeg: Double = state == .hueShift ? frame.minY * 0.1 : 0
        return base
            .offset(y: offsetY)
            .scaleEffect(scale)
            .opacity(alphaValue)
            .hueRotation(.degrees(hueDeg))
    }
}

// MARK: - Code generation
private extension GeometryVisualEffectShowcase {
    var generatedCode: String {
        let magnitudeStr = magnitude.formatted(.number.precision(.fractionLength(0...2)))
        return effectCodeSnippet(
            effect: selectedEffect,
            metric: selectedMetric,
            magnitude: magnitudeStr,
        )
    }

    func effectCodeSnippet(
        effect: EffectOption,
        metric: SourceMetric,
        magnitude: String,
    ) -> String {
        let body = effectBodyCode(effect: effect, magnitude: magnitude)
        return """
        content
            .visualEffect { effect, proxy in
                let value = proxy.frame(in: .global).\(metric.label)
                return effect
                    \(body)
            }
        """
    }

    func effectBodyCode(effect: EffectOption, magnitude: String) -> String {
        switch effect {
        case .offset:
            return ".offset(y: value * \(magnitude) * 0.1)"
        case .scaleEffect:
            return ".scaleEffect(1 + value / 1000 * \(magnitude))"
        case .blur:
            return ".blur(radius: abs(value) / 200 * \(magnitude) * 10)"
        case .opacity:
            return ".opacity(1 - abs(value) / 500 * \(magnitude))"
        case .hueRotation:
            return ".hueRotation(.degrees(value * \(magnitude) * 0.2))"
        }
    }
}
