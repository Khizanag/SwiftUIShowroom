import SwiftUI

struct ToolbarSpacerShowcase: View {
    enum SpacerSizingOption: String, ShowcasePickable, CaseIterable {
        case fixed
        case flexible

        var label: String {
            switch self {
            case .fixed: return "Fixed"
            case .flexible: return "Flexible"
            }
        }

        var id: String { rawValue }
    }

    enum SpacerState: String, ShowcaseState, CaseIterable {
        case fixed
        case flexible

        var caption: String {
            switch self {
            case .fixed: return "Fixed spacing"
            case .flexible: return "Flexible spacing"
            }
        }

        var id: String { rawValue }
    }

    @State private var sizing: SpacerSizingOption = .fixed

    var body: some View {
        ShowcaseScreen(
            title: "ToolbarSpacer",
            summary: "Inserts fixed or flexible space between toolbar items to separate glass item groups."
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ToolbarSpacerShowcase {
    var preview: some View {
        NavigationStack {
            Text("Content")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("ToolbarSpacer")
                .toolbar {
                    toolbarLeading
                    toolbarSpacer(sizingOption: sizing)
                    toolbarTrailing
                }
        }
        .frame(height: 120)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ToolbarContentBuilder var toolbarLeading: some ToolbarContent {
#if os(iOS)
        ToolbarItem(placement: .topBarLeading) {
            Button("Tag") {}
        }
#else
        ToolbarItem(placement: .automatic) {
            Button("Tag") {}
        }
#endif
    }

    @ToolbarContentBuilder var toolbarTrailing: some ToolbarContent {
#if os(iOS)
        ToolbarItem(placement: .topBarTrailing) {
            Button("More") {}
        }
#else
        ToolbarItem(placement: .automatic) {
            Button("More") {}
        }
#endif
    }

    @ToolbarContentBuilder
    func toolbarSpacer(sizingOption: SpacerSizingOption) -> some ToolbarContent {
#if !os(tvOS)
        switch sizingOption {
        case .fixed:
            ToolbarSpacer(.fixed)
        case .flexible:
            ToolbarSpacer(.flexible)
        }
#endif
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Sizing", selection: $sizing)
    }

    @ViewBuilder
    func stateView(_ state: SpacerState) -> some View {
        let option: SpacerSizingOption = state == .fixed ? .fixed : .flexible
        NavigationStack {
            Text("Content")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("Spacer")
                .toolbar {
                    toolbarLeading
                    toolbarSpacer(sizingOption: option)
                    toolbarTrailing
                }
        }
        .frame(height: 100)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Code generation
private extension ToolbarSpacerShowcase {
    var generatedCode: String {
        """
        Text("Content")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Tag") {} }
                ToolbarSpacer(.\(sizing.rawValue))
                ToolbarItem(placement: .topBarTrailing) { Button("More") {} }
            }
        """
    }
}
