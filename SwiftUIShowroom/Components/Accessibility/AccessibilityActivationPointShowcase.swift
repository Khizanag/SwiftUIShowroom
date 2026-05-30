import SwiftUI

struct AccessibilityActivationPointShowcase: View {
    @State private var point: ActivationPoint = .center
    @State private var isEnabled = true

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Activation Point",
            summary: "Specifies the exact screen point assistive tech uses when activating a combined element.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityActivationPointShowcase {
    var preview: some View {
        activationRow(point: point, isEnabled: isEnabled)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Activation Point", selection: $point)
        ShowcaseToggle("Enabled", isOn: $isEnabled)
    }

    @ViewBuilder func stateView(_ state: ActivationState) -> some View {
        activationRow(point: state.point, isEnabled: state.isEnabled)
    }
}

// MARK: - Row builder
private extension AccessibilityActivationPointShowcase {
    func activationRow(point: ActivationPoint, isEnabled: Bool) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            rowCard(point: point, isEnabled: isEnabled)
            statusLabel(point: point, isEnabled: isEnabled)
        }
        .padding(DesignSystem.Spacing.medium)
    }

    func rowCard(point: ActivationPoint, isEnabled: Bool) -> some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: "rectangle.and.hand.point.up.left")
                .font(DesignSystem.Font.title3)
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(width: DesignSystem.Size.Icon.medium, height: DesignSystem.Size.Icon.medium)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.hairline) {
                Text("Combined row element")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.primary)
                Text("VoiceOver activates at: \(point.label)")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
            Spacer()
            Button {
            } label: {
                Image(systemName: "chevron.right")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .overlay(activationMarker(for: point, isEnabled: isEnabled))
        .accessibilityElement(children: .combine)
        .modifier(ConditionalActivationPoint(unitPoint: point.unitPoint, isActive: isEnabled))
    }

    func statusLabel(point: ActivationPoint, isEnabled: Bool) -> some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: isEnabled ? "scope" : "scope")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(isEnabled ? DesignSystem.Color.accent : DesignSystem.Color.secondary)
            Text(isEnabled ? "Activation point: .\(point.rawValue)" : "isEnabled: false — default center used")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }

    @ViewBuilder
    func activationMarker(for point: ActivationPoint, isEnabled: Bool) -> some View {
        if isEnabled {
            GeometryReader { proxy in
                let size = proxy.size
                let markerSize: CGFloat = 10
                let relX = point.unitPoint.x * size.width
                let relY = point.unitPoint.y * size.height
                Circle()
                    .fill(DesignSystem.Color.accent)
                    .frame(width: markerSize, height: markerSize)
                    .position(x: relX, y: relY)
                    .accessibilityHidden(true)
            }
        }
    }
}

// MARK: - Code generation
private extension AccessibilityActivationPointShowcase {
    var generatedCode: String {
        if isEnabled {
            return """
            RowView()
                .accessibilityElement(children: .combine)
                .accessibilityActivationPoint(.\(point.rawValue))
            """
        } else {
            return """
            RowView()
                .accessibilityElement(children: .combine)
            // accessibilityActivationPoint omitted — defaults to center
            """
        }
    }
}

// MARK: - ConditionalActivationPoint
private struct ConditionalActivationPoint: ViewModifier {
    let unitPoint: UnitPoint
    let isActive: Bool
    @ViewBuilder
    func body(content: Content) -> some View {
        if isActive {
            content.accessibilityActivationPoint(unitPoint)
        } else {
            content
        }
    }
}

// MARK: - Nested types
extension AccessibilityActivationPointShowcase {
    fileprivate enum ActivationPoint: String, ShowcasePickable {
        case center
        case topLeading
        case top
        case trailing
        case bottom
        case leading

        var label: String {
            switch self {
            case .center: return ".center"
            case .topLeading: return ".topLeading"
            case .top: return ".top"
            case .trailing: return ".trailing"
            case .bottom: return ".bottom"
            case .leading: return ".leading"
            }
        }

        var unitPoint: UnitPoint {
            switch self {
            case .center: return .center
            case .topLeading: return .topLeading
            case .top: return .top
            case .trailing: return .trailing
            case .bottom: return .bottom
            case .leading: return .leading
            }
        }
    }

    fileprivate enum ActivationState: ShowcaseState {
        case defaultCenter
        case topLeadingEnabled
        case trailingEnabled
        case disabledModifier

        var caption: String {
            switch self {
            case .defaultCenter: return "center (default)"
            case .topLeadingEnabled: return "topLeading"
            case .trailingEnabled: return "trailing"
            case .disabledModifier: return "isEnabled: false"
            }
        }

        var point: ActivationPoint {
            switch self {
            case .defaultCenter: return .center
            case .topLeadingEnabled: return .topLeading
            case .trailingEnabled: return .trailing
            case .disabledModifier: return .trailing
            }
        }

        var isEnabled: Bool {
            switch self {
            case .defaultCenter, .topLeadingEnabled, .trailingEnabled: return true
            case .disabledModifier: return false
            }
        }
    }
}
