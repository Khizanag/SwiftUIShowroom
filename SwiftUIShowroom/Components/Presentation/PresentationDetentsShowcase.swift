import SwiftUI

struct PresentationDetentsShowcase: View {
    enum DetentSetOption: ShowcasePickable {
        case mediumOnly
        case largeOnly
        case mediumAndLarge
        case fractionQuarter
        case fractionHalf
        case fixedHeight150
        case fixedHeight300

        var label: String {
            switch self {
            case .mediumOnly: "[.medium]"
            case .largeOnly: "[.large]"
            case .mediumAndLarge: "[.medium, .large]"
            case .fractionQuarter: "[.fraction(0.25), .large]"
            case .fractionHalf: "[.fraction(0.5), .large]"
            case .fixedHeight150: "[.height(150), .large]"
            case .fixedHeight300: "[.height(300), .large]"
            }
        }

        #if os(iOS)
        var detents: Set<PresentationDetent> {
            switch self {
            case .mediumOnly: [.medium]
            case .largeOnly: [.large]
            case .mediumAndLarge: [.medium, .large]
            case .fractionQuarter: [.fraction(0.25), .large]
            case .fractionHalf: [.fraction(0.5), .large]
            case .fixedHeight150: [.height(150), .large]
            case .fixedHeight300: [.height(300), .large]
            }
        }
        #endif
    }

    enum DetentOption: ShowcasePickable {
        case medium
        case large

        var label: String {
            switch self {
            case .medium: ".medium"
            case .large: ".large"
            }
        }

        #if os(iOS)
        var detent: PresentationDetent {
            switch self {
            case .medium: .medium
            case .large: .large
            }
        }
        #endif
    }

    enum DetentState: ShowcaseState {
        case singleDetent
        case multiDetent
        case fractionDetent
        case fixedHeightDetent

        var caption: String {
            switch self {
            case .singleDetent: "Single (.large)"
            case .multiDetent: "Multi (.medium + .large)"
            case .fractionDetent: "Fraction (0.5)"
            case .fixedHeightDetent: "Fixed height (250)"
            }
        }
    }

    @State private var selectedDetentSet: DetentSetOption = .mediumAndLarge
    @State private var selectedDetent: DetentOption = .large
    @State private var useSelection = false
    @State private var isSheetPresented = false

    var body: some View {
        ShowcaseScreen(
            title: "Presentation Detents",
            summary: "Defines the set of heights a sheet snaps to, with optional programmatic selection.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
        #if os(iOS)
        .sheet(isPresented: $isSheetPresented) {
            sheetContent
        }
        #endif
    }
}

// MARK: - Sub-views
private extension PresentationDetentsShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            detentDiagram(detentSet: selectedDetentSet)
            #if os(iOS)
            Button("Open Sheet") {
                isSheetPresented = true
            }
            .buttonStyle(.borderedProminent)
            #else
            Text("Sheet preview available on iOS")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            #endif
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Detents", selection: $selectedDetentSet)
        ShowcaseToggle("Bind selection", isOn: $useSelection)
        if useSelection {
            ShowcasePicker("Selected detent", selection: $selectedDetent)
        }
    }

    @ViewBuilder
    func stateView(_ state: DetentState) -> some View {
        switch state {
        case .singleDetent:
            detentStateCard(
                label: ".large",
                icon: "arrow.up.to.line",
                barCount: 1,
            )
        case .multiDetent:
            detentStateCard(
                label: ".medium + .large",
                icon: "arrow.up.and.down",
                barCount: 2,
            )
        case .fractionDetent:
            detentStateCard(
                label: ".fraction(0.5) + .large",
                icon: "divide",
                barCount: 2,
            )
        case .fixedHeightDetent:
            detentStateCard(
                label: ".height(250) + .large",
                icon: "ruler",
                barCount: 2,
            )
        }
    }

    func detentStateCard(
        label: String,
        icon: String,
        barCount: Int
    ) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: icon)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(label)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
            detentBars(count: barCount)
        }
        .padding(DesignSystem.Spacing.medium)
    }

    func detentBars(count: Int) -> some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            ForEach(0..<count, id: \.self) { idx in
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .fill(
                        DesignSystem.Color.accent
                            .opacity(Double(idx + 1) / Double(count + 1) + 0.2)
                    )
                    .frame(width: 8, height: CGFloat(16 + idx * 12))
            }
        }
    }

    func detentDiagram(detentSet: DetentSetOption) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "rectangle.bottomhalf.filled")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(detentSet.label)
                .font(DesignSystem.Font.code)
                .foregroundStyle(DesignSystem.Color.primary)
                .multilineTextAlignment(.center)
        }
    }

    #if os(iOS)
    var sheetContent: some View {
        DetentSheetView(
            detents: selectedDetentSet.detents,
            selection: useSelection ? selectedDetent.detent : nil,
            isPresented: $isSheetPresented,
        )
    }
    #endif
}

// MARK: - Code generation
private extension PresentationDetentsShowcase {
    var generatedCode: String {
        let detentsArg = selectedDetentSet.label
        if useSelection {
            return """
            SheetContentView()
                .presentationDetents(\(detentsArg), selection: $selectedDetent)
            """
        } else {
            return """
            SheetContentView()
                .presentationDetents(\(detentsArg))
            """
        }
    }
}

// MARK: - DetentSheetView
#if os(iOS)
private struct DetentSheetView: View {
    let detents: Set<PresentationDetent>
    let selection: PresentationDetent?
    @Binding var isPresented: Bool
    @State private var activeDetent: PresentationDetent = .large

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.large) {
                    Image(systemName: "rectangle.bottomhalf.filled")
                        .font(DesignSystem.Font.largeTitle)
                        .foregroundStyle(DesignSystem.Color.accent)
                    Text("Drag to resize")
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.primary)
                    Text("Active detent: \(activeDetentLabel)")
                        .font(DesignSystem.Font.body)
                        .foregroundStyle(DesignSystem.Color.secondary)
                    detentList
                }
                .padding(DesignSystem.Spacing.large)
            }
            .navigationTitle("Detents Demo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { isPresented = false }
                }
            }
        }
        .presentationDetents(detents, selection: $activeDetent)
        .onAppear {
            activeDetent = selection ?? (detents.contains(.large) ? .large : detents.first ?? .large)
        }
    }

    private var activeDetentLabel: String {
        if activeDetent == .medium { return ".medium" }
        if activeDetent == .large { return ".large" }
        return "custom"
    }

    private var detentList: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Text("Configured detents:")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.primary)
            ForEach(Array(detents), id: \.self) { detent in
                HStack {
                    Image(
                        systemName: detent == activeDetent
                            ? "checkmark.circle.fill"
                            : "circle"
                    )
                    .foregroundStyle(
                        detent == activeDetent
                            ? DesignSystem.Color.accent
                            : DesignSystem.Color.secondary
                    )
                    Text(labelFor(detent: detent))
                        .font(DesignSystem.Font.body)
                        .foregroundStyle(DesignSystem.Color.primary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func labelFor(detent: PresentationDetent) -> String {
        if detent == .medium { return ".medium" }
        if detent == .large { return ".large" }
        return "custom detent"
    }
}
#endif
