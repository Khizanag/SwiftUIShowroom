import SwiftUI

struct ContentShapeShowcase: View {
    @State private var shapeOption: ShapeOption = .rectangle
    @State private var kindOption: KindOption = .interaction
    @State private var tapCount: Int = 0

    var body: some View {
        ShowcaseScreen(
            title: "Content Shape",
            summary: "Defines the hit-testing or preview shape of a view, changing its tappable region.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ContentShapeShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            rowSwatch(shape: shapeOption, tapCount: tapCount)
                .modifier(ContentShapeModifier(shape: shapeOption, kind: kindOption))
                .onTapGesture { tapCount += 1 }
            Text(tapCount == 0 ? "Tap anywhere on the row" : "Tapped \(tapCount) time\(tapCount == 1 ? "" : "s")")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
                .animation(.easeInOut, value: tapCount)
        }
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Shape", selection: $shapeOption)
        ShowcasePicker("Kind", selection: $kindOption)
    }

    @ViewBuilder func stateView(_ state: ContentShapeState) -> some View {
        rowSwatch(shape: state.shape, tapCount: 0)
            .modifier(ContentShapeModifier(shape: state.shape, kind: .interaction))
    }

    func rowSwatch(shape: ShapeOption, tapCount: Int) -> some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: "folder.fill")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(width: DesignSystem.Size.Icon.medium, height: DesignSystem.Size.Icon.medium)
            Text("Files")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(.horizontal, DesignSystem.Spacing.medium)
        .padding(.vertical, DesignSystem.Spacing.small)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }
}

// MARK: - Code generation
private extension ContentShapeShowcase {
    var generatedCode: String {
        """
        HStack {
            Image(systemName: "folder")
            Spacer()
            Text("Files")
        }
        .contentShape(\(shapeOption.codeLabel))
        .onTapGesture { open() }
        """
    }
}

// MARK: - ContentShape modifier (cross-platform dispatch)
private struct ContentShapeModifier: ViewModifier {
    let shape: ContentShapeShowcase.ShapeOption
    let kind: ContentShapeShowcase.KindOption

    func body(content: Content) -> some View {
        switch shape {
        case .rectangle:
            content.contentShape(kind.kinds, Rectangle())
        case .roundedRectangle:
            content.contentShape(kind.kinds, RoundedRectangle(cornerRadius: 12))
        case .capsule:
            content.contentShape(kind.kinds, Capsule())
        case .circle:
            content.contentShape(kind.kinds, Circle())
        }
    }
}

// MARK: - Nested types
extension ContentShapeShowcase {
    enum ShapeOption: ShowcasePickable {
        case rectangle
        case roundedRectangle
        case capsule
        case circle

        var label: String {
            switch self {
            case .rectangle: "Rectangle"
            case .roundedRectangle: "RoundedRect r:12"
            case .capsule: "Capsule"
            case .circle: "Circle"
            }
        }

        var codeLabel: String {
            switch self {
            case .rectangle: "Rectangle()"
            case .roundedRectangle: "RoundedRectangle(cornerRadius: 12)"
            case .capsule: "Capsule()"
            case .circle: "Circle()"
            }
        }
    }

    enum KindOption: ShowcasePickable {
        case interaction
        case focusEffect
        case accessibility

        var label: String {
            switch self {
            case .interaction: "interaction"
            case .focusEffect: "focusEffect"
            case .accessibility: "accessibility"
            }
        }

        var kinds: ContentShapeKinds {
            switch self {
            case .interaction: return .interaction
            case .focusEffect:
                #if !os(iOS)
                return .focusEffect
                #else
                return .interaction
                #endif
            case .accessibility: return .accessibility
            }
        }
    }

    enum ContentShapeState: ShowcaseState {
        case fullRow
        case rounded
        case capsuleShape
        case circleShape

        var caption: String {
            switch self {
            case .fullRow: "Rectangle (full row)"
            case .rounded: "RoundedRect r:12"
            case .capsuleShape: "Capsule"
            case .circleShape: "Circle"
            }
        }

        var shape: ShapeOption {
            switch self {
            case .fullRow: .rectangle
            case .rounded: .roundedRectangle
            case .capsuleShape: .capsule
            case .circleShape: .circle
            }
        }
    }
}
