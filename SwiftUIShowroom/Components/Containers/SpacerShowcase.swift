import SwiftUI

struct SpacerShowcase: View {
    @State private var useMinLength = false
    @State private var minLengthValue: Double = 20
    @State private var axis: AxisOption = .horizontal

    var body: some View {
        ShowcaseScreen(
            title: "Spacer",
            summary: "A flexible space that expands along the major axis of its containing stack.",
        ) {
            PreviewStage {
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
private extension SpacerShowcase {
    var preview: some View {
        Group {
            if axis == .horizontal {
                horizontalPreview
            } else {
                verticalPreview
            }
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var horizontalPreview: some View {
        HStack {
            pill(label: "Leading", systemImage: "arrow.left")
            Spacer(minLength: useMinLength ? minLengthValue : nil)
            pill(label: "Trailing", systemImage: "arrow.right")
        }
    }

    var verticalPreview: some View {
        VStack {
            pill(label: "Top", systemImage: "arrow.up")
            Spacer(minLength: useMinLength ? minLengthValue : nil)
            pill(label: "Bottom", systemImage: "arrow.down")
        }
        .frame(height: 160)
    }

    func stateLabel(_ text: String) -> some View {
        Text(text)
            .font(DesignSystem.Font.footnote)
            .padding(DesignSystem.Spacing.xSmall)
            .background(
                DesignSystem.Color.accent.opacity(0.2),
                in: .rect(cornerRadius: DesignSystem.CornerRadius.small)
            )
    }

    func pill(label: String, systemImage: String) -> some View {
        Label(label, systemImage: systemImage)
            .font(DesignSystem.Font.footnote)
            .padding(.horizontal, DesignSystem.Spacing.small)
            .padding(.vertical, DesignSystem.Spacing.xSmall)
            .background(DesignSystem.Color.cardBackground, in: .capsule)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Axis", selection: $axis)
        ShowcaseToggle("Custom minLength", isOn: $useMinLength)
        if useMinLength {
            ShowcaseSlider("Min length", value: $minLengthValue, in: 0...100, step: 1)
        }
    }

    @ViewBuilder
    func stateView(_ state: SpacerState) -> some View {
        switch state {
        case .default:
            HStack {
                stateLabel("A")
                Spacer()
                stateLabel("B")
            }
        case .minLength:
            HStack {
                stateLabel("A")
                Spacer(minLength: 60)
                stateLabel("B")
            }
        case .vertical:
            VStack {
                stateLabel("Top")
                Spacer()
                stateLabel("Bottom")
            }
            .frame(height: 100)
        }
    }
}

// MARK: - Code generation
private extension SpacerShowcase {
    var generatedCode: String {
        let stackType = axis == .horizontal ? "HStack" : "VStack"
        let leading = axis == .horizontal ? "Leading" : "Top"
        let trailing = axis == .horizontal ? "Trailing" : "Bottom"
        let spacerLine: String
        if useMinLength {
            let formatted = minLengthValue.formatted(.number.precision(.fractionLength(0...1)))
            spacerLine = "Spacer(minLength: \(formatted))"
        } else {
            spacerLine = "Spacer()"
        }
        return """
        \(stackType) {
            Text("\(leading)")
            \(spacerLine)
            Text("\(trailing)")
        }
        """
    }
}

// MARK: - Supporting types
extension SpacerShowcase {
    enum AxisOption: ShowcasePickable {
        case horizontal
        case vertical

        var label: String {
            switch self {
            case .horizontal: "horizontal"
            case .vertical: "vertical"
            }
        }
    }

    enum SpacerState: ShowcaseState {
        case `default`
        case minLength
        case vertical

        var caption: String {
            switch self {
            case .default: "Default (HStack)"
            case .minLength: "Min length = 60"
            case .vertical: "Vertical (VStack)"
            }
        }
    }
}
