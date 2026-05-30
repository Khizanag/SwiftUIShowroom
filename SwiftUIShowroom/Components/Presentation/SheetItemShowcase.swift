import SwiftUI

struct SheetItemShowcase: View {
    #if !os(tvOS)
    @State private var activeItem: DemoItem?
    @State private var enableDismissCallback = false
    @State private var lastDismissed: String?
    #endif
    @State private var selectedPreset: ItemPreset = .sample

    var body: some View {
        ShowcaseScreen(
            title: "Sheet (item-driven)",
            summary: "Presents a sheet bound to an Identifiable optional; rebuilds on identity change.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
        #if !os(tvOS)
        .sheet(item: $activeItem, onDismiss: dismissHandler) { item in
            SheetItemShowcase.sheetContent(item: item, isLong: false)
        }
        #endif
    }
}

// MARK: - Nested types
extension SheetItemShowcase {
    struct DemoItem: Identifiable {
        let id: String
        let title: String
        let subtitle: String
    }

    enum ItemPreset: ShowcasePickable {
        case none
        case sample
        case alternate

        var label: String {
            switch self {
            case .none: "nil"
            case .sample: "Item.sample"
            case .alternate: "Item.alternate"
            }
        }

        var item: DemoItem? {
            switch self {
            case .none: nil
            case .sample:
                DemoItem(
                    id: "sample",
                    title: "Sample Item",
                    subtitle: "A representative sheet item.",
                )
            case .alternate:
                DemoItem(
                    id: "alternate",
                    title: "Alternate Item",
                    subtitle: "A different identity rebuilds the sheet.",
                )
            }
        }
    }

    enum SheetContentState: ShowcaseState {
        case `default`
        case longContent

        var caption: String {
            switch self {
            case .default: "Default"
            case .longContent: "Long content"
            }
        }
    }
}

// MARK: - Sub-views
private extension SheetItemShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            #if !os(tvOS)
            Button("Present sheet") {
                activeItem = selectedPreset.item
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedPreset == .none)

            if let name = lastDismissed {
                Text("Last dismissed: \(name)")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
            #else
            Text("Sheet not available on tvOS")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.secondary)
            #endif
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Item preset", selection: $selectedPreset)
        #if !os(tvOS)
        ShowcaseToggle("Wire onDismiss callback", isOn: $enableDismissCallback)
        #endif
    }

    @ViewBuilder
    func stateView(_ state: SheetContentState) -> some View {
        switch state {
        case .default:
            SheetItemShowcase.sheetContent(
                item: DemoItem(
                    id: "gallery-default",
                    title: "Sheet Title",
                    subtitle: "Sheet subtitle.",
                ),
                isLong: false,
            )
            .frame(height: 200)
            .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))

        case .longContent:
            SheetItemShowcase.sheetContent(
                item: DemoItem(
                    id: "gallery-long",
                    title: "Long Content",
                    subtitle: "Demonstrates scrollable sheet with many rows.",
                ),
                isLong: true,
            )
            .frame(height: 200)
            .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
        }
    }

    static func sheetContent(item: DemoItem, isLong: Bool) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                    Text(item.subtitle)
                        .font(DesignSystem.Font.body)
                        .foregroundStyle(DesignSystem.Color.secondary)

                    if isLong {
                        ForEach(1...20, id: \.self) { row in
                            Text("Row \(row)")
                                .font(DesignSystem.Font.body)
                                .padding(.vertical, DesignSystem.Spacing.xSmall)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .overlay(
                                    alignment: .bottom,
                                    content: { Divider() },
                                )
                        }
                    }
                }
                .padding(DesignSystem.Spacing.large)
            }
            .navigationTitle(item.title)
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

// MARK: - Helpers
private extension SheetItemShowcase {
    #if !os(tvOS)
    var dismissHandler: (() -> Void)? {
        guard enableDismissCallback else { return nil }
        return {
            lastDismissed = selectedPreset.item?.title ?? "item"
        }
    }
    #endif
}

// MARK: - Code generation
private extension SheetItemShowcase {
    var generatedCode: String {
        let itemArg = selectedPreset == .none ? "nil" : "$item"
        #if !os(tvOS)
        let dismissArg = enableDismissCallback ? "onDismiss: handleDismiss" : "onDismiss: nil"
        #else
        let dismissArg = "onDismiss: nil"
        #endif
        return """
        .sheet(item: \(itemArg), \(dismissArg)) { item in
            DetailView(item: item)
        }
        """
    }
}
