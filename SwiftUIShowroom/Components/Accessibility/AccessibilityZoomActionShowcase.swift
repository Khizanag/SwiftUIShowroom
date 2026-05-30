import SwiftUI

struct AccessibilityZoomActionShowcase: View {
    @State private var zoomScale: Double = 1.0

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Zoom Action",
            summary: "Handles VoiceOver's zoom gesture so users can magnify custom zoomable content.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }

    fileprivate enum ZoomState: ShowcaseState {
        case defaultZoom
        case zoomedIn
        case zoomedOut

        var caption: String {
            switch self {
            case .defaultZoom: return "Default (100%)"
            case .zoomedIn: return "Zoomed in (250%)"
            case .zoomedOut: return "Zoomed out (50%)"
            }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityZoomActionShowcase {
    var preview: some View {
        zoomCanvas(scale: zoomScale)
    }

    @ViewBuilder var controls: some View {
        ShowcaseSlider("Zoom level", value: $zoomScale, in: 0.5...4.0, step: 0.25)
    }

    @ViewBuilder func stateView(_ state: ZoomState) -> some View {
        switch state {
        case .defaultZoom:
            zoomCanvas(scale: 1.0)
        case .zoomedIn:
            zoomCanvas(scale: 2.5)
        case .zoomedOut:
            zoomCanvas(scale: 0.5)
        }
    }
}

// MARK: - Helpers
private extension AccessibilityZoomActionShowcase {
    func zoomCanvas(scale: Double) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .fill(DesignSystem.Color.cardBackground)
            VStack(spacing: DesignSystem.Spacing.small) {
                mapGridView(scale: scale)
                zoomBadge(scale: scale)
            }
            .padding(DesignSystem.Spacing.medium)
        }
        .frame(height: 200)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Zoomable map canvas")
        .accessibilityValue(zoomValueLabel(scale: scale))
        .accessibilityZoomAction { action in
            let factor = action.direction == .zoomIn ? 1.25 : 0.8
            zoomScale = min(max(zoomScale * factor, 0.5), 4.0)
        }
    }

    func zoomValueLabel(scale: Double) -> String {
        let percent = Int(scale * 100)
        return "\(percent) percent zoom"
    }

    func mapGridView(scale: Double) -> some View {
        ZStack {
            gridBackground()
            mapPin(scale: scale)
        }
        .frame(height: 120)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    func gridBackground() -> some View {
        Canvas { context, size in
            let step: CGFloat = 20
            var col: CGFloat = 0
            while col <= size.width {
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: col, y: 0))
                        path.addLine(to: CGPoint(x: col, y: size.height))
                    },
                    with: .color(DesignSystem.Color.separator.opacity(0.4)),
                    lineWidth: 0.5,
                )
                col += step
            }
            var row: CGFloat = 0
            while row <= size.height {
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: row))
                        path.addLine(to: CGPoint(x: size.width, y: row))
                    },
                    with: .color(DesignSystem.Color.separator.opacity(0.4)),
                    lineWidth: 0.5,
                )
                row += step
            }
        }
        .background(DesignSystem.Color.background)
    }

    func mapPin(scale: Double) -> some View {
        Image(systemName: "mappin.circle.fill")
            .font(DesignSystem.Font.title)
            .foregroundStyle(DesignSystem.Color.accent)
            .scaleEffect(min(scale, 2.0))
            .animation(.spring(response: 0.3), value: scale)
    }

    func zoomBadge(scale: Double) -> some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: scale >= 1.0 ? "plus.magnifyingglass" : "minus.magnifyingglass")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(zoomValueLabel(scale: scale))
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            Spacer()
            zoomHint()
        }
    }

    func zoomHint() -> some View {
        Text("Pinch or VoiceOver zoom")
            .font(DesignSystem.Font.caption2)
            .foregroundStyle(DesignSystem.Color.secondary)
    }
}

// MARK: - Code generation
private extension AccessibilityZoomActionShowcase {
    var generatedCode: String {
        let scaleStr = String(format: "%.2f", zoomScale)
        return """
        MapCanvas(scale: $scale)
            .accessibilityLabel("Zoomable map canvas")
            .accessibilityValue("\\(Int(scale * 100)) percent zoom")
            .accessibilityZoomAction { action in
                let factor = action.direction == .zoomIn ? 1.25 : 0.8
                scale = min(max(scale * factor, 0.5), 4.0)
            }
        // initialScale: \(scaleStr)
        """
    }
}
