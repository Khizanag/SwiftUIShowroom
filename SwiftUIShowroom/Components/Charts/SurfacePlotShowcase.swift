import Charts
import SwiftUI

struct SurfacePlotShowcase: View {
    @State private var surfaceStyle: SurfaceStyleOption = .heightBased
    @State private var solidColor: Color = .accentColor
    @State private var xDomainLength: Double = 2
    @State private var zDomainLength: Double = 2

    var body: some View {
        ShowcaseScreen(
            title: "SurfacePlot",
            summary: "3D chart content rendering a mathematical surface y = f(x, z) inside Chart3D.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension SurfacePlotShowcase {
    var preview: some View {
        Group {
#if os(tvOS)
            platformUnavailablePlaceholder
#else
            if #available(iOS 26.0, macOS 26.0, *) {
                liveChart
                    .frame(height: 280)
            } else {
                platformUnavailablePlaceholder
                    .frame(height: 280)
            }
#endif
        }
        .padding(DesignSystem.Spacing.small)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Surface style", selection: $surfaceStyle)
        if surfaceStyle == .solid {
            ShowcaseColorControl("Solid color", selection: $solidColor, supportsOpacity: false)
        }
        ShowcaseSlider("X domain ±", value: $xDomainLength, in: 1...10, step: 0.5)
        ShowcaseSlider("Z domain ±", value: $zDomainLength, in: 1...10, step: 0.5)
    }

    @ViewBuilder
    func stateView(_ state: SurfaceState) -> some View {
#if os(tvOS)
        platformUnavailablePlaceholder
            .frame(height: 140)
#else
        if #available(iOS 26.0, macOS 26.0, *) {
            state.chart
                .frame(height: 140)
        } else {
            platformUnavailablePlaceholder
                .frame(height: 140)
        }
#endif
    }

    var platformUnavailablePlaceholder: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(DesignSystem.Color.cardBackground)
            .overlay {
                Text("Requires iOS 26 / macOS 26")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
    }
}

// MARK: - Live chart
#if !os(tvOS)
@available(iOS 26.0, macOS 26.0, *)
private extension SurfacePlotShowcase {
    @ViewBuilder
    var liveChart: some View {
        switch surfaceStyle {
        case .heightBased:
            Chart3D {
                SurfacePlot(x: "x", y: "y", z: "z") { (xVal: Double, zVal: Double) in
                    sin(2 * xVal) * cos(2 * zVal)
                }
                .foregroundStyle(.heightBased)
            }
            .chartXScale(domain: -xDomainLength...xDomainLength)
            .chartYScale(domain: -1...1)
            .chartZScale(domain: -zDomainLength...zDomainLength)
        case .normalBased:
            Chart3D {
                SurfacePlot(x: "x", y: "y", z: "z") { (xVal: Double, zVal: Double) in
                    sin(2 * xVal) * cos(2 * zVal)
                }
                .foregroundStyle(.normalBased)
            }
            .chartXScale(domain: -xDomainLength...xDomainLength)
            .chartYScale(domain: -1...1)
            .chartZScale(domain: -zDomainLength...zDomainLength)
        case .solid:
            Chart3D {
                SurfacePlot(x: "x", y: "y", z: "z") { (xVal: Double, zVal: Double) in
                    sin(2 * xVal) * cos(2 * zVal)
                }
                .foregroundStyle(solidColor)
            }
            .chartXScale(domain: -xDomainLength...xDomainLength)
            .chartYScale(domain: -1...1)
            .chartZScale(domain: -zDomainLength...zDomainLength)
        }
    }
}
#endif

// MARK: - Code generation
private extension SurfacePlotShowcase {
    var generatedCode: String {
        let styleLine: String
        switch surfaceStyle {
        case .heightBased:
            styleLine = "    .foregroundStyle(.heightBased)"
        case .normalBased:
            styleLine = "    .foregroundStyle(.normalBased)"
        case .solid:
            styleLine = "    .foregroundStyle(solidColor)"
        }
        let xStr = formatDomainValue(xDomainLength)
        let zStr = formatDomainValue(zDomainLength)

        return """
        Chart3D {
            SurfacePlot(x: "x", y: "y", z: "z") { x, z in
                sin(2 * x) * cos(2 * z)
            }
        \(styleLine)
        }
        .chartXScale(domain: -\(xStr) ... \(xStr))
        .chartYScale(domain: -1 ... 1)
        .chartZScale(domain: -\(zStr) ... \(zStr))
        """
    }

    func formatDomainValue(_ half: Double) -> String {
        half.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(half))
            : String(format: "%.1f", half)
    }
}

// MARK: - Nested types
extension SurfacePlotShowcase {
    enum SurfaceStyleOption: ShowcasePickable {
        case heightBased
        case normalBased
        case solid

        var label: String {
            switch self {
            case .heightBased: "heightBased"
            case .normalBased: "normalBased"
            case .solid: "solid"
            }
        }
    }

    enum SurfaceState: ShowcaseState {
        case `default`
        case empty
        case ripple

        var caption: String {
            switch self {
            case .default: "Default (heightBased)"
            case .empty: "Empty / no data"
            case .ripple: "Ripple (normalBased)"
            }
        }
    }
}

// MARK: - State gallery charts
#if !os(tvOS)
@available(iOS 26.0, macOS 26.0, *)
@MainActor
private extension SurfacePlotShowcase.SurfaceState {
    @ViewBuilder var chart: some View {
        switch self {
        case .default:
            Chart3D {
                SurfacePlot(x: "x", y: "y", z: "z") { (xVal: Double, zVal: Double) in
                    sin(2 * xVal) * cos(2 * zVal)
                }
                .foregroundStyle(.heightBased)
            }
            .chartXScale(domain: -2.0...2.0)
            .chartYScale(domain: -1.0...1.0)
            .chartZScale(domain: -2.0...2.0)
        case .empty:
            Chart3D {
                SurfacePlot(x: "x", y: "y", z: "z") { (_: Double, _: Double) in
                    Double.nan
                }
                .foregroundStyle(.heightBased)
            }
            .chartXScale(domain: -1.0...1.0)
            .chartYScale(domain: -1.0...1.0)
            .chartZScale(domain: -1.0...1.0)
            .overlay {
                Text("No data")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        case .ripple:
            Chart3D {
                SurfacePlot(x: "x", y: "y", z: "z") { (xVal: Double, zVal: Double) in
                    let radius = sqrt(xVal * xVal + zVal * zVal)
                    return radius == 0 ? 1.0 : sin(radius * 4) / radius
                }
                .foregroundStyle(.normalBased)
            }
            .chartXScale(domain: -4.0...4.0)
            .chartYScale(domain: -0.5...1.0)
            .chartZScale(domain: -4.0...4.0)
        }
    }
}
#endif
