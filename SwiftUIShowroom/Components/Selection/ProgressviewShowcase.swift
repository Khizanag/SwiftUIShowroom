import SwiftUI

struct ProgressviewShowcase: View {
    // MARK: - Nested enums
    enum ProgressStyleOption: ShowcasePickable {
        case automatic, linear, circular

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .linear: "linear"
            case .circular: "circular"
            }
        }

        var code: String { ".\(label)" }
    }

    enum ProgressModeOption: ShowcasePickable {
        case indeterminate, determinate, timerInterval

        var label: String {
            switch self {
            case .indeterminate: "indeterminate"
            case .determinate: "determinate"
            case .timerInterval: "timerInterval"
            }
        }
    }

    enum ProgressVisualState: ShowcaseState {
        case indeterminate
        case quarterFull
        case halfFull
        case complete
        case longLabel

        var caption: String {
            switch self {
            case .indeterminate: "Indeterminate"
            case .quarterFull: "25%"
            case .halfFull: "50%"
            case .complete: "Complete"
            case .longLabel: "Long label"
            }
        }

        var mode: ProgressModeOption {
            self == .indeterminate ? .indeterminate : .determinate
        }

        var value: Double {
            switch self {
            case .indeterminate: 0
            case .quarterFull: 0.25
            case .halfFull: 0.5
            case .complete: 1.0
            case .longLabel: 0.7
            }
        }

        var labelText: String {
            switch self {
            case .indeterminate: "Loading…"
            case .quarterFull: "Downloading…"
            case .halfFull: "Processing…"
            case .complete: "Done"
            case .longLabel: "Syncing your library with iCloud Drive…"
            }
        }

        var currentValueText: String? {
            switch self {
            case .indeterminate: nil
            case .quarterFull: "25%"
            case .halfFull: "50%"
            case .complete: "100%"
            case .longLabel: "70%"
            }
        }
    }

    // MARK: - Progress content configuration
    struct ProgressViewConfig {
        var mode: ProgressModeOption
        var value: Double
        var total: Double
        var labelText: String?
        var currentValueText: String?
    }

    // MARK: - Configuration state
    @State private var style: ProgressStyleOption = .automatic
    @State private var mode: ProgressModeOption = .determinate
    @State private var value: Double = 0.5
    @State private var total: Int = 1
    @State private var labelText: String = "Downloading…"
    @State private var showLabel: Bool = true
    @State private var showCurrentValueLabel: Bool = true
    @State private var tint: Color = DesignSystem.Color.accent

    var body: some View {
        ShowcaseScreen(
            title: "ProgressView",
            summary: "Shows progress toward a task — determinate, indeterminate, or timer-based.",
        ) {
            PreviewStage {
                preview
            }
            ShowcaseSection("Configuration") {
                controls
            }
            ShowcaseSection("States") {
                StateGallery(content: stateView)
            }
            ShowcaseSection("Generated code") {
                CodeBlock(code: generatedCode)
            }
        }
    }
}

// MARK: - Sub-views
private extension ProgressviewShowcase {
    var preview: some View {
        progressView(
            style: style,
            config: ProgressViewConfig(
                mode: mode,
                value: value,
                total: Double(total),
                labelText: showLabel ? labelText : nil,
                currentValueText: showCurrentValueLabel ? currentValueText : nil,
            ),
        )
        .tint(tint)
        .frame(maxWidth: 320)
        .padding(DesignSystem.Spacing.small)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Style", selection: $style)
        ShowcasePicker("Mode", selection: $mode)
        if mode == .determinate {
            ShowcaseSlider("Value", value: $value, in: 0...1, step: 0.01)
            ShowcaseStepper("Total (×1.0)", value: $total, in: 1...10)
        }
        ShowcaseToggle("Show label", isOn: $showLabel)
        if showLabel {
            ShowcaseTextControl("Label text", text: $labelText)
        }
        if mode == .determinate {
            ShowcaseToggle("Show value label", isOn: $showCurrentValueLabel)
        }
        ShowcaseColorControl("Tint", selection: $tint, supportsOpacity: false)
    }

