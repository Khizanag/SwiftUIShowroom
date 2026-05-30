import SwiftUI

struct ToolbarItemGroupShowcase: View {
    @State private var placement: PlacementOption = .topBarTrailing
    @State private var itemCount = 3
    @State private var itemsDisabled = false

    var body: some View {
        ShowcaseScreen(
            title: "ToolbarItemGroup",
            summary: "Groups multiple controls under one placement so they lay out and overflow together.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension ToolbarItemGroupShowcase {
    enum PlacementOption: ShowcasePickable {
        case automatic
        case primaryAction
        case topBarLeading
        case topBarTrailing
        case bottomBar
        case navigation

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .primaryAction: "primaryAction"
            case .topBarLeading: "topBarLeading"
            case .topBarTrailing: "topBarTrailing"
            case .bottomBar: "bottomBar"
            case .navigation: "navigation"
            }
        }

        var toolbarPlacement: ToolbarItemPlacement {
            switch self {
            case .automatic: .automatic
            case .primaryAction: .primaryAction
            #if os(tvOS)
            case .topBarLeading, .topBarTrailing, .bottomBar, .navigation: .automatic
            #else
            case .topBarLeading: .topBarLeading
            case .topBarTrailing: .topBarTrailing
            case .bottomBar: .bottomBar
            case .navigation: .navigation
            #endif
            }
        }
    }

    enum GroupState: ShowcaseState {
        case defaultState
        case disabled

        var caption: String {
            switch self {
            case .defaultState: "Default (enabled)"
            case .disabled: "Disabled"
            }
        }
    }
}

// MARK: - Sub-views
private extension ToolbarItemGroupShowcase {
    var preview: some View {
        groupDemo(
            placement: placement,
            count: itemCount,
            isDisabled: itemsDisabled,
        )
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Placement", selection: $placement)
        ShowcaseStepper("Item count", value: $itemCount, in: 2...5)
        ShowcaseToggle("Disabled", isOn: $itemsDisabled)
    }

    @ViewBuilder
    func stateView(_ state: GroupState) -> some View {
        switch state {
        case .defaultState:
            groupDemo(placement: .topBarTrailing, count: 3, isDisabled: false)
        case .disabled:
            groupDemo(placement: .topBarTrailing, count: 3, isDisabled: true)
        }
    }

    func groupDemo(
        placement: PlacementOption,
        count: Int,
        isDisabled: Bool,
    ) -> some View {
        NavigationStack {
            Text("Content")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("Toolbar")
                .toolbar {
                    toolbarGroupContent(
                        placement: placement,
                        count: count,
                        isDisabled: isDisabled,
                    )
                }
        }
        .frame(maxWidth: 320, minHeight: 220)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ToolbarContentBuilder
    func toolbarGroupContent(
        placement: PlacementOption,
        count: Int,
        isDisabled: Bool,
    ) -> some ToolbarContent {
        ToolbarItemGroup(placement: placement.toolbarPlacement) {
            if count >= 1 {
                Button { } label: { Image(systemName: "bold") }
                    .disabled(isDisabled)
            }
            if count >= 2 {
                Button { } label: { Image(systemName: "italic") }
                    .disabled(isDisabled)
            }
            if count >= 3 {
                Button { } label: { Image(systemName: "underline") }
                    .disabled(isDisabled)
            }
            if count >= 4 {
                Button { } label: { Image(systemName: "strikethrough") }
                    .disabled(isDisabled)
            }
            if count >= 5 {
                Button { } label: { Image(systemName: "link") }
                    .disabled(isDisabled)
            }
        }
    }
}

// MARK: - Code generation
private extension ToolbarItemGroupShowcase {
    var generatedCode: String {
        let symbols = ["bold", "italic", "underline", "strikethrough", "link"]
        var lines: [String] = []
        lines.append("ToolbarItemGroup(placement: .\(placement.label)) {")
        for index in 0..<itemCount {
            let sym = symbols[index]
            lines.append("    Button { } label: { Image(systemName: \"\(sym)\") }")
            if itemsDisabled {
                lines.append("        .disabled(true)")
            }
        }
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}
