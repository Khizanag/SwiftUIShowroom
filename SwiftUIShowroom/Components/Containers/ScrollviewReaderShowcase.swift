import SwiftUI

struct ScrollviewReaderShowcase: View {
    enum AnchorOption: ShowcasePickable {
        case none, top, center, bottom, leading, trailing

        var label: String {
            switch self {
            case .none: "nil"
            case .top: "top"
            case .center: "center"
            case .bottom: "bottom"
            case .leading: "leading"
            case .trailing: "trailing"
            }
        }

        var unitPoint: UnitPoint? {
            switch self {
            case .none: nil
            case .top: .top
            case .center: .center
            case .bottom: .bottom
            case .leading: .leading
            case .trailing: .trailing
            }
        }

        var codeString: String {
            self == .none ? "nil" : ".\(label)"
        }
    }

    enum ScrollViewReaderState: ShowcaseState {
        case fewItems
        case manyItems
        case jumpToFirst
        case jumpToLast

        var caption: String {
            switch self {
            case .fewItems: "Few items"
            case .manyItems: "Many items"
            case .jumpToFirst: "Jump to first"
            case .jumpToLast: "Jump to last"
            }
        }
    }

    @State private var targetAnchor: AnchorOption = .top
    @State private var animated: Bool = true
    @State private var itemCount: Int = 20
    @State private var highlightedID: Int?

    var body: some View {
        ShowcaseScreen(
            title: "ScrollViewReader",
            summary: "Programmatic scrolling to a child identified by ID via a ScrollViewProxy.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") {
                StateGallery(content: stateView)
            }
            ShowcaseSection("Generated code") {
                CodeBlock(code: generatedCode)
            }
        }
    }
}

// MARK: - Sub-views
private extension ScrollviewReaderShowcase {
    var preview: some View {
        ScrollViewReader { proxy in
            VStack(spacing: DesignSystem.Spacing.medium) {
                ScrollView {
                    LazyVStack(spacing: DesignSystem.Spacing.xSmall) {
                        ForEach(1 ... itemCount, id: \.self) { index in
                            rowView(index: index, isHighlighted: highlightedID == index)
                                .id(index)
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.small)
                }
                .frame(height: 260)
                .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))

                jumpButtons(proxy: proxy)
            }
        }
        .frame(maxWidth: .infinity)
    }

    func rowView(index: Int, isHighlighted: Bool) -> some View {
        HStack {
            Text("Item \(index)")
                .font(DesignSystem.Font.body)
                .foregroundStyle(isHighlighted ? DesignSystem.Color.onAccent : DesignSystem.Color.primary)
            Spacer()
            if isHighlighted {
                Image(systemName: "arrow.left")
                    .foregroundStyle(DesignSystem.Color.onAccent)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.medium)
        .padding(.vertical, DesignSystem.Spacing.xSmall)
        .background(
            isHighlighted ? DesignSystem.Color.accent : DesignSystem.Color.cardBackground,
            in: .rect(cornerRadius: DesignSystem.CornerRadius.small),
        )
        .animation(.easeInOut(duration: 0.25), value: isHighlighted)
    }

    func jumpButtons(proxy: ScrollViewProxy) -> some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            jumpButton(label: "First", target: 1, proxy: proxy)
            jumpButton(label: "Middle", target: itemCount / 2, proxy: proxy)
            jumpButton(label: "Last", target: itemCount, proxy: proxy)
        }
    }

    func jumpButton(label: String, target: Int, proxy: ScrollViewProxy) -> some View {
        Button(label) {
            highlightedID = target
            let anchor = targetAnchor.unitPoint
            if animated {
                withAnimation { proxy.scrollTo(target, anchor: anchor) }
            } else {
                proxy.scrollTo(target, anchor: anchor)
            }
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Target anchor", selection: $targetAnchor)
        ShowcaseToggle("Animated", isOn: $animated)
        ShowcaseStepper("Item count", value: $itemCount, in: 5 ... 50)
    }

    @ViewBuilder
    func stateView(_ state: ScrollViewReaderState) -> some View {
        let count = stateItemCount(state)
        let jumpTarget = stateJumpTarget(state, count: count)
        GalleryScrollReader(count: count, jumpTarget: jumpTarget, anchor: targetAnchor.unitPoint)
    }

    func stateItemCount(_ state: ScrollViewReaderState) -> Int {
        switch state {
        case .fewItems: 6
        case .manyItems, .jumpToFirst, .jumpToLast: 20
        }
    }

    func stateJumpTarget(_ state: ScrollViewReaderState, count: Int) -> Int? {
        switch state {
        case .fewItems, .manyItems: nil
        case .jumpToFirst: 1
        case .jumpToLast: count
        }
    }
}

// MARK: - Gallery helper
private struct GalleryScrollReader: View {
    let count: Int
    let jumpTarget: Int?
    let anchor: UnitPoint?

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.hairline) {
                    ForEach(1 ... count, id: \.self) { index in
                        HStack {
                            Text("Item \(index)")
                                .font(DesignSystem.Font.caption)
                                .foregroundStyle(
                                    jumpTarget == index
                                        ? DesignSystem.Color.onAccent
                                        : DesignSystem.Color.primary,
                                )
                            Spacer()
                        }
                        .padding(.horizontal, DesignSystem.Spacing.small)
                        .padding(.vertical, DesignSystem.Spacing.hairline)
                        .background(
                            jumpTarget == index
                                ? DesignSystem.Color.accent
                                : DesignSystem.Color.cardBackground,
                            in: .rect(cornerRadius: DesignSystem.CornerRadius.small),
                        )
                        .id(index)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.xSmall)
            }
            .frame(height: 140)
            .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
            .task {
                if let target = jumpTarget {
                    try? await Task.sleep(for: .milliseconds(100))
                    withAnimation { proxy.scrollTo(target, anchor: anchor) }
                }
            }
        }
    }
}

// MARK: - Code generation
private extension ScrollviewReaderShowcase {
    var generatedCode: String {
        let anchorArg = targetAnchor == .none ? "" : ", anchor: \(targetAnchor.codeString)"
        let scrollCall = animated
            ? "withAnimation { proxy.scrollTo(targetID\(anchorArg)) }"
            : "proxy.scrollTo(targetID\(anchorArg))"
        let lines: [String] = [
            "ScrollViewReader { proxy in",
            "    ScrollView {",
            "        ForEach(items) { item in",
            "            RowView(item).id(item.id)",
            "        }",
            "    }",
            "    Button(\"Jump\") {",
            "        \(scrollCall)",
            "    }",
            "}",
        ]
        return lines.joined(separator: "\n")
    }
}
