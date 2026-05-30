import SwiftUI

struct GlassEffectTransitionShowcase: View {
    enum TransitionOption: String, ShowcasePickable, CaseIterable {
        case materialize
        case identity

        var label: String {
            switch self {
            case .materialize: "materialize"
            case .identity: "identity"
            }
        }

        var id: String { rawValue }

        var resolved: GlassEffectTransition {
            switch self {
            case .materialize: .materialize
            case .identity: .identity
            }
        }
    }

    enum TransitionState: String, ShowcaseState, CaseIterable {
        case appearing
        case disappearing

        var caption: String {
            switch self {
            case .appearing: "Appearing"
            case .disappearing: "Disappearing"
            }
        }

        var id: String { rawValue }
    }

    @State private var selectedTransition: TransitionOption = .materialize
    @State private var isVisible = true
    @Namespace private var previewNamespace

    var body: some View {
        ShowcaseScreen(
            title: "Glass Effect Transition",
            summary: "Controls how a glass shape animates as it is added to or removed from the hierarchy.",
        ) {
            PreviewStage(backdrop: .colorful) { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension GlassEffectTransitionShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            GlassEffectContainer {
                if isVisible {
                    Image(systemName: "star.fill")
                        .font(DesignSystem.Font.title)
                        .padding(DesignSystem.Spacing.xLarge)
                        .glassEffect()
                        .glassEffectTransition(selectedTransition.resolved)
                        .glassEffectID("star", in: previewNamespace)
                }
            }
            .frame(height: 80)
            Button(isVisible ? "Remove" : "Add") {
                withAnimation(.smooth) {
                    isVisible.toggle()
                }
            }
            .buttonStyle(.glass)
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Transition", selection: $selectedTransition)
    }

    @ViewBuilder
    func stateView(_ state: TransitionState) -> some View {
        ZStack {
            LinearGradient(
                colors: [.purple, .blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing,
            )
            .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))

            GlassEffectContainer {
                if state == .appearing {
                    Image(systemName: "checkmark.circle.fill")
                        .font(DesignSystem.Font.title)
                        .padding(DesignSystem.Spacing.large)
                        .glassEffect()
                        .glassEffectTransition(.materialize)
                }
            }
        }
        .frame(height: 80)
    }
}

// MARK: - Code generation
private extension GlassEffectTransitionShowcase {
    var generatedCode: String {
        """
        Image(systemName: "star.fill")
            .padding()
            .glassEffect()
            .glassEffectTransition(.\(selectedTransition.rawValue))
        """
    }
}
