import SwiftUI

struct ContentTransitionShowcase: View {
    @State private var transitionKind: TransitionKind = .numericText
    @State private var countsDown: Bool = false
    @State private var counter: Int = 0
    @State private var symbolToggle: Bool = false

    var body: some View {
        ShowcaseScreen(
            title: "Content Transition",
            summary: "Animates content changes in place: digit rolls, symbol swaps, opacity, interpolation.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ContentTransitionShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            contentDisplay
            HStack(spacing: DesignSystem.Spacing.medium) {
                decrementButton
                incrementButton
            }
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var resolvedTransition: ContentTransition {
        switch transitionKind {
        case .identity: return .identity
        case .opacity: return .opacity
        case .interpolate: return .interpolate
        case .numericText: return .numericText(countsDown: countsDown)
        case .symbolEffect: return .symbolEffect(.replace)
        }
    }

    var contentDisplay: some View {
        Group {
            if transitionKind == .symbolEffect {
                symbolPreview
            } else {
                numericPreview
            }
        }
    }

    var numericPreview: some View {
        Text("\(counter)")
            .font(DesignSystem.Font.largeTitle)
            .foregroundStyle(DesignSystem.Color.accent)
            .monospacedDigit()
            .contentTransition(resolvedTransition)
            .animation(.default, value: counter)
    }

    var symbolPreview: some View {
        Image(systemName: symbolToggle ? "star.fill" : "heart.fill")
            .font(DesignSystem.Font.largeTitle)
            .foregroundStyle(DesignSystem.Color.accent)
            .contentTransition(.symbolEffect(.replace))
            .animation(.default, value: symbolToggle)
    }

    var decrementButton: some View {
        Button {
            if transitionKind == .symbolEffect {
                symbolToggle.toggle()
            } else {
                counter -= 1
            }
        } label: {
            Image(systemName: transitionKind == .symbolEffect ? "arrow.2.circlepath" : "minus")
                .font(DesignSystem.Font.headline)
        }
        .buttonStyle(.bordered)
    }

    var incrementButton: some View {
        Button {
            if transitionKind == .symbolEffect {
                symbolToggle.toggle()
            } else {
                counter += 1
            }
        } label: {
            Image(systemName: transitionKind == .symbolEffect ? "shuffle" : "plus")
                .font(DesignSystem.Font.headline)
        }
        .buttonStyle(.bordered)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Transition", selection: $transitionKind)
        if transitionKind == .numericText {
            ShowcaseToggle("Counts down", isOn: $countsDown)
        }
        ShowcaseStepper("Counter", value: $counter, in: -9999...9999)
    }

    @ViewBuilder func stateView(_ state: ContentTransitionState) -> some View {
        ContentTransitionStateView(state: state)
    }
}

// MARK: - Code generation
private extension ContentTransitionShowcase {
    var generatedCode: String {
        let transitionCode: String
        switch transitionKind {
        case .identity:
            transitionCode = ".identity"
        case .opacity:
            transitionCode = ".opacity"
        case .interpolate:
            transitionCode = ".interpolate"
        case .numericText:
            transitionCode = countsDown ? ".numericText(countsDown: true)" : ".numericText()"
        case .symbolEffect:
            transitionCode = ".symbolEffect(.replace)"
        }
        var lines: [String] = []
        if transitionKind == .symbolEffect {
            lines.append("Image(systemName: isAlternate ? \"star.fill\" : \"heart.fill\")")
            lines.append("    .contentTransition(\(transitionCode))")
            lines.append("    .animation(.default, value: isAlternate)")
        } else {
            lines.append("Text(\"\\(count)\")")
            lines.append("    .monospacedDigit()")
            lines.append("    .contentTransition(\(transitionCode))")
            lines.append("    .animation(.default, value: count)")
        }
        return lines.joined(separator: "\n")
    }
}

// MARK: - Nested types
extension ContentTransitionShowcase {
    fileprivate enum TransitionKind: String, ShowcasePickable, CaseIterable {
        case identity
        case opacity
        case interpolate
        case numericText
        case symbolEffect

        var label: String {
            switch self {
            case .identity: "identity"
            case .opacity: "opacity"
            case .interpolate: "interpolate"
            case .numericText: "numericText"
            case .symbolEffect: "symbolEffect"
            }
        }
    }

    fileprivate enum ContentTransitionState: ShowcaseState, CaseIterable {
        case numericRollUp
        case numericRollDown
        case symbolReplace
        case opacityCross
        case identityNone

        var caption: String {
            switch self {
            case .numericRollUp: "numericText (up)"
            case .numericRollDown: "numericText (countsDown)"
            case .symbolReplace: "symbolEffect"
            case .opacityCross: "opacity"
            case .identityNone: "identity"
            }
        }
    }
}

// MARK: - State demo view
private struct ContentTransitionStateView: View {
    let state: ContentTransitionShowcase.ContentTransitionState
    @State private var count: Int = 42
    @State private var altSymbol: Bool = false

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            stateContent
            tapHint
        }
        .padding(.vertical, DesignSystem.Spacing.xSmall)
    }

    @ViewBuilder private var stateContent: some View {
        switch state {
        case .numericRollUp:
            Button { count += 1 } label: {
                Text("\(count)")
                    .font(DesignSystem.Font.title2)
                    .monospacedDigit()
                    .foregroundStyle(DesignSystem.Color.accent)
                    .contentTransition(.numericText())
                    .animation(.default, value: count)
            }
            .buttonStyle(.plain)
        case .numericRollDown:
            Button { count -= 1 } label: {
                Text("\(count)")
                    .font(DesignSystem.Font.title2)
                    .monospacedDigit()
                    .foregroundStyle(DesignSystem.Color.accent)
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.default, value: count)
            }
            .buttonStyle(.plain)
        case .symbolReplace:
            Button { altSymbol.toggle() } label: {
                Image(systemName: altSymbol ? "star.fill" : "heart.fill")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .contentTransition(.symbolEffect(.replace))
                    .animation(.default, value: altSymbol)
            }
            .buttonStyle(.plain)
        case .opacityCross:
            Button { count += 1 } label: {
                Text("\(count)")
                    .font(DesignSystem.Font.title2)
                    .monospacedDigit()
                    .foregroundStyle(DesignSystem.Color.accent)
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: count)
            }
            .buttonStyle(.plain)
        case .identityNone:
            Button { count += 1 } label: {
                Text("\(count)")
                    .font(DesignSystem.Font.title2)
                    .monospacedDigit()
                    .foregroundStyle(DesignSystem.Color.accent)
                    .contentTransition(.identity)
                    .animation(.default, value: count)
            }
            .buttonStyle(.plain)
        }
    }

    private var tapHint: some View {
        Text("tap to trigger")
            .font(DesignSystem.Font.caption2)
            .foregroundStyle(DesignSystem.Color.secondary)
    }
}
