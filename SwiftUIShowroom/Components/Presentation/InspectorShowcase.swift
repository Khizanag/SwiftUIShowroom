import SwiftUI

struct InspectorShowcase: View {
    enum InspectorContentState: ShowcaseState {
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

    @State private var isPresented = false
    @State private var columnWidth: Double = 270
    @State private var minWidth: Double = 200
    @State private var maxWidth: Double = 500

    var body: some View {
        ShowcaseScreen(
            title: "Inspector",
            summary: "Trailing detail pane that docks on wide layouts and adapts to a sheet in compact widths.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension InspectorShowcase {
    var preview: some View {
        InspectorDemoContainer(
            isPresented: $isPresented,
            columnWidth: CGFloat(columnWidth),
            minWidth: CGFloat(minWidth),
            maxWidth: CGFloat(maxWidth),
            contentState: .defaultState,
        )
        .frame(maxWidth: 480, minHeight: 220)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseToggle("Show inspector", isOn: $isPresented)
        ShowcaseSlider("Column width (ideal)", value: $columnWidth, in: 200...500, step: 10)
        ShowcaseSlider("Min width", value: $minWidth, in: 150...400, step: 10)
        ShowcaseSlider("Max width", value: $maxWidth, in: 300...700, step: 10)
    }

    @ViewBuilder
    func stateView(_ state: InspectorContentState) -> some View {
        InspectorDemoContainer(
            isPresented: .constant(true),
            columnWidth: 270,
            minWidth: 200,
            maxWidth: 500,
            contentState: state,
        )
        .frame(maxWidth: 340, minHeight: 180)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Code generation
private extension InspectorShowcase {
    var generatedCode: String {
        [
            ".inspector(isPresented: $isInspectorPresented) {",
            "    InspectorContentView()",
            "        .inspectorColumnWidth(",
            "            min: \(Int(minWidth)),",
            "            ideal: \(Int(columnWidth)),",
            "            max: \(Int(maxWidth))",
            "        )",
            "}",
        ].joined(separator: "\n")
    }
}

// MARK: - InspectorDemoContainer
private struct InspectorDemoContainer: View {
    @Binding var isPresented: Bool
    let columnWidth: CGFloat
    let minWidth: CGFloat
    let maxWidth: CGFloat
    let contentState: InspectorShowcase.InspectorContentState

    var body: some View {
        #if os(tvOS)
        tvFallback
        #else
        liveContent
        #endif
    }
}

// MARK: - Platform implementations
private extension InspectorDemoContainer {
    #if os(tvOS)
    var tvFallback: some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            mainContent
            if isPresented {
                Divider()
                inspectorBody
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground)
    }
    #else
    var liveContent: some View {
        mainContent
            .inspector(isPresented: $isPresented) {
                inspectorBody
                    .inspectorColumnWidth(
                        min: minWidth,
                        ideal: columnWidth,
                        max: maxWidth,
                    )
            }
    }
    #endif

    var mainContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            HStack {
                Text("Content")
                    .font(DesignSystem.Font.headline)
                Spacer()
                Button {
                    isPresented.toggle()
                } label: {
                    Image(systemName: "sidebar.trailing")
                        .font(DesignSystem.Font.body)
                }
                .buttonStyle(.bordered)
            }
            Divider()
            ForEach(mainRows, id: \.self) { row in
                rowView(title: row)
            }
            Spacer()
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.background)
    }

    @ViewBuilder
    var inspectorBody: some View {
        switch contentState {
        case .defaultState:
            defaultInspectorContent
        case .empty:
            emptyInspectorContent
        case .longContent:
            longInspectorContent
        }
    }

    var defaultInspectorContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("Inspector")
                .font(DesignSystem.Font.headline)
            Divider()
            propertyRow(label: "Type", value: "Document")
            propertyRow(label: "Size", value: "12 KB")
            propertyRow(label: "Modified", value: "Today")
            Spacer()
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var emptyInspectorContent: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: "sidebar.right")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.secondary)
            Text("No selection")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var longInspectorContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                Text("Properties")
                    .font(DesignSystem.Font.headline)
                Divider()
                ForEach(longPropertyLabels, id: \.self) { label in
                    propertyRow(label: label, value: "Value")
                }
            }
            .padding(DesignSystem.Spacing.medium)
        }
    }

    func rowView(title: String) -> some View {
        HStack {
            Image(systemName: "doc.text")
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(width: DesignSystem.Size.Icon.small)
            Text(title)
                .font(DesignSystem.Font.body)
            Spacer()
        }
        .padding(.vertical, DesignSystem.Spacing.xSmall)
    }

    func propertyRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
            Spacer()
            Text(value)
                .font(DesignSystem.Font.footnote)
        }
        .padding(.vertical, DesignSystem.Spacing.xSmall)
    }

    var mainRows: [String] {
        ["Report.pdf", "Presentation.key", "Notes.txt"]
    }

    var longPropertyLabels: [String] {
        [
            "Name", "Kind", "Size", "Location", "Created",
            "Modified", "Owner", "Permissions", "Tags", "Comments",
        ]
    }
}
