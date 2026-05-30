import SwiftUI

struct GroupboxShowcase: View {
    enum GroupBoxState: ShowcaseState {
        case `default`
        case unlabeled
        case longContent

        var caption: String {
            switch self {
            case .default: "Default (labeled)"
            case .unlabeled: "Unlabeled"
            case .longContent: "Long content"
            }
        }
    }

    @State private var labelText = "Network"
    @State private var showLabel = true
    @State private var wifiEnabled = true
    @State private var bluetoothEnabled = false
    @State private var airplaneEnabled = false

    var body: some View {
        ShowcaseScreen(
            title: "GroupBox",
            summary: "A stylized container that visually groups a label with related content in a bordered card.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension GroupboxShowcase {
    @ViewBuilder
    var preview: some View {
        #if os(tvOS)
        tvFallbackCard(title: showLabel ? labelText : nil) {
            tvToggleRow("Wi-Fi", systemImage: "wifi")
            tvToggleRow("Bluetooth", systemImage: "dot.radiowaves.left.and.right")
            tvToggleRow("Airplane Mode", systemImage: "airplane")
        }
        #else
        if showLabel {
            GroupBox(labelText) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                    Toggle("Wi-Fi", isOn: $wifiEnabled)
                    Toggle("Bluetooth", isOn: $bluetoothEnabled)
                    Toggle("Airplane Mode", isOn: $airplaneEnabled)
                }
            }
            .padding(DesignSystem.Spacing.medium)
        } else {
            GroupBox {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                    Toggle("Wi-Fi", isOn: $wifiEnabled)
                    Toggle("Bluetooth", isOn: $bluetoothEnabled)
                    Toggle("Airplane Mode", isOn: $airplaneEnabled)
                }
            }
            .padding(DesignSystem.Spacing.medium)
        }
        #endif
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseToggle("Show label", isOn: $showLabel)
        if showLabel {
            ShowcaseTextControl("Label text", text: $labelText, prompt: "Group title")
        }
    }

    @ViewBuilder
    func stateView(_ state: GroupBoxState) -> some View {
        switch state {
        case .default:
            #if os(tvOS)
            tvFallbackCard(title: "Settings") {
                Text("Toggle A")
                    .font(DesignSystem.Font.body)
            }
            #else
            GroupBox("Settings") {
                Toggle("Option A", isOn: .constant(true))
            }
            #endif
        case .unlabeled:
            #if os(tvOS)
            tvFallbackCard(title: nil) {
                Text("No label above")
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
            #else
            GroupBox {
                Text("No label above")
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
            #endif
        case .longContent:
            #if os(tvOS)
            tvFallbackCard(title: "Connectivity") {
                ForEach(["Wi-Fi", "Bluetooth", "Cellular", "Airplane Mode", "VPN"], id: \.self) { item in
                    Text(item)
                        .font(DesignSystem.Font.body)
                }
            }
            #else
            GroupBox("Connectivity") {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                    Toggle("Wi-Fi", isOn: .constant(true))
                    Toggle("Bluetooth", isOn: .constant(false))
                    Toggle("Cellular", isOn: .constant(true))
                    Toggle("Airplane Mode", isOn: .constant(false))
                    Toggle("VPN", isOn: .constant(false))
                }
            }
            #endif
        }
    }

    #if os(tvOS)
    func tvToggleRow(_ label: String, systemImage: String) -> some View {
        Label(label, systemImage: systemImage)
            .font(DesignSystem.Font.body)
    }

    func tvFallbackCard<Content: View>(
        title: String?,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            if let title {
                Text(title)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.primary)
            }
            content()
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground, in: .rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }
    #endif
}

// MARK: - Code generation
private extension GroupboxShowcase {
    var generatedCode: String {
        let labelLine = showLabel ? "\"\(labelText)\"" : ""
        let openParen = showLabel ? "GroupBox(\(labelLine)) {" : "GroupBox {"
        return """
        \(openParen)
            Toggle("Wi-Fi", isOn: $wifi)
            Toggle("Bluetooth", isOn: $bluetooth)
            Toggle("Airplane Mode", isOn: $airplane)
        }
        .groupBoxStyle(.automatic)
        """
    }
}
