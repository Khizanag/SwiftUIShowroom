import SwiftUI
import Combine

struct OnReceiveShowcase: View {
    @State private var publisherKind: PublisherKind = .timer
    @State private var timerInterval: Double = 1.0
    @State private var tickCount = 0
    @State private var lastTimestamp = ""
    @State private var isRunning = true

    private var timerPublisher: AnyPublisher<Date, Never> {
        Timer.publish(every: timerInterval, on: .main, in: .common)
            .autoconnect()
            .eraseToAnyPublisher()
    }

    var body: some View {
        ShowcaseScreen(
            title: "onReceive",
            summary: "Runs an action when a Combine Publisher emits, bridging external streams into a view.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
        .onReceive(timerPublisher) { date in
            guard isRunning && publisherKind == .timer else { return }
            tickCount += 1
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            lastTimestamp = formatter.string(from: date)
        }
    }
}

// MARK: - Sub-views
private extension OnReceiveShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            publisherBadge
            counterCard
            timestampLabel
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var publisherBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: publisherKind.systemImage)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(publisherKind.badgeLabel)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }

    var counterCard: some View {
        VStack(spacing: DesignSystem.Spacing.xSmall) {
            Text("\(tickCount)")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.accent)
                .monospacedDigit()
            Text(publisherKind == .timer ? "ticks received" : "events received")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    var timestampLabel: some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: "clock")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.secondary)
            Text(lastTimestamp.isEmpty ? "Waiting for first emission…" : "Last: \(lastTimestamp)")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Publisher", selection: $publisherKind)
            .onChange(of: publisherKind) { _, _ in
                tickCount = 0
                lastTimestamp = ""
            }
        if publisherKind == .timer {
            ShowcaseSlider("Interval (seconds)", value: $timerInterval, in: 0.5...5.0, step: 0.5)
                .onChange(of: timerInterval) { _, _ in
                    tickCount = 0
                    lastTimestamp = ""
                }
        }
        ShowcaseToggle("Running", isOn: $isRunning)
    }

    @ViewBuilder
    func stateView(_ state: ReceiveState) -> some View {
        switch state {
        case .running:
            runningStateView
        case .paused:
            pausedStateView
        case .noEmissions:
            noEmissionsStateView
        }
    }

    var runningStateView: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "waveform")
                .foregroundStyle(DesignSystem.Color.accent)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.hairline) {
                Text("Publisher active")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.primary)
                Text("View receives and handles each emitted value")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
        .padding(DesignSystem.Spacing.small)
    }

    var pausedStateView: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "pause.circle")
                .foregroundStyle(DesignSystem.Color.secondary)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.hairline) {
                Text("Publisher paused")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.primary)
                Text("Guard in perform closure skips processing")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
        .padding(DesignSystem.Spacing.small)
    }

    var noEmissionsStateView: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "antenna.radiowaves.left.and.right.slash")
                .foregroundStyle(DesignSystem.Color.secondary)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.hairline) {
                Text("No emissions yet")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.primary)
                Text("Waiting for the publisher to emit its first value")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
        .padding(DesignSystem.Spacing.small)
    }
}

// MARK: - Code generation
private extension OnReceiveShowcase {
    var generatedCode: String {
        let publisherExpr = publisherKind.publisherExpression(interval: timerInterval)
        let performBody = publisherKind.performBody
        var lines = [String]()

        switch publisherKind {
        case .timer:
            lines.append("struct OnReceiveDemo: View {")
            lines.append("    @State private var tickCount = 0")
            lines.append("    @State private var lastDate: Date?")
            lines.append("")
            lines.append("    private let ticker = \(publisherExpr)")
            lines.append("")
            lines.append("    var body: some View {")
            lines.append("        Text(\"Ticks: \\(tickCount)\")")
            lines.append("            .onReceive(ticker) { date in")
            lines.append("                \(performBody)")
            lines.append("            }")
            lines.append("    }")
            lines.append("}")
        case .notificationCenter:
            lines.append("struct OnReceiveDemo: View {")
            lines.append("    @State private var received = false")
            lines.append("")
            lines.append("    var body: some View {")
            lines.append("        Text(received ? \"Active\" : \"Background\")")
            lines.append("            .onReceive(\(publisherExpr)) { _ in")
            lines.append("                \(performBody)")
            lines.append("            }")
            lines.append("    }")
            lines.append("}")
        case .customSubject:
            lines.append("class EventBus {")
            lines.append("    static let shared = EventBus()")
            lines.append("    let subject = PassthroughSubject<String, Never>()")
            lines.append("}")
            lines.append("")
            lines.append("struct OnReceiveDemo: View {")
            lines.append("    @State private var lastEvent = \"\"")
            lines.append("")
            lines.append("    var body: some View {")
            lines.append("        Text(lastEvent)")
            lines.append("            .onReceive(\(publisherExpr)) { value in")
            lines.append("                \(performBody)")
            lines.append("            }")
            lines.append("    }")
            lines.append("}")
        case .willEnterForeground:
            lines.append("struct OnReceiveDemo: View {")
            lines.append("    @State private var isActive = false")
            lines.append("")
            lines.append("    var body: some View {")
            lines.append("        Text(isActive ? \"Foreground\" : \"Background\")")
            lines.append("            .onReceive(\(publisherExpr)) { _ in")
            lines.append("                \(performBody)")
            lines.append("            }")
            lines.append("    }")
            lines.append("}")
        }

        return lines.joined(separator: "\n")
    }
}

// MARK: - Nested types
extension OnReceiveShowcase {
    fileprivate enum PublisherKind: ShowcasePickable {
        case timer
        case notificationCenter
        case customSubject
        case willEnterForeground

        var label: String {
            switch self {
            case .timer: "Timer.publish"
            case .notificationCenter: "NotificationCenter"
            case .customSubject: "PassthroughSubject"
            case .willEnterForeground: "willEnterForeground"
            }
        }

        var systemImage: String {
            switch self {
            case .timer: "timer"
            case .notificationCenter: "bell"
            case .customSubject: "arrow.triangle.branch"
            case .willEnterForeground: "arrow.up.forward.app"
            }
        }

        var badgeLabel: String {
            switch self {
            case .timer: "Receives Date every tick"
            case .notificationCenter: "Receives system notifications"
            case .customSubject: "Receives custom subject values"
            case .willEnterForeground: "Receives foreground transitions"
            }
        }

        func publisherExpression(interval: Double) -> String {
            let intervalStr = interval.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(interval))
                : String(format: "%.1f", interval)
            switch self {
            case .timer:
                return "Timer.publish(every: \(intervalStr), on: .main, in: .common).autoconnect()"
            case .notificationCenter:
                #if os(macOS)
                return "NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)"
                #else
                return "NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)"
                #endif
            case .customSubject:
                return "EventBus.shared.subject"
            case .willEnterForeground:
                #if os(macOS)
                return "NotificationCenter.default.publisher(for: NSApplication.didUnhideNotification)"
                #else
                return "NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)"
                #endif
            }
        }

        var performBody: String {
            switch self {
            case .timer:
                return "tickCount += 1\n                lastDate = date"
            case .notificationCenter:
                return "received = true"
            case .customSubject:
                return "lastEvent = value"
            case .willEnterForeground:
                return "isActive = true"
            }
        }
    }

    fileprivate enum ReceiveState: ShowcaseState {
        case running
        case paused
        case noEmissions

        var caption: String {
            switch self {
            case .running: "Running"
            case .paused: "Paused"
            case .noEmissions: "No emissions"
            }
        }
    }
}
