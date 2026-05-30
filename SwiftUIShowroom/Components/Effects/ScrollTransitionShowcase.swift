import SwiftUI

struct ScrollTransitionShowcase: View {
    enum TransitionConfig: String, ShowcasePickable, CaseIterable {
        case interactive, animated, identity

        var label: String {
            switch self {
            case .interactive: ".interactive"
            case .animated: ".animated"
            case .identity: ".identity"
            }
        }

        var value: ScrollTransitionConfiguration {
            switch self {
            case .interactive: return .interactive
            case .animated: return .animated
            case .identity: return .identity
            }
        }

        var codeName: String {
            switch self {
            case .interactive: return ".interactive"
            case .animated: return ".animated"
            case .identity: return ".identity"
            }
        }
    }

    enum AxisOption: String, ShowcasePickable, CaseIterable {
        case automatic, horizontal, vertical

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .horizontal: ".horizontal"
            case .vertical: ".vertical"
            }
        }

        var axisValue: Axis? {
            switch self {
            case .automatic: return nil
            case .horizontal: return .horizontal
            case .vertical: return .vertical
            }
        }

        var codeName: String {
            switch self {
            case .automatic: return "nil"
            case .horizontal: return ".horizontal"
            case .vertical: return ".vertical"
            }
        }
    }

    enum EffectKind: String, ShowcasePickable, CaseIterable {
        case opacity, scale, blur, rotation3D

        var label: String {
            switch self {
            case .opacity: "opacity"
            case .scale: "scaleEffect"
            case .blur: "blur"
            case .rotation3D: "rotation3D"
            }
        }
    }

    enum TransitionState: ShowcaseState, CaseIterable {
        case opacityEffect
        case scaleEffect
        case blurEffect
        case rotation3DEffect

        var caption: String {
            switch self {
            case .opacityEffect: "opacity"
            case .scaleEffect: "scaleEffect"
            case .blurEffect: "blur"
            case .rotation3DEffect: "rotation3D"
            }
        }
    }

    @State private var configuration: TransitionConfig = .interactive
    @State private var axisOption: AxisOption = .automatic
    @State private var effectKind: EffectKind = .opacity
    @State private var identityScale: Double = 0.8

    var body: some View {
        ShowcaseScreen(
            title: "Scroll Transition",
            summary: "Applies visual effects to a view based on its position in the scroll view.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ScrollTransitionShowcase {
    var preview: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: DesignSystem.Spacing.medium) {
                ForEach(0..<12, id: \.self) { index in
                    previewRow(index: index)
                }
            }
            .padding(DesignSystem.Spacing.medium)
        }
        .frame(maxHeight: 320)
    }

    func previewRow(index: Int) -> some View {
        let scaleFactor = identityScale
        let kind = effectKind
        let config = configuration.value
        let axis = axisOption.axisValue
        return RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(Color.accentColor.opacity(0.15 + Double(index % 4) * 0.1))
            .frame(height: 64)
            .overlay {
                Text("Row \(index + 1)")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.primary)
            }
            .scrollTransition(config, axis: axis) { content, phase in
                content
                    .opacity(rowOpacity(kind: kind, isIdentity: phase.isIdentity))
                    .scaleEffect(rowScale(kind: kind, isIdentity: phase.isIdentity, scaleFactor: scaleFactor))
                    .blur(radius: rowBlur(kind: kind, isIdentity: phase.isIdentity))
            }
    }

    func rowOpacity(kind: EffectKind, isIdentity: Bool) -> Double {
        guard !isIdentity else { return 1 }
        switch kind {
        case .opacity: return 0
        case .scale: return 0.4
        case .blur: return 0.5
        case .rotation3D: return 0.3
        }
    }

    func rowScale(kind: EffectKind, isIdentity: Bool, scaleFactor: Double) -> Double {
        guard !isIdentity else { return 1 }
        switch kind {
        case .opacity: return 1
        case .scale: return scaleFactor
        case .blur: return 1
        case .rotation3D: return scaleFactor
        }
    }

    func rowBlur(kind: EffectKind, isIdentity: Bool) -> CGFloat {
        guard !isIdentity, kind == .blur else { return 0 }
        return 8
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Configuration", selection: $configuration)
        ShowcasePicker("Axis", selection: $axisOption)
        ShowcasePicker("Effect", selection: $effectKind)
        if effectKind == .scale || effectKind == .rotation3D {
            ShowcaseSlider("Off-stage Scale", value: $identityScale, in: 0.5...1.0, step: 0.05)
        }
    }

    @ViewBuilder func stateView(_ state: TransitionState) -> some View {
        TransitionStateCell(stateKind: state)
    }
}

