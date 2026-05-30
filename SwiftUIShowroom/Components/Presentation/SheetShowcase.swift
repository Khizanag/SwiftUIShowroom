import SwiftUI

struct SheetShowcase: View {
    @State private var isPresented = false
    @State private var detentOption: DetentOption = .large
    @State private var dragIndicator: VisibilityOption = .automatic
    @State private var cornerRadius: Double = 20
    @State private var useCustomCornerRadius = false
    @State private var backgroundOption: BackgroundOption = .regularMaterial
    @State private var backgroundInteraction: BackgroundInteractionOption = .automatic
    @State private var contentInteraction: ContentInteractionOption = .automatic
    @State private var compactAdaptation: CompactAdaptationOption = .automatic
    @State private var sizingOption: SizingOption = .automatic
    @State private var interactiveDismissDisabled = false

    var body: some View {
        ShowcaseScreen(
            title: "Sheet",
            summary: "Modal view that slides up from the bottom, resizable via detents.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension SheetShowcase {
    var preview: some View {
        Button {
            isPresented = true
        } label: {
            Label("Present Sheet", systemImage: "rectangle.stack")
        }
        .buttonStyle(.borderedProminent)
        .sheet(isPresented: $isPresented) {
            sheetContent
                .applyiOSPresentationModifiers(
                    appearance: SheetAppearanceConfig(
                        detent: detentOption,
                        dragIndicator: dragIndicator,
                        cornerRadius: useCustomCornerRadius ? cornerRadius : nil,
                        background: backgroundOption,
                    ),
                    interaction: SheetInteractionConfig(
                        backgroundInteraction: backgroundInteraction,
                        contentInteraction: contentInteraction,
                        compactAdaptation: compactAdaptation,
                    ),
                )
                .applySizing(sizingOption)
                .interactiveDismissDisabled(interactiveDismissDisabled)
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseToggle("Show sheet", isOn: $isPresented)
        ShowcasePicker("Detent", selection: $detentOption)
        ShowcasePicker("Drag indicator", selection: $dragIndicator)
        ShowcaseToggle("Custom corner radius", isOn: $useCustomCornerRadius)
        if useCustomCornerRadius {
            ShowcaseSlider("Corner radius", value: $cornerRadius, in: 0...60)
        }
        ShowcasePicker("Background", selection: $backgroundOption)
        ShowcasePicker("Background interaction", selection: $backgroundInteraction)
        ShowcasePicker("Content interaction", selection: $contentInteraction)
        ShowcasePicker("Compact adaptation", selection: $compactAdaptation)
        ShowcasePicker("Sizing (iOS 18+ / macOS 15+)", selection: $sizingOption)
        ShowcaseToggle("Interactive dismiss disabled", isOn: $interactiveDismissDisabled)
    }

    @ViewBuilder
    func stateView(_ state: SheetState) -> some View {
        stateCard(title: state.caption, subtitle: state.subtitle, icon: state.icon)
    }

    func stateCard(title: String, subtitle: String, icon: String) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: icon)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(title)
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.primary)
            Text(subtitle)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground, in: .rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    var sheetContent: some View {
        NavigationStack {
            VStack(spacing: DesignSystem.Spacing.medium) {
                Image(systemName: "rectangle.stack.fill")
                    .font(DesignSystem.Font.largeTitle)
                    .foregroundStyle(DesignSystem.Color.accent)
                Text("Sheet Content")
                    .font(DesignSystem.Font.headline)
                Text("This is the modal sheet presentation.")
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(DesignSystem.Spacing.large)
            .navigationTitle("Sheet")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: dismissPlacement) {
                    DismissButton()
                }
            }
        }
    }

    var dismissPlacement: ToolbarItemPlacement {
        #if os(macOS)
        .automatic
        #else
        .cancellationAction
        #endif
    }
}

// MARK: - Dismiss Button
private struct DismissButton: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        Button("Done") { dismiss() }
    }
}

