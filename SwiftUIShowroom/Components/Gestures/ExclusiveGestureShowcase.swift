import SwiftUI

struct ExclusiveGestureShowcase: View {
    @State private var firstGesture: FirstGestureKind = .drag
    @State private var secondGesture: SecondGestureKind = .longPress
    @State private var isEnabled: Bool = true
    @State private var lastWinner: Winner = .none

    var body: some View {
        ShowcaseScreen(
            title: "Exclusive Gesture",
            summary: "Lets only the first gesture to succeed win; the other is ignored.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }

    // MARK: - Nested types
    enum Winner: Equatable {
        case none, first, second
    }

    enum FirstGestureKind: String, ShowcasePickable {
        case drag, tap, longPress

        var label: String {
            switch self {
            case .drag: "DragGesture"
            case .tap: "TapGesture"
            case .longPress: "LongPressGesture"
            }
        }
    }

    enum SecondGestureKind: String, ShowcasePickable {
        case tap, longPress, magnify

        var label: String {
            switch self {
            case .tap: "TapGesture"
            case .longPress: "LongPressGesture"
            case .magnify: "MagnifyGesture"
            }
        }
    }

    enum GestureState: ShowcaseState {
        case ready, firstWon, secondWon, disabled

        var caption: String {
            switch self {
            case .ready: "Ready"
            case .firstWon: "First won"
            case .secondWon: "Second won"
            case .disabled: "Disabled"
            }
        }
    }
}

// MARK: - Sub-views
private extension ExclusiveGestureShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            interactiveCircle
            statusLabel
        }
    }

    var interactiveCircle: some View {
        Circle()
            .fill(circleColor)
            .frame(width: 120, height: 120)
            .overlay(circleOverlay)
            .animation(.easeInOut(duration: 0.2), value: lastWinner)
            .applyExclusiveGesture(
                first: firstGesture,
                second: secondGesture,
                isEnabled: isEnabled,
                onWinner: { lastWinner = $0 },
            )
    }

    var circleOverlay: some View {
        Text(circleLabel)
            .font(DesignSystem.Font.headline)
            .foregroundStyle(DesignSystem.Color.onAccent)
    }

    var circleColor: Color {
        switch lastWinner {
        case .none: DesignSystem.Color.accent.opacity(0.5)
        case .first: DesignSystem.Color.accent
        case .second: Color.orange
        }
    }

    var circleLabel: String {
        switch lastWinner {
        case .none: "Interact"
        case .first: "First!"
        case .second: "Second!"
        }
    }

    var statusLabel: some View {
        Text(statusDescription)
            .font(DesignSystem.Font.footnote)
            .foregroundStyle(DesignSystem.Color.secondary)
    }

    var statusDescription: String {
        switch lastWinner {
        case .none: "No gesture fired yet"
        case .first: "\(firstGesture.label) won (first priority)"
        case .second: "\(secondGesture.label) won (fallback)"
        }
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("First gesture (priority)", selection: $firstGesture)
        ShowcasePicker("Second gesture (fallback)", selection: $secondGesture)
        ShowcaseToggle("Enabled", isOn: $isEnabled)
    }

    @ViewBuilder
    func stateView(_ state: GestureState) -> some View {
        switch state {
        case .ready:
            staticCircle(fill: DesignSystem.Color.accent.opacity(0.5), label: "Interact")
        case .firstWon:
            staticCircle(fill: DesignSystem.Color.accent, label: "First!")
        case .secondWon:
            staticCircle(fill: Color.orange, label: "Second!")
        case .disabled:
            staticCircle(fill: DesignSystem.Color.secondary.opacity(0.3), label: "Interact")
                .disabled(true)
        }
    }

    func staticCircle(fill: Color, label: String) -> some View {
        Circle()
            .fill(fill)
            .frame(width: 100, height: 100)
            .overlay(
                Text(label)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.onAccent),
            )
    }
}

// MARK: - Code generation
private extension ExclusiveGestureShowcase {
    var generatedCode: String {
        let firstName = firstGesture.label
        let secondName = secondGesture.label
        let enabledStr = isEnabled ? "true" : "false"
        let lines: [String] = [
            "@State private var label = \"Idle\"",
            "",
            "Circle()",
            "    .fill(.blue)",
            "    .frame(width: 120, height: 120)",
            "    .overlay(Text(label).foregroundStyle(.white))",
            "    .gesture(",
            "        \(firstName)()",
            "            .exclusively(before: \(secondName)())",
            "            .onEnded { value in",
            "                switch value {",
            "                case .first: label = \"First\"",
            "                case .second: label = \"Second\"",
            "                }",
            "            }",
            "    )",
            "    .disabled(!\(enabledStr))",
        ]
        return lines.joined(separator: "\n")
    }
}

// MARK: - Gesture helpers
private extension View {
    func applyExclusiveGesture(
        first: ExclusiveGestureShowcase.FirstGestureKind,
        second: ExclusiveGestureShowcase.SecondGestureKind,
        isEnabled: Bool,
        onWinner: @escaping (ExclusiveGestureShowcase.Winner) -> Void,
    ) -> some View {
        self
            .modifier(
                ExclusiveGestureModifier(
                    first: first,
                    second: second,
                    isEnabled: isEnabled,
                    onWinner: onWinner,
                ),
            )
    }
}

// MARK: - ExclusiveGestureModifier
private struct ExclusiveGestureModifier: ViewModifier {
    let first: ExclusiveGestureShowcase.FirstGestureKind
    let second: ExclusiveGestureShowcase.SecondGestureKind
    let isEnabled: Bool
    let onWinner: (ExclusiveGestureShowcase.Winner) -> Void

    func body(content: Content) -> some View {
        content
#if os(tvOS)
            .gesture(tvExclusiveGesture)
#else
            .gesture(platformExclusiveGesture)
#endif
            .disabled(!isEnabled)
    }

#if os(tvOS)
    private var tvExclusiveGesture: some Gesture {
        TapGesture()
            .exclusively(before: LongPressGesture(minimumDuration: 0.5))
            .onEnded { value in
                switch value {
                case .first: onWinner(.first)
                case .second: onWinner(.second)
                }
            }
    }
#else
    private var platformExclusiveGesture: some Gesture {
        firstGestureValue
            .exclusively(before: secondGestureValue)
            .onEnded { value in
                switch value {
                case .first: onWinner(.first)
                case .second: onWinner(.second)
                }
            }
    }

    private var firstGestureValue: AnyGesture<Void> {
        switch first {
        case .drag:
            AnyGesture(DragGesture().map { _ in () })
        case .tap:
            AnyGesture(TapGesture().map { _ in () })
        case .longPress:
            AnyGesture(LongPressGesture().map { _ in () })
        }
    }

    private var secondGestureValue: AnyGesture<Void> {
        switch second {
        case .tap:
            AnyGesture(TapGesture().map { _ in () })
        case .longPress:
            AnyGesture(LongPressGesture().map { _ in () })
        case .magnify:
            AnyGesture(MagnifyGesture().map { _ in () })
        }
    }
#endif
}
