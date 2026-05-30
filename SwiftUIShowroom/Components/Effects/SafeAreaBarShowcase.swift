import SwiftUI

struct SafeAreaBarShowcase: View {
    @State private var selectedEdge: EdgeOption = .bottom
    @State private var selectedHAlignment: HAlignmentOption = .center
    @State private var selectedVAlignment: VAlignmentOption = .center
    @State private var spacing: Double = 8
    @State private var useCustomSpacing: Bool = true

    var body: some View {
        ShowcaseScreen(
            title: "Safe Area Bar",
            summary: "Pins a floating bar along a scroll edge so content flows under it.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension SafeAreaBarShowcase {
    var preview: some View {
        barDemo(edge: selectedEdge, spacing: effectiveSpacing)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Edge", selection: $selectedEdge)
        if selectedEdge.isVertical {
            ShowcasePicker("Alignment", selection: $selectedHAlignment)
        } else {
            ShowcasePicker("Alignment", selection: $selectedVAlignment)
        }
        ShowcaseToggle("Custom spacing", isOn: $useCustomSpacing)
        if useCustomSpacing {
            ShowcaseSlider("Spacing", value: $spacing, in: 0...40, step: 1)
        }
    }

    @ViewBuilder func stateView(_ state: BarEdgeState) -> some View {
        barDemo(edge: state.edgeOption, spacing: 8)
    }

    var effectiveSpacing: CGFloat? {
        useCustomSpacing ? CGFloat(spacing) : nil
    }

    @ViewBuilder func barDemo(edge: EdgeOption, spacing: CGFloat?) -> some View {
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, *) {
            barDemoAvailable(edge: edge, spacing: spacing)
        } else {
            barFallback(edge: edge)
        }
    }

    @available(iOS 26.0, macOS 26.0, tvOS 26.0, *)
    @ViewBuilder func barDemoAvailable(edge: EdgeOption, spacing: CGFloat?) -> some View {
        if edge.isVertical {
            scrollContent
                .safeAreaBar(
                    edge: edge.verticalEdge,
                    alignment: selectedHAlignment.swiftUIAlignment,
                    spacing: spacing,
                ) {
                    actionBar
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        } else {
            scrollContent
                .safeAreaBar(
                    edge: edge.horizontalEdge,
                    alignment: selectedVAlignment.swiftUIAlignment,
                    spacing: spacing,
                ) {
                    actionBar
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        }
    }

    func barFallback(edge: EdgeOption) -> some View {
        scrollContent
            .overlay(alignment: edge.fallbackAlignment) {
                actionBar.padding(DesignSystem.Spacing.small)
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    var scrollContent: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xSmall) {
                ForEach(0..<16, id: \.self) { idx in
                    rowView(index: idx)
                }
            }
            .padding(DesignSystem.Spacing.small)
        }
    }

    func rowView(index: Int) -> some View {
        HStack {
            Image(systemName: "doc.text.fill")
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(
                    width: DesignSystem.Size.Icon.small,
                    height: DesignSystem.Size.Icon.small,
                )
            Text("Row \(index + 1)")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.primary)
            Spacer()
        }
        .padding(DesignSystem.Spacing.small)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small),
        )
    }

    var actionBar: some View {
        Text("Action Bar")
            .font(DesignSystem.Font.footnote)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .padding(.vertical, DesignSystem.Spacing.xSmall)
            .background(DesignSystem.Color.accent, in: Capsule())
    }
}

// MARK: - Code generation
private extension SafeAreaBarShowcase {
    var generatedCode: String {
        let edgeName = selectedEdge.label
        let alignmentName = selectedEdge.isVertical
            ? selectedHAlignment.label
            : selectedVAlignment.label
        let spacingArg = useCustomSpacing ? ", spacing: \(Int(spacing))" : ""
        return """
        ScrollView {
            LazyVStack { /* rows */ }
        }
        .safeAreaBar(edge: .\(edgeName), alignment: .\(alignmentName)\(spacingArg)) {
            Button("Action") { }
        }
        """
    }
}

// MARK: - Nested types
extension SafeAreaBarShowcase {
    fileprivate enum EdgeOption: ShowcasePickable {
        case top, bottom, leading, trailing

        var label: String {
            switch self {
            case .top: "top"
            case .bottom: "bottom"
            case .leading: "leading"
            case .trailing: "trailing"
            }
        }

        var isVertical: Bool {
            self == .top || self == .bottom
        }

        var verticalEdge: VerticalEdge {
            self == .top ? .top : .bottom
        }

        var horizontalEdge: HorizontalEdge {
            self == .leading ? .leading : .trailing
        }

        var fallbackAlignment: Alignment {
            switch self {
            case .top: .top
            case .bottom: .bottom
            case .leading: .leading
            case .trailing: .trailing
            }
        }
    }

    fileprivate enum HAlignmentOption: ShowcasePickable {
        case center, leading, trailing

        var label: String {
            switch self {
            case .center: "center"
            case .leading: "leading"
            case .trailing: "trailing"
            }
        }

        var swiftUIAlignment: HorizontalAlignment {
            switch self {
            case .center: .center
            case .leading: .leading
            case .trailing: .trailing
            }
        }
    }

    fileprivate enum VAlignmentOption: ShowcasePickable {
        case top, center, bottom

        var label: String {
            switch self {
            case .top: "top"
            case .center: "center"
            case .bottom: "bottom"
            }
        }

        var swiftUIAlignment: VerticalAlignment {
            switch self {
            case .top: .top
            case .center: .center
            case .bottom: .bottom
            }
        }
    }

    fileprivate enum BarEdgeState: ShowcaseState {
        case bottom, top, leading, trailing

        var caption: String {
            switch self {
            case .bottom: "Bottom edge"
            case .top: "Top edge"
            case .leading: "Leading edge"
            case .trailing: "Trailing edge"
            }
        }

        var edgeOption: EdgeOption {
            switch self {
            case .bottom: .bottom
            case .top: .top
            case .leading: .leading
            case .trailing: .trailing
            }
        }
    }
}
