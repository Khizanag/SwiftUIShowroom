import SwiftUI

struct LazyvstackShowcase: View {
    enum AlignmentOption: ShowcasePickable {
        case leading, center, trailing

        var label: String {
            switch self {
            case .leading: "leading"
            case .center: "center"
            case .trailing: "trailing"
            }
        }

        var value: HorizontalAlignment {
            switch self {
            case .leading: .leading
            case .center: .center
            case .trailing: .trailing
            }
        }
    }

    enum PinnedOption: ShowcasePickable {
        case none, sectionHeaders, sectionFooters, both

        var label: String {
            switch self {
            case .none: "none"
            case .sectionHeaders: "sectionHeaders"
            case .sectionFooters: "sectionFooters"
            case .both: "sectionHeaders + sectionFooters"
            }
        }

        var codeValue: String {
            switch self {
            case .none: "[]"
            case .sectionHeaders: "[.sectionHeaders]"
            case .sectionFooters: "[.sectionFooters]"
            case .both: "[.sectionHeaders, .sectionFooters]"
            }
        }

        var value: PinnedScrollableViews {
            switch self {
            case .none: []
            case .sectionHeaders: [.sectionHeaders]
            case .sectionFooters: [.sectionFooters]
            case .both: [.sectionHeaders, .sectionFooters]
            }
        }
    }

    enum ContentState: ShowcaseState {
        case `default`, empty, longContent

        var caption: String {
            switch self {
            case .default: "Default"
            case .empty: "Empty"
            case .longContent: "Long content"
            }
        }
    }

    @State private var alignment: AlignmentOption = .center
    @State private var spacingEnabled = false
    @State private var spacing: Double = 12
    @State private var pinnedViews: PinnedOption = .none
    @State private var itemCount: Int = 8

    var body: some View {
        ShowcaseScreen(
            title: "LazyVStack",
            summary: "A vertical stack that lazily creates subviews as they become visible inside a ScrollView.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension LazyvstackShowcase {
    var preview: some View {
        ScrollView {
            LazyVStack(
                alignment: alignment.value,
                spacing: spacingEnabled ? spacing : nil,
                pinnedViews: pinnedViews.value,
            ) {
                if pinnedViews != .none {
                    Section {
                        ForEach(0 ..< itemCount, id: \.self) { idx in
                            rowView(index: idx, alignment: alignment)
                        }
                    } header: {
                        sectionHeader(title: "Section A")
                    }
                    Section {
                        ForEach(itemCount ..< itemCount * 2, id: \.self) { idx in
                            rowView(index: idx, alignment: alignment)
                        }
                    } header: {
                        sectionHeader(title: "Section B")
                    }
                } else {
                    ForEach(0 ..< itemCount, id: \.self) { idx in
                        rowView(index: idx, alignment: alignment)
                    }
                }
            }
        }
        .frame(height: 260)
    }

    func rowView(index: Int, alignment: AlignmentOption) -> some View {
        HStack {
            if alignment == .trailing || alignment == .center {
                Spacer()
            }
            Text("Row \(index + 1)")
                .font(DesignSystem.Font.body)
                .padding(.horizontal, DesignSystem.Spacing.medium)
                .padding(.vertical, DesignSystem.Spacing.small)
                .background(DesignSystem.Color.cardBackground)
                .cornerRadius(DesignSystem.CornerRadius.small)
            if alignment == .leading || alignment == .center {
                Spacer()
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.small)
    }

    func sectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.primary)
            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.small)
        .padding(.vertical, DesignSystem.Spacing.xSmall)
        .background(DesignSystem.Color.background)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Alignment", selection: $alignment)
        ShowcaseToggle("Custom spacing", isOn: $spacingEnabled)
        if spacingEnabled {
            ShowcaseSlider("Spacing", value: $spacing, in: 0 ... 48, step: 1)
        }
        ShowcasePicker("Pinned views", selection: $pinnedViews)
        ShowcaseStepper("Item count", value: $itemCount, in: 0 ... 20)
    }

    @ViewBuilder
    func stateView(_ state: ContentState) -> some View {
        switch state {
        case .default:
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.small) {
                    ForEach(0 ..< 4, id: \.self) { idx in
                        rowView(index: idx, alignment: .center)
                    }
                }
            }
            .frame(height: 160)
        case .empty:
            ScrollView {
                LazyVStack {
                    ContentUnavailableView(
                        "No Items",
                        systemImage: "tray",
                        description: Text("Add items to see them here."),
                    )
                }
            }
            .frame(height: 160)
        case .longContent:
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.xSmall) {
                    ForEach(0 ..< 12, id: \.self) { idx in
                        rowView(index: idx, alignment: .center)
                    }
                }
            }
            .frame(height: 160)
        }
    }
}

// MARK: - Code generation
private extension LazyvstackShowcase {
    var generatedCode: String {
        let alignArg = "alignment: .\(alignment.label)"
        let spacingArg = spacingEnabled ? ", spacing: \(Int(spacing))" : ""
        let pinnedArg = pinnedViews == .none ? "" : ", pinnedViews: \(pinnedViews.codeValue)"
        return """
        ScrollView {
            LazyVStack(\(alignArg)\(spacingArg)\(pinnedArg)) {
                ForEach(items) { item in
                    Text(item.title)
                }
            }
        }
        """
    }
}
