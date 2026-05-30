import SwiftUI

struct StateObjectShowcase: View {
    fileprivate enum DemoState: ShowcaseState {
        case normal
        case loading

        var caption: String {
            switch self {
            case .normal: "Default"
            case .loading: "Loading"
            }
        }
    }

    @State private var showsPublishedDriver = true
    @State private var demoTitle = "Hello"
    @State private var demoCount = 0
    @State private var isLoading = false

    var body: some View {
        ShowcaseScreen(
            title: "@StateObject (legacy)",
            summary: "Owns an ObservableObject for a view's lifetime — the pre-Observation reference model.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension StateObjectShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            modelCard
            if showsPublishedDriver {
                publishedBadge
            }
        }
    }

    var modelCard: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Text("@StateObject ViewModel")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            Text(demoTitle)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.primary)
            HStack(spacing: DesignSystem.Spacing.small) {
                Button {
                    demoCount -= 1
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(DesignSystem.Font.title2)
                }
                .buttonStyle(.plain)
                .foregroundStyle(DesignSystem.Color.accent)
                Text("\(demoCount)")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.primary)
                    .monospacedDigit()
                    .frame(minWidth: 40)
                Button {
                    demoCount += 1
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(DesignSystem.Font.title2)
                }
                .buttonStyle(.plain)
                .foregroundStyle(DesignSystem.Color.accent)
            }
        }
        .padding(DesignSystem.Spacing.large)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium),
        )
    }

    var publishedBadge: some View {
        Text("@Published triggers re-render")
            .font(DesignSystem.Font.codeInline)
            .foregroundStyle(DesignSystem.Color.secondary)
            .padding(.horizontal, DesignSystem.Spacing.small)
            .padding(.vertical, DesignSystem.Spacing.xSmall)
            .background(
                DesignSystem.Color.cardBackground,
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small),
            )
    }

    @ViewBuilder var controls: some View {
        ShowcaseTextControl("ViewModel title", text: $demoTitle, prompt: "Hello")
        ShowcaseStepper("Count", value: $demoCount, in: -99...99)
        ShowcaseToggle("Show @Published driver note", isOn: $showsPublishedDriver)
        ShowcaseToggle("Simulate loading", isOn: $isLoading)
    }

    @ViewBuilder func stateView(_ state: DemoState) -> some View {
        switch state {
        case .normal:
            stateCard(
                icon: "checkmark.circle.fill",
                iconColor: .green,
                label: "model.title",
                value: "\"Hello\"",
            )
        case .loading:
            VStack(spacing: DesignSystem.Spacing.xSmall) {
                ProgressView()
                Text("Loading…")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
            .padding(DesignSystem.Spacing.medium)
        }
    }

    func stateCard(
        icon: String,
        iconColor: Color,
        label: String,
        value: String
    ) -> some View {
        VStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .font(DesignSystem.Font.title2)
            Text("\(label): \(value)")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.primary)
        }
        .padding(DesignSystem.Spacing.medium)
    }
}

// MARK: - Code generation
private extension StateObjectShowcase {
    var generatedCode: String {
        let titleValue = demoTitle.isEmpty ? "Hello" : demoTitle
        var lines: [String] = []
        lines.append("final class ViewModel: ObservableObject {")
        if showsPublishedDriver {
            lines.append("    @Published var title: String = \"\(titleValue)\"")
            lines.append("    @Published var count: Int = \(demoCount)")
        } else {
            lines.append("    var title: String = \"\(titleValue)\"")
            lines.append("    var count: Int = \(demoCount)")
        }
        lines.append("}")
        lines.append("")
        lines.append("struct StateObjectDemo: View {")
        lines.append("    @StateObject private var model = ViewModel()")
        lines.append("")
        lines.append("    var body: some View {")
        lines.append("        Text(model.title)")
        lines.append("    }")
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}
