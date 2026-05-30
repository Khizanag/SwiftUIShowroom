import SwiftUI

struct EditButtonShowcase: View {
    enum PlacementOption: ShowcasePickable {
        case automatic
        case topBarTrailing
        case topBarLeading
        case navigationBarTrailing

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .topBarTrailing: "topBarTrailing"
            case .topBarLeading: "topBarLeading"
            case .navigationBarTrailing: "navigationBarTrailing"
            }
        }

        #if os(iOS)
        var placement: ToolbarItemPlacement {
            switch self {
            case .automatic: .automatic
            case .topBarTrailing: .topBarTrailing
            case .topBarLeading: .topBarLeading
            case .navigationBarTrailing: .navigationBarTrailing
            }
        }
        #endif
    }

    enum EditButtonState: ShowcaseState {
        case normal
        case editing
        case disabled

        var caption: String {
            switch self {
            case .normal: "Default"
            case .editing: "Editing"
            case .disabled: "Disabled"
            }
        }
    }

    @State private var placement: PlacementOption = .automatic
    @State private var isEnabled = true

    var body: some View {
        ShowcaseScreen(
            title: "EditButton",
            summary: "Toggles editMode for an editable container — auto-labels Edit / Done.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension EditButtonShowcase {
    @ViewBuilder
    var preview: some View {
        #if os(iOS)
        EditButtonPreviewContainer(placement: placement, isEnabled: isEnabled)
            .frame(height: 260)
            .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
        #else
        unavailableNotice
        #endif
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Placement", selection: $placement)
        ShowcaseToggle("Enabled", isOn: $isEnabled)
    }

    @ViewBuilder
    func stateView(_ state: EditButtonState) -> some View {
        #if os(iOS)
        EditButtonStateCell(state: state)
        #else
        Text(state.caption)
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.secondary)
        #endif
    }

    var unavailableNotice: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "iphone.slash")
                .font(DesignSystem.Font.title)
                .foregroundStyle(DesignSystem.Color.secondary)
            Text("iOS / iPadOS only")
                .font(DesignSystem.Font.callout)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Code generation
private extension EditButtonShowcase {
    var generatedCode: String {
        """
        NavigationStack {
            List {
                ForEach(items, id: \\.self) { Text($0) }
                    .onDelete { items.remove(atOffsets: $0) }
                    .onMove { items.move(fromOffsets: $0, toOffset: $1) }
            }
            .toolbar {
                ToolbarItem(placement: .\(placement.label)) {
                    EditButton()
                        .disabled(\(!isEnabled))
                }
            }
        }
        """
    }
}

// MARK: - iOS-only subviews
#if os(iOS)
private struct EditButtonPreviewContainer: View {
    let placement: EditButtonShowcase.PlacementOption
    let isEnabled: Bool

    private static let sampleItems = [
        "Mercury", "Venus", "Earth",
        "Mars", "Jupiter", "Saturn",
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(Self.sampleItems, id: \.self) { item in
                    Text(item)
                        .font(DesignSystem.Font.body)
                }
                .onDelete { _ in }
                .onMove { _, _ in }
            }
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: placement.placement) {
                    EditButton()
                        .disabled(!isEnabled)
                }
            }
            .navigationTitle("Planets")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct EditButtonStateCell: View {
    let state: EditButtonShowcase.EditButtonState

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(iconColor)
            Text(buttonTitle)
                .font(DesignSystem.Font.body)
                .foregroundStyle(labelColor)
        }
        .padding(.horizontal, DesignSystem.Spacing.medium)
        .padding(.vertical, DesignSystem.Spacing.small)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    private var buttonTitle: String {
        switch state {
        case .normal: "Edit"
        case .editing: "Done"
        case .disabled: "Edit"
        }
    }

    private var iconName: String {
        switch state {
        case .normal: "pencil"
        case .editing: "checkmark"
        case .disabled: "pencil"
        }
    }

    private var iconColor: Color {
        switch state {
        case .normal, .editing: DesignSystem.Color.accent
        case .disabled: DesignSystem.Color.secondary
        }
    }

    private var labelColor: Color {
        switch state {
        case .normal, .editing: DesignSystem.Color.accent
        case .disabled: DesignSystem.Color.secondary
        }
    }
}
#endif