    @ViewBuilder
    func stateView(_ state: ProgressVisualState) -> some View {
        progressView(
            style: style,
            config: ProgressViewConfig(
                mode: state.mode,
                value: state.value,
                total: 1.0,
                labelText: state.labelText,
                currentValueText: state.currentValueText,
            ),
        )
        .tint(tint)
        .frame(maxWidth: 260)
        .padding(DesignSystem.Spacing.xSmall)
    }

    @ViewBuilder
    func progressView(style: ProgressStyleOption, config: ProgressViewConfig) -> some View {
        switch style {
        case .automatic:
            progressViewContent(config: config).progressViewStyle(.automatic)
        case .linear:
            progressViewContent(config: config).progressViewStyle(.linear)
        case .circular:
            progressViewContent(config: config).progressViewStyle(.circular)
        }
    }

    @ViewBuilder
    func progressViewContent(config: ProgressViewConfig) -> some View {
        switch config.mode {
        case .indeterminate:
            if let labelText = config.labelText {
                ProgressView { Text(labelText) }
            } else {
                ProgressView()
            }
        case .determinate:
            if let labelText = config.labelText, let currentValueText = config.currentValueText {
                ProgressView(value: config.value, total: config.total) {
                    Text(labelText)
                } currentValueLabel: {
                    Text(currentValueText)
                }
            } else if let labelText = config.labelText {
                ProgressView(value: config.value, total: config.total) {
                    Text(labelText)
                }
            } else {
                ProgressView(value: config.value, total: config.total)
            }
        case .timerInterval:
            timerIntervalView(labelText: config.labelText)
        }
    }

    @ViewBuilder
    func timerIntervalView(labelText: String?) -> some View {
        #if os(tvOS)
        // ProgressView(timerInterval:) is unavailable on tvOS
        if let labelText {
            ProgressView { Text(labelText) }
        } else {
            ProgressView()
        }
        #else
        let interval = Date.now ... Date.now.addingTimeInterval(30)
        if let labelText {
            ProgressView(timerInterval: interval) { Text(labelText) }
        } else {
            ProgressView(timerInterval: interval)
        }
        #endif
    }

    var currentValueText: String {
        "\(Int((value / Double(total)) * 100))%"
    }
}

// MARK: - Code generation
private extension ProgressviewShowcase {
    var generatedCode: String {
        var lines: [String] = []

        switch mode {
        case .indeterminate:
            if showLabel {
                lines.append("ProgressView {")
                lines.append("    Text(\"\(labelText)\")")
                lines.append("}")
            } else {
                lines.append("ProgressView()")
            }
        case .determinate:
            let totalValue = Double(total)
            let totalStr = total == 1 ? "1.0" : "\(totalValue)"
            let valueStr = String(format: "%.2f", value * totalValue)
            if showLabel && showCurrentValueLabel {
                lines.append("ProgressView(value: \(valueStr), total: \(totalStr)) {")
                lines.append("    Text(\"\(labelText)\")")
                lines.append("} currentValueLabel: {")
                lines.append("    Text(\"\(currentValueText)\")")
                lines.append("}")
            } else if showLabel {
                lines.append("ProgressView(value: \(valueStr), total: \(totalStr)) {")
                lines.append("    Text(\"\(labelText)\")")
                lines.append("}")
            } else {
                lines.append("ProgressView(value: \(valueStr), total: \(totalStr))")
            }
        case .timerInterval:
            if showLabel {
                lines.append("ProgressView(timerInterval: startDate ... endDate) {")
                lines.append("    Text(\"\(labelText)\")")
                lines.append("}")
            } else {
                lines.append("ProgressView(timerInterval: startDate ... endDate)")
            }
        }

        lines.append(".progressViewStyle(\(style.code))")

        return lines.joined(separator: "\n")
    }
}
