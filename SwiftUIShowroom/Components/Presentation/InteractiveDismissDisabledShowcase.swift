import SwiftUI

struct InteractiveDismissDisabledShowcase: View {
    @State private var isDisabled = true
    @State private var isSheetPresented = false

    var body: some View {
        ShowcaseScreen(
            title: "Interactive Dismiss Disabled",
            summary: "Conditionally blocks swipe / interactive dismissal of the enclosing sheet or popover.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension InteractiveDismissDisabledShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: isDisabled ? "lock.fill" : "lock.open.fill")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(isDisabled ? DesignSystem.Color.accent : DesignSystem.Color.secondary)
            Text(isDisabled ? "Dismiss blocked" : "Dismiss allowed")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.primary)
            Button("Open Sheet") {
                isSheetPresented = true
            }
            .buttonStyle(.borderedProminent)
            .sheet(isPresented: $isSheetPresented) {
                sheetContent
            }
        }
    }

    var sheetContent: some View {
        SheetDemoView(isDisabled: isDisabled, isPresented: $isSheetPresented)
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseToggle("Dismiss disabled", isOn: $isDisabled)
    }

    @ViewBuilder
    func stateView(_ state: EnabledState) -> some View {
        let locked = state == .enabled
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: locked ? "lock.fill" : "lock.open.fill")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(locked ? DesignSystem.Color.accent : DesignSystem.Color.secondary)
            Text(locked ? "Blocked" : "Allowed")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(DesignSystem.Spacing.medium)
    }
}

// MARK: - Code generation
private extension InteractiveDismissDisabledShowcase {
    var generatedCode: String {
        """
        SheetContentView()
            .interactiveDismissDisabled(\(isDisabled))
        """
    }
}

// MARK: - SheetDemoView
private struct SheetDemoView: View {
    let isDisabled: Bool
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: DesignSystem.Spacing.large) {
                Image(systemName: isDisabled ? "lock.fill" : "lock.open.fill")
                    .font(DesignSystem.Font.largeTitle)
                    .foregroundStyle(isDisabled ? DesignSystem.Color.accent : DesignSystem.Color.secondary)
                Text(isDisabled ? "Swipe-to-dismiss is disabled" : "Swipe down to dismiss")
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(DesignSystem.Spacing.xLarge)
            .navigationTitle("Demo Sheet")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
            .interactiveDismissDisabled(isDisabled)
        }
    }
}
