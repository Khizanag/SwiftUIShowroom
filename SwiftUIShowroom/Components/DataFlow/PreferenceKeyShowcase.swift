import SwiftUI

struct PreferenceKeyShowcase: View {
    @State private var reduceStrategy: ReduceStrategyOption = .max
    @State private var itemCount = 3
    @State private var reportedValue: CGFloat = 0

    var body: some View {
        ShowcaseScreen(
            title: "PreferenceKey",
            summary: "A protocol defining a typed value that flows up the view tree with a reduce strategy.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension PreferenceKeyShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            childStack
            readoutCard
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var childStack: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            ForEach(childItems, id: \.self) { item in
                childRow(item)
            }
        }
        .onPreferenceChange(DemoWidthKey.self) { @MainActor value in
            reportedValue = value
        }
    }

    func childRow(_ item: DemoItem) -> some View {
        Text(item.label)
            .font(DesignSystem.Font.body)
            .foregroundStyle(DesignSystem.Color.primary)
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .padding(.vertical, DesignSystem.Spacing.xSmall)
            .background(
                DesignSystem.Color.cardBackground,
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
            )
            .background(
                GeometryReader { geo in
                    Color.clear.preference(key: DemoWidthKey.self, value: geo.size.width)
                }
            )
    }

    var readoutCard: some View {
        HStack {
            Image(systemName: "arrow.up.to.line")
                .foregroundStyle(DesignSystem.Color.accent)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.hairline) {
                Text("Reported to parent")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
                Text("\(reduceStrategy.readoutLabel): \(reportedValue, specifier: "%.1f") pt")
                    .font(DesignSystem.Font.codeInline)
                    .foregroundStyle(DesignSystem.Color.primary)
            }
            Spacer()
        }
        .padding(DesignSystem.Spacing.small)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Reduce strategy", selection: $reduceStrategy)
        ShowcaseStepper("Child item count", value: $itemCount, in: 0...6)
    }

    @ViewBuilder
    func stateView(_ state: PreferenceKeyDemoState) -> some View {
        switch state {
        case .default:
            defaultStateView
        case .empty:
            emptyStateView
        }
    }

    var defaultStateView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("Children report values upward")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            Group {
                Text("struct WidthKey: PreferenceKey {")
                Text("    static let defaultValue: CGFloat = 0")
                Text("    static func reduce(value: inout CGFloat,")
                Text("        nextValue: () -> CGFloat) {")
                Text("        value = max(value, nextValue())")
                Text("    }")
                Text("}")
            }
            .font(DesignSystem.Font.codeInline)
            .foregroundStyle(DesignSystem.Color.primary)
        }
        .padding(DesignSystem.Spacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var emptyStateView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("No children — defaultValue propagates")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            HStack {
                Image(systemName: "tray")
                    .foregroundStyle(DesignSystem.Color.secondary)
                Text("defaultValue: 0")
                    .font(DesignSystem.Font.codeInline)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
        .padding(DesignSystem.Spacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Code generation
private extension PreferenceKeyShowcase {
    var generatedCode: String {
        let strategyBody = reduceStrategy.reduceBody
        return [
            "struct WidthKey: PreferenceKey {",
            "    static let defaultValue: CGFloat = 0",
            "    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {",
            "        \(strategyBody)",
            "    }",
            "}",
            "",
            "// Set in a child:",
            "// Text(\"Item\")",
            "//     .background(GeometryReader { geo in",
            "//         Color.clear.preference(key: WidthKey.self, value: geo.size.width)",
            "//     })",
            "",
            "// Read in the parent:",
            "// containerView",
            "//     .onPreferenceChange(WidthKey.self) { newWidth in",
            "//         maxWidth = newWidth",
            "//     }",
        ].joined(separator: "\n")
    }
}

// MARK: - Helpers
private extension PreferenceKeyShowcase {
    var childItems: [DemoItem] {
        let all: [DemoItem] = [
            DemoItem(label: "Short"),
            DemoItem(label: "Medium length"),
            DemoItem(label: "A longer label text"),
            DemoItem(label: "Tiny"),
            DemoItem(label: "The widest item in the list"),
            DemoItem(label: "Mid"),
        ]
        return Array(all.prefix(itemCount))
    }
}

// MARK: - Nested types
extension PreferenceKeyShowcase {
    fileprivate struct DemoItem: Hashable {
        let label: String
    }

    fileprivate enum ReduceStrategyOption: ShowcasePickable {
        case takeLast
        case max
        case min
        case sum
        case first

        var label: String {
            switch self {
            case .takeLast: "takeLast"
            case .max: "max"
            case .min: "min"
            case .sum: "sum"
            case .first: "first"
            }
        }

        var readoutLabel: String {
            switch self {
            case .takeLast: "last"
            case .max: "max"
            case .min: "min"
            case .sum: "sum"
            case .first: "first"
            }
        }

        var reduceBody: String {
            switch self {
            case .takeLast: "value = nextValue()"
            case .max: "value = max(value, nextValue())"
            case .min: "value = min(value, nextValue())"
            case .sum: "value += nextValue()"
            case .first: "_ = nextValue()"
            }
        }
    }

    fileprivate enum PreferenceKeyDemoState: ShowcaseState {
        case `default`
        case empty

        var caption: String {
            switch self {
            case .default: "Default"
            case .empty: "Empty (no children)"
            }
        }
    }
}

// MARK: - PreferenceKey definition
private struct DemoWidthKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
