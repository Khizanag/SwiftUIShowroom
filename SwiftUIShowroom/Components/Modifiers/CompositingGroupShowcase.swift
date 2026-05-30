import SwiftUI

struct CompositingGroupShowcase: View {
    enum GroupingState: ShowcaseState {
        case grouped
        case ungrouped

        var caption: String {
            switch self {
            case .grouped: "With compositingGroup()"
            case .ungrouped: "Without compositingGroup()"
            }
        }

        var isGrouped: Bool {
            switch self {
            case .grouped: true
            case .ungrouped: false
            }
        }
    }

    @State private var enabled: Bool = true
    @State private var opacity: Double = 0.6

    var body: some View {
        ShowcaseScreen(
            title: "Compositing Group",
            summary: "Renders children as one flattened layer before effects like opacity or shadow apply.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension CompositingGroupShowcase {
    var preview: some View {
        overlappingCircles(isGrouped: enabled, opacity: opacity)
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("Compositing Group", isOn: $enabled)
        ShowcaseSlider("Opacity", value: $opacity, in: 0...1, step: 0.01)
    }

    @ViewBuilder func stateView(_ state: GroupingState) -> some View {
        overlappingCircles(isGrouped: state.isGrouped, opacity: 0.6)
    }

    func overlappingCircles(isGrouped: Bool, opacity: Double) -> some View {
        let stack = ZStack {
            Circle()
                .fill(DesignSystem.Color.accent)
                .frame(width: 80, height: 80)
            Circle()
                .fill(Color.red)
                .frame(width: 80, height: 80)
                .offset(x: 30)
        }

        return Group {
            if isGrouped {
                stack
                    .compositingGroup()
                    .opacity(opacity)
            } else {
                stack
                    .opacity(opacity)
            }
        }
    }
}

// MARK: - Code generation
private extension CompositingGroupShowcase {
    var generatedCode: String {
        let opacityStr = String(format: "%.2f", opacity)
        let groupLine = enabled ? "\n    .compositingGroup()" : ""
        return """
        ZStack {
            Circle().fill(.blue)
            Circle().fill(.red).offset(x: 30)
        }\(groupLine)
        .opacity(\(opacityStr))
        """
    }
}
