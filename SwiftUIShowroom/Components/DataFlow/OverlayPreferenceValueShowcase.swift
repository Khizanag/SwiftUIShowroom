import SwiftUI

struct OverlayPreferenceValueShowcase: View {
    @State private var layer: LayerOption = .overlay
    @State private var selectedItem: Int = 0
    @State private var strokeWidth: Double = 2
    @State private var cornerRadiusValue: Double = 8

    var body: some View {
        ShowcaseScreen(
            title: "overlayPreferenceValue",
            summary: "Use overlayPreferenceValue / backgroundPreferenceValue to draw from anchor bounds.",
        ) {
            PreviewStage(backdrop: .colorful) { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension OverlayPreferenceValueShowcase {
    fileprivate enum LayerOption: ShowcasePickable {
        case overlay, background

        var label: String {
            switch self {
            case .overlay: "overlay"
            case .background: "background"
            }
        }

        var apiName: String {
            switch self {
            case .overlay: "overlayPreferenceValue"
            case .background: "backgroundPreferenceValue"
            }
        }
    }

    fileprivate enum DemoState: ShowcaseState {
        case withOverlay, withBackground, multipleItems

        var caption: String {
            switch self {
            case .withOverlay: "Overlay highlight"
            case .withBackground: "Background highlight"
            case .multipleItems: "Multiple anchors"
            }
        }
    }
}

// MARK: - Preference key
private struct ItemBoundsKey: PreferenceKey {
    static let defaultValue: Anchor<CGRect>? = nil
    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = nextValue() ?? value
    }
}

private struct AllBoundsKey: PreferenceKey {
    static let defaultValue: [Anchor<CGRect>] = []
    static func reduce(value: inout [Anchor<CGRect>], nextValue: () -> [Anchor<CGRect>]) {
        value.append(contentsOf: nextValue())
    }
}

// MARK: - Sub-views
private extension OverlayPreferenceValueShowcase {
    var preview: some View {
        let items = ["Swift", "SwiftUI", "Xcode"]
        return VStack(spacing: DesignSystem.Spacing.medium) {
            HStack(spacing: DesignSystem.Spacing.medium) {
                ForEach(items.indices, id: \.self) { index in
                    Button {
                        withAnimation(.spring) { selectedItem = index }
                    } label: {
                        Text(items[index])
                            .font(DesignSystem.Font.headline)
                            .foregroundStyle(
                                selectedItem == index ? DesignSystem.Color.onAccent : DesignSystem.Color.primary
                            )
                            .padding(.horizontal, DesignSystem.Spacing.medium)
                            .padding(.vertical, DesignSystem.Spacing.small)
                    }
                    .anchorPreference(key: ItemBoundsKey.self, value: .bounds) { anchor in
                        index == selectedItem ? anchor : nil
                    }
                }
            }
            .modifier(HighlightOverlay(layer: layer, strokeWidth: strokeWidth, cornerRadius: cornerRadiusValue))
            Text("Tap an item to move the \(layer.label) highlight")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.onAccent.opacity(0.8))
        }
        .padding(DesignSystem.Spacing.large)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Layer", selection: $layer)
        ShowcaseSlider("Stroke width", value: $strokeWidth, in: 1...6, step: 0.5)
        ShowcaseSlider("Corner radius", value: $cornerRadiusValue, in: 0...20, step: 1)
    }

    @ViewBuilder
    func stateView(_ state: DemoState) -> some View {
        switch state {
        case .withOverlay:
            overlayHighlightExample
        case .withBackground:
            backgroundHighlightExample
        case .multipleItems:
            multipleAnchorsExample
        }
    }

    var overlayHighlightExample: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Text("Selected")
                .font(DesignSystem.Font.caption)
                .padding(.horizontal, DesignSystem.Spacing.small)
                .padding(.vertical, DesignSystem.Spacing.xSmall)
                .anchorPreference(key: ItemBoundsKey.self, value: .bounds) { $0 }
            Text("Other")
                .font(DesignSystem.Font.caption)
                .padding(.horizontal, DesignSystem.Spacing.small)
                .padding(.vertical, DesignSystem.Spacing.xSmall)
        }
        .overlayPreferenceValue(ItemBoundsKey.self) { anchor in
            GeometryReader { proxy in
                if let anchor {
                    let rect = proxy[anchor]
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(DesignSystem.Color.accent, lineWidth: 2)
                        .frame(width: rect.width, height: rect.height)
                        .offset(x: rect.minX, y: rect.minY)
                }
            }
        }
    }

