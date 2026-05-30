import SwiftUI

struct GlassEffectUnionShowcase: View {
    enum UnionState: ShowcaseState {
        case allUnified
        case oneOptedOut

        var caption: String {
            switch self {
            case .allUnified: "All unified"
            case .oneOptedOut: "One opted out"
            }
        }
    }

    @Namespace private var previewNamespace
    @State private var unionID = "group"
    @State private var selectedIndex: Int?
    @State private var itemCount = 3

    var body: some View {
        ShowcaseScreen(
            title: "Glass Effect Union",
            summary: "Merges adjacent glass shapes sharing an id into one continuous glass surface.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension GlassEffectUnionShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            Text("Tap an item to select — it exits the union; the rest merge.")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
            GlassEffectContainer {
                HStack(spacing: DesignSystem.Spacing.small) {
                    ForEach(0 ..< itemCount, id: \.self) { index in
                        itemButton(index: index, isSelected: selectedIndex == index)
                    }
                }
            }
        }
    }

    func itemButton(index: Int, isSelected: Bool) -> some View {
        let icons = ["star.fill", "heart.fill", "bolt.fill", "flame.fill", "leaf.fill"]
        let icon = icons[index % icons.count]
        let effectiveID: String? = isSelected ? nil : unionID
        return Button {
            withAnimation(.spring) {
                selectedIndex = isSelected ? nil : index
            }
        } label: {
            Image(systemName: icon)
                .font(DesignSystem.Font.title2)
                .frame(
                    width: DesignSystem.Size.Icon.xLarge,
                    height: DesignSystem.Size.Icon.xLarge,
                )
                .glassEffect(.regular.interactive(true))
                .glassEffectUnion(id: effectiveID, namespace: previewNamespace)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Union ID", text: $unionID, prompt: "e.g. group")
        ShowcaseStepper("Item count", value: $itemCount, in: 2 ... 5)
    }

    @ViewBuilder
    func stateView(_ state: UnionState) -> some View {
        switch state {
        case .allUnified: unifiedGalleryCell
        case .oneOptedOut: optedOutGalleryCell
        }
    }

    var unifiedGalleryCell: some View {
        GalleryCell(optedOutIndex: nil)
    }

    var optedOutGalleryCell: some View {
        GalleryCell(optedOutIndex: 1)
    }
}

// MARK: - Code generation
private extension GlassEffectUnionShowcase {
    var generatedCode: String {
        let idLiteral = unionID.isEmpty ? "\"group\"" : "\"\(unionID)\""
        return """
        @Namespace private var namespace

        GlassEffectContainer {
            HStack {
                ForEach(items) { item in
                    Image(systemName: item.icon)
                        .padding()
                        .glassEffect()
                        .glassEffectUnion(id: \(idLiteral), in: namespace)
                }
            }
        }
        """
    }
}

// MARK: - GalleryCell
private struct GalleryCell: View {
    let optedOutIndex: Int?
    @Namespace private var namespace
    private let icons = ["star.fill", "heart.fill", "bolt.fill"]

    var body: some View {
        GlassEffectContainer {
            HStack(spacing: DesignSystem.Spacing.small) {
                ForEach(Array(icons.enumerated()), id: \.offset) { index, icon in
                    let effectiveID: String? = optedOutIndex == index ? nil : "group"
                    Image(systemName: icon)
                        .font(DesignSystem.Font.title2)
                        .frame(
                            width: DesignSystem.Size.Icon.xLarge,
                            height: DesignSystem.Size.Icon.xLarge,
                        )
                        .glassEffect(.regular)
                        .glassEffectUnion(id: effectiveID, namespace: namespace)
                }
            }
        }
    }
}