// MARK: - Appearance Config
private struct SheetAppearanceConfig {
    var detent: SheetShowcase.DetentOption
    var dragIndicator: SheetShowcase.VisibilityOption
    var cornerRadius: Double?
    var background: SheetShowcase.BackgroundOption
}

// MARK: - Interaction Config
private struct SheetInteractionConfig {
    var backgroundInteraction: SheetShowcase.BackgroundInteractionOption
    var contentInteraction: SheetShowcase.ContentInteractionOption
    var compactAdaptation: SheetShowcase.CompactAdaptationOption
}

// MARK: - Presentation Modifiers
private extension View {
    @ViewBuilder
    func applyiOSPresentationModifiers(
        appearance: SheetAppearanceConfig,
        interaction: SheetInteractionConfig,
    ) -> some View {
        #if os(iOS)
        self
            .presentationDetents(appearance.detent.detents)
            .presentationDragIndicator(appearance.dragIndicator.visibility)
            .modifier(CornerRadiusModifier(radius: appearance.cornerRadius))
            .modifier(BackgroundModifier(option: appearance.background))
            .modifier(BackgroundInteractionModifier(option: interaction.backgroundInteraction))
            .modifier(ContentInteractionModifier(option: interaction.contentInteraction))
            .modifier(CompactAdaptationModifier(option: interaction.compactAdaptation))
        #else
        self
        #endif
    }

    @ViewBuilder
    func applySizing(_ option: SheetShowcase.SizingOption) -> some View {
        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, *) {
            switch option {
            case .automatic: self.presentationSizing(.automatic)
            case .fitted: self.presentationSizing(.fitted)
            case .form: self.presentationSizing(.form)
            case .page: self.presentationSizing(.page)
            }
        } else {
            self
        }
    }
}

// MARK: - iOS-only ViewModifiers
#if os(iOS)
private struct CornerRadiusModifier: ViewModifier {
    let radius: Double?
    func body(content: Content) -> some View {
        if let radius {
            content.presentationCornerRadius(radius)
        } else {
            content
        }
    }
}

private struct BackgroundModifier: ViewModifier {
    let option: SheetShowcase.BackgroundOption
    func body(content: Content) -> some View {
        switch option {
        case .regularMaterial: content.presentationBackground(.regularMaterial)
        case .thinMaterial: content.presentationBackground(.thinMaterial)
        case .ultraThinMaterial: content.presentationBackground(.ultraThinMaterial)
        case .thickMaterial: content.presentationBackground(.thickMaterial)
        case .colorClear: content.presentationBackground(.clear)
        }
    }
}

private struct BackgroundInteractionModifier: ViewModifier {
    let option: SheetShowcase.BackgroundInteractionOption
    func body(content: Content) -> some View {
        switch option {
        case .automatic: content.presentationBackgroundInteraction(.automatic)
        case .enabled: content.presentationBackgroundInteraction(.enabled)
        case .disabled: content.presentationBackgroundInteraction(.disabled)
        }
    }
}

private struct ContentInteractionModifier: ViewModifier {
    let option: SheetShowcase.ContentInteractionOption
    func body(content: Content) -> some View {
        switch option {
        case .automatic: content.presentationContentInteraction(.automatic)
        case .resizes: content.presentationContentInteraction(.resizes)
        case .scrolls: content.presentationContentInteraction(.scrolls)
        }
    }
}

private struct CompactAdaptationModifier: ViewModifier {
    let option: SheetShowcase.CompactAdaptationOption
    func body(content: Content) -> some View {
        switch option {
        case .automatic: content.presentationCompactAdaptation(.automatic)
        case .none: content.presentationCompactAdaptation(.none)
        case .sheet: content.presentationCompactAdaptation(.sheet)
        case .popover: content.presentationCompactAdaptation(.popover)
        }
    }
}
#endif

// MARK: - Enums
extension SheetShowcase {
    enum DetentOption: ShowcasePickable {
        case medium, large, mediumAndLarge, fraction30, height200

