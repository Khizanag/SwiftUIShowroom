import Charts
import SwiftUI

struct Chart3dShowcase: View {
    @State private var projection: CameraProjectionOption = .perspective
    @State private var pose: PoseOption = .default
    @State private var zAxisLabel: String = "z"
    @State private var xDomainLength: Double = 2
    @State private var zDomainLength: Double = 2

    var body: some View {
        ShowcaseScreen(
            title: "Chart3D",
            summary: "Three-dimensional chart container for spatial visualizations such as surface plots.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension Chart3dShowcase {
    var preview: some View {
        Group {
            #if os(tvOS)
            unavailablePlaceholder
            #else
            if #available(iOS 26.0, macOS 26.0, *) {
                liveChart
            } else {
                unavailablePlaceholder
            }
            #endif
        }
        .frame(height: 280)
        .padding(DesignSystem.Spacing.small)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Camera projection", selection: $projection)
        ShowcasePicker("Pose", selection: $pose)
        ShowcaseTextControl("Z axis label", text: $zAxisLabel, prompt: "e.g. Altitude")
        ShowcaseSlider("X domain (±)", value: $xDomainLength, in: 1...10, step: 0.5)
        ShowcaseSlider("Z domain (±)", value: $zDomainLength, in: 1...10, step: 0.5)
    }

    @ViewBuilder
    func stateView(_ state: Chart3DState) -> some View {
        #if os(tvOS)
        unavailablePlaceholder
            .frame(height: 140)
        #else
        if #available(iOS 26.0, macOS 26.0, *) {
            stateChart(state)
                .frame(height: 140)
        } else {
            unavailablePlaceholder
                .frame(height: 140)
        }
        #endif
    }

    var unavailablePlaceholder: some View {
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
private extension Chart3dShowcase {
    var liveChart: some View {
        Chart3D {
            SurfacePlot(x: "x", y: "y", z: zAxisLabel) { (xVal: Double, zVal: Double) in
                sin(2 * xVal) * cos(2 * zVal)
            }
            .foregroundStyle(.heightBased)
        }
        .chart3DCameraProjection(projection.value)
        .chart3DPose(pose.value)
        .chartXScale(domain: -xDomainLength...xDomainLength)
        .chartYScale(domain: -1...1)
        .chartZScale(domain: -zDomainLength...zDomainLength)
    }

    @ViewBuilder
    func stateChart(_ state: Chart3DState) -> some View {
        switch state {
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
                .foregroundStyle(Color.accentColor)
            }
            .chartXScale(domain: -1.0...1.0)
            .chartYScale(domain: -1.0...1.0)
            .chartZScale(domain: -1.0...1.0)
            .overlay {
                Text("No data")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }

        case .focused:
            Chart3D {
                SurfacePlot(x: "x", y: "y", z: "z") { (xVal: Double, zVal: Double) in
                    cos(xVal) * sin(zVal)
                }
                .foregroundStyle(.normalBased)
            }
            .chart3DCameraProjection(.orthographic)
            .chartXScale(domain: -Double.pi...Double.pi)
            .chartYScale(domain: -1.0...1.0)
            .chartZScale(domain: -Double.pi...Double.pi)
        }
    }
}
#endif

// MARK: - Code generation
private extension Chart3dShowcase {
    var generatedCode: String {
        let projectionStr = projection.codeLabel
        let poseStr = pose.codeLabel
        let xDomStr = formatDomain(xDomainLength)
        let zDomStr = formatDomain(zDomainLength)

        return """
        Chart3D {
            SurfacePlot(x: "x", y: "y", z: "\(zAxisLabel)") { x, z in
                sin(2 * x) * cos(2 * z)
            }
            .foregroundStyle(.heightBased)
        }
        .chart3DCameraProjection(\(projectionStr))
        .chart3DPose(\(poseStr))
        .chartXScale(domain: \(xDomStr))
        .chartYScale(domain: -1 ... 1)
        .chartZScale(domain: \(zDomStr))
        """
    }

    func formatDomain(_ half: Double) -> String {
        let formatted = half.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(half))
            : String(format: "%.1f", half)
        return "-\(formatted) ... \(formatted)"
    }
}

// MARK: - Nested types
extension Chart3dShowcase {
    enum CameraProjectionOption: ShowcasePickable {
        case automatic
        case perspective
        case orthographic

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .perspective: "perspective"
            case .orthographic: "orthographic"
            }
        }

        var codeLabel: String {
            switch self {
            case .automatic: ".automatic"
            case .perspective: ".perspective"
            case .orthographic: ".orthographic"
            }
        }

        #if !os(tvOS)
        @available(iOS 26.0, macOS 26.0, *)
        var value: Chart3DCameraProjection {
            switch self {
            case .automatic: .automatic
            case .perspective: .perspective
            case .orthographic: .orthographic
            }
        }
        #endif
    }

    enum PoseOption: ShowcasePickable {
        case `default`
        case front
        case back
        case top

        var label: String {
            switch self {
            case .default: "default"
            case .front: "front"
            case .back: "back"
            case .top: "top"
            }
        }

        var codeLabel: String {
            switch self {
            case .default: ".default"
            case .front: ".front"
            case .back: ".back"
            case .top: ".top"
            }
        }

        #if !os(tvOS)
        @available(iOS 26.0, macOS 26.0, *)
        var value: Chart3DPose {
            switch self {
            case .default: .default
            case .front: .front
            case .back: .back
            case .top: .top
            }
        }
        #endif
    }

    enum Chart3DState: ShowcaseState {
        case `default`
        case empty
        case focused

        var caption: String {
            switch self {
            case .default: "Surface (heightBased)"
            case .empty: "Empty / no data"
            case .focused: "Normal shading"
            }
        }
    }
}
