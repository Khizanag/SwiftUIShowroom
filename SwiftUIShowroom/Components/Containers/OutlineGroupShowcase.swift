import SwiftUI

struct OutlineGroupShowcase: View {
    @State private var showIcons = true

    var body: some View {
        ShowcaseScreen(
            title: "OutlineGroup",
            summary: "Renders an expandable/collapsible hierarchy from tree-structured, identified data.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension OutlineGroupShowcase {
    struct FileNode: Identifiable, Hashable {
        let id: UUID
        let name: String
        let icon: String
        var children: [FileNode]?

        init(
            name: String,
            icon: String,
            children: [FileNode]? = nil
        ) {
            self.id = UUID()
            self.name = name
            self.icon = icon
            self.children = children
        }
    }

    enum OutlineState: ShowcaseState {
        case defaultState
        case empty
        case longContent

        var caption: String {
            switch self {
            case .defaultState: "Default"
            case .empty: "Empty"
            case .longContent: "Long content"
            }
        }
    }
}

// MARK: - Sample data
private extension OutlineGroupShowcase {
    static let sampleTree: [FileNode] = [
        FileNode(
            name: "Sources",
            icon: "folder.fill",
            children: [
                FileNode(
                    name: "App",
                    icon: "folder",
                    children: [
                        FileNode(name: "AppMain.swift", icon: "swift"),
                        FileNode(name: "ContentView.swift", icon: "swift"),
                    ]
                ),
                FileNode(
                    name: "Feature",
                    icon: "folder",
                    children: [
                        FileNode(name: "HomeView.swift", icon: "swift"),
                        FileNode(name: "DetailView.swift", icon: "swift"),
                    ]
                ),
                FileNode(name: "README.md", icon: "doc.text"),
            ]
        ),
        FileNode(
            name: "Resources",
            icon: "folder.fill",
            children: [
                FileNode(name: "Assets.xcassets", icon: "photo.stack"),
                FileNode(name: "Localizable.xcstrings", icon: "globe"),
            ]
        ),
        FileNode(name: "Package.swift", icon: "shippingbox"),
    ]

    static let longTree: [FileNode] = [
        FileNode(
            name: "Modules",
            icon: "folder.fill",
            children: (1...8).map { index in
                FileNode(
                    name: "Module\(index)",
                    icon: "folder",
                    children: [
                        FileNode(name: "View\(index).swift", icon: "swift"),
                        FileNode(name: "Model\(index).swift", icon: "swift"),
                    ]
                )
            }
        ),
    ]
}

// MARK: - Sub-views
private extension OutlineGroupShowcase {
    var preview: some View {
        #if os(tvOS)
        tvUnavailableNotice
        #else
        List {
            OutlineGroup(
                Self.sampleTree,
                children: \.children,
            ) { node in
                nodeLabel(node)
            }
        }
        .frame(maxHeight: 280)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        #endif
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("Show icons", isOn: $showIcons)
    }

    @ViewBuilder func nodeLabel(_ node: FileNode) -> some View {
        if showIcons {
            Label(node.name, systemImage: node.icon)
                .font(DesignSystem.Font.body)
        } else {
            Text(node.name)
                .font(DesignSystem.Font.body)
        }
    }

    @ViewBuilder func stateView(_ state: OutlineState) -> some View {
        switch state {
        case .defaultState:
            defaultStateView
        case .empty:
            emptyStateView
        case .longContent:
            longContentStateView
        }
    }

    var defaultStateView: some View {
        #if os(tvOS)
        tvUnavailableNotice
        #else
        List {
            OutlineGroup(
                Self.sampleTree,
                children: \.children,
            ) { node in
                Label(node.name, systemImage: node.icon)
                    .font(DesignSystem.Font.body)
            }
        }
        .frame(maxHeight: 240)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        #endif
    }

    var emptyStateView: some View {
        #if os(tvOS)
        tvUnavailableNotice
        #else
        List {
            ContentUnavailableView(
                "No Files",
                systemImage: "folder",
                description: Text("The hierarchy is empty."),
            )
        }
        .frame(maxHeight: 200)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        #endif
    }

    var longContentStateView: some View {
        #if os(tvOS)
        tvUnavailableNotice
        #else
        List {
            OutlineGroup(
                Self.longTree,
                children: \.children,
            ) { node in
                Label(node.name, systemImage: node.icon)
                    .font(DesignSystem.Font.body)
            }
        }
        .frame(maxHeight: 240)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        #endif
    }

    #if os(tvOS)
    var tvUnavailableNotice: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "xmark.circle")
                .font(DesignSystem.Font.title)
                .foregroundStyle(DesignSystem.Color.secondary)
            Text("OutlineGroup is not available on tvOS.")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.medium)
    }
    #endif
}

// MARK: - Code generation
private extension OutlineGroupShowcase {
    var generatedCode: String {
        let rowContent = showIcons
            ? "Label(item.name, systemImage: item.icon)"
            : "Text(item.name)"
        return """
        OutlineGroup(rootItems, children: \\.children) { item in
            \(rowContent)
        }
        """
    }
}
