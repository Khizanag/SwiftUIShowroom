import SwiftUI

struct GlassEffectShowcase: View {
    @State private var variant: GlassVariant = .regular
    @State private var tint: Color = .accentColor
    @State private var hasTint = false
    @State private var isInteractive = false
    @State private var shape: GlassShape = .capsule
    @State private var cornerRadius: Double = 20

    enum GlassVariant: ShowcasePickable {
        case regular
        case clear
        case identity

        var label: String {
            switch self {
            case .regular: "regular"
            case .clear: "clear"
            case .identity: "identity"
            }
        }
    }

    enum GlassShape: ShowcasePickable {
        case capsule
        case roundedRectangle
        case circle
        case rectangle

        var label: String {
            switch self {
            case .capsule: "Capsule"
            case .roundedRectangle: "RoundedRectangle"
            case .circle: "Circle"
            case .rectangle: "Rectangle"
            }
        }
    }

    enum GlassState: ShowcaseState {
        case defaultState
        case selected
        case disabled
        case longContent

        var caption: String {
            switch self {
            case .defaultState: "Default"
            case .selected: "Selected"
            case .disabled: "Disabled"
            case .longContent: "Long content"
            }
        }
    }

    struct GlassConfig {
        var labelText: String
        var variant: GlassVariant
        var tintColor: Color?
        var interactive: Bool
        var glassShape: GlassShape
        var radius: Double
        var isEnabled: Bool
    }

    var body: some View {
        ShowcaseScreen(
            title: "Glass Effect",
            summary: "Applies the Liquid Glass material to a view, clipping it to a shape.",
        ) {
            PreviewStage(backdrop: .colorful) {
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
private extension GlassEffectShowcase {
    var preview: some View {
        glassView(GlassConfig(
            labelText: "Hello",
            variant: variant,
            tintColor: hasTint ? tint : nil,
            interactive: isInteractive,
            glassShape: shape,
            radius: cornerRadius,
            isEnabled: true,
        ))
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Variant", selection: $variant)
        ShowcaseToggle("Apply tint", isOn: $hasTint)
        if hasTint {
            ShowcaseColorControl("Tint color", selection: $tint, supportsOpacity: false)
        }
        ShowcaseToggle("Interactive", isOn: $isInteractive)
        ShowcasePicker("Shape", selection: $shape)
        if shape == .roundedRectangle {
            ShowcaseSlider("Corner radius", value: $cornerRadius, in: 0...60, step: 1)
        }
    }

    @ViewBuilder
    func stateView(_ state: GlassState) -> some View {
        switch state {
        case .defaultState:
            glassView(GlassConfig(
                labelText: "Hello",
                variant: .regular,
                tintColor: nil,
                interactive: false,
                glassShape: .capsule,
                radius: 20,
                isEnabled: true,
            ))
        case .selected:
            glassView(GlassConfig(
                labelText: "Selected",
                variant: .regular,
                tintColor: .accentColor,
                interactive: true,
                glassShape: .capsule,
                radius: 20,
                isEnabled: true,
            ))
        case .disabled:
            glassView(GlassConfig(
                labelText: "Disabled",
                variant: .regular,
                tintColor: nil,
                interactive: false,
                glassShape: .capsule,
                radius: 20,
                isEnabled: false,
            ))
        case .longContent:
            glassView(GlassConfig(
                labelText: "Long content label",
                variant: .clear,
                tintColor: nil,
                interactive: false,
                glassShape: .roundedRectangle,
                radius: 16,
                isEnabled: true,
            ))
        }
    }
}
// MARK: - Helpers
private extension GlassEffectShowcase {
    @ViewBuilder
    func glassView(_ config: GlassConfig) -> some View {
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, *) {
            glassContent(config)
        } else {
            fallbackView(labelText: config.labelText, isEnabled: config.isEnabled)
        }
    }

    @available(iOS 26.0, macOS 26.0, tvOS 26.0, *)
    @ViewBuilder
    func glassContent(_ config: GlassConfig) -> some View {
        let glass = resolvedGlass(
            variant: config.variant,
            tintColor: config.tintColor,
            interactive: config.interactive,
        )
        let base = Text(config.labelText)
            .font(DesignSystem.Font.title2)
            .padding(DesignSystem.Spacing.medium)
        glassInShape(base, glass: glass, config: config)
    }

    @available(iOS 26.0, macOS 26.0, tvOS 26.0, *)
    @ViewBuilder
    func glassInShape(
        _ base: some View,
        glass: Glass,
        config: GlassConfig,
    ) -> some View {
        let opacity: Double = config.isEnabled ? 1 : 0.4
        switch config.glassShape {
        case .capsule:
            base
                .glassEffect(glass, in: .capsule)
                .disabled(!config.isEnabled)
                .opacity(opacity)
        case .roundedRectangle:
            base
                .glassEffect(glass, in: .rect(cornerRadius: config.radius))
                .disabled(!config.isEnabled)
                .opacity(opacity)
        case .circle:
            base
                .glassEffect(glass, in: .circle)
                .disabled(!config.isEnabled)
                .opacity(opacity)
        case .rectangle:
            base
                .glassEffect(glass, in: .rect)
                .disabled(!config.isEnabled)
                .opacity(opacity)
        }
    }

    @available(iOS 26.0, macOS 26.0, tvOS 26.0, *)
    func resolvedGlass(variant: GlassVariant, tintColor: Color?, interactive: Bool) -> Glass {
        let base: Glass
        switch variant {
        case .regular: base = .regular
        case .clear: base = .clear
        case .identity: base = .identity
        }
        let tinted = tintColor.map { base.tint($0) } ?? base
        return tinted.interactive(interactive)
    }

    func fallbackView(labelText: String, isEnabled: Bool) -> some View {
        Text(labelText)
            .font(DesignSystem.Font.title2)
            .padding(DesignSystem.Spacing.medium)
            .background(DesignSystem.Color.cardBackground, in: .capsule)
            .opacity(isEnabled ? 1 : 0.4)
    }
}
// MARK: - Code generation
private extension GlassEffectShowcase {
    var generatedCode: String {
        [
            "Text(\"Hello\")",
            "    .font(.title2)",
            "    .padding()",
            "    .glassEffect(",
            "        \(glassExpression),",
            "        in: \(shapeCode)",
            "    )",
        ].joined(separator: "\n")
    }

    var glassExpression: String {
        var expr = ".\(variant.label)"
        if hasTint {
            expr += "\n            .tint(/* your color */)"
        }
        if isInteractive {
            expr += "\n            .interactive(true)"
        }
        return expr
    }

    var shapeCode: String {
        switch shape {
        case .capsule: return ".capsule"
        case .roundedRectangle: return ".rect(cornerRadius: \(Int(cornerRadius)))"
        case .circle: return ".circle"
        case .rectangle: return ".rect"
        }
    }
}