    var backgroundHighlightExample: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Text("Highlighted")
                .font(DesignSystem.Font.caption)
                .padding(.horizontal, DesignSystem.Spacing.small)
                .padding(.vertical, DesignSystem.Spacing.xSmall)
                .anchorPreference(key: ItemBoundsKey.self, value: .bounds) { $0 }
            Text("Plain")
                .font(DesignSystem.Font.caption)
                .padding(.horizontal, DesignSystem.Spacing.small)
                .padding(.vertical, DesignSystem.Spacing.xSmall)
        }
        .backgroundPreferenceValue(ItemBoundsKey.self) { anchor in
            GeometryReader { proxy in
                if let anchor {
                    let rect = proxy[anchor]
                    RoundedRectangle(cornerRadius: 6)
                        .fill(DesignSystem.Color.accent.opacity(0.2))
                        .frame(width: rect.width, height: rect.height)
                        .offset(x: rect.minX, y: rect.minY)
                }
            }
        }
    }

    var multipleAnchorsExample: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            ForEach(0..<3) { index in
                Text("Item \(index + 1)")
                    .font(DesignSystem.Font.caption)
                    .padding(.horizontal, DesignSystem.Spacing.xSmall)
                    .padding(.vertical, DesignSystem.Spacing.xSmall)
                    .anchorPreference(key: AllBoundsKey.self, value: .bounds) { [$0] }
            }
        }
        .overlayPreferenceValue(AllBoundsKey.self) { anchors in
            GeometryReader { proxy in
                ForEach(anchors.indices, id: \.self) { index in
                    let rect = proxy[anchors[index]]
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(DesignSystem.Color.accent.opacity(0.6), lineWidth: 1.5)
                        .frame(width: rect.width, height: rect.height)
                        .offset(x: rect.minX, y: rect.minY)
                }
            }
        }
    }
}

// MARK: - ViewModifier
private struct HighlightOverlay: ViewModifier {
    let layer: OverlayPreferenceValueShowcase.LayerOption
    let strokeWidth: Double
    let cornerRadius: Double

    func body(content: Content) -> some View {
        if layer == .overlay {
            content.overlayPreferenceValue(ItemBoundsKey.self) { anchor in
                highlightShape(anchor: anchor)
            }
        } else {
            content.backgroundPreferenceValue(ItemBoundsKey.self) { anchor in
                backgroundShape(anchor: anchor)
            }
        }
    }

    private func highlightShape(anchor: Anchor<CGRect>?) -> some View {
        GeometryReader { proxy in
            if let anchor {
                let rect = proxy[anchor]
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.9), lineWidth: strokeWidth)
                    .frame(width: rect.width, height: rect.height)
                    .offset(x: rect.minX, y: rect.minY)
                    .animation(.spring, value: rect.minX)
            }
        }
    }

    private func backgroundShape(anchor: Anchor<CGRect>?) -> some View {
        GeometryReader { proxy in
            if let anchor {
                let rect = proxy[anchor]
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white.opacity(0.25))
                    .frame(width: rect.width, height: rect.height)
                    .offset(x: rect.minX, y: rect.minY)
                    .animation(.spring, value: rect.minX)
            }
        }
    }
}

// MARK: - Code generation
private extension OverlayPreferenceValueShowcase {
    var generatedCode: String {
        let apiName = layer.apiName
        let radius = Int(cornerRadiusValue)
        let width = strokeWidth.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(strokeWidth))
            : String(format: "%.1f", strokeWidth)
        return [
            "// 1. Define a PreferenceKey that collects an Anchor<CGRect>",
            "struct BoundsKey: PreferenceKey {",
            "    static let defaultValue: Anchor<CGRect>? = nil",
            "    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {",
            "        value = nextValue() ?? value",
            "    }",
            "}",
            "",
            "// 2. Tag the child view",
            "Text(\"Item\")",
            "    .anchorPreference(key: BoundsKey.self, value: .bounds) { $0 }",
            "",
            "// 3. Consume the anchor in the \(layer.label)",
            "ContainerView()",
            "    .\(apiName)(BoundsKey.self) { anchor in",
            "        GeometryReader { proxy in",
            "            if let anchor {",
            "                let rect = proxy[anchor]",
            "                RoundedRectangle(cornerRadius: \(radius))",
            layer == .overlay
                ? "                    .stroke(.accent, lineWidth: \(width))"
                : "                    .fill(.accent.opacity(0.2))",
            "                    .frame(width: rect.width, height: rect.height)",
            "                    .offset(x: rect.minX, y: rect.minY)",
            "            }",
            "        }",
            "    }",
        ].joined(separator: "\n")
    }
}
