import SwiftUI

struct GlassEffectIdMorphShowcase: View {
    @State private var glassID = "primary"
    @State private var isExpanded = false
    @Namespace private var namespace

    enum MorphState: ShowcaseState {
        case collapsed
        case expanded

        var caption: String {
            switch self {
            case .collapsed: "Collapsed (default)"
            case .expanded: "Expanded (selected)"
            }
        }
    }

    var body: some View {
        ShowcaseScreen(
            title: "Glass Effect ID (Morph)",
            summary: "Assigns a stable identity to a glass shape so it morphs as it appears, moves, or merges.",
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
private extension GlassEffectIdMorphShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            morphDemo
            Button(isExpanded ? "Collapse" : "Expand") {
                withAnimation(.spring) {
                    isExpanded.toggle()
                }
            }
            .buttonStyle(.glass)
        }
    }

    var morphDemo: some View {
        GlassEffectContainer {
            if isExpanded {
                expandedCard
            } else {
                compactPill
            }
        }
    }

    var compactPill: some View {
        Image(systemName: "star.fill")
            .font(DesignSystem.Font.title)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(DesignSystem.Spacing.medium)
            .glassEffect(.regular.interactive(true), in: .capsule)
            .glassEffectID(glassID, in: namespace)
    }

    var expandedCard: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "star.fill")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.onAccent)
            Text("Expanded")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.onAccent)
        }
        .padding(DesignSystem.Spacing.large)
        .glassEffect(.regular, in: .rect(cornerRadius: DesignSystem.CornerRadius.large))
        .glassEffectID(glassID, in: namespace)
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl(
            "Glass ID",
            text: $glassID,
            prompt: "e.g. \"primary\"",
        )
        ShowcaseToggle("Expanded (live toggle)", isOn: $isExpanded)
    }

    @ViewBuilder
    func stateView(_ state: MorphState) -> some View {
        switch state {
        case .collapsed:
            collapsedStateView
        case .expanded:
            expandedStateView
        }
    }

    var collapsedStateView: some View {
        GlassEffectContainer {
            Image(systemName: "star.fill")
                .font(DesignSystem.Font.title)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .padding(DesignSystem.Spacing.medium)
                .glassEffect(.regular, in: .capsule)
        }
        .padding(DesignSystem.Spacing.small)
    }

    var expandedStateView: some View {
        GlassEffectContainer {
            VStack(spacing: DesignSystem.Spacing.xSmall) {
                Image(systemName: "star.fill")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.onAccent)
                Text("Expanded")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.onAccent)
            }
            .padding(DesignSystem.Spacing.medium)
            .glassEffect(.regular, in: .rect(cornerRadius: DesignSystem.CornerRadius.medium))
        }
        .padding(DesignSystem.Spacing.small)
    }
}

// MARK: - Code generation
private extension GlassEffectIdMorphShowcase {
    var generatedCode: String {
        """
        @Namespace private var namespace

        GlassEffectContainer {
            Image(systemName: "plus")
                .padding()
                .glassEffect()
                .glassEffectID("\(glassID)", in: namespace)
        }
        """
    }
}
