import SwiftUI

struct ToolbarShowcase: View {
    @State private var primaryPlacement: PlacementOption = .primaryAction
    @State private var itemCount = 2
    @State private var showPrincipal = false
    @State private var showBottomBar = false
    @State private var useGroup = true
    @State private var itemsDisabled = false

    var body: some View {
        ShowcaseScreen(
            title: "Toolbar",
            summary: "Populates navigation bar and platform toolbars with semantic placement-based items.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension ToolbarShowcase {
    struct DemoConfig {
        var placement: ToolbarItemPlacement
        var itemCount: Int
        var showPrincipal: Bool
        var showBottomBar: Bool
        var useGroup: Bool
        var itemsDisabled: Bool
    }

    enum PlacementOption: ShowcasePickable {
        case automatic
        case primaryAction
        case confirmationAction
        case cancellationAction
        case topBarLeading
        case topBarTrailing
        case bottomBar
        case principal
        case navigation
        case secondaryAction

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .primaryAction: "primaryAction"
            case .confirmationAction: "confirmationAction"
            case .cancellationAction: "cancellationAction"
            case .topBarLeading: "topBarLeading"
            case .topBarTrailing: "topBarTrailing"
            case .bottomBar: "bottomBar"
            case .principal: "principal"
            case .navigation: "navigation"
            case .secondaryAction: "secondaryAction"
            }
        }

        var placement: ToolbarItemPlacement {
            switch self {
            case .automatic: return .automatic
            case .primaryAction: return .primaryAction
            case .confirmationAction: return .confirmationAction
            case .cancellationAction: return .cancellationAction
            case .topBarLeading:
                #if os(iOS)
                return .topBarLeading
                #else
                return .automatic
                #endif
            case .topBarTrailing:
                #if os(iOS)
                return .topBarTrailing
                #else
                return .automatic
                #endif
            case .bottomBar:
                #if os(iOS)
                return .bottomBar
                #else
                return .automatic
                #endif
            case .principal: return .principal
            case .navigation: return .navigation
            case .secondaryAction: return .secondaryAction
            }
        }
    }

    enum ToolbarState: ShowcaseState {
        case defaultState
        case disabled
        case longContent

        var caption: String {
            switch self {
            case .defaultState: "Default"
            case .disabled: "Disabled"
            case .longContent: "Long content"
            }
        }
    }
}

// MARK: - Sub-views
private extension ToolbarShowcase {
    var currentConfig: DemoConfig {
        DemoConfig(
            placement: primaryPlacement.placement,
            itemCount: itemCount,
            showPrincipal: showPrincipal,
            showBottomBar: showBottomBar,
            useGroup: useGroup,
            itemsDisabled: itemsDisabled,
        )
    }

    var preview: some View {
        toolbarDemo(config: currentConfig)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Primary placement", selection: $primaryPlacement)
        ShowcaseStepper("Item count", value: $itemCount, in: 1...5)
        ShowcaseToggle("Show principal", isOn: $showPrincipal)
        ShowcaseToggle("Show bottom bar", isOn: $showBottomBar)
        ShowcaseToggle("Use group", isOn: $useGroup)
        ShowcaseToggle("Items disabled", isOn: $itemsDisabled)
    }

    @ViewBuilder
    func stateView(_ state: ToolbarState) -> some View {
        switch state {
        case .defaultState:
            toolbarDemo(config: DemoConfig(
                placement: .primaryAction,
                itemCount: 2,
                showPrincipal: false,
                showBottomBar: false,
                useGroup: true,
                itemsDisabled: false,
            ))
        case .disabled:
            toolbarDemo(config: DemoConfig(
                placement: .primaryAction,
                itemCount: 2,
                showPrincipal: false,
                showBottomBar: false,
                useGroup: true,
                itemsDisabled: true,
            ))
        case .longContent:
            toolbarDemo(config: DemoConfig(
                placement: .primaryAction,
                itemCount: 4,
                showPrincipal: true,
                showBottomBar: false,
                useGroup: true,
                itemsDisabled: false,
            ))
        }
    }

