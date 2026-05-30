import SwiftUI

struct PopoverShowcase: View {
    @State private var isPresented = false
    @State private var attachmentAnchor: AttachmentAnchorOption = .rectBounds
    @State private var arrowEdge: ArrowEdgeOption = .top
    @State private var compactAdaptation: CompactAdaptationOption = .automatic
    @State private var background: PopoverBackgroundOption = .system

    var body: some View {
        ShowcaseScreen(
            title: "Popover",
            summary: "Anchored transient presentation with an arrow, adapting to a sheet in compact widths.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension PopoverShowcase {
    var preview: some View {
        #if os(tvOS)
        popoverUnavailableNotice
        #else
        Button("Show Popover") {
            isPresented.toggle()
        }
        .buttonStyle(.bordered)
        .popover(
            isPresented: $isPresented,
            attachmentAnchor: attachmentAnchor.value,
            arrowEdge: arrowEdge.edge,
        ) {
            popoverContent(isLong: false)
        }
        #endif
    }

    #if os(tvOS)
    var popoverUnavailableNotice: some View {
        Text("Popover is not available on tvOS")
            .font(DesignSystem.Font.body)
            .foregroundStyle(DesignSystem.Color.secondary)
            .padding(DesignSystem.Spacing.medium)
    }
    #else
    func popoverContent(isLong: Bool) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Label("Popover Title", systemImage: "info.circle")
                .font(DesignSystem.Font.headline)
            Text(
                isLong
                    ? "This popover has a longer body to demonstrate how it scrolls or expands."
                    : "This popover is anchored to the source view. Tap outside to dismiss.",
            )
            .font(DesignSystem.Font.body)
            .foregroundStyle(DesignSystem.Color.secondary)
            if isLong {
                ForEach(0..<5, id: \.self) { idx in
                    Text("Additional row \(idx + 1)")
                        .font(DesignSystem.Font.callout)
                }
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .frame(minWidth: 240)
        .presentationCompactAdaptation(compactAdaptation.adaptation)
        .applyPopoverBackground(background)
    }
    #endif

    @ViewBuilder
    var controls: some View {
        #if os(tvOS)
        Text("Controls not available on tvOS")
            .font(DesignSystem.Font.body)
            .foregroundStyle(DesignSystem.Color.secondary)
        #else
        ShowcasePicker("Attachment anchor", selection: $attachmentAnchor)
        ShowcasePicker("Arrow edge", selection: $arrowEdge)
        ShowcasePicker("Compact adaptation", selection: $compactAdaptation)
        ShowcasePicker("Background", selection: $background)
        #endif
    }

    @ViewBuilder
    func stateView(_ state: PopoverState) -> some View {
        switch state {
        case .anchored:
            popoverStateIndicator(
                label: "Anchored",
                systemImage: "arrow.up.right",
                description: "Anchored to source, arrow visible on iPad/Mac",
            )
        case .longContent:
            popoverStateIndicator(
                label: "Long Content",
                systemImage: "text.alignleft",
                description: "Scrollable or expanded when content is tall",
            )
        case .compactSheet:
            popoverStateIndicator(
                label: "Compact → Sheet",
                systemImage: "iphone",
                description: "Adapts to a sheet in compact width (default)",
            )
        }
    }

    func popoverStateIndicator(
        label: String,
        systemImage: String,
        description: String,
    ) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: systemImage)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(
                    width: DesignSystem.Size.Icon.large,
                    height: DesignSystem.Size.Icon.large,
                )
            Text(label)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.primary)
            Text(description)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.medium)
    }
}

// MARK: - Code generation
private extension PopoverShowcase {
    var generatedCode: String {
        #if os(tvOS)
        return "// .popover is not available on tvOS"
        #else
        var lines = [
            ".popover(",
            "    isPresented: $isPresented,",
            "    attachmentAnchor: \(attachmentAnchor.code),",
            "    arrowEdge: \(arrowEdge.code)",
            ") {",
            "    PopoverContentView()",
        ]
        if compactAdaptation != .automatic {
            lines.append("        .presentationCompactAdaptation(\(compactAdaptation.code))")
        }
        if background != .system {
            lines.append("        .presentationBackground(\(background.code))")
        }
        lines.append("}")
        return lines.joined(separator: "\n")
        #endif
    }
}

// MARK: - Nested types
extension PopoverShowcase {
    enum AttachmentAnchorOption: ShowcasePickable {
        case rectBounds
        case pointCenter
        case pointTop
        case pointBottom

        var label: String {
            switch self {
            case .rectBounds: ".rect(.bounds)"
            case .pointCenter: ".point(.center)"
            case .pointTop: ".point(.top)"
            case .pointBottom: ".point(.bottom)"
            }
        }

        var value: PopoverAttachmentAnchor {
            switch self {
            case .rectBounds: .rect(.bounds)
            case .pointCenter: .point(.center)
            case .pointTop: .point(.top)
            case .pointBottom: .point(.bottom)
            }
        }

        var code: String { label }
    }

    enum ArrowEdgeOption: ShowcasePickable {
        case top
        case bottom
        case leading
        case trailing

        var label: String {
            switch self {
            case .top: "top"
            case .bottom: "bottom"
            case .leading: "leading"
            case .trailing: "trailing"
            }
        }

        var edge: Edge {
            switch self {
            case .top: .top
            case .bottom: .bottom
            case .leading: .leading
            case .trailing: .trailing
            }
        }

        var code: String { ".\(label)" }
    }

    enum CompactAdaptationOption: ShowcasePickable {
        case automatic
        case keepPopover
        case sheet

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .keepPopover: "popover"
            case .sheet: "sheet"
            }
        }

        var code: String {
            switch self {
            case .automatic: ".automatic"
            case .keepPopover: ".popover"
            case .sheet: ".sheet"
            }
        }

        var adaptation: PresentationAdaptation {
            switch self {
            case .automatic: .automatic
            case .keepPopover: .popover
            case .sheet: .sheet
            }
        }
    }

    enum PopoverBackgroundOption: ShowcasePickable {
        case system
        case regularMaterial
        case thinMaterial
        case ultraThinMaterial

        var label: String {
            switch self {
            case .system: "system default"
            case .regularMaterial: ".regularMaterial"
            case .thinMaterial: ".thinMaterial"
            case .ultraThinMaterial: ".ultraThinMaterial"
            }
        }

        var code: String {
            switch self {
            case .system: ".regularMaterial"
            case .regularMaterial: ".regularMaterial"
            case .thinMaterial: ".thinMaterial"
            case .ultraThinMaterial: ".ultraThinMaterial"
            }
        }
    }

    enum PopoverState: ShowcaseState {
        case anchored
        case longContent
        case compactSheet

        var caption: String {
            switch self {
            case .anchored: "Anchored"
            case .longContent: "Long content"
            case .compactSheet: "Compact → Sheet"
            }
        }
    }
}

// MARK: - View helpers
#if !os(tvOS)
private extension View {
    @ViewBuilder
    func applyPopoverBackground(_ option: PopoverShowcase.PopoverBackgroundOption) -> some View {
        switch option {
        case .system:
            self
        case .regularMaterial:
            self.presentationBackground(.regularMaterial)
        case .thinMaterial:
            self.presentationBackground(.thinMaterial)
        case .ultraThinMaterial:
            self.presentationBackground(.ultraThinMaterial)
        }
    }
}
#endif
