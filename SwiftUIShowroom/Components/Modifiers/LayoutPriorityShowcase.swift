import SwiftUI

struct LayoutPriorityShowcase: View {
    fileprivate enum ContentLengthState: ShowcaseState {
        case `default`
        case longContent
        var caption: String {
            switch self {
            case .default: "Default"
            case .longContent: "Long content"
            }
        }
    }

    @State private var priorityValue: Int = 0

    var body: some View {
        ShowcaseScreen(
            title: "Layout Priority",
            summary: "Sets the priority a view has when a stack divides limited space among children.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension LayoutPriorityShowcase {
    var preview: some View {
        priorityRow(priority: Double(priorityValue), isLong: false)
    }

    @ViewBuilder var controls: some View {
        ShowcaseStepper("Priority value", value: $priorityValue, in: -10...10)
    }

    @ViewBuilder func stateView(_ state: ContentLengthState) -> some View {
        priorityRow(priority: Double(priorityValue), isLong: state == .longContent)
    }

    func priorityRow(priority: Double, isLong: Bool) -> some View {
        let title = isLong
            ? "A very long title that competes for space in a tight HStack layout"
            : "Title"
        return HStack(spacing: DesignSystem.Spacing.small) {
            Text(title)
                .font(DesignSystem.Font.body)
                .layoutPriority(priority)
                .foregroundStyle(DesignSystem.Color.primary)
                .lineLimit(2)
            Text("Trailing")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.secondary)
                .lineLimit(1)
        }
        .padding(DesignSystem.Spacing.medium)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium),
        )
    }
}

// MARK: - Code generation
private extension LayoutPriorityShowcase {
    var generatedCode: String {
        let priorityLine = "        .layoutPriority(\(priorityValue))"
        return [
            "HStack {",
            "    Text(\"Title that wins space\")",
            priorityLine,
            "    Text(\"Trailing\")",
            "}",
        ].joined(separator: "\n")
    }
}