    func toolbarDemo(config: DemoConfig) -> some View {
        NavigationStack {
            List(0..<8, id: \.self) { index in
                Text("Row \(index)")
            }
            .navigationTitle("Toolbar")
            .toolbar {
                toolbarContent(config: config)
            }
        }
        .frame(maxWidth: 320, minHeight: 220)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ToolbarContentBuilder
    func toolbarContent(config: DemoConfig) -> some ToolbarContent {
        ToolbarItem(placement: config.placement) {
            Button("Action") {}
                .disabled(config.itemsDisabled)
        }
        if config.showPrincipal {
            ToolbarItem(placement: .principal) {
                Text("Custom Title")
                    .font(DesignSystem.Font.headline)
            }
        }
        if config.useGroup {
            trailingGroup(itemCount: config.itemCount, itemsDisabled: config.itemsDisabled)
        } else {
            trailingItems(itemCount: config.itemCount, itemsDisabled: config.itemsDisabled)
        }
        #if os(iOS)
        if config.showBottomBar {
            bottomBarContent(itemsDisabled: config.itemsDisabled)
        }
        #endif
    }

    @ToolbarContentBuilder
    func trailingGroup(itemCount: Int, itemsDisabled: Bool) -> some ToolbarContent {
        #if os(iOS) || os(tvOS)
        ToolbarItemGroup(placement: .topBarTrailing) {
            actionButtons(itemCount: itemCount, itemsDisabled: itemsDisabled)
        }
        #else
        ToolbarItemGroup(placement: .automatic) {
            actionButtons(itemCount: itemCount, itemsDisabled: itemsDisabled)
        }
        #endif
    }

    @ToolbarContentBuilder
    func trailingItems(itemCount: Int, itemsDisabled: Bool) -> some ToolbarContent {
        #if os(iOS) || os(tvOS)
        ToolbarItem(placement: .topBarTrailing) {
            actionButtons(itemCount: itemCount, itemsDisabled: itemsDisabled)
        }
        #else
        ToolbarItem(placement: .automatic) {
            actionButtons(itemCount: itemCount, itemsDisabled: itemsDisabled)
        }
        #endif
    }

    @ViewBuilder
    func actionButtons(itemCount: Int, itemsDisabled: Bool) -> some View {
        let symbols = ["square.and.arrow.up", "ellipsis", "star", "tag", "bookmark"]
        let count = min(itemCount, symbols.count)
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            ForEach(0..<count, id: \.self) { index in
                Button {
                } label: {
                    Image(systemName: symbols[index])
                }
                .accessibilityLabel(symbols[index])
                .disabled(itemsDisabled)
            }
        }
    }

    #if os(iOS)
    @ToolbarContentBuilder
    func bottomBarContent(itemsDisabled: Bool) -> some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Button {
            } label: {
                Image(systemName: "trash")
            }
            .accessibilityLabel("Delete")
            .disabled(itemsDisabled)
            Spacer()
            Button {
            } label: {
                Image(systemName: "square.and.pencil")
            }
            .accessibilityLabel("Edit")
            .disabled(itemsDisabled)
        }
    }
    #endif
}

// MARK: - Code generation
private extension ToolbarShowcase {
    var generatedCode: String {
        let symbols = ["square.and.arrow.up", "ellipsis", "star", "tag", "bookmark"]
        let count = min(itemCount, symbols.count)
        let trailingType = useGroup ? "ToolbarItemGroup" : "ToolbarItem"
        var lines: [String] = []
        lines.append("struct ToolbarDemo: View {")
        lines.append("    var body: some View {")
        lines.append("        NavigationStack {")
        lines.append("            Text(\"Content\")")
        lines.append("                .navigationTitle(\"Toolbar\")")
        lines.append("                .toolbar {")
        lines.append("                    ToolbarItem(placement: .\(primaryPlacement.label)) {")
        lines.append("                        Button(\"Action\") {}")
        if itemsDisabled {
            lines.append("                            .disabled(true)")
        }
        lines.append("                    }")
        if showPrincipal {
            lines.append("                    ToolbarItem(placement: .principal) {")
            lines.append("                        Text(\"Custom Title\")")
            lines.append("                    }")
        }
        lines.append("                    \(trailingType)(placement: .topBarTrailing) {")
        for index in 0..<count {
            lines.append("                        Button { } label: { Image(systemName: \"\(symbols[index])\") }")
            if itemsDisabled {
                lines.append("                            .disabled(true)")
            }
        }
        lines.append("                    }")
        if showBottomBar {
            lines.append("                    ToolbarItemGroup(placement: .bottomBar) {")
            lines.append("                        Button { } label: { Image(systemName: \"trash\") }")
            lines.append("                        Spacer()")
            lines.append("                        Button { } label: { Image(systemName: \"square.and.pencil\") }")
            lines.append("                    }")
        }
        lines.append("                }")
        lines.append("        }")
        lines.append("    }")
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}
