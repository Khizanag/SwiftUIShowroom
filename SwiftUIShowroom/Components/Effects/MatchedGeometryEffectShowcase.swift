import SwiftUI

struct MatchedGeometryEffectShowcase: View {
    @Namespace private var namespace
    @State private var heroID = "hero"
    @State private var properties: GeometryPropertiesOption = .frame
    @State private var anchor: AnchorOption = .center
    @State private var isSource: Bool = true
    @State private var isExpanded: Bool = false

    var body: some View {
        ShowcaseScreen(
            title: "Matched Geometry Effect",
            summary: "Animates a view morphing between two layouts by matching frame geometry across a namespace.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension MatchedGeometryEffectShowcase {
    fileprivate enum GeometryPropertiesOption: String, ShowcasePickable, CaseIterable {
        case frame, position, size

        var label: String {
            switch self {
            case .frame: ".frame"
            case .position: ".position"
            case .size: ".size"
            }
        }

        var value: MatchedGeometryProperties {
            switch self {
            case .frame: .frame
            case .position: .position
            case .size: .size
            }
        }

        var codeString: String {
            switch self {
            case .frame: ".frame"
            case .position: ".position"
            case .size: ".size"
            }
        }
    }

    fileprivate enum AnchorOption: String, ShowcasePickable, CaseIterable {
        case center, top, topLeading, bottomTrailing

        var label: String {
            switch self {
            case .center: ".center"
            case .top: ".top"
            case .topLeading: ".topLeading"
            case .bottomTrailing: ".bottomTrailing"
            }
        }

        var value: UnitPoint {
            switch self {
            case .center: .center
            case .top: .top
            case .topLeading: .topLeading
            case .bottomTrailing: .bottomTrailing
            }
        }

        var codeString: String {
            switch self {
            case .center: ".center"
            case .top: ".top"
            case .topLeading: ".topLeading"
            case .bottomTrailing: ".bottomTrailing"
            }
        }
    }

    fileprivate enum HeroState: ShowcaseState {
        case collapsed, expanded

        var caption: String {
            switch self {
            case .collapsed: "Default (thumbnail)"
            case .expanded: "Selected (hero)"
            }
        }
    }
}

// MARK: - Sub-views
private extension MatchedGeometryEffectShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            heroPreview
            Button(isExpanded ? "Collapse" : "Expand") {
                withAnimation(.spring) {
                    isExpanded.toggle()
                }
            }
            .font(DesignSystem.Font.headline)
            .buttonStyle(.borderedProminent)
        }
        .padding(DesignSystem.Spacing.medium)
    }

    @ViewBuilder
    var heroPreview: some View {
        if isExpanded {
            expandedHero
                .matchedGeometryEffect(
                    id: heroID,
                    in: namespace,
                    properties: properties.value,
                    anchor: anchor.value,
                    isSource: isSource,
                )
        } else {
            collapsedThumbnail
                .matchedGeometryEffect(
                    id: heroID,
                    in: namespace,
                    properties: properties.value,
                    anchor: anchor.value,
                    isSource: isSource,
                )
        }
    }

    var collapsedThumbnail: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(DesignSystem.Color.accent)
            .frame(width: DesignSystem.Size.Icon.xLarge, height: DesignSystem.Size.Icon.xLarge)
            .overlay {
                Image(systemName: "photo.fill")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.onAccent)
            }
    }

    var expandedHero: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
            .fill(DesignSystem.Color.accent)
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .overlay {
                VStack(spacing: DesignSystem.Spacing.small) {
                    Image(systemName: "photo.fill")
                        .font(DesignSystem.Font.largeTitle)
                        .foregroundStyle(DesignSystem.Color.onAccent)
                    Text("Hero View")
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.onAccent)
                }
            }
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("ID", text: $heroID, prompt: "e.g. \"hero\"")
        ShowcasePicker("Properties", selection: $properties)
        ShowcasePicker("Anchor", selection: $anchor)
        ShowcaseToggle("Is Source", isOn: $isSource)
    }

    @ViewBuilder
    func stateView(_ state: HeroState) -> some View {
        switch state {
        case .collapsed:
            StaticThumbnailView()
        case .expanded:
            StaticHeroView()
        }
    }
}

// MARK: - Code generation
private extension MatchedGeometryEffectShowcase {
    var generatedCode: String {
        let isSourceStr = isSource ? "true" : "false"
        return """
        @Namespace private var namespace

        // Collapsed
        thumbnail
            .matchedGeometryEffect(
                id: "\(heroID)",
                in: namespace,
                properties: \(properties.codeString),
                anchor: \(anchor.codeString),
                isSource: \(isSourceStr)
            )

        // Expanded
        heroView
            .matchedGeometryEffect(
                id: "\(heroID)",
                in: namespace,
                properties: \(properties.codeString),
                anchor: \(anchor.codeString),
                isSource: \(isSourceStr)
            )

        // Animate the swap:
        Button("Toggle") {
            withAnimation(.spring) { isExpanded.toggle() }
        }
        """
    }
}

// MARK: - Gallery helper views
private struct StaticThumbnailView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(DesignSystem.Color.accent)
            .frame(width: DesignSystem.Size.Icon.xLarge, height: DesignSystem.Size.Icon.xLarge)
            .overlay {
                Image(systemName: "photo.fill")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.onAccent)
            }
    }
}

// MARK: - Gallery hero view
private struct StaticHeroView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
            .fill(DesignSystem.Color.accent)
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .overlay {
                VStack(spacing: DesignSystem.Spacing.xSmall) {
                    Image(systemName: "photo.fill")
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.onAccent)
                    Text("Hero View")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.onAccent)
                }
            }
    }
}
