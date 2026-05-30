import SwiftUI

struct DefersSystemGesturesShowcase: View {
    enum EdgeSetOption: ShowcasePickable {
        case all, top, bottom, leading, trailing, horizontal, vertical

        var label: String {
            switch self {
            case .all: ".all"
            case .top: ".top"
            case .bottom: ".bottom"
            case .leading: ".leading"
            case .trailing: ".trailing"
            case .horizontal: ".horizontal"
            case .vertical: ".vertical"
            }
        }

        #if os(iOS)
        var edgeSet: Edge.Set {
            switch self {
            case .all: .all
            case .top: .top
            case .bottom: .bottom
            case .leading: .leading
            case .trailing: .trailing
            case .horizontal: .horizontal
            case .vertical: .vertical
            }
        }
        #endif
    }

    enum DeferralState: ShowcaseState {
        case allEdges, topEdge, bottomEdge, horizontalEdges, inactive

        var caption: String {
            switch self {
            case .allEdges: "All edges deferred"
            case .topEdge: "Top edge deferred"
            case .bottomEdge: "Bottom edge deferred"
            case .horizontalEdges: "Horizontal edges deferred"
            case .inactive: "No deferral (.init())"
            }
        }

        var edgeLabel: String {
            switch self {
            case .allEdges: ".all"
            case .topEdge: ".top"
            case .bottomEdge: ".bottom"
            case .horizontalEdges: ".horizontal"
            case .inactive: "none"
            }
        }

        var systemImage: String {
            switch self {
            case .allEdges: "hand.raised.slash"
            case .topEdge: "arrow.up.to.line"
            case .bottomEdge: "arrow.down.to.line"
            case .horizontalEdges: "arrow.left.arrow.right"
            case .inactive: "hand.raised"
            }
        }
    }

    @State private var selectedEdge: EdgeSetOption = .all

    var body: some View {
        ShowcaseScreen(
            title: "Defers System Gestures",
            summary: "Asks the system to delay edge gestures so your view's gestures take priority.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension DefersSystemGesturesShowcase {
    var preview: some View {
        #if os(iOS)
        iOSPreview
        #else
        platformUnavailableNotice
        #endif
    }

    #if os(iOS)
    var iOSPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .fill(DesignSystem.Color.accent.opacity(0.15))
                .frame(height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                        .strokeBorder(DesignSystem.Color.accent, lineWidth: 2)
                )
            VStack(spacing: DesignSystem.Spacing.small) {
                Image(systemName: "hand.raised.slash")
                    .font(DesignSystem.Font.largeTitle)
                    .foregroundStyle(DesignSystem.Color.accent)
                Text("System gestures deferred")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.primary)
                Text("on \(selectedEdge.label) edges")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .defersSystemGestures(on: selectedEdge.edgeSet)
    }
    #endif

    var platformUnavailableNotice: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "iphone.slash")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.secondary)
            Text("iOS / iPadOS only")
                .font(DesignSystem.Font.callout)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(DesignSystem.Spacing.large)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Edges", selection: $selectedEdge)
    }

    @ViewBuilder func stateView(_ state: DeferralState) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(stateBackgroundColor(state).opacity(0.12))
                .frame(width: 140, height: 90)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .strokeBorder(stateBackgroundColor(state).opacity(0.4), lineWidth: 1)
                )
            VStack(spacing: DesignSystem.Spacing.xSmall) {
                Image(systemName: state.systemImage)
                    .font(DesignSystem.Font.title3)
                    .foregroundStyle(stateBackgroundColor(state))
                Text(state.edgeLabel)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.primary)
            }
        }
    }

    func stateBackgroundColor(_ state: DeferralState) -> Color {
        state == .inactive ? DesignSystem.Color.secondary : DesignSystem.Color.accent
    }
}

// MARK: - Code generation
private extension DefersSystemGesturesShowcase {
    var generatedCode: String {
        let edgeArg = selectedEdge.label
        return [
            "struct DeferSystemGesturesDemo: View {",
            "    var body: some View {",
            "        Color.black",
            "            .ignoresSafeArea()",
            "            .gesture(DragGesture().onChanged { _ in })",
            "            .defersSystemGestures(on: \(edgeArg))",
            "    }",
            "}",
        ].joined(separator: "\n")
    }
}
