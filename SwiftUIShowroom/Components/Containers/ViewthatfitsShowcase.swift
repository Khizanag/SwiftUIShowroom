import SwiftUI

struct ViewthatfitsShowcase: View {
    enum AxesOption: ShowcasePickable {
        case horizontal
        case vertical
        case both

        var label: String {
            switch self {
            case .horizontal: "horizontal"
            case .vertical: "vertical"
            case .both: "both"
            }
        }

        var axisSet: Axis.Set {
            switch self {
            case .horizontal: .horizontal
            case .vertical: .vertical
            case .both: [.horizontal, .vertical]
            }
        }

        var codeValue: String {
            switch self {
            case .horizontal: ".horizontal"
            case .vertical: ".vertical"
            case .both: "[.horizontal, .vertical]"
            }
        }
    }

    enum FitState: ShowcaseState {
        case `default`
        case longContent

        var caption: String {
            switch self {
            case .default: "Default (wide)"
            case .longContent: "Narrow (compact)"
            }
        }
    }

    @State private var axes: AxesOption = .both
    @State private var containerWidth: Double = 280

    var body: some View {
        ShowcaseScreen(
            title: "ViewThatFits",
            summary: "Picks the first child view that fits the available space along the specified axes.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}
// MARK: - Sub-views
private extension ViewthatfitsShowcase {
    var preview: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            widthSliderLabel
            adaptiveContainer
                .frame(width: containerWidth)
                .animation(.easeInOut(duration: 0.25), value: containerWidth)
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var widthSliderLabel: some View {
        Text("Container width: \(Int(containerWidth)) pt")
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.secondary)
    }

    var adaptiveContainer: some View {
        ViewThatFits(in: axes.axisSet) {
            fullLabel
            compactLabel
            iconOnly
        }
        .padding(DesignSystem.Spacing.small)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }

    var fullLabel: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "gear")
                .foregroundStyle(DesignSystem.Color.accent)
            Text("Open Settings")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.primary)
            Spacer()
        }
    }

    var compactLabel: some View {
        Label("Settings", systemImage: "gear")
            .font(DesignSystem.Font.body)
            .foregroundStyle(DesignSystem.Color.primary)
    }

    var iconOnly: some View {
        Image(systemName: "gear")
            .font(DesignSystem.Font.body)
            .foregroundStyle(DesignSystem.Color.accent)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Axes", selection: $axes)
        ShowcaseSlider("Container width", value: $containerWidth, in: 40...340, step: 1)
    }

    @ViewBuilder
    func stateView(_ state: FitState) -> some View {
        switch state {
        case .default:
            wideFitExample
        case .longContent:
            narrowFitExample
        }
    }

    var wideFitExample: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: DesignSystem.Spacing.small) {
                Image(systemName: "bell.fill")
                    .foregroundStyle(DesignSystem.Color.accent)
                Text("Notifications")
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.primary)
                Spacer()
            }
            Label("Notifications", systemImage: "bell.fill")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.primary)
            Image(systemName: "bell.fill")
                .foregroundStyle(DesignSystem.Color.accent)
        }
        .padding(DesignSystem.Spacing.small)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
        .frame(width: 260)
    }

    var narrowFitExample: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: DesignSystem.Spacing.small) {
                Image(systemName: "bell.fill")
                    .foregroundStyle(DesignSystem.Color.accent)
                Text("Notifications")
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.primary)
                Spacer()
            }
            Label("Notifications", systemImage: "bell.fill")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.primary)
            Image(systemName: "bell.fill")
                .foregroundStyle(DesignSystem.Color.accent)
        }
        .padding(DesignSystem.Spacing.small)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
        .frame(width: 60)
    }
}
// MARK: - Code generation
private extension ViewthatfitsShowcase {
    var generatedCode: String {
        """
        ViewThatFits(in: \(axes.codeValue)) {
            HStack { Label("Settings", systemImage: "gear"); Spacer() }
            Image(systemName: "gear")
        }
        """
    }
}
