import SwiftUI

struct AccessibilityRotorEntryShowcase: View {
    @State private var entryID = "message-42"
    @Namespace private var rotorNS

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Rotor Entry",
            summary: "Tags a view so a custom rotor can locate and scroll to it, even off-screen.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityRotorEntryShowcase {
    var preview: some View {
        rotorEntryPreview(entryID: entryID, namespace: rotorNS)
    }

    @ViewBuilder var controls: some View {
        ShowcaseTextControl("Entry ID", text: $entryID, prompt: "e.g. message-42")
    }

    @ViewBuilder func stateView(_ state: EntryState) -> some View {
        switch state {
        case .default:
            staticRotorEntryPreview(
                entryID: "message-42",
                highlightedID: "message-42",
            )
        }
    }

    @ViewBuilder func rotorEntryPreview(
        entryID: String,
        namespace: Namespace.ID,
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            entryBadge(entryID: entryID)
            messageListWithEntry(entryID: entryID, namespace: namespace)
        }
        .padding(DesignSystem.Spacing.small)
    }

    @ViewBuilder func staticRotorEntryPreview(
        entryID: String,
        highlightedID: String,
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            entryBadge(entryID: entryID)
            staticMessageList(highlightedID: highlightedID)
        }
        .padding(DesignSystem.Spacing.small)
    }

    @ViewBuilder func entryBadge(entryID: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: "scope")
                .foregroundStyle(DesignSystem.Color.accent)
                .font(DesignSystem.Font.caption)
            Text("Rotor entry ID: \"\(entryID)\"")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }

    @ViewBuilder func messageListWithEntry(
        entryID: String,
        namespace: Namespace.ID,
    ) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                ForEach(sampleMessages) { message in
                    messageRow(
                        message,
                        isTagged: message.identifier == entryID,
                        namespace: namespace,
                    )
                }
            }
        }
        .frame(maxHeight: 180)
        .accessibilityElement(children: .contain)
        .accessibilityRotor("VIPs") {
            ForEach(sampleMessages.filter(\.isVip)) { message in
                AccessibilityRotorEntry(Text(message.subject), id: message.id, in: namespace)
            }
        }
    }

    @ViewBuilder func staticMessageList(highlightedID: String) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                ForEach(sampleMessages) { message in
                    staticMessageRow(
                        message,
                        isHighlighted: message.identifier == highlightedID,
                    )
                }
            }
        }
        .frame(maxHeight: 180)
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder func messageRow(
        _ message: SampleMessage,
        isTagged: Bool,
        namespace: Namespace.ID,
    ) -> some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            rowLeadingIcon(isVip: message.isVip)
            rowContent(sender: message.sender, subject: message.subject)
            Spacer()
            if isTagged {
                Image(systemName: "scope")
                    .foregroundStyle(DesignSystem.Color.accent)
                    .font(DesignSystem.Font.caption2)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.hairline)
        .background(isTagged ? DesignSystem.Color.accent.opacity(0.08) : Color.clear)
        .cornerRadius(DesignSystem.CornerRadius.small)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(message.isVip ? "VIP " : "")\(message.sender): \(message.subject)")
        .accessibilityRotorEntry(id: message.id, in: namespace)
    }

    @ViewBuilder func staticMessageRow(
        _ message: SampleMessage,
        isHighlighted: Bool,
    ) -> some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            rowLeadingIcon(isVip: message.isVip)
            rowContent(sender: message.sender, subject: message.subject)
            Spacer()
            if isHighlighted {
                Image(systemName: "scope")
                    .foregroundStyle(DesignSystem.Color.accent)
                    .font(DesignSystem.Font.caption2)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.hairline)
        .background(isHighlighted ? DesignSystem.Color.accent.opacity(0.08) : Color.clear)
        .cornerRadius(DesignSystem.CornerRadius.small)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(message.isVip ? "VIP " : "")\(message.sender): \(message.subject)")
    }

    @ViewBuilder func rowLeadingIcon(isVip: Bool) -> some View {
        if isVip {
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
                .font(DesignSystem.Font.caption2)
                .accessibilityHidden(true)
        } else {
            Image(systemName: "envelope")
                .foregroundStyle(DesignSystem.Color.secondary)
                .font(DesignSystem.Font.caption2)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder func rowContent(sender: String, subject: String) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.hairline) {
            Text(sender)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.primary)
            Text(subject)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.secondary)
                .lineLimit(1)
        }
    }
}

// MARK: - Code generation
private extension AccessibilityRotorEntryShowcase {
    var generatedCode: String {
        let idLiteral = entryID.isEmpty ? "message-42" : entryID
        return """
        @Namespace private var rotorNS

        ScrollView {
            LazyVStack {
                ForEach(messages) { message in
                    MessageView(message)
                        .accessibilityRotorEntry(id: message.id, in: rotorNS)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityRotor("VIPs") {
            ForEach(messages.filter(\\.isVip)) { message in
                AccessibilityRotorEntry(
                    message.subject,
                    id: message.id,
                    in: rotorNS,
                )
            }
        }
        // Tagged entry ID: "\(idLiteral)"
        """
    }
}

// MARK: - Sample data helpers
private extension AccessibilityRotorEntryShowcase {
    struct SampleMessage: Identifiable {
        let identifier: String
        let sender: String
        let subject: String
        let isVip: Bool
        var id: String { identifier }
    }

    var sampleMessages: [SampleMessage] {
        [
            SampleMessage(identifier: "message-40", sender: "Alice", subject: "Project update", isVip: true),
            SampleMessage(identifier: "message-41", sender: "Bob", subject: "Lunch tomorrow?", isVip: false),
            SampleMessage(identifier: "message-42", sender: "Carol", subject: "Q3 review", isVip: true),
            SampleMessage(identifier: "message-43", sender: "Dave", subject: "Newsletter", isVip: false),
            SampleMessage(identifier: "message-44", sender: "Eve", subject: "Urgent: deploy now", isVip: true),
            SampleMessage(identifier: "message-45", sender: "Frank", subject: "Meeting notes", isVip: false),
        ]
    }
}

// MARK: - Nested types
extension AccessibilityRotorEntryShowcase {
    fileprivate enum EntryState: ShowcaseState {
        case `default`

        var caption: String {
            switch self {
            case .default: "Default (entry tagged with ID)"
            }
        }
    }
}
