import SwiftUI

struct NavigationTransitionZoomShowcase: View {
    enum TransitionOption: ShowcasePickable {
        case automatic
        case zoom

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .zoom: "zoom"
            }
        }
    }

    enum ZoomState: ShowcaseState {
        case defaultState
        case selected

        var caption: String {
            switch self {
            case .defaultState: "Default (automatic)"
            case .selected: "Zoom (matched source)"
            }
        }
    }

    @State private var transitionOption: TransitionOption = .zoom
    @State private var sourceID = "hero"

    var body: some View {
        ShowcaseScreen(
            title: "Zoom transition",
            summary: "Animates a pushed view zooming from a matched source view via matchedTransitionSource.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension NavigationTransitionZoomShowcase {
    var preview: some View {
        ZoomDemoStack(
            transitionOption: transitionOption,
            sourceID: sourceID,
        )
        .frame(maxWidth: 320, minHeight: 260)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Transition", selection: $transitionOption)
        ShowcaseTextControl("Source ID", text: $sourceID, prompt: "hero")
    }

    @ViewBuilder
    func stateView(_ state: ZoomState) -> some View {
        switch state {
        case .defaultState:
            ZoomDemoStack(
                transitionOption: .automatic,
                sourceID: "hero-default",
            )
            .frame(maxWidth: 320, minHeight: 260)
            .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
        case .selected:
            ZoomDemoStack(
                transitionOption: .zoom,
                sourceID: "hero-selected",
            )
            .frame(maxWidth: 320, minHeight: 260)
            .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
        }
    }
}

// MARK: - Code generation
private extension NavigationTransitionZoomShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("struct ZoomTransitionDemo: View {")
        lines.append("    @Namespace private var namespace")
        lines.append("")
        lines.append("    var body: some View {")
        lines.append("        NavigationStack {")
        lines.append("            NavigationLink {")
        lines.append("                DetailView()")
        if transitionOption == .zoom {
            lines.append("                    .navigationTransition(.zoom(sourceID: \"\(sourceID)\", in: namespace))")
        } else {
            lines.append("                    .navigationTransition(.automatic)")
        }
        lines.append("            } label: {")
        lines.append("                Thumbnail()")
        lines.append("            }")
        if transitionOption == .zoom {
            lines.append("            .matchedTransitionSource(id: \"\(sourceID)\", in: namespace)")
        }
        lines.append("        }")
        lines.append("    }")
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}

// MARK: - ZoomDemoStack
private struct ZoomDemoStack: View {
    let transitionOption: NavigationTransitionZoomShowcase.TransitionOption
    let sourceID: String

    @Namespace private var namespace

    var body: some View {
        NavigationStack {
            VStack(spacing: DesignSystem.Spacing.medium) {
                NavigationLink {
                    detailView
                } label: {
                    thumbnailView
                }
                .matchedTransitionSource(id: sourceID, in: namespace)
                Text("Tap to push")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
            .padding(DesignSystem.Spacing.large)
            .navigationTitle("Gallery")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }

    private var thumbnailView: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(DesignSystem.Color.accent)
            .frame(width: 120, height: 120)
            .overlay(
                Image(systemName: "photo")
                    .font(DesignSystem.Font.title)
                    .foregroundStyle(.white)
            )
    }

    private var detailView: some View {
        ZStack {
            DesignSystem.Color.accent.ignoresSafeArea()
            VStack(spacing: DesignSystem.Spacing.medium) {
                Image(systemName: "photo")
                    .font(DesignSystem.Font.largeTitle)
                    .foregroundStyle(.white)
                Text("Detail")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(.white)
            }
        }
        .navigationTitle("Detail")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .modifier(ZoomTransitionModifier(
            transitionOption: transitionOption,
            sourceID: sourceID,
            namespace: namespace,
        ))
    }
}

// MARK: - ZoomTransitionModifier
private struct ZoomTransitionModifier: ViewModifier {
    let transitionOption: NavigationTransitionZoomShowcase.TransitionOption
    let sourceID: String
    let namespace: Namespace.ID

    func body(content: Content) -> some View {
        #if os(macOS)
        content
            .navigationTransition(.automatic)
        #else
        if transitionOption == .zoom {
            content
                .navigationTransition(.zoom(sourceID: sourceID, in: namespace))
        } else {
            content
                .navigationTransition(.automatic)
        }
        #endif
    }
}