        var label: String {
            switch self {
            case .medium: ".medium"
            case .large: ".large"
            case .mediumAndLarge: "[.medium, .large]"
            case .fraction30: ".fraction(0.3)"
            case .height200: ".height(200)"
            }
        }

        var detents: Set<PresentationDetent> {
            switch self {
            case .medium: [.medium]
            case .large: [.large]
            case .mediumAndLarge: [.medium, .large]
            case .fraction30: [.fraction(0.3)]
            case .height200: [.height(200)]
            }
        }
    }

    enum VisibilityOption: ShowcasePickable {
        case automatic, visible, hidden

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .visible: "visible"
            case .hidden: "hidden"
            }
        }

        var visibility: Visibility {
            switch self {
            case .automatic: .automatic
            case .visible: .visible
            case .hidden: .hidden
            }
        }
    }

    enum BackgroundOption: ShowcasePickable {
        case regularMaterial, thinMaterial, ultraThinMaterial, thickMaterial, colorClear

        var label: String {
            switch self {
            case .regularMaterial: ".regularMaterial"
            case .thinMaterial: ".thinMaterial"
            case .ultraThinMaterial: ".ultraThinMaterial"
            case .thickMaterial: ".thickMaterial"
            case .colorClear: "Color.clear"
            }
        }
    }

    enum BackgroundInteractionOption: ShowcasePickable {
        case automatic, enabled, disabled

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .enabled: "enabled"
            case .disabled: "disabled"
            }
        }
    }

    enum ContentInteractionOption: ShowcasePickable {
        case automatic, resizes, scrolls

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .resizes: "resizes"
            case .scrolls: "scrolls"
            }
        }
    }

    enum CompactAdaptationOption: ShowcasePickable {
        case automatic, none, sheet, popover

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .none: "none"
            case .sheet: "sheet"
            case .popover: "popover"
            }
        }
    }

    enum SizingOption: ShowcasePickable {
        case automatic, fitted, form, page

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .fitted: "fitted"
            case .form: "form"
            case .page: "page"
            }
        }
    }

    enum SheetState: ShowcaseState {
        case `default`, longContent, dismissDisabled, mediumDetent

        var caption: String {
            switch self {
            case .default: "Default"
            case .longContent: "Long Content"
            case .dismissDisabled: "Dismiss Disabled"
            case .mediumDetent: "Medium Detent"
            }
        }

        var subtitle: String {
            switch self {
            case .default: "Standard sheet"
            case .longContent: "Scrollable body"
            case .dismissDisabled: "Swipe blocked"
            case .mediumDetent: "Half-height"
            }
        }

        var icon: String {
            switch self {
            case .default: "rectangle.stack"
            case .longContent: "text.alignleft"
            case .dismissDisabled: "lock.rectangle"
            case .mediumDetent: "rectangle.bottomhalf.inset.filled"
            }
        }
    }
}

// MARK: - Code generation
private extension SheetShowcase {
    var generatedCode: String {
        var lines = [String]()
        lines.append(".sheet(isPresented: $isPresented) {")
        lines.append("    SheetContentView()")
        lines.append("        .presentationDetents([\(detentOption.label)])")
        lines.append("        .presentationDragIndicator(.\(dragIndicator.label))")
        if useCustomCornerRadius {
            lines.append("        .presentationCornerRadius(\(Int(cornerRadius)))")
        }
        lines.append("        .presentationBackground(\(backgroundOption.label))")
        if backgroundInteraction != .automatic {
            lines.append("        .presentationBackgroundInteraction(.\(backgroundInteraction.label))")
        }
        if contentInteraction != .automatic {
            lines.append("        .presentationContentInteraction(.\(contentInteraction.label))")
        }
        if compactAdaptation != .automatic {
            lines.append("        .presentationCompactAdaptation(.\(compactAdaptation.label))")
        }
        if sizingOption != .automatic {
            lines.append("        .presentationSizing(.\(sizingOption.label))")
        }
        if interactiveDismissDisabled {
            lines.append("        .interactiveDismissDisabled(true)")
        }
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}
