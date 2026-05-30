import SwiftUI

struct TransformEnvironmentShowcase: View {
    @State private var keyPathOption: KeyPathOption = .lineSpacing
    @State private var lineSpacingDelta: Double = 8
    @State private var applyTransform = true

    var body: some View {
        ShowcaseScreen(
            title: ".transformEnvironment(_:transform:)",
            summary: "Mutates an inherited environment value in place for a subtree.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension TransformEnvironmentShowcase {
    fileprivate enum KeyPathOption: ShowcasePickable {
        case lineSpacing, dynamicTypeSize, font

        var label: String {
            switch self {
            case .lineSpacing: "\\.lineSpacing"
            case .dynamicTypeSize: "\\.dynamicTypeSize"
            case .font: "\\.font"
            }
        }

        var keyPathString: String {
            switch self {
            case .lineSpacing: "\\.lineSpacing"
            case .dynamicTypeSize: "\\.dynamicTypeSize"
            case .font: "\\.font"
            }
        }
    }

    fileprivate enum DemoState: ShowcaseState {
        case withTransform, withoutTransform, nested

        var caption: String {
            switch self {
            case .withTransform: "With transform"
            case .withoutTransform: "No transform"
            case .nested: "Nested transforms"
            }
        }
    }
}

// MARK: - Sub-views
private extension TransformEnvironmentShowcase {
    var preview: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("Outer environment (baseline)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            sampleText
                .transformEnvironment(\.lineSpacing) { spacing in
                    if applyTransform {
                        spacing += lineSpacingDelta
                    }
                }
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var sampleText: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("Line one of sample text")
                .font(DesignSystem.Font.body)
            Text("Line two of sample text")
                .font(DesignSystem.Font.body)
            Text("Line three of sample text")
                .font(DesignSystem.Font.body)
        }
        .foregroundStyle(DesignSystem.Color.primary)
        .padding(DesignSystem.Spacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Key path", selection: $keyPathOption)
        ShowcaseToggle("Apply transform", isOn: $applyTransform)
        ShowcaseSlider(
            "Line spacing delta",
            value: $lineSpacingDelta,
            in: 0...32,
            step: 2,
        )
    }

    @ViewBuilder
    func stateView(_ state: DemoState) -> some View {
        switch state {
        case .withTransform:
            withTransformDemo
        case .withoutTransform:
            withoutTransformDemo
        case .nested:
            nestedDemo
        }
    }

    var withTransformDemo: some View {
        demoCard(label: "lineSpacing += 10") {
            sampleLines
                .transformEnvironment(\.lineSpacing) { $0 += 10 }
        }
    }

    var withoutTransformDemo: some View {
        demoCard(label: "no transform") {
            sampleLines
        }
    }

    var nestedDemo: some View {
        demoCard(label: "+=6, then +=6") {
            sampleLines
                .transformEnvironment(\.lineSpacing) { $0 += 6 }
                .transformEnvironment(\.lineSpacing) { $0 += 6 }
        }
    }

    func demoCard(label: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text(label)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.secondary)
            content()
        }
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    var sampleLines: some View {
        VStack(alignment: .leading) {
            Text("First line")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.primary)
            Text("Second line")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.primary)
            Text("Third line")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.primary)
        }
    }
}

// MARK: - Code generation
private extension TransformEnvironmentShowcase {
    var generatedCode: String {
        let keyPathRef = keyPathOption.keyPathString
        let body = transformBodySnippet
        var lines: [String] = []
        lines.append("VStack { childViews }")
        lines.append("    .transformEnvironment(\(keyPathRef)) { value in")
        lines.append("        \(body)")
        lines.append("    }")
        return lines.joined(separator: "\n")
    }

    var transformBodySnippet: String {
        switch keyPathOption {
        case .lineSpacing:
            let delta = Int(lineSpacingDelta)
            return "value += \(delta)"
        case .dynamicTypeSize:
            return "if value < .accessibility1 { value = .xLarge }"
        case .font:
            return "value = (value ?? .body).bold()"
        }
    }
}
