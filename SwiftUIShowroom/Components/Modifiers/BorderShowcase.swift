import SwiftUI

struct BorderShowcase: View {
    enum BorderState: ShowcaseState {
        case defaultState
        case focused
        case thick
        case subtle

        var caption: String {
            switch self {
            case .defaultState: "Default (1 pt)"
            case .focused: "Focused (2 pt)"
            case .thick: "Thick (6 pt)"
            case .subtle: "Subtle (0.5 pt)"
            }
        }

        var color: Color {
            switch self {
            case .defaultState: .accentColor
            case .focused: .accentColor
            case .thick: .accentColor
            case .subtle: Color(white: 0.5)
            }
        }

        var lineWidth: CGFloat {
            switch self {
            case .defaultState: 1
            case .focused: 2
            case .thick: 6
            case .subtle: 0.5
            }
        }
    }

    @State private var borderColor: Color = .accentColor
    @State private var width: Double = 1

    var body: some View {
        ShowcaseScreen(
            title: "Border",
            summary: "Draws a rectangular border of the given style and width along the view's edges.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension BorderShowcase {
    var preview: some View {
        borderedSwatch(color: borderColor, lineWidth: CGFloat(width))
    }

    @ViewBuilder var controls: some View {
        ShowcaseColorControl("Color", selection: $borderColor)
        ShowcaseSlider("Width", value: $width, in: 0...12, step: 0.5)
    }

    @ViewBuilder func stateView(_ state: BorderState) -> some View {
        borderedSwatch(color: state.color, lineWidth: state.lineWidth)
    }

    func borderedSwatch(color: Color, lineWidth: CGFloat) -> some View {
        Text("Bordered")
            .font(DesignSystem.Font.body)
            .foregroundStyle(DesignSystem.Color.primary)
            .padding(DesignSystem.Spacing.medium)
            .border(color, width: lineWidth)
    }
}

// MARK: - Code generation
private extension BorderShowcase {
    var generatedCode: String {
        let widthFormatted = width.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(width))
            : String(format: "%.1f", width)
        return "Text(\"Bordered\")\n    .padding()\n    .border(color, width: \(widthFormatted))"
    }
}
