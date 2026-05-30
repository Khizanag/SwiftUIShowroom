import SwiftUI

struct TransitionShowcase: View {
    @State private var transitionKind: TransitionKind = .opacity
    @State private var edge: EdgeOption = .bottom
    @State private var scaleAnchor: AnchorOption = .center
    @State private var combineWithOpacity: Bool = false
    @State private var isVisible: Bool = true

    var body: some View {
        ShowcaseScreen(
            title: "Transition",
            summary: "Animates how a view is inserted into and removed from the hierarchy.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension TransitionShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .fill(DesignSystem.Color.cardBackground)
                    .frame(width: 200, height: 100)
                    .opacity(0.001)
                if isVisible {
                    transitionCard
                }
            }
            .frame(height: 110)
            Button(isVisible ? "Remove" : "Insert") {
                withAnimation(.spring) {
                    isVisible.toggle()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var transitionCard: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(DesignSystem.Color.accent)
            .frame(width: 200, height: 100)
            .overlay {
                Text("Card")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.onAccent)
            }
            .transition(resolvedTransition)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Transition", selection: $transitionKind)
        if transitionKind.usesEdge {
            ShowcasePicker("Edge", selection: $edge)
        }
        if transitionKind == .scale {
            ShowcasePicker("Scale Anchor", selection: $scaleAnchor)
        }
        ShowcaseToggle("Combine with opacity", isOn: $combineWithOpacity)
    }

    @ViewBuilder func stateView(_ state: TransitionState) -> some View {
        TransitionStateCell(transition: state.transition)
    }
}

// MARK: - Code generation
private extension TransitionShowcase {
    var resolvedTransition: AnyTransition {
        let base = transitionKind.makeTransition(edge: edge, anchor: scaleAnchor)
        if combineWithOpacity {
            return base.combined(with: .opacity)
        }
        return base
    }

    var generatedCode: String {
        let transitionCode = transitionKind.codeString(edge: edge, anchor: scaleAnchor)
        var lines: [String] = []
        lines.append("if isShown {")
        lines.append("    CardView()")
        if combineWithOpacity {
            lines.append("        .transition(")
            lines.append("            \(transitionCode)")
            lines.append("                .combined(with: .opacity)")
            lines.append("        )")
        } else {
            lines.append("        .transition(\(transitionCode))")
        }
        lines.append("}")
        lines.append("// trigger inside: withAnimation { isShown.toggle() }")
        return lines.joined(separator: "\n")
    }
}

// MARK: - Nested types
extension TransitionShowcase {
    fileprivate enum TransitionKind: String, ShowcasePickable, CaseIterable {
        case opacity
        case slide
        case scale
        case move
        case push
        case blurReplace
        case offset
        case identity

        var label: String {
            switch self {
            case .opacity: ".opacity"
            case .slide: ".slide"
            case .scale: ".scale"
            case .move: ".move(edge:)"
            case .push: ".push(from:)"
            case .blurReplace: ".blurReplace"
            case .offset: ".offset"
            case .identity: ".identity"
            }
        }

        var usesEdge: Bool {
            self == .move || self == .push
        }

        func makeTransition(edge: EdgeOption, anchor: AnchorOption) -> AnyTransition {
            switch self {
            case .opacity: return .opacity
            case .slide: return .slide
            case .scale: return .scale(scale: 0.001, anchor: anchor.unitPoint)
            case .move: return .move(edge: edge.edgeValue)
            case .push: return .push(from: edge.edgeValue)
            case .blurReplace: return AnyTransition(.blurReplace)
            case .offset: return .offset(x: 0, y: 80)
            case .identity: return .identity
            }
        }

        func codeString(edge: EdgeOption, anchor: AnchorOption) -> String {
            switch self {
            case .opacity: return ".opacity"
            case .slide: return ".slide"
            case .scale: return ".scale(scale: 0.001, anchor: .\(anchor.label))"
            case .move: return ".move(edge: .\(edge.label))"
            case .push: return ".push(from: .\(edge.label))"
            case .blurReplace: return ".blurReplace"
            case .offset: return ".offset(x: 0, y: 80)"
            case .identity: return ".identity"
            }
        }
    }

    fileprivate enum EdgeOption: String, ShowcasePickable, CaseIterable {
        case top, bottom, leading, trailing

        var label: String {
            switch self {
            case .top: "top"
            case .bottom: "bottom"
            case .leading: "leading"
            case .trailing: "trailing"
            }
        }

        var edgeValue: Edge {
            switch self {
            case .top: .top
            case .bottom: .bottom
            case .leading: .leading
            case .trailing: .trailing
            }
        }
    }

    fileprivate enum AnchorOption: String, ShowcasePickable, CaseIterable {
        case center
        case top
        case bottom
        case leading
        case trailing
        case topLeading
        case bottomTrailing

        var label: String {
            switch self {
            case .center: "center"
            case .top: "top"
            case .bottom: "bottom"
            case .leading: "leading"
            case .trailing: "trailing"
            case .topLeading: "topLeading"
            case .bottomTrailing: "bottomTrailing"
            }
        }

        var unitPoint: UnitPoint {
            switch self {
            case .center: .center
            case .top: .top
            case .bottom: .bottom
            case .leading: .leading
            case .trailing: .trailing
            case .topLeading: .topLeading
            case .bottomTrailing: .bottomTrailing
            }
        }
    }

    fileprivate enum TransitionState: ShowcaseState {
        case opacity
        case slide
        case scale
        case move
        case blurReplace
        case identity

        var caption: String {
            switch self {
            case .opacity: ".opacity"
            case .slide: ".slide"
            case .scale: ".scale"
            case .move: ".move(edge: .bottom)"
            case .blurReplace: ".blurReplace"
            case .identity: ".identity"
            }
        }

        var transition: AnyTransition {
            switch self {
            case .opacity: return .opacity
            case .slide: return .slide
            case .scale: return .scale(scale: 0.001)
            case .move: return .move(edge: .bottom)
            case .blurReplace: return AnyTransition(.blurReplace)
            case .identity: return .identity
            }
        }
    }
}

// MARK: - TransitionStateCell
private struct TransitionStateCell: View {
    let transition: AnyTransition
    @State private var shown: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .fill(DesignSystem.Color.cardBackground)
                .frame(width: 64, height: 40)
                .opacity(0.001)
            if shown {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .fill(Color.accentColor)
                    .frame(width: 64, height: 40)
                    .transition(transition)
            }
        }
        .frame(height: 48)
        .onAppear {
            withAnimation(.spring(duration: 0.5)) {
                shown = true
            }
        }
    }
}
