import SwiftUI

struct AsymmetricTransitionShowcase: View {
    @State private var insertion: TransitionOption = .moveBottom
    @State private var removal: TransitionOption = .opacity
    @State private var isShown: Bool = true

    var body: some View {
        ShowcaseScreen(
            title: "Asymmetric Transition",
            summary: "Uses different transitions for view insertion versus removal.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AsymmetricTransitionShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            ZStack {
                Color.clear
                    .frame(height: 120)
                if isShown {
                    bannerCard
                        .transition(
                            .asymmetric(
                                insertion: insertion.anyTransition,
                                removal: removal.anyTransition,
                            )
                        )
                }
            }
            .animation(.spring, value: isShown)
            toggleButton
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var bannerCard: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
            .fill(DesignSystem.Color.accent)
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .overlay {
                Text("Banner")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.onAccent)
            }
            .padding(.horizontal, DesignSystem.Spacing.medium)
    }

    var toggleButton: some View {
        Button(isShown ? "Remove" : "Insert") {
            withAnimation(.spring) {
                isShown.toggle()
            }
        }
        .buttonStyle(.bordered)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Insertion", selection: $insertion)
        ShowcasePicker("Removal", selection: $removal)
    }

    @ViewBuilder func stateView(_ state: PairingState) -> some View {
        StatePairingView(
            insertionTransition: state.insertion,
            removalTransition: state.removal,
        )
    }
}

// MARK: - Code generation
private extension AsymmetricTransitionShowcase {
    var generatedCode: String {
        [
            "if isShown {",
            "    BannerView()",
            "        .transition(.asymmetric(",
            "            insertion: .\(insertion.codeLabel),",
            "            removal: .\(removal.codeLabel),",
            "        ))",
            "}",
            "// trigger inside: withAnimation { isShown.toggle() }",
        ].joined(separator: "\n")
    }
}

// MARK: - State demo helper
private struct StatePairingView: View {
    let insertionTransition: AnyTransition
    let removalTransition: AnyTransition
    @State private var isVisible: Bool = true

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            ZStack {
                Color.clear.frame(height: 60)
                if isVisible {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .fill(DesignSystem.Color.accent)
                        .frame(width: 120, height: 50)
                        .transition(
                            .asymmetric(
                                insertion: insertionTransition,
                                removal: removalTransition,
                            )
                        )
                }
            }
            .animation(.spring, value: isVisible)
            Button(isVisible ? "Remove" : "Insert") {
                withAnimation(.spring) {
                    isVisible.toggle()
                }
            }
            .buttonStyle(.bordered)
            .font(DesignSystem.Font.caption)
        }
    }
}

// MARK: - Nested types
extension AsymmetricTransitionShowcase {
    fileprivate enum TransitionOption: String, ShowcasePickable, CaseIterable {
        case opacity
        case slide
        case scale
        case moveBottom = "move(.bottom)"
        case moveTop = "move(.top)"
        case pushBottom = "push(.bottom)"
        case pushTop = "push(.top)"
        case blurReplace

        var label: String {
            switch self {
            case .opacity: "opacity"
            case .slide: "slide"
            case .scale: "scale"
            case .moveBottom: "move(edge: .bottom)"
            case .moveTop: "move(edge: .top)"
            case .pushBottom: "push(from: .bottom)"
            case .pushTop: "push(from: .top)"
            case .blurReplace: "blurReplace"
            }
        }

        var codeLabel: String { label }

        var anyTransition: AnyTransition {
            switch self {
            case .opacity: .opacity
            case .slide: .slide
            case .scale: .scale
            case .moveBottom: .move(edge: .bottom)
            case .moveTop: .move(edge: .top)
            case .pushBottom: .push(from: .bottom)
            case .pushTop: .push(from: .top)
            case .blurReplace: AnyTransition(.blurReplace)
            }
        }
    }

    fileprivate enum PairingState: ShowcaseState {
        case slideInFadeOut
        case moveInScaleOut
        case pushInOpacityOut
        case blurInSlideOut

        var caption: String {
            switch self {
            case .slideInFadeOut: "slide in / opacity out"
            case .moveInScaleOut: "move(.bottom) in / scale out"
            case .pushInOpacityOut: "push(.bottom) in / opacity out"
            case .blurInSlideOut: "blurReplace in / slide out"
            }
        }

        var insertion: AnyTransition {
            switch self {
            case .slideInFadeOut: .slide
            case .moveInScaleOut: .move(edge: .bottom)
            case .pushInOpacityOut: .push(from: .bottom)
            case .blurInSlideOut: AnyTransition(.blurReplace)
            }
        }

        var removal: AnyTransition {
            switch self {
            case .slideInFadeOut: .opacity
            case .moveInScaleOut: .scale
            case .pushInOpacityOut: .opacity
            case .blurInSlideOut: .slide
            }
        }
    }
}
