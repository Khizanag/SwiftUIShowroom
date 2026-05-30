import SwiftUI

struct SpatialTapGestureShowcase: View {
    enum CoordinateSpaceOption: ShowcasePickable {
        case local
        case global
        case named

        var label: String {
            switch self {
            case .local: ".local"
            case .global: ".global"
            case .named: ".named(\"container\")"
            }
        }

        var codeValue: String {
            switch self {
            case .local: ".local"
            case .global: ".global"
            case .named: ".named(\"container\")"
            }
        }
    }

    enum TapGestureState: ShowcaseState {
        case `default`
        case disabled
        case selected

        var caption: String {
            switch self {
            case .default: "Default"
            case .disabled: "Disabled"
            case .selected: "Tapped"
            }
        }
    }

    @State private var tapCount: Int = 1
    @State private var coordinateSpace: CoordinateSpaceOption = .local
    @State private var isEnabled: Bool = true
    @State private var tapLocation: CGPoint?

    var body: some View {
        ShowcaseScreen(
            title: "Spatial Tap Gesture",
            summary: "Recognizes taps and reports the tap location in a chosen coordinate space.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension SpatialTapGestureShowcase {
    var preview: some View {
        tapTarget(
            location: tapLocation,
            isEnabled: isEnabled,
            count: tapCount,
            space: coordinateSpace,
            onTap: { location in tapLocation = location }
        )
        .frame(width: 240, height: 160)
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseStepper("Count", value: $tapCount, in: 1...3)
        ShowcasePicker("Coordinate Space", selection: $coordinateSpace)
        ShowcaseToggle("Enabled", isOn: $isEnabled)
    }

    @ViewBuilder
    func stateView(_ state: TapGestureState) -> some View {
        switch state {
        case .default:
            tapTarget(
                location: nil,
                isEnabled: true,
                count: 1,
                space: .local,
                onTap: { _ in }
            )
            .frame(width: 180, height: 120)
        case .disabled:
            tapTarget(
                location: nil,
                isEnabled: false,
                count: 1,
                space: .local,
                onTap: { _ in }
            )
            .frame(width: 180, height: 120)
        case .selected:
            tapTarget(
                location: CGPoint(x: 90, y: 60),
                isEnabled: true,
                count: 1,
                space: .local,
                onTap: { _ in }
            )
            .frame(width: 180, height: 120)
        }
    }
}

// MARK: - Tap target
private extension SpatialTapGestureShowcase {
    @ViewBuilder
    func tapTarget(
        location: CGPoint?,
        isEnabled: Bool,
        count: Int,
        space: CoordinateSpaceOption,
        onTap: @escaping (CGPoint) -> Void
    ) -> some View {
        #if os(tvOS)
        unavailableView
        #else
        TapTargetView(
            location: location,
            isEnabled: isEnabled,
            count: count,
            space: space,
            onTap: onTap
        )
        #endif
    }

    var unavailableView: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(DesignSystem.Color.cardBackground)
            .overlay(
                Text("Not available on tvOS")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            )
    }
}

// MARK: - Code generation
private extension SpatialTapGestureShowcase {
    var generatedCode: String {
        """
        struct SpatialTapDemo: View {
            @State private var location: CGPoint = .zero

            var body: some View {
                Rectangle()
                    .fill(.blue.opacity(0.2))
                    .frame(width: 240, height: 160)
                    .coordinateSpace(name: "container")
                    .overlay(alignment: .topLeading) {
                        if location != .zero {
                            Circle().fill(.red).frame(width: 16, height: 16)
                                .position(location)
                        }
                    }
                    .gesture(
                        SpatialTapGesture(count: \(tapCount), coordinateSpace: \(coordinateSpace.codeValue))
                            .onEnded { value in location = value.location },
                        isEnabled: \(isEnabled)
                    )
            }
        }
        """
    }
}

// MARK: - TapTargetView
#if !os(tvOS)
private struct TapTargetView: View {
    let location: CGPoint?
    let isEnabled: Bool
    let count: Int
    let space: SpatialTapGestureShowcase.CoordinateSpaceOption
    let onTap: (CGPoint) -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(isEnabled ? Color.accentColor.opacity(0.15) : DesignSystem.Color.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .strokeBorder(
                            isEnabled ? Color.accentColor.opacity(0.4) : DesignSystem.Color.separator,
                            lineWidth: 1.5
                        )
                )
            hint
            if let point = location {
                pinView(at: point)
            }
        }
        .coordinateSpace(name: "container")
        .gestureAttachment(
            count: count,
            space: space,
            isEnabled: isEnabled,
            onTap: onTap
        )
    }
}

// MARK: - TapTargetView sub-views
private extension TapTargetView {
    var hint: some View {
        VStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: isEnabled ? "hand.tap" : "hand.tap.fill")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(isEnabled ? Color.accentColor : DesignSystem.Color.secondary)
            Text(isEnabled ? tapHintText : "Disabled")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var tapHintText: String {
        count == 1 ? "Tap anywhere" : "Tap \(count)x anywhere"
    }

    func pinView(at point: CGPoint) -> some View {
        Circle()
            .fill(Color.red)
            .frame(
                width: DesignSystem.Size.Icon.small,
                height: DesignSystem.Size.Icon.small
            )
            .shadow(radius: 2)
            .position(point)
    }
}

// MARK: - Gesture attachment helper
private extension View {
    @ViewBuilder
    func gestureAttachment(
        count: Int,
        space: SpatialTapGestureShowcase.CoordinateSpaceOption,
        isEnabled: Bool,
        onTap: @escaping (CGPoint) -> Void
    ) -> some View {
        switch space {
        case .local:
            self.gesture(
                SpatialTapGesture(count: count, coordinateSpace: .local)
                    .onEnded { value in onTap(value.location) },
                isEnabled: isEnabled
            )
        case .global:
            self.gesture(
                SpatialTapGesture(count: count, coordinateSpace: .global)
                    .onEnded { value in onTap(value.location) },
                isEnabled: isEnabled
            )
        case .named:
            self.gesture(
                SpatialTapGesture(count: count, coordinateSpace: .named("container"))
                    .onEnded { value in onTap(value.location) },
                isEnabled: isEnabled
            )
        }
    }
}
#endif
