import SwiftUI

struct IgnoresSafeAreaShowcase: View {
    @State private var regions: RegionsOption = .all
    @State private var edges: EdgesOption = .all

    var body: some View {
        ShowcaseScreen(
            title: "Ignores Safe Area",
            summary: "Extends a view under safe-area regions (notch, home indicator, keyboard) on chosen edges.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension IgnoresSafeAreaShowcase {
    var preview: some View {
        ZStack {
            Color.accentColor
                .ignoresSafeArea(regions.safeAreaRegions, edges: edges.edgeSet)
                .opacity(0.25)
            VStack(spacing: DesignSystem.Spacing.small) {
                Image(systemName: "rectangle.expand.vertical")
                    .font(DesignSystem.Font.largeTitle)
                    .foregroundStyle(DesignSystem.Color.accent)
                Text("regions: .\(regions.label)")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
                Text("edges: .\(edges.label)")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Regions", selection: $regions)
        ShowcasePicker("Edges", selection: $edges)
    }

    @ViewBuilder func stateView(_ state: SafeAreaState) -> some View {
        ZStack {
            Color.accentColor
                .ignoresSafeArea(state.safeAreaRegions, edges: .all)
                .opacity(0.2)
            Text(state.caption)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.primary)
                .padding(DesignSystem.Spacing.small)
        }
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Code generation
private extension IgnoresSafeAreaShowcase {
    var generatedCode: String {
        "Color.accentColor\n    .ignoresSafeArea(.\(regions.label), edges: .\(edges.label))"
    }
}

// MARK: - Nested types
extension IgnoresSafeAreaShowcase {
    enum RegionsOption: ShowcasePickable {
        case all, container, keyboard

        var label: String {
            switch self {
            case .all: "all"
            case .container: "container"
            case .keyboard: "keyboard"
            }
        }

        var safeAreaRegions: SafeAreaRegions {
            switch self {
            case .all: .all
            case .container: .container
            case .keyboard: .keyboard
            }
        }
    }

    enum EdgesOption: ShowcasePickable {
        case all, horizontal, vertical, top, bottom, leading, trailing

        var label: String {
            switch self {
            case .all: "all"
            case .horizontal: "horizontal"
            case .vertical: "vertical"
            case .top: "top"
            case .bottom: "bottom"
            case .leading: "leading"
            case .trailing: "trailing"
            }
        }

        var edgeSet: Edge.Set {
            switch self {
            case .all: .all
            case .horizontal: .horizontal
            case .vertical: .vertical
            case .top: .top
            case .bottom: .bottom
            case .leading: .leading
            case .trailing: .trailing
            }
        }
    }

    enum SafeAreaState: ShowcaseState {
        case defaultState, containerOnly, keyboardOnly

        var caption: String {
            switch self {
            case .defaultState: "All regions"
            case .containerOnly: "Container"
            case .keyboardOnly: "Keyboard"
            }
        }

        var safeAreaRegions: SafeAreaRegions {
            switch self {
            case .defaultState: .all
            case .containerOnly: .container
            case .keyboardOnly: .keyboard
            }
        }
    }
}
