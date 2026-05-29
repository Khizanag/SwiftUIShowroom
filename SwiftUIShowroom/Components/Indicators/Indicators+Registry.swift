import SwiftUI

extension ShowcaseRegistry {
    static let indicatorsEntries: [ShowcaseEntry] = [
        ShowcaseEntry(
            id: "content-unavailable-view",
            title: "Content Unavailable View",
            category: .indicators,
            subtitle: "An empty-state interface with a",
            keywords: ["content", "contentunavailableview", "unavailable", "view"],
        ) {
            ContentUnavailableViewShowcase()
        },
        ShowcaseEntry(
            id: "redaction-placeholder",
            title: "Redaction (Placeholder / Skeleton)",
            category: .indicators,
            subtitle: "Replaces text and images with neutral",
            keywords: ["placeholder", "reason", "redacted", "redaction", "skeleton", "view"],
        ) {
            RedactionPlaceholderShowcase()
        },
        ShowcaseEntry(
            id: "privacy-sensitive",
            title: "Privacy Sensitive",
            category: .indicators,
            subtitle: "Marks a view's content as private so",
            keywords: ["privacy", "privacysensitive", "sensitive", "view"],
        ) {
            PrivacySensitiveShowcase()
        },
        ShowcaseEntry(
            id: "sensory-feedback",
            title: "Sensory Feedback (Haptics)",
            category: .indicators,
            subtitle: "Plays haptic and/or audio feedback",
            keywords: ["feedback", "haptics", "sensory", "sensoryfeedback", "trigger", "view"],
        ) {
            SensoryFeedbackShowcase()
        },
        ShowcaseEntry(
            id: "badge",
            title: "Badge",
            category: .indicators,
            subtitle: "Attaches a small count or short text",
            keywords: ["badge", "view"],
        ) {
            BadgeShowcase()
        },
    ]
}
