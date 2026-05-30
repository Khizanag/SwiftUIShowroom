import SwiftUI

struct ScrollviewShowcase: View {
    @State private var axes: AxesOption = .vertical
    @State private var indicators: IndicatorOption = .automatic
    @State private var targetBehavior: TargetBehaviorOption = .none
    @State private var bounceBehavior: BounceOption = .automatic
    @State private var scrollDisabled = false
    @State private var clipDisabled = false
    @State private var indicatorsFlash = false

    var body: some View {
        ShowcaseScreen(
            title: "ScrollView",
            summary: "A scrollable container that lets users move through content larger than the visible area.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension ScrollviewShowcase {
    enum AxesOption: ShowcasePickable {
        case vertical, horizontal, both

        var label: String {
            switch self {
            case .vertical: "vertical"
            case .horizontal: "horizontal"
            case .both: "both"
            }
        }

        var axes: Axis.Set {
            switch self {
            case .vertical: .vertical
            case .horizontal: .horizontal
            case .both: [.vertical, .horizontal]
            }
        }

        var codeValue: String {
            switch self {
            case .vertical: ".vertical"
            case .horizontal: ".horizontal"
            case .both: "[.vertical, .horizontal]"
            }
        }
    }

    enum IndicatorOption: ShowcasePickable {
        case automatic, visible, hidden, never

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .visible: "visible"
            case .hidden: "hidden"
            case .never: "never"
            }
        }

        var visibility: ScrollIndicatorVisibility {
            switch self {
            case .automatic: .automatic
            case .visible: .visible
            case .hidden: .hidden
            case .never: .never
            }
        }
    }

    enum TargetBehaviorOption: ShowcasePickable {
        case none, paging, viewAligned

        var label: String {
            switch self {
            case .none: "none"
            case .paging: "paging"
            case .viewAligned: "viewAligned"
            }
        }
    }

    enum BounceOption: ShowcasePickable {
        case automatic, always, basedOnSize

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .always: "always"
            case .basedOnSize: "basedOnSize"
            }
        }

        var behavior: ScrollBounceBehavior {
            switch self {
            case .automatic: .automatic
            case .always: .always
            case .basedOnSize: .basedOnSize
            }
        }
    }

    enum ScrollState: ShowcaseState {
        case defaultState, empty, longContent, disabled

        var caption: String {
            switch self {
            case .defaultState: "Default"
            case .empty: "Empty"
            case .longContent: "Long content"
            case .disabled: "Disabled"
            }
        }
    }
}

// MARK: - Sub-views
private extension ScrollviewShowcase {
    var preview: some View {
        scrollView(
            itemCount: 8,
            disabled: scrollDisabled,
        )
        .frame(maxHeight: axes == .horizontal ? 100 : 200)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Axes", selection: $axes)
        ShowcasePicker("Indicators", selection: $indicators)
        ShowcasePicker("Target behavior", selection: $targetBehavior)
        ShowcasePicker("Bounce behavior", selection: $bounceBehavior)
        ShowcaseToggle("Scroll disabled", isOn: $scrollDisabled)
        ShowcaseToggle("Clip disabled", isOn: $clipDisabled)
        ShowcaseToggle("Indicators flash", isOn: $indicatorsFlash)
    }

    @ViewBuilder
    func stateView(_ state: ScrollState) -> some View {
        switch state {
        case .defaultState:
            scrollView(itemCount: 6, disabled: false)
                .frame(maxHeight: 160)
        case .empty:
            ScrollView {
                ContentUnavailableView(
                    "No Items",
                    systemImage: "tray.fill",
                )
            }
            .frame(maxHeight: 160)
        case .longContent:
            scrollView(itemCount: 30, disabled: false)
                .frame(maxHeight: 160)
        case .disabled:
            scrollView(itemCount: 6, disabled: true)
                .frame(maxHeight: 160)
        }
    }

    @ViewBuilder
    func scrollView(itemCount: Int, disabled: Bool) -> some View {
        let isHorizontal = axes == .horizontal
        if indicatorsFlash {
            buildScrollView(itemCount: itemCount, horizontal: isHorizontal)
                .scrollIndicators(indicators.visibility)
                .scrollBounceBehavior(bounceBehavior.behavior)
                .scrollDisabled(disabled)
                .scrollClipDisabled(clipDisabled)
                .scrollIndicatorsFlash(onAppear: true)
        } else {
            buildScrollView(itemCount: itemCount, horizontal: isHorizontal)
                .scrollIndicators(indicators.visibility)
                .scrollBounceBehavior(bounceBehavior.behavior)
                .scrollDisabled(disabled)
                .scrollClipDisabled(clipDisabled)
        }
    }

    @ViewBuilder
    func buildScrollView(itemCount: Int, horizontal: Bool) -> some View {
        if horizontal {
            horizontalScrollContent(itemCount: itemCount)
        } else {
            verticalScrollContent(itemCount: itemCount)
        }
    }

    func horizontalScrollContent(itemCount: Int) -> some View {
        applyTargetBehavior(
            to: ScrollView(.horizontal) {
                LazyHStack(spacing: DesignSystem.Spacing.small) {
                    ForEach(0..<itemCount, id: \.self) { index in
                        itemCard(index: index, horizontal: true)
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, DesignSystem.Spacing.small)
            }
        )
    }

    func verticalScrollContent(itemCount: Int) -> some View {
        applyTargetBehavior(
            to: ScrollView(axes.axes) {
                LazyVStack(spacing: DesignSystem.Spacing.small) {
                    ForEach(0..<itemCount, id: \.self) { index in
                        itemCard(index: index, horizontal: false)
                    }
                }
                .scrollTargetLayout()
                .padding(.vertical, DesignSystem.Spacing.small)
            }
        )
    }

    @ViewBuilder
    func applyTargetBehavior(to scrollView: some View) -> some View {
        switch targetBehavior {
        case .none:
            scrollView
        case .paging:
            scrollView.scrollTargetBehavior(.paging)
        case .viewAligned:
            scrollView.scrollTargetBehavior(.viewAligned)
        }
    }

    func itemCard(index: Int, horizontal: Bool) -> some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(DesignSystem.Color.accent.opacity(0.15))
            .overlay(
                Text("Item \(index + 1)")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.primary),
            )
            .frame(
                width: horizontal ? 120 : nil,
                height: horizontal ? 80 : 52,
            )
            .frame(maxWidth: horizontal ? nil : .infinity)
    }
}

// MARK: - Code generation
private extension ScrollviewShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("ScrollView(\(axes.codeValue)) {")
        lines.append("    LazyVStack {")
        lines.append("        ForEach(items) { item in")
        lines.append("            RowView(item)")
        lines.append("        }")
        lines.append("    }")
        lines.append("    .scrollTargetLayout()")
        lines.append("}")
        lines.append(".scrollIndicators(.\(indicators.label))")
        if targetBehavior != .none {
            lines.append(".scrollTargetBehavior(.\(targetBehavior.label))")
        }
        lines.append(".scrollBounceBehavior(.\(bounceBehavior.label))")
        if scrollDisabled {
            lines.append(".scrollDisabled(true)")
        }
        if clipDisabled {
            lines.append(".scrollClipDisabled(true)")
        }
        if indicatorsFlash {
            lines.append(".scrollIndicatorsFlash(onAppear: true)")
        }
        return lines.joined(separator: "\n")
    }
}
