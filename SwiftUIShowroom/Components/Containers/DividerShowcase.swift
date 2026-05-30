import SwiftUI

struct DividerShowcase: View {
    enum DividerState: ShowcaseState {
        case horizontal
        case vertical
        case tinted

        var caption: String {
            switch self {
            case .horizontal: "Horizontal (VStack)"
            case .vertical: "Vertical (HStack)"
            case .tinted: "Custom tint"
            }
        }
    }

    @State private var useTint = false
    @State private var tintColor: Color = .accentColor

    var body: some View {
        ShowcaseScreen(
            title: "Divider",
            summary: "A visual line that separates content; horizontal in VStack, vertical in HStack.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension DividerShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            contentRow(label: "Above")
            dividerView
            contentRow(label: "Below")
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var dividerView: some View {
        Group {
            if useTint {
                Divider().overlay(tintColor)
            } else {
                Divider()
            }
        }
    }

    func contentRow(label: String) -> some View {
        Text(label)
            .font(DesignSystem.Font.body)
            .foregroundStyle(DesignSystem.Color.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DesignSystem.Spacing.small)
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseToggle("Custom tint", isOn: $useTint)
        if useTint {
            ShowcaseColorControl("Tint color", selection: $tintColor, supportsOpacity: false)
        }
    }

    @ViewBuilder
    func stateView(_ state: DividerState) -> some View {
        switch state {
        case .horizontal:
            horizontalState
        case .vertical:
            verticalState
        case .tinted:
            tintedState
        }
    }

    var horizontalState: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Text("Above")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
            Divider()
            Text("Below")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(.horizontal, DesignSystem.Spacing.small)
    }

    var verticalState: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Text("Left")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
            Divider()
                .frame(height: 24)
            Text("Right")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }

    var tintedState: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Text("Above")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
            Divider()
                .overlay(DesignSystem.Color.accent)
            Text("Below")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(.horizontal, DesignSystem.Spacing.small)
    }
}

// MARK: - Code generation
private extension DividerShowcase {
    var generatedCode: String {
        if useTint {
            return """
            VStack {
                Text("Above")
                Divider()
                    .overlay(Color.accentColor)
                Text("Below")
            }
            """
        } else {
            return """
            VStack {
                Text("Above")
                Divider()
                Text("Below")
            }
            """
        }
    }
}
