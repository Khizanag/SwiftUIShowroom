import SwiftUI

struct ObservableMacroShowcase: View {
    @State private var ownership: OwnershipPattern = .stateOwned
    @State private var isMainActor = true
    @State private var ignoredProps = "cache"
    @State private var trackedProperty = "count"
    @State private var demoCount = 0

    var body: some View {
        ShowcaseScreen(
            title: "@Observable",
            summary: "Makes a reference type observable so SwiftUI tracks per-property reads and re-renders minimally.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ObservableMacroShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            counterCard
            ownershipBadge
        }
    }

    var counterCard: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Text(trackedProperty.isEmpty ? "count" : trackedProperty)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            Text("\(demoCount)")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.primary)
                .monospacedDigit()
            HStack(spacing: DesignSystem.Spacing.small) {
                Button {
                    demoCount -= 1
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(DesignSystem.Font.title2)
                }
                .buttonStyle(.plain)
                .foregroundStyle(DesignSystem.Color.accent)
                Button {
                    demoCount += 1
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(DesignSystem.Font.title2)
                }
                .buttonStyle(.plain)
                .foregroundStyle(DesignSystem.Color.accent)
            }
        }
        .padding(DesignSystem.Spacing.large)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }

    var ownershipBadge: some View {
        Text(ownership.declarationSnippet)
            .font(DesignSystem.Font.codeInline)
            .foregroundStyle(DesignSystem.Color.secondary)
            .padding(.horizontal, DesignSystem.Spacing.small)
            .padding(.vertical, DesignSystem.Spacing.xSmall)
            .background(
                DesignSystem.Color.cardBackground,
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
            )
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Ownership pattern", selection: $ownership)
        ShowcaseToggle("@MainActor", isOn: $isMainActor)
        ShowcaseTextControl("Tracked property name", text: $trackedProperty, prompt: "count")
        ShowcaseTextControl("@ObservationIgnored properties", text: $ignoredProps, prompt: "cache")
    }

    @ViewBuilder
    func stateView(_ state: ObservableModelState) -> some View {
        state.sampleView
    }
}

// MARK: - Code generation
private extension ObservableMacroShowcase {
    var generatedCode: String {
        let propName = trackedProperty.isEmpty ? "count" : trackedProperty
        let ignoredName = ignoredProps.isEmpty ? "cache" : ignoredProps
        var lines: [String] = []
        if isMainActor { lines.append("@MainActor") }
        lines.append("@Observable")
        lines.append("final class DemoModel {")
        lines.append("    var \(propName) = 0")
        lines.append("    @ObservationIgnored var \(ignoredName): [String: Any] = [:]")
        lines.append("}")
        lines.append("")
        lines.append("struct ObservableDemo: View {")
        lines.append("    \(ownership.viewDeclaration(propName: propName))")
        lines.append("")
        lines.append("    var body: some View {")
        lines.append("        Stepper(\"\\(model.\(propName))\", value: $model.\(propName))")
        lines.append("    }")
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}

// MARK: - Nested enums
extension ObservableMacroShowcase {
    fileprivate enum OwnershipPattern: ShowcasePickable {
        case stateOwned
        case environmentInjected
        case passedReference
        case globalSingleton

        var label: String {
            switch self {
            case .stateOwned: "stateOwned (@State)"
            case .environmentInjected: "environmentInjected (@Environment)"
            case .passedReference: "passedReference (let)"
            case .globalSingleton: "globalSingleton (.shared)"
            }
        }

        var declarationSnippet: String {
            switch self {
            case .stateOwned: "@State private var model = DemoModel()"
            case .environmentInjected: "@Environment(DemoModel.self) private var model"
            case .passedReference: "let model: DemoModel"
            case .globalSingleton: "DemoModel.shared"
            }
        }

        func viewDeclaration(propName: String) -> String {
            switch self {
            case .stateOwned: "@State private var model = DemoModel()"
            case .environmentInjected: "@Environment(DemoModel.self) private var model"
            case .passedReference: "let model: DemoModel"
            case .globalSingleton: "// model accessed via DemoModel.shared"
            }
        }
    }

    fileprivate enum ObservableModelState: ShowcaseState {
        case `default`
        case loading
        case empty
        case error

        var caption: String {
            switch self {
            case .default: "Default"
            case .loading: "Loading"
            case .empty: "Empty"
            case .error: "Error"
            }
        }

        @ViewBuilder
        var sampleView: some View {
            switch self {
            case .default:
                VStack(spacing: DesignSystem.Spacing.xSmall) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(DesignSystem.Font.title2)
                    Text("count: 42")
                        .font(DesignSystem.Font.codeInline)
                        .foregroundStyle(DesignSystem.Color.primary)
                }
                .padding(DesignSystem.Spacing.medium)
            case .loading:
                VStack(spacing: DesignSystem.Spacing.xSmall) {
                    ProgressView()
                    Text("Fetching…")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.secondary)
                }
                .padding(DesignSystem.Spacing.medium)
            case .empty:
                VStack(spacing: DesignSystem.Spacing.xSmall) {
                    Image(systemName: "tray")
                        .foregroundStyle(DesignSystem.Color.secondary)
                        .font(DesignSystem.Font.title2)
                    Text("count: 0")
                        .font(DesignSystem.Font.codeInline)
                        .foregroundStyle(DesignSystem.Color.secondary)
                }
                .padding(DesignSystem.Spacing.medium)
            case .error:
                VStack(spacing: DesignSystem.Spacing.xSmall) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .font(DesignSystem.Font.title2)
                    Text("Load failed")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.secondary)
                }
                .padding(DesignSystem.Spacing.medium)
            }
        }
    }
}
