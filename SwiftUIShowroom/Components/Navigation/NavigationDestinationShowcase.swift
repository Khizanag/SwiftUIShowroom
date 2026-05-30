import SwiftUI

struct NavigationDestinationShowcase: View {
    @State private var triggerMode: TriggerMode = .forType
    @State private var isPresentedToggle = false
    @State private var itemToggle = false

    var body: some View {
        ShowcaseScreen(
            title: "navigationDestination",
            summary: "Associates a data type or boolean/item trigger with a destination view inside a NavigationStack.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension NavigationDestinationShowcase {
    var preview: some View {
        NavigationStack {
            List {
                NavigationLink("Value link (42)", value: 42)
                Button("Boolean push") { isPresentedToggle = true }
                    .disabled(triggerMode != .isPresented)
                itemPushButton
            }
            .navigationDestination(for: Int.self) { value in
                Text("Detail for \(value)")
                    .font(DesignSystem.Font.title2)
            }
            .navigationDestination(isPresented: $isPresentedToggle) {
                Text("Boolean-driven detail")
                    .font(DesignSystem.Font.title2)
            }
            .modifier(ItemDestinationModifier(isActive: $itemToggle))
            .navigationTitle("Destinations")
        }
        .frame(height: 340)
    }

    @ViewBuilder
    var itemPushButton: some View {
        #if os(iOS)
        if #available(iOS 17, *) {
            Button("Item push") { itemToggle = true }
                .disabled(triggerMode != .item)
        }
        #elseif os(macOS)
        if #available(macOS 14, *) {
            Button("Item push") { itemToggle = true }
                .disabled(triggerMode != .item)
        }
        #endif
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Trigger mode", selection: $triggerMode)
        ShowcaseToggle("isPresented (boolean push)", isOn: $isPresentedToggle)
            .disabled(triggerMode != .isPresented)
        itemToggleControl
    }

    @ViewBuilder
    var itemToggleControl: some View {
        #if os(iOS)
        if #available(iOS 17, *) {
            ShowcaseToggle("Item binding (item push)", isOn: $itemToggle)
                .disabled(triggerMode != .item)
        }
        #elseif os(macOS)
        if #available(macOS 14, *) {
            ShowcaseToggle("Item binding (item push)", isOn: $itemToggle)
                .disabled(triggerMode != .item)
        }
        #else
        EmptyView()
        #endif
    }

    @ViewBuilder
    func stateView(_ state: DestinationState) -> some View {
        switch state {
        case .defaultForType:
            destinationDemo(mode: .forType)
        case .selected:
            destinationDemo(mode: .isPresented)
        case .longContent:
            longContentDemo
        }
    }

    func destinationDemo(mode: TriggerMode) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: mode == .forType ? "arrow.right.circle" : "square.and.arrow.up")
                .font(DesignSystem.Font.title)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(mode.label)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var longContentDemo: some View {
        VStack(spacing: DesignSystem.Spacing.xSmall) {
            ForEach(0..<4, id: \.self) { index in
                HStack {
                    Image(systemName: "arrow.right")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.accent)
                    Text("Destination \(index)")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.primary)
                }
            }
        }
        .padding(DesignSystem.Spacing.small)
    }
}

// MARK: - Code generation
private extension NavigationDestinationShowcase {
    var generatedCode: String {
        switch triggerMode {
        case .forType:
            return forTypeCode
        case .isPresented:
            return isPresentedCode
        case .item:
            return itemCode
        }
    }

    var forTypeCode: String {
        """
        NavigationStack {
            List {
                NavigationLink("Row", value: 42)
            }
            .navigationDestination(for: Int.self) { value in
                Text("Detail for \\(value)")
            }
        }
        """
    }

    var isPresentedCode: String {
        """
        struct Demo: View {
            @State private var showDetail = \(isPresentedToggle)

            var body: some View {
                NavigationStack {
                    List {
                        Button("Boolean push") { showDetail = true }
                    }
                    .navigationDestination(isPresented: $showDetail) {
                        Text("Boolean-driven detail")
                    }
                }
            }
        }
        """
    }

    var itemCode: String {
        """
        // Requires iOS 17+ / macOS 14+
        struct Demo: View {
            @State private var selectedItem: MyItem?

            var body: some View {
                NavigationStack {
                    List {
                        Button("Push item") { selectedItem = MyItem(id: 1) }
                    }
                    .navigationDestination(item: $selectedItem) { item in
                        Text("Detail for \\(item.id)")
                    }
                }
            }
        }
        """
    }
}

// MARK: - Configuration enums
private extension NavigationDestinationShowcase {
    enum TriggerMode: ShowcasePickable {
        case forType
        case isPresented
        case item

        var label: String {
            switch self {
            case .forType: "for: (type)"
            case .isPresented: "isPresented:"
            case .item: "item: (iOS 17+)"
            }
        }
    }

    enum DestinationState: ShowcaseState {
        case defaultForType
        case selected
        case longContent

        var caption: String {
            switch self {
            case .defaultForType: "for: type"
            case .selected: "isPresented"
            case .longContent: "Many destinations"
            }
        }
    }
}

// MARK: - ItemDestinationModifier
private struct ItemDestinationModifier: ViewModifier {
    @Binding var isActive: Bool

    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 17, *) {
            content.navigationDestination(item: binding) { _ in
                Text("Item-driven detail")
                    .font(DesignSystem.Font.title2)
            }
        } else {
            content
        }
        #elseif os(macOS)
        if #available(macOS 14, *) {
            content.navigationDestination(item: binding) { _ in
                Text("Item-driven detail")
                    .font(DesignSystem.Font.title2)
            }
        } else {
            content
        }
        #else
        content
        #endif
    }

    private var binding: Binding<DemoItem?> {
        Binding(
            get: { isActive ? DemoItem() : nil },
            set: { isActive = $0 != nil },
        )
    }
}

// MARK: - DemoItem
private struct DemoItem: Identifiable, Hashable {
    let id = UUID()
}
