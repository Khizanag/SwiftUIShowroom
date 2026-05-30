import SwiftUI

struct PreferenceModifierShowcase: View {
    enum ReduceOption: ShowcasePickable {
        case max, sum, takeLast

        var label: String {
            switch self {
            case .max: "max"
            case .sum: "sum"
            case .takeLast: "takeLast"
            }
        }

        var description: String {
            switch self {
            case .max: "value = max(value, nextValue())"
            case .sum: "value += nextValue()"
            case .takeLast: "value = nextValue()"
            }
        }
    }

    enum DemoState: ShowcaseState {
        case singleChild, multipleChildren, nestedBackground

        var caption: String {
            switch self {
            case .singleChild: "Single child"
            case .multipleChildren: "Multiple children"
            case .nestedBackground: "GeometryReader background"
            }
        }
    }

    @State private var itemCount: Int = 3
    @State private var reduceStrategy: ReduceOption = .max
    @State private var useBackground = true
    @State private var reportedWidth: CGFloat = 0

    var body: some View {
        ShowcaseScreen(
            title: ".preference(key:value:)",
            summary: "Sets a PreferenceKey value on a view, contributing it upward to ancestor readers.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Preference key
private struct MaxWidthKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - Sub-views
private extension PreferenceModifierShowcase {
    var preview: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            reportedWidthBadge
            itemStack
                .onPreferenceChange(MaxWidthKey.self) { reportedWidth = $0 }
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var reportedWidthBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: "arrow.up.to.line")
                .foregroundStyle(DesignSystem.Color.accent)
                .imageScale(.small)
            Text("Max reported width: \(Int(reportedWidth)) pt")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }

    var itemStack: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            ForEach(0..<itemCount, id: \.self) { index in
                preferenceItem(index: index)
            }
        }
    }

    func preferenceItem(index: Int) -> some View {
        let labels = ["Short", "A medium label", "A significantly longer label"]
        let label = index < labels.count ? labels[index] : "Item \(index + 1)"
        return Text(label)
            .font(DesignSystem.Font.body)
            .foregroundStyle(DesignSystem.Color.primary)
            .padding(.horizontal, DesignSystem.Spacing.small)
            .padding(.vertical, DesignSystem.Spacing.xSmall)
            .background(
                GeometryReader { geo in
                    DesignSystem.Color.cardBackground
                        .preference(key: MaxWidthKey.self, value: geo.size.width)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseStepper("Item count", value: $itemCount, in: 1...5)
        ShowcasePicker("Reduce strategy", selection: $reduceStrategy)
        ShowcaseToggle("Measure via background", isOn: $useBackground)
    }

    @ViewBuilder
    func stateView(_ state: DemoState) -> some View {
        switch state {
        case .singleChild:
            singleChildDemo
        case .multipleChildren:
            multipleChildrenDemo
        case .nestedBackground:
            nestedBackgroundDemo
        }
    }

    var singleChildDemo: some View {
        demoCard(label: "Single child sets preference") {
            Text("Hello")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.primary)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: MaxWidthKey.self, value: geo.size.width)
                    }
                )
        }
    }

    var multipleChildrenDemo: some View {
        demoCard(label: "Multiple children — reduce: max") {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                styledRow("Short")
                styledRow("A longer row")
                styledRow("Longest row here")
            }
        }
    }

    var nestedBackgroundDemo: some View {
        demoCard(label: "Color.clear in GeometryReader") {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                Text("Color.clear")
                    .font(DesignSystem.Font.codeInline)
                    .foregroundStyle(DesignSystem.Color.secondary)
                Text("  .preference(key: WidthKey.self,")
                    .font(DesignSystem.Font.codeInline)
                    .foregroundStyle(DesignSystem.Color.primary)
                Text("  value: geo.size.width)")
                    .font(DesignSystem.Font.codeInline)
                    .foregroundStyle(DesignSystem.Color.primary)
            }
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    func styledRow(_ text: String) -> some View {
        Text(text)
            .font(DesignSystem.Font.footnote)
            .foregroundStyle(DesignSystem.Color.primary)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(key: MaxWidthKey.self, value: geo.size.width)
                }
            )
    }
}

// MARK: - Code generation
private extension PreferenceModifierShowcase {
    var generatedCode: String {
        let reduceBody = reduceStrategy.description
        var lines: [String] = []
        lines.append("struct WidthKey: PreferenceKey {")
        lines.append("    static let defaultValue: CGFloat = 0")
        lines.append("    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {")
        lines.append("        \(reduceBody)")
        lines.append("    }")
        lines.append("}")
        lines.append("")
        lines.append("struct ContentView: View {")
        lines.append("    @State private var maxWidth: CGFloat = 0")
        lines.append("")
        lines.append("    var body: some View {")
        lines.append("        VStack {")
        lines.append("            ForEach(items) { item in")
        lines.append("                Text(item.label)")
        if useBackground {
            lines.append("                    .background(")
            lines.append("                        GeometryReader { geo in")
            lines.append("                            Color.clear")
            lines.append("                                .preference(key: WidthKey.self, value: geo.size.width)")
            lines.append("                        }")
            lines.append("                    )")
        } else {
            lines.append("                    .preference(key: WidthKey.self, value: measuredWidth)")
        }
        lines.append("            }")
        lines.append("        }")
        lines.append("        .onPreferenceChange(WidthKey.self) { maxWidth = $0 }")
        lines.append("    }")
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}
