import SwiftUI

struct AccessibilityRotorShowcase: View {
    @State private var rotorLabel = "VIPs"
    @State private var entriesKind: EntriesKind = .filteredSubset
    @State private var rotorKind: RotorKind = .elementEntries

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Rotor",
            summary: "Adds a custom VoiceOver rotor letting users jump to a curated set of elements.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityRotorShowcase {
    var preview: some View {
        rotorPreview(
            rotorLabel: rotorLabel,
            entriesKind: entriesKind,
            rotorKind: rotorKind,
        )
    }

    @ViewBuilder var controls: some View {
        ShowcaseTextControl("Rotor label", text: $rotorLabel, prompt: "e.g. VIPs")
        ShowcasePicker("Entries kind", selection: $entriesKind)
        ShowcasePicker("Rotor kind", selection: $rotorKind)
    }

    @ViewBuilder func stateView(_ state: RotorState) -> some View {
        switch state {
        case .default:
            rotorPreview(
                rotorLabel: "VIPs",
                entriesKind: .filteredSubset,
                rotorKind: .elementEntries,
            )
        case .empty:
            rotorPreview(
                rotorLabel: "VIPs",
                entriesKind: .empty,
                rotorKind: .elementEntries,
            )
        }
    }

    @ViewBuilder func rotorPreview(
        rotorLabel: String,
        entriesKind: EntriesKind,
        rotorKind: RotorKind,
    ) -> some View {
        let messages = sampleMessages(for: entriesKind)
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            rotorBadge(label: rotorLabel, kind: rotorKind)
            messageList(messages: messages, rotorLabel: rotorLabel)
        }
        .padding(DesignSystem.Spacing.small)
    }

    @ViewBuilder func rotorBadge(label: String, kind: RotorKind) -> some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: "dial.high")
                .foregroundStyle(DesignSystem.Color.accent)
                .font(DesignSystem.Font.caption)
            Text("Rotor: \"\(label)\" (\(kind.label))")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }

    @ViewBuilder func messageList(messages: [SampleMessage], rotorLabel: String) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                ForEach(messages) { message in
                    messageRow(message)
                }
            }
        }
        .frame(maxHeight: 180)
        .accessibilityElement(children: .contain)
        .accessibilityRotor(rotorLabel) {
            ForEach(messages.filter(\.isVip)) { message in
                AccessibilityRotorEntry(message.subject, id: message.id)
            }
        }
    }

    @ViewBuilder func messageRow(_ message: SampleMessage) -> some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            if message.isVip {
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
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.hairline) {
                Text(message.sender)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.primary)
                Text(message.subject)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.secondary)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.vertical, DesignSystem.Spacing.hairline)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(message.isVip ? "VIP " : "")\(message.sender): \(message.subject)")
    }
}

// MARK: - Code generation
private extension AccessibilityRotorShowcase {
    var generatedCode: String {
        switch rotorKind {
        case .elementEntries:
            return elementEntriesCode
        case .textRanges:
            return textRangesCode
        }
    }

    var elementEntriesCode: String {
        let labelLiteral = rotorLabel.isEmpty ? "VIPs" : rotorLabel
        return """
        ScrollView {
            LazyVStack {
                ForEach(messages) { message in
                    MessageView(message)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityRotor("\(labelLiteral)") {
            ForEach(messages.filter(\\.isVip)) { message in
                AccessibilityRotorEntry(message.subject, id: message.id)
            }
        }
        """
    }

    var textRangesCode: String {
        let labelLiteral = rotorLabel.isEmpty ? "Headings" : rotorLabel
        return """
        Text(articleBody)
            .accessibilityRotor("\(labelLiteral)", textRanges: headingRanges)
        """
    }
}

// MARK: - Sample data helpers
private extension AccessibilityRotorShowcase {
    struct SampleMessage: Identifiable {
        let identifier: String
        let sender: String
        let subject: String
        let isVip: Bool
        var id: String { identifier }
    }

    func sampleMessages(for kind: EntriesKind) -> [SampleMessage] {
        switch kind {
        case .filteredSubset:
            return allMessages
        case .headings:
            return headingMessages
        case .searchResults:
            return searchResultMessages
        case .empty:
            return []
        }
    }

    var allMessages: [SampleMessage] {
        [
            SampleMessage(identifier: "msg-1", sender: "Alice", subject: "Project update", isVip: true),
            SampleMessage(identifier: "msg-2", sender: "Bob", subject: "Lunch tomorrow?", isVip: false),
            SampleMessage(identifier: "msg-3", sender: "Carol", subject: "Q3 review", isVip: true),
            SampleMessage(identifier: "msg-4", sender: "Dave", subject: "Newsletter", isVip: false),
            SampleMessage(identifier: "msg-5", sender: "Eve", subject: "Urgent: deploy now", isVip: true),
            SampleMessage(identifier: "msg-6", sender: "Frank", subject: "Meeting notes", isVip: false),
        ]
    }

    var headingMessages: [SampleMessage] {
        [
            SampleMessage(identifier: "hd-1", sender: "System", subject: "Inbox", isVip: true),
            SampleMessage(identifier: "hd-2", sender: "System", subject: "Starred", isVip: false),
            SampleMessage(identifier: "hd-3", sender: "System", subject: "Sent", isVip: false),
        ]
    }

    var searchResultMessages: [SampleMessage] {
        [
            SampleMessage(identifier: "sr-1", sender: "Alice", subject: "Re: Project update", isVip: true),
            SampleMessage(identifier: "sr-2", sender: "Carol", subject: "Re: Q3 review", isVip: true),
        ]
    }
}

// MARK: - Nested types
extension AccessibilityRotorShowcase {
    fileprivate enum RotorKind: ShowcasePickable {
        case elementEntries
        case textRanges

        var label: String {
            switch self {
            case .elementEntries: "Element entries"
            case .textRanges: "Text ranges"
            }
        }
    }

    fileprivate enum EntriesKind: ShowcasePickable {
        case filteredSubset
        case headings
        case searchResults
        case empty

        var label: String {
            switch self {
            case .filteredSubset: "Filtered list subset"
            case .headings: "Headings"
            case .searchResults: "Search results"
            case .empty: "Empty"
            }
        }
    }

    fileprivate enum RotorState: ShowcaseState {
        case `default`
        case empty

        var caption: String {
            switch self {
            case .default: "Default (with VIP entries)"
            case .empty: "Empty (no rotor entries)"
            }
        }
    }
}
