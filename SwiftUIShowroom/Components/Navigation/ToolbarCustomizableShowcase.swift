import SwiftUI

struct ToolbarCustomizableShowcase: View {
    @State private var itemCount = 3
    @State private var defaultVisibility: VisibilityOption = .automatic
    @State private var pinnedBehavior: BehaviorOption = .default

    var body: some View {
        ShowcaseScreen(
            title: "Customizable toolbar",
            summary: "A user-customizable toolbar whose items carry stable ids for add, remove, and reorder.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension ToolbarCustomizableShowcase {
    enum VisibilityOption: ShowcasePickable {
        case automatic
        case visible
        case hidden

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .visible: "visible"
            case .hidden: "hidden"
            }
        }

        var visibility: Visibility {
            switch self {
            case .automatic: .automatic
            case .visible: .visible
            case .hidden: .hidden
            }
        }
    }

    enum BehaviorOption: ShowcasePickable {
        case `default`
        case reorderable
        case disabled

        var label: String {
            switch self {
            case .default: "default"
            case .reorderable: "reorderable"
            case .disabled: "disabled"
            }
        }

        var behavior: ToolbarCustomizationBehavior {
            switch self {
            case .default: .default
            case .reorderable: .reorderable
            case .disabled: .disabled
            }
        }
    }

    enum ToolbarCustomizableState: ShowcaseState {
        case defaultState
        case disabled

        var caption: String {
            switch self {
            case .defaultState: "Default"
            case .disabled: "Disabled"
            }
        }
    }
}

// MARK: - Sub-views
private extension ToolbarCustomizableShowcase {
    var preview: some View {
        toolbarDemo(
            itemCount: itemCount,
            visibility: defaultVisibility.visibility,
            behavior: pinnedBehavior.behavior,
            isDisabled: false,
        )
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseStepper("Item count", value: $itemCount, in: 1...6)
        ShowcasePicker("Default visibility", selection: $defaultVisibility)
        ShowcasePicker("Pinned behavior", selection: $pinnedBehavior)
    }

    @ViewBuilder
    func stateView(_ state: ToolbarCustomizableState) -> some View {
        switch state {
        case .defaultState:
            toolbarDemo(
                itemCount: 3,
                visibility: .automatic,
                behavior: .default,
                isDisabled: false,
            )
        case .disabled:
            toolbarDemo(
                itemCount: 3,
                visibility: .automatic,
                behavior: .disabled,
                isDisabled: true,
            )
        }
    }

    func toolbarDemo(
        itemCount: Int,
        visibility: Visibility,
        behavior: ToolbarCustomizationBehavior,
        isDisabled: Bool,
    ) -> some View {
        NavigationStack {
            List(0..<6, id: \.self) { index in
                Text("Row \(index)")
            }
            .navigationTitle("Document")
            .toolbar(id: "showcase-main") {
                customizableItems(
                    itemCount: itemCount,
                    visibility: visibility,
                    behavior: behavior,
                    isDisabled: isDisabled,
                )
            }
        }
        .frame(maxWidth: 320, minHeight: 220)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ToolbarContentBuilder
    func customizableItems(
        itemCount: Int,
        visibility: Visibility,
        behavior: ToolbarCustomizationBehavior,
        isDisabled: Bool,
    ) -> some CustomizableToolbarContent {
        let itemDefs = itemDefinitions()
//        ForEach(0..<min(itemCount, itemDefs.count), id: \.self) { index in
            let def = itemDefs[0]
            ToolbarItem(id: def.identifier, placement: toolbarPlacement) {
                Button {
                } label: {
                    Label(def.title, systemImage: def.symbol)
                }
                .accessibilityLabel(def.title)
                .disabled(isDisabled)
            }
            .defaultCustomization(visibility)
            .customizationBehavior(behavior)
//        }
    }

    var toolbarPlacement: ToolbarItemPlacement {
        #if os(tvOS)
        .primaryAction
        #else
        .secondaryAction
        #endif
    }

    func itemDefinitions() -> [(identifier: String, title: String, symbol: String)] {
        [
            (identifier: "tag", title: "Tag", symbol: "tag"),
            (identifier: "share", title: "Share", symbol: "square.and.arrow.up"),
            (identifier: "bookmark", title: "Bookmark", symbol: "bookmark"),
            (identifier: "star", title: "Star", symbol: "star"),
            (identifier: "flag", title: "Flag", symbol: "flag"),
            (identifier: "info", title: "Info", symbol: "info.circle"),
        ]
    }
}

// MARK: - Code generation
private extension ToolbarCustomizableShowcase {
    var generatedCode: String {
        let defs = itemDefinitions()
        let count = min(itemCount, defs.count)
        var lines: [String] = []
        lines.append("struct CustomizableToolbarDemo: View {")
        lines.append("    var body: some View {")
        lines.append("        NavigationStack {")
        lines.append("            Text(\"Content\")")
        lines.append("                .navigationTitle(\"Document\")")
        lines.append("                .toolbar(id: \"main\") {")
        for index in 0..<count {
            let def = defs[index]
            lines.append("                    ToolbarItem(id: \"\(def.identifier)\", placement: .secondaryAction) {")
            lines.append(
                "                        Button { } label: { Label(\"\(def.title)\", systemImage: \"\(def.symbol)\") }"
            )
            lines.append("                    }")
            if defaultVisibility != .automatic {
                lines.append("                    .defaultCustomization(.\(defaultVisibility.label))")
            }
            if pinnedBehavior != .default {
                lines.append("                    .customizationBehavior(.\(pinnedBehavior.label))")
            }
        }
        lines.append("                }")
        lines.append("        }")
        lines.append("    }")
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}
