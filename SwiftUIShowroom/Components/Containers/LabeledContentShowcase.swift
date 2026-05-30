import SwiftUI

struct LabeledContentShowcase: View {
    enum ContentState: ShowcaseState {
        case `default`, longContent
        var caption: String {
            switch self {
            case .default: "Default"
            case .longContent: "Long content"
            }
        }
    }

    @State private var labelText = "Label"
    @State private var valueText = "Value"
    @State private var labelHidden = false

    var body: some View {
        ShowcaseScreen(
            title: "LabeledContent",
            summary: "Pairs a label with a value view, styled consistently inside Forms and Lists.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension LabeledContentShowcase {
    var preview: some View {
        Form {
            labeledRow(label: labelText, value: valueText, hidden: labelHidden)
        }
        .frame(maxWidth: 480)
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Label", text: $labelText)
        ShowcaseTextControl("Value", text: $valueText)
        ShowcaseToggle("Hide label (.labelsHidden)", isOn: $labelHidden)
    }

    @ViewBuilder
    func stateView(_ state: ContentState) -> some View {
        switch state {
        case .default:
            Form {
                labeledRow(label: "Version", value: "1.0.0", hidden: false)
            }
            .frame(maxWidth: 300)
        case .longContent:
            Form {
                labeledRow(
                    label: "A very long descriptive label that wraps",
                    value: "A long value string that may also wrap on narrow screens",
                    hidden: false
                )
            }
            .frame(maxWidth: 300)
        }
    }

    @ViewBuilder
    func labeledRow(label: String, value: String, hidden: Bool) -> some View {
        if hidden {
            LabeledContent(label, value: value)
                .labelsHidden()
        } else {
            LabeledContent(label, value: value)
        }
    }
}

// MARK: - Code generation
private extension LabeledContentShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("LabeledContent(\"\(labelText)\", value: \"\(valueText)\")")
        if labelHidden {
            lines.append("    .labelsHidden()")
        }
        return lines.joined(separator: "\n")
    }
}
