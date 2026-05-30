import SwiftUI

struct NamespaceShowcase: View {
    @Namespace private var namespace
    @State private var matchID = "hero"
    @State private var expanded = false
    @State private var animationStyle: AnimationStyle = .spring
    @State private var showProperties = true

    var body: some View {
        ShowcaseScreen(
            title: "@Namespace",
            summary: "Vends a stable namespace ID for matchedGeometryEffect, linking views across layout transitions.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension NamespaceShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            animationDemo
            tapHint
        }
    }

    var animationDemo: some View {
        ZStack {
            if expanded {
                expandedCard
            } else {
                collapsedChip
            }
        }
        .animation(animationStyle.value, value: expanded)
    }

    var expandedCard: some View {
        let resolvedID = matchID.isEmpty ? "hero" : matchID
        return RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
            .fill(DesignSystem.Color.accent)
            .matchedGeometryEffect(id: resolvedID, in: namespace)
            .frame(width: 260, height: 160)
            .overlay(expandedLabel)
            .contentShape(Rectangle())
            .onTapGesture { expanded = false }
    }

    var expandedLabel: some View {
        VStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: "arrowshape.down.circle.fill")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.onAccent)
            Text("Tap to collapse")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.onAccent)
        }
    }

    var collapsedChip: some View {
        let resolvedID = matchID.isEmpty ? "hero" : matchID
        return RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(DesignSystem.Color.accent)
            .matchedGeometryEffect(id: resolvedID, in: namespace)
            .frame(width: 100, height: 44)
            .overlay(collapsedLabel)
            .contentShape(Rectangle())
            .onTapGesture { expanded = true }
    }

    var collapsedLabel: some View {
        Text("Tap")
            .font(DesignSystem.Font.footnote)
            .foregroundStyle(DesignSystem.Color.onAccent)
    }

    var tapHint: some View {
        Text(expanded ? "Expanded — tap to collapse" : "Collapsed — tap to expand")
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.secondary)
            .animation(.default, value: expanded)
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Match ID", text: $matchID, prompt: "hero")
        ShowcasePicker("Animation", selection: $animationStyle)
        ShowcaseToggle("Show @Namespace declaration", isOn: $showProperties)
    }

    @ViewBuilder
    func stateView(_ state: NamespaceState) -> some View {
        switch state {
        case .collapsed:
            stateChip(label: "collapsed", icon: "arrow.up.left.and.arrow.down.right")
        case .expanded:
            stateCard(label: "expanded", icon: "arrow.down.right.and.arrow.up.left")
        case .multiMatch:
            multiMatchDiagram
        }
    }

    func stateChip(label: String, icon: String) -> some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(DesignSystem.Color.accent)
            .frame(width: 100, height: 44)
            .overlay(
                HStack(spacing: DesignSystem.Spacing.xSmall) {
                    Image(systemName: icon)
                        .font(DesignSystem.Font.caption)
                    Text(label)
                        .font(DesignSystem.Font.caption)
                }
                .foregroundStyle(DesignSystem.Color.onAccent)
            )
    }

    func stateCard(label: String, icon: String) -> some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
            .fill(DesignSystem.Color.accent)
            .frame(width: 220, height: 130)
            .overlay(
                VStack(spacing: DesignSystem.Spacing.xSmall) {
                    Image(systemName: icon)
                        .font(DesignSystem.Font.title2)
                    Text(label)
                        .font(DesignSystem.Font.footnote)
                }
                .foregroundStyle(DesignSystem.Color.onAccent)
            )
    }

    var multiMatchDiagram: some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            ForEach(["A", "B", "C"], id: \.self) { key in
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .fill(DesignSystem.Color.cardBackground)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Text(key)
                            .font(DesignSystem.Font.headline)
                            .foregroundStyle(DesignSystem.Color.accent)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                            .strokeBorder(DesignSystem.Color.accent, lineWidth: 1.5)
                    )
            }
        }
    }
}

// MARK: - Code generation
private extension NamespaceShowcase {
    var generatedCode: String {
        let idLiteral = matchID.isEmpty ? "hero" : matchID
        var lines: [String] = []
        lines.append("struct NamespaceDemo: View {")
        if showProperties {
            lines.append("    @Namespace private var namespace")
            lines.append("    @State private var expanded = false")
            lines.append("")
        }
        lines.append("    var body: some View {")
        lines.append("        if expanded {")
        lines.append("            RoundedRectangle(cornerRadius: 24)")
        lines.append("                .matchedGeometryEffect(id: \"\(idLiteral)\", in: namespace)")
        lines.append("                .frame(width: 260, height: 160)")
        lines.append("        } else {")
        lines.append("            RoundedRectangle(cornerRadius: 12)")
        lines.append("                .matchedGeometryEffect(id: \"\(idLiteral)\", in: namespace)")
        lines.append("                .frame(width: 100, height: 44)")
        lines.append("        }")
        lines.append("    }")
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}

// MARK: - Nested types
extension NamespaceShowcase {
    fileprivate enum AnimationStyle: ShowcasePickable {
        case spring
        case easeInOut
        case bouncy
        case linear

        var label: String {
            switch self {
            case .spring: "Spring"
            case .easeInOut: "Ease In Out"
            case .bouncy: "Bouncy"
            case .linear: "Linear"
            }
        }

        var value: Animation {
            switch self {
            case .spring: .spring(response: 0.4, dampingFraction: 0.75)
            case .easeInOut: .easeInOut(duration: 0.35)
            case .bouncy: .bouncy
            case .linear: .linear(duration: 0.3)
            }
        }
    }

    fileprivate enum NamespaceState: ShowcaseState {
        case collapsed
        case expanded
        case multiMatch

        var caption: String {
            switch self {
            case .collapsed: "Collapsed (source shape)"
            case .expanded: "Expanded (destination shape)"
            case .multiMatch: "Multiple matched IDs"
            }
        }
    }
}
