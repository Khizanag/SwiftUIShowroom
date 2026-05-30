import SwiftUI

struct EnvironmentObjectShowcase: View {
    fileprivate enum EnvObjectState: ShowcaseState {
        case injected
        case missing

        var caption: String {
            switch self {
            case .injected: "Injected"
            case .missing: "Missing injection"
            }
        }
    }

    @State private var objectType: String = "Session"
    @State private var injected: Bool = true
    @State private var demoUsername: String = "giga"
    @State private var demoCounter: Int = 0

    var body: some View {
        ShowcaseScreen(
            title: "@EnvironmentObject (legacy)",
            summary: "Reads an ObservableObject injected by type — legacy counterpart to @Environment(Type.self).",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension EnvironmentObjectShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            injectionStatusBadge
            if injected {
                injectedDemoCard
            } else {
                missingObjectWarning
            }
        }
    }

    var injectionStatusBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: injected ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(injected ? Color.green : Color.red)
            Text(injected ? ".environmentObject(session) injected" : "No ancestor injection — crash risk")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(.horizontal, DesignSystem.Spacing.small)
        .padding(.vertical, DesignSystem.Spacing.xSmall)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
        )
    }

    var injectedDemoCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Text("@EnvironmentObject private var \(safeTypeName): \(safeTypeName)")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Divider()
            HStack {
                Text("username:")
                    .font(DesignSystem.Font.footnote)
                    .foregroundStyle(DesignSystem.Color.secondary)
                Spacer()
                Text(demoUsername)
                    .font(DesignSystem.Font.footnote)
                    .foregroundStyle(DesignSystem.Color.primary)
            }
            HStack {
                Text("counter:")
                    .font(DesignSystem.Font.footnote)
                    .foregroundStyle(DesignSystem.Color.secondary)
                Spacer()
                Text("\(demoCounter)")
                    .font(DesignSystem.Font.footnote)
                    .foregroundStyle(DesignSystem.Color.primary)
                    .monospacedDigit()
            }
            Button {
                demoCounter += 1
            } label: {
                Label("Increment counter", systemImage: "plus.circle")
                    .font(DesignSystem.Font.callout)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(DesignSystem.Spacing.medium)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
        .frame(maxWidth: 320)
    }

    var missingObjectWarning: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(Color.orange)
            Text("Fatal error at runtime")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.primary)
            Text("No \(safeTypeName) injected via\n.environmentObject(_:) in the hierarchy.")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.large)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
        .frame(maxWidth: 320)
    }

    @ViewBuilder var controls: some View {
        ShowcaseTextControl("Object type name", text: $objectType, prompt: "Session")
        ShowcaseToggle("Injected via .environmentObject(_:)", isOn: $injected)
        ShowcaseTextControl("Demo username", text: $demoUsername, prompt: "giga")
    }

    @ViewBuilder func stateView(_ state: EnvObjectState) -> some View {
        switch state {
        case .injected:
            injectedStateCard
        case .missing:
            errorStateCard
        }
    }

    var injectedStateCard: some View {
        VStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.green)
                .font(DesignSystem.Font.title2)
            Text("Injected")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.primary)
            Text("session.username = \"giga\"")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var errorStateCard: some View {
        VStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color.orange)
                .font(DesignSystem.Font.title2)
            Text("Missing injection")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.primary)
            Text("Crashes at runtime —\nno ancestor called .environmentObject(_:)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var safeTypeName: String {
        objectType.isEmpty ? "Session" : objectType
    }
}

// MARK: - Code generation
private extension EnvironmentObjectShowcase {
    var generatedCode: String {
        let typeName = safeTypeName
        let injectionLine = injected
            ? "ContentView()\n    .environmentObject(\(typeName.lowercased()))"
            : "// Missing — will crash at runtime:\n// ContentView() // no .environmentObject call"
        return """
        // 1. Define an ObservableObject
        final class \(typeName): ObservableObject {
            @Published var username: String = ""
            @Published var counter: Int = 0
        }

        // 2. Read it anywhere in the subtree
        struct EnvObjectDemo: View {
            @EnvironmentObject private var \(typeName.lowercased()): \(typeName)

            var body: some View {
                Text(\(typeName.lowercased()).username)
            }
        }

        // 3. Inject at the root
        \(injectionLine)
        """
    }
}
