import SwiftUI

struct NavigationPathShowcase: View {
    @State private var path = NavigationPath()
    @State private var elementCount = 0
    @State private var mixedTypes = true
    @State private var codablePersistence = false

    var body: some View {
        ShowcaseScreen(
            title: "NavigationPath",
            summary: "Type-erased heterogeneous navigation state for programmatic, codable deep-link navigation.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
        .onChange(of: elementCount) { _, newValue in
            syncPath(to: newValue)
        }
        .onChange(of: mixedTypes) { _, _ in
            syncPath(to: elementCount)
        }
    }
}

// MARK: - Sub-views
private extension NavigationPathShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            pathVisualization(path: path, mixed: mixedTypes)
            pathStats
        }
        .frame(maxWidth: 400)
    }

    @ViewBuilder var controls: some View {
        ShowcaseStepper("Element count", value: $elementCount, in: 0...8)
        ShowcaseToggle("Mixed types (Int + String)", isOn: $mixedTypes)
        ShowcaseToggle("Codable persistence", isOn: $codablePersistence)
    }

    @ViewBuilder
    func stateView(_ state: PathState) -> some View {
        pathVisualization(path: state.samplePath(mixed: mixedTypes), mixed: mixedTypes)
    }
}

// MARK: - Helpers
private extension NavigationPathShowcase {
    var pathStats: some View {
        HStack(spacing: DesignSystem.Spacing.large) {
            statBadge(label: "count", value: "\(path.count)")
            statBadge(label: "isEmpty", value: path.isEmpty ? "true" : "false")
            if codablePersistence {
                statBadge(label: "codable", value: path.codable != nil ? "yes" : "no")
            }
        }
        .padding(.vertical, DesignSystem.Spacing.xSmall)
    }

    func statBadge(label: String, value: String) -> some View {
        VStack(spacing: DesignSystem.Spacing.hairline) {
            Text(value)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(label)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }

    func pathVisualization(path: NavigationPath, mixed: Bool) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            if path.isEmpty {
                Text("Path is empty")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(DesignSystem.Spacing.medium)
            } else {
                pathElementRows(count: path.count, mixed: mixed)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground, in: .rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ViewBuilder
    func pathElementRows(count: Int, mixed: Bool) -> some View {
        ForEach(0..<count, id: \.self) { index in
            HStack(spacing: DesignSystem.Spacing.small) {
                Image(systemName: "arrow.right")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.accent)
                if mixed && index % 2 != 0 {
                    Text("String \"\(stringValue(index: index))\"")
                        .font(DesignSystem.Font.codeInline)
                } else {
                    Text("Int \(index + 1)")
                        .font(DesignSystem.Font.codeInline)
                }
            }
        }
    }

    func stringValue(index: Int) -> String {
        let labels = ["alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta"]
        return labels[index % labels.count]
    }

    func syncPath(to count: Int) {
        path = NavigationPath()
        for index in 0..<count {
            if mixedTypes && index % 2 != 0 {
                path.append(stringValue(index: index))
            } else {
                path.append(index + 1)
            }
        }
        elementCount = count
    }
}

// MARK: - State enum
extension NavigationPathShowcase {
    fileprivate enum PathState: ShowcaseState {
        case empty
        case defaultState
        case longContent

        var caption: String {
            switch self {
            case .empty: "Empty"
            case .defaultState: "Default"
            case .longContent: "Long (8 elements)"
            }
        }

        func samplePath(mixed: Bool) -> NavigationPath {
            var result = NavigationPath()
            let depth: Int
            switch self {
            case .empty: depth = 0
            case .defaultState: depth = 2
            case .longContent: depth = 8
            }
            for index in 0..<depth {
                if mixed && index % 2 != 0 {
                    let labels = ["alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta"]
                    result.append(labels[index % labels.count])
                } else {
                    result.append(index + 1)
                }
            }
            return result
        }
    }
}

// MARK: - Code generation
private extension NavigationPathShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("struct NavigationPathDemo: View {")
        lines.append("    @State private var path = NavigationPath()")
        if codablePersistence {
            lines.append("    @AppStorage(\"navPath\") private var storedPath: Data?")
        }
        lines.append("")
        lines.append("    var body: some View {")
        lines.append("        NavigationStack(path: $path) {")
        lines.append("            List {")
        if mixedTypes {
            lines.append("                Button(\"Push Int\") { path.append(42) }")
            lines.append("                Button(\"Push String\") { path.append(\"detail\") }")
        } else {
            lines.append("                Button(\"Push\") { path.append(path.count + 1) }")
        }
        lines.append("                Button(\"Pop\") { if !path.isEmpty { path.removeLast() } }")
        lines.append("                Button(\"Pop all\") { path = NavigationPath() }")
        lines.append("            }")
        lines.append("            .navigationTitle(\"Count \\(path.count)\")")
        lines.append("            .navigationDestination(for: Int.self) { Text(\"Int \\($0)\") }")
        if mixedTypes {
            lines.append("            .navigationDestination(for: String.self) { Text(\"String \\($0)\") }")
        }
        if codablePersistence {
            lines.append("            .onDisappear { storedPath = try? JSONEncoder().encode(path.codable) }")
        }
        lines.append("        }")
        lines.append("    }")
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}
