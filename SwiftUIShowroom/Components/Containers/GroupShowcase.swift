import SwiftUI

struct GroupShowcase: View {
    @State private var sharedFontStyle: FontStyleOption = .headline
    @State private var sharedOpacity: Double = 1.0
    @State private var tintColor: Color = .accentColor
    @State private var showConditional: Bool = true

    var body: some View {
        ShowcaseScreen(
            title: "Group",
            summary: "A transparent container that applies shared modifiers and removes the ten-child limit.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension GroupShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            Group {
                Text("One")
                Text("Two")
                Text("Three")
            }
            .font(sharedFontStyle.value)
            .foregroundStyle(tintColor)
            .opacity(sharedOpacity)
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Font style", selection: $sharedFontStyle)
        ShowcaseSlider("Opacity", value: $sharedOpacity, in: 0.1...1.0, step: 0.05)
        ShowcaseColorControl("Tint", selection: $tintColor)
        ShowcaseToggle("Show conditional member", isOn: $showConditional)
    }

    @ViewBuilder
    func stateView(_ state: GroupDemoState) -> some View {
        switch state {
        case .sharedModifier:
            sharedModifierDemo
        case .tenChildLimit:
            tenChildLimitDemo
        case .conditionalContent:
            conditionalContentDemo
        }
    }

    var sharedModifierDemo: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Group {
                Text("Alpha")
                Text("Beta")
                Text("Gamma")
            }
            .font(DesignSystem.Font.headline)
            .foregroundStyle(DesignSystem.Color.accent)
        }
    }

    var tenChildLimitDemo: some View {
        VStack(spacing: DesignSystem.Spacing.xSmall) {
            Group {
                Text("Item 1")
                Text("Item 2")
                Text("Item 3")
                Text("Item 4")
                Text("Item 5")
                Text("Item 6")
                Text("Item 7")
                Text("Item 8")
                Text("Item 9")
                Text("Item 10")
                Text("Item 11")
            }
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.secondary)
        }
    }

    var conditionalContentDemo: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Group {
                Text("Always visible")
                if showConditional {
                    Text("Conditional member")
                        .foregroundStyle(DesignSystem.Color.accent)
                }
            }
            .font(DesignSystem.Font.body)
        }
    }
}

// MARK: - Code generation
private extension GroupShowcase {
    var generatedCode: String {
        let fontLine = "    .font(.\(sharedFontStyle.label))"
        let opacityLine = sharedOpacity < 1.0
            ? "\n    .opacity(\(String(format: "%.2f", sharedOpacity)))"
            : ""
        return """
        Group {
            Text("One")
            Text("Two")
            Text("Three")
        }
        \(fontLine)\(opacityLine)
        .foregroundStyle(.accent)
        """
    }
}

// MARK: - Nested types
extension GroupShowcase {
    enum FontStyleOption: ShowcasePickable {
        case largeTitle
        case title
        case headline
        case body
        case caption

        var label: String {
            switch self {
            case .largeTitle: "largeTitle"
            case .title: "title"
            case .headline: "headline"
            case .body: "body"
            case .caption: "caption"
            }
        }

        var value: Font {
            switch self {
            case .largeTitle: DesignSystem.Font.largeTitle
            case .title: DesignSystem.Font.title
            case .headline: DesignSystem.Font.headline
            case .body: DesignSystem.Font.body
            case .caption: DesignSystem.Font.caption
            }
        }
    }

    enum GroupDemoState: ShowcaseState {
        case sharedModifier
        case tenChildLimit
        case conditionalContent

        var caption: String {
            switch self {
            case .sharedModifier: "Shared modifier"
            case .tenChildLimit: "10+ children"
            case .conditionalContent: "Conditional content"
            }
        }
    }
}
