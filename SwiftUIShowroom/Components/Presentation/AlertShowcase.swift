import SwiftUI

struct AlertShowcase: View {
    enum PrimaryRoleOption: ShowcasePickable {
        case none
        case destructive
        case cancel

        var label: String {
            switch self {
            case .none: "none"
            case .destructive: "destructive"
            case .cancel: "cancel"
            }
        }

        var buttonRole: ButtonRole? {
            switch self {
            case .none: nil
            case .destructive: .destructive
            case .cancel: .cancel
            }
        }

        var actionLabel: String {
            switch self {
            case .none: "Confirm"
            case .destructive: "Delete"
            case .cancel: "Done"
            }
        }
    }

    enum AlertGalleryState: ShowcaseState {
        case standard
        case error

        var caption: String {
            switch self {
            case .standard: "Standard"
            case .error: "Error"
            }
        }
    }

    @State private var alertTitle = "Delete Item"
    @State private var alertMessage = "This action cannot be undone."
    @State private var isPresented = false
    @State private var primaryRole: PrimaryRoleOption = .destructive
    @State private var includesCancel = true
    @State private var includesTextField = false
    @State private var errorDriven = false
    @State private var inputText = ""

    var body: some View {
        ShowcaseScreen(
            title: "Alert",
            summary: "Modal alert with a title, optional message, action buttons with roles, and optional text fields.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
        .alert(alertTitle, isPresented: $isPresented) {
            alertActions
        } message: {
            if !alertMessage.isEmpty {
                Text(alertMessage)
            }
        }
    }
}

// MARK: - Sub-views
private extension AlertShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            Button("Show Alert") {
                isPresented = true
            }
            .buttonStyle(.borderedProminent)
            Text(errorDriven ? "Error-driven overload" : "Standard overload")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Title", text: $alertTitle, prompt: "Alert title")
        ShowcaseTextControl("Message", text: $alertMessage, prompt: "Optional message")
        ShowcasePicker("Primary button role", selection: $primaryRole)
        ShowcaseToggle("Includes cancel", isOn: $includesCancel)
        #if os(iOS)
        ShowcaseToggle("Includes text field", isOn: $includesTextField)
        #endif
        ShowcaseToggle("Error-driven overload", isOn: $errorDriven)
    }

    @ViewBuilder
    func stateView(_ state: AlertGalleryState) -> some View {
        switch state {
        case .standard:
            alertPreviewCard(
                title: "Delete Item",
                message: "This action cannot be undone.",
                role: .destructive,
            )
        case .error:
            alertPreviewCard(
                title: "Connection Failed",
                message: "Check your network and try again.",
                role: nil,
            )
        }
    }

    func alertPreviewCard(title: String, message: String, role: ButtonRole?) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text(title)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.primary)
            Text(message)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            HStack(spacing: DesignSystem.Spacing.small) {
                Button("OK", role: role) {}
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                Button("Cancel", role: .cancel) {}
                    .buttonStyle(.borderless)
                    .controlSize(.small)
            }
        }
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ViewBuilder
    var alertActions: some View {
        Button(primaryRole.actionLabel, role: primaryRole.buttonRole) {}
        if includesCancel {
            Button("Cancel", role: .cancel) {}
        }
        #if os(iOS)
        if includesTextField {
            TextField("Enter value", text: $inputText)
        }
        #endif
    }
}

// MARK: - Code generation
private extension AlertShowcase {
    var generatedCode: String {
        var lines: [String] = []
        if errorDriven {
            lines.append(".alert(isPresented: $isPresented, error: appError) { _ in")
            lines.append("    Button(\"OK\") {}")
            lines.append("} message: { error in")
            lines.append("    Text(error.recoverySuggestion ?? \"\")")
            lines.append("}")
        } else {
            lines.append(".\(alertModifier)(\"\(alertTitle)\", isPresented: $isPresented) {")
            lines.append("    Button(\"\(primaryRole.actionLabel)\"\(roleArgument)) {}")
            if includesCancel {
                lines.append("    Button(\"Cancel\", role: .cancel) {}")
            }
            #if os(iOS)
            if includesTextField {
                lines.append("    TextField(\"Enter value\", text: $inputText)")
            }
            #endif
            lines.append("} message: {")
            if alertMessage.isEmpty {
                lines.append("    EmptyView()")
            } else {
                lines.append("    Text(\"\(alertMessage)\")")
            }
            lines.append("}")
        }
        return lines.joined(separator: "\n")
    }

    var alertModifier: String { "alert" }

    var roleArgument: String {
        switch primaryRole {
        case .none: return ""
        case .destructive: return ", role: .destructive"
        case .cancel: return ", role: .cancel"
        }
    }
}