// MARK: - Code generation
private extension ScrollTransitionShowcase {
    var generatedCode: String {
        let scaleStr = String(format: "%.2f", identityScale)
        let axisArg = axisOption == .automatic
            ? ""
            : ", axis: \(axisOption.codeName)"
        let effectLines = effectCodeLines(scaleStr: scaleStr)
        var lines: [String] = []
        lines.append("row")
        lines.append("    .scrollTransition(\(configuration.codeName)\(axisArg)) { content, phase in")
        lines.append("        content")
        for line in effectLines {
            lines.append("            \(line)")
        }
        lines.append("    }")
        return lines.joined(separator: "\n")
    }

    func effectCodeLines(scaleStr: String) -> [String] {
        switch effectKind {
        case .opacity:
            return [".opacity(phase.isIdentity ? 1 : 0)"]
        case .scale:
            return [
                ".opacity(phase.isIdentity ? 1 : 0.4)",
                ".scaleEffect(phase.isIdentity ? 1 : \(scaleStr))",
            ]
        case .blur:
            return [
                ".opacity(phase.isIdentity ? 1 : 0.5)",
                ".blur(radius: phase.isIdentity ? 0 : 8)",
            ]
        case .rotation3D:
            return [
                ".opacity(phase.isIdentity ? 1 : 0.3)",
                ".scaleEffect(phase.isIdentity ? 1 : \(scaleStr))",
            ]
        }
    }
}

// MARK: - TransitionStateCell
private struct TransitionStateCell: View {
    let stateKind: ScrollTransitionShowcase.TransitionState

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: DesignSystem.Spacing.xSmall) {
                ForEach(0..<5, id: \.self) { index in
                    stateRow(index: index)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.xSmall)
        }
        .frame(height: 120)
    }

    func stateRow(index: Int) -> some View {
        let kind = stateKind
        return RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
            .fill(Color.accentColor.opacity(0.2 + Double(index) * 0.1))
            .frame(height: 36)
            .scrollTransition(.interactive) { content, phase in
                content
                    .opacity(cellOpacity(kind: kind, isIdentity: phase.isIdentity))
                    .scaleEffect(cellScale(kind: kind, isIdentity: phase.isIdentity))
                    .blur(radius: cellBlur(kind: kind, isIdentity: phase.isIdentity))
            }
    }

    func cellOpacity(kind: ScrollTransitionShowcase.TransitionState, isIdentity: Bool) -> Double {
        guard !isIdentity else { return 1 }
        switch kind {
        case .opacityEffect: return 0
        case .scaleEffect: return 0.4
        case .blurEffect: return 0.5
        case .rotation3DEffect: return 0.3
        }
    }

    func cellScale(kind: ScrollTransitionShowcase.TransitionState, isIdentity: Bool) -> Double {
        guard !isIdentity else { return 1 }
        switch kind {
        case .opacityEffect: return 1
        case .scaleEffect: return 0.8
        case .blurEffect: return 1
        case .rotation3DEffect: return 0.7
        }
    }

    func cellBlur(kind: ScrollTransitionShowcase.TransitionState, isIdentity: Bool) -> CGFloat {
        guard !isIdentity, kind == .blurEffect else { return 0 }
        return 8
    }
}
