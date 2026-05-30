import SwiftUI

struct DismissActionShowcase: View {
    fileprivate enum DismissActionState: ShowcaseState {
        case presented, dismissed
        var caption: String {
            switch self {
            case .presented: "Presented"
            case .dismissed: "Dismissed"
            }
        }
    }

    @State private var isSheetPresented = false
    @State private var lastDismissedFrom = ""

    var body: some View {
        ShowcaseScreen(
            title: "Dismiss Action",
            summary: "Environment action a presented view calls to dismiss itself programmatically.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension DismissActionShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: "arrow.down.circle.fill")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.accent)
            Text("Tap the button to present a sheet.\nThe sheet dismisses itself via dismiss().")
                .font(DesignSystem.Font.callout)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
            if !lastDismissedFrom.isEmpty {
                Text("Last dismissed from: \(lastDismissedFrom)")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
            Button("Present Sheet") {
                isSheetPresented = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(DesignSystem.Spacing.medium)
        .sheet(isPresented: $isSheetPresented) {
            DismissActionDemoSheet(lastDismissedFrom: $lastDismissedFrom)
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseToggle("Show sheet", isOn: $isSheetPresented)
    }

    @ViewBuilder
    func stateView(_ state: DismissActionState) -> some View {
        switch state {
        case .presented:
            VStack(spacing: DesignSystem.Spacing.small) {
                Image(systemName: "rectangle.center.inset.filled")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.accent)
                Text("Sheet visible")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
            .padding(DesignSystem.Spacing.medium)
        case .dismissed:
            VStack(spacing: DesignSystem.Spacing.small) {
                Image(systemName: "rectangle.slash")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.secondary)
                Text("Dismissed")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
            .padding(DesignSystem.Spacing.medium)
        }
    }
}

// MARK: - Code generation
private extension DismissActionShowcase {
    var generatedCode: String {
        """
        @Environment(\\.dismiss) private var dismiss

        var body: some View {
            Button("Done") { dismiss() }
        }
        """
    }
}

// MARK: - DismissActionDemoSheet
private struct DismissActionDemoSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var lastDismissedFrom: String
    var body: some View {
        NavigationStack {
            VStack(spacing: DesignSystem.Spacing.large) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(DesignSystem.Font.largeTitle)
                    .foregroundStyle(DesignSystem.Color.accent)
                Text("This sheet dismisses itself by calling dismiss() from @Environment(\\.dismiss).")
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.secondary)
                    .multilineTextAlignment(.center)
                Button("Dismiss") {
                    lastDismissedFrom = "Done button"
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(DesignSystem.Spacing.xLarge)
            .navigationTitle("Dismiss Demo")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        lastDismissedFrom = "Toolbar Done"
                        dismiss()
                    }
                }
            }
        }
    }
}
