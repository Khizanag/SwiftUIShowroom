import SwiftUI

struct ShaderEffectShowcase: View {
    enum EffectKind: String, ShowcasePickable, CaseIterable {
        case colorEffect
        case layerEffect
        case distortionEffect

        var label: String {
            switch self {
            case .colorEffect: "colorEffect"
            case .layerEffect: "layerEffect"
            case .distortionEffect: "distortionEffect"
            }
        }

        var signature: String {
            switch self {
            case .colorEffect: "half4 fn(float2 pos, half4 color, …)"
            case .layerEffect: "half4 fn(float2 pos, SwiftUI::Layer layer, …)"
            case .distortionEffect: "float2 fn(float2 pos, …)"
            }
        }
    }

    @State private var effectKind: EffectKind = .colorEffect
    @State private var maxSampleOffset: Double = 20
    @State private var isEnabled: Bool = true
    @State private var uniform: Double = 1.0

    var body: some View {
        ShowcaseScreen(
            title: "Metal Shader Effect",
            summary: "Custom Metal shader as a per-pixel color filter, layer effect, or distortion.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ShaderEffectShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            previewContent(kind: effectKind, uniformValue: uniform, active: isEnabled)
            Text(effectKind.signature)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.large)
    }

    @ViewBuilder
    func previewContent(kind: EffectKind, uniformValue: Double, active: Bool) -> some View {
        switch kind {
        case .colorEffect:
            sampleImage
                .hueRotation(.degrees(active ? uniformValue * 36 : 0))
                .saturation(active ? uniformValue : 1.0)
        case .layerEffect:
            sampleImage
                .blur(radius: active ? uniformValue * 2 : 0, opaque: false)
                .brightness(active ? (uniformValue - 1.0) * 0.1 : 0)
        case .distortionEffect:
            sampleImage
                .offset(
                    x: active ? sin(uniformValue) * 8 : 0,
                    y: active ? cos(uniformValue) * 8 : 0,
                )
                .scaleEffect(active ? 1.0 + (uniformValue - 1.0) * 0.05 : 1.0)
        }
    }

    var sampleImage: some View {
        ZStack {
            LinearGradient(
                colors: [.purple, .blue, .cyan],
                startPoint: .topLeading,
                endPoint: .bottomTrailing,
            )
            Image(systemName: "wand.and.stars")
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .frame(
                    width: DesignSystem.Size.Icon.xLarge,
                    height: DesignSystem.Size.Icon.xLarge,
                )
                .foregroundStyle(.white)
        }
        .frame(width: 120, height: 120)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Effect kind", selection: $effectKind)
        ShowcaseSlider("Uniform value", value: $uniform, in: 0.0...10.0, step: 0.1)
        ShowcaseSlider("Max sample offset", value: $maxSampleOffset, in: 0...100, step: 1)
        ShowcaseToggle("Enabled", isOn: $isEnabled)
    }

    @ViewBuilder func stateView(_ state: EnabledState) -> some View {
        let active = state == .enabled
        previewContent(kind: effectKind, uniformValue: uniform, active: active)
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Code generation
private extension ShaderEffectShowcase {
    var generatedCode: String {
        let uniformStr = String(format: "%.1f", uniform)
        let offsetStr = String(format: "%.0f", maxSampleOffset)
        switch effectKind {
        case .colorEffect:
            return [
                "image",
                "    .colorEffect(",
                "        ShaderLibrary.default.myColorShader(.float(\(uniformStr))),",
                "        isEnabled: \(isEnabled)",
                "    )",
            ].joined(separator: "\n")
        case .layerEffect:
            return [
                "image",
                "    .layerEffect(",
                "        ShaderLibrary.default.myLayerShader(.float(\(uniformStr))),",
                "        maxSampleOffset: CGSize(width: \(offsetStr), height: \(offsetStr)),",
                "        isEnabled: \(isEnabled)",
                "    )",
            ].joined(separator: "\n")
        case .distortionEffect:
            return [
                "image",
                "    .distortionEffect(",
                "        ShaderLibrary.default.myDistortionShader(.float(\(uniformStr))),",
                "        maxSampleOffset: CGSize(width: \(offsetStr), height: \(offsetStr)),",
                "        isEnabled: \(isEnabled)",
                "    )",
            ].joined(separator: "\n")
        }
    }
}
