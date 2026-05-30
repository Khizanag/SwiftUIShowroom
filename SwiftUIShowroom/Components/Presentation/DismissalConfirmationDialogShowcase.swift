import SwiftUI

struct DismissalConfirmationDialogShowcase: View {
    @State private var dialogTitle = "Discard changes?"
    @State private var shouldPresent = true
    @State private var isSheetOpen = false

    var body: some View {
        ShowcaseScreen(
            title: "Dismissal Confirmation",
            summary: "macOS: intercepts sheet dismissal to confirm unsaved work before discarding.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension DismissalConfirmationDialogShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: shouldPresent ? "exclamationmark.shield.fill" : "shield.slash.fill")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(shouldPresent ? DesignSystem.Color.accent : DesignSystem.Color.secondary)
            Text(shouldPresent ? "Confirmation active" : "Confirmation inactive")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.primary)
            #if os(macOS)
            Text("Swipe to dismiss the sheet — confirmation will appear")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
            Button("Open Sheet") { isSheetOpen = true }
                .buttonStyle(.borderedProminent)
            #else
            Text("dismissalConfirmationDialog is macOS-only.")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
            #endif
        }
        #if os(macOS)
        .sheet(isPresented: $isSheetOpen) { sheetContent }
        #endif
    }

    #if os(macOS)
    var sheetContent: some View {
        EditDemoSheet(dialogTitle: dialogTitle, shouldPresent: shouldPresent)
    }
    #endif

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Dialog title", text: $dialogTitle)
        ShowcaseToggle("Should present confirmation", isOn: $shouldPresent)
    }

    @ViewBuilder
    func stateView(_ state: EnabledState) -> some View {
        let active = state == .enabled
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: active ? "exclamationmark.shield.fill" : "shield.slash.fill")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(active ? DesignSystem.Color.accent : DesignSystem.Color.secondary)
            Text(active ? "Confirms on dismiss" : "Dismisses freely")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.medium)
    }
}

// MARK: - Code generation
private extension DismissalConfirmationDialogShowcase {
    var generatedCode: String {
        """
        // macOS only — unavailable on iOS / tvOS / watchOS
        SheetContentView()
            .dismissalConfirmationDialog(
                "\(dialogTitle)",
                shouldPresent: \(shouldPresent)
            ) {
                Button("Discard", role: .destructive) { dismiss() }
            }
        """
    }
}

#if os(macOS)
// MARK: - EditDemoSheet
private struct EditDemoSheet: View {
    let dialogTitle: String
    let shouldPresent: Bool

    @Environment(\.dismiss) private var dismiss
    @State private var inputText = "Edit me before dismissing…"

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
                statusBanner
                TextEditor(text: $inputText)
                    .font(DesignSystem.Font.body)
                    .frame(minHeight: 120)
                    .padding(DesignSystem.Spacing.small)
                    .background(DesignSystem.Color.cardBackground)
                    .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
                Spacer()
            }
            .padding(DesignSystem.Spacing.large)
            .navigationTitle("Edit Content")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .dismissalConfirmationDialog(
                LocalizedStringKey(dialogTitle),
                shouldPresent: shouldPresent,
            ) {
                Button("Discard", role: .destructive) { dismiss() }
            }
        }
    }

    private var statusBanner: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: shouldPresent ? "exclamationmark.shield.fill" : "shield.slash.fill")
                .foregroundStyle(shouldPresent ? DesignSystem.Color.accent : DesignSystem.Color.secondary)
            Text(shouldPresent ? "Dismiss — confirmation will appear" : "Dismiss freely — no confirmation")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.small))
    }
}
#endif
