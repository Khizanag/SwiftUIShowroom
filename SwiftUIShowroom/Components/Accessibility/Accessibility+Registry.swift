import SwiftUI

extension ShowcaseRegistry {
    static let accessibilityEntries: [ShowcaseEntry] = [
        ShowcaseEntry(
            id: "accessibility-label",
            title: "Accessibility Label",
            category: .accessibility,
            subtitle: "Overrides the short, localized name",
            keywords: ["accessibility", "accessibilitylabel", "label", "view"],
        ) {
            AccessibilityLabelShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-value",
            title: "Accessibility Value",
            category: .accessibility,
            subtitle: "Supplies the current value VoiceOver",
            keywords: ["accessibility", "accessibilityvalue", "value", "view"],
        ) {
            AccessibilityValueShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-hint",
            title: "Accessibility Hint",
            category: .accessibility,
            subtitle: "Adds a longer description of what",
            keywords: ["accessibility", "accessibilityhint", "hint", "view"],
        ) {
            AccessibilityHintShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-traits",
            title: "Accessibility Traits",
            category: .accessibility,
            subtitle: "Describes how an element behaves so",
            keywords: ["accessibility", "accessibilityaddtraits", "accessibilityremovetraits", "traits", "view"],
        ) {
            AccessibilityTraitsShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-input-labels",
            title: "Accessibility Input Labels",
            category: .accessibility,
            subtitle: "Provides alternate spoken names Voice",
            keywords: ["accessibility", "accessibilityinputlabels", "input", "labels", "view"],
        ) {
            AccessibilityInputLabelsShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-hidden",
            title: "Accessibility Hidden",
            category: .accessibility,
            subtitle: "Removes an element and its children",
            keywords: ["accessibility", "accessibilityhidden", "hidden", "view"],
        ) {
            AccessibilityHiddenShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-element-children",
            title: "Accessibility Element (Children Behavior)",
            category: .accessibility,
            subtitle: "Merges a subtree into a single",
            keywords: ["accessibility", "accessibilityelement", "behavior", "children", "element", "view"],
        ) {
            AccessibilityElementChildrenShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-children-synthetic",
            title: "Accessibility Children (Synthetic)",
            category: .accessibility,
            subtitle: "Replaces an element's children with",
            keywords: ["accessibility", "accessibilitychildren", "children", "synthetic", "view"],
        ) {
            AccessibilityChildrenSyntheticShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-representation",
            title: "Accessibility Representation",
            category: .accessibility,
            subtitle: "Substitutes a custom view's",
            keywords: ["accessibility", "accessibilityrepresentation", "representation", "view"],
        ) {
            AccessibilityRepresentationShowcase()
        },
        ShowcaseEntry(
            id: "dynamic-type-size",
            title: "Dynamic Type Size",
            category: .accessibility,
            subtitle: "Constrains or overrides the Dynamic",
            keywords: ["dynamic", "dynamictypesize", "environmentvalues", "size", "type", "view"],
        ) {
            DynamicTypeSizeShowcase()
        },
        ShowcaseEntry(
            id: "scaled-metric",
            title: "ScaledMetric",
            category: .accessibility,
            subtitle: "Property wrapper that scales a",
            keywords: ["metric", "scaled", "scaledmetric"],
        ) {
            ScaledMetricShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-action",
            title: "Accessibility Action",
            category: .accessibility,
            subtitle: "Adds default, escape, magic-tap, or",
            keywords: ["accessibility", "accessibilityaction", "action", "named", "view"],
        ) {
            AccessibilityActionShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-adjustable-action",
            title: "Accessibility Adjustable Action",
            category: .accessibility,
            subtitle: "Handles VoiceOver swipe-up/down",
            keywords: ["accessibility", "accessibilityadjustableaction", "action", "adjustable", "view"],
        ) {
            AccessibilityAdjustableActionShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-scroll-action",
            title: "Accessibility Scroll Action",
            category: .accessibility,
            subtitle: "Responds to VoiceOver's three-finger",
            keywords: ["accessibility", "accessibilityscrollaction", "action", "scroll", "view"],
        ) {
            AccessibilityScrollActionShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-rotor",
            title: "Accessibility Rotor",
            category: .accessibility,
            subtitle: "Adds a custom VoiceOver rotor letting",
            keywords: ["accessibility", "accessibilityrotor", "entries", "rotor", "view"],
        ) {
            AccessibilityRotorShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-focused",
            title: "Accessibility Focus State",
            category: .accessibility,
            subtitle: "Reads and programmatically moves",
            keywords: [
                "accessibility",
                "accessibilityfocused",
                "accessibilityfocusstate",
                "focus",
                "focused",
                "state",
                "view",
            ],
        ) {
            AccessibilityFocusedShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-custom-content",
            title: "Accessibility Custom Content",
            category: .accessibility,
            subtitle: "Attaches extra label/value pairs that",
            keywords: ["accessibility", "accessibilitycustomcontent", "content", "custom", "importance", "view"],
        ) {
            AccessibilityCustomContentShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-heading",
            title: "Accessibility Heading",
            category: .accessibility,
            subtitle: "Marks an element as a heading at a",
            keywords: ["accessibility", "accessibilityheading", "heading", "view"],
        ) {
            AccessibilityHeadingShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-text-content-type",
            title: "Accessibility Text Content Type",
            category: .accessibility,
            subtitle: "Tells VoiceOver the semantic kind of",
            keywords: ["accessibility", "accessibilitytextcontenttype", "content", "text", "type", "view"],
        ) {
            AccessibilityTextContentTypeShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-reduce-motion",
            title: "Reduce Motion",
            category: .accessibility,
            subtitle: "Read-only flag indicating the user",
            keywords: ["accessibility", "accessibilityreducemotion", "environmentvalues", "motion", "reduce"],
        ) {
            AccessibilityReduceMotionShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-reduce-transparency",
            title: "Reduce Transparency",
            category: .accessibility,
            subtitle: "Read-only flag indicating the user",
            keywords: [
                "accessibility",
                "accessibilityreducetransparency",
                "environmentvalues",
                "reduce",
                "transparency",
            ],
        ) {
            AccessibilityReduceTransparencyShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-differentiate-without-color",
            title: "Differentiate Without Color",
            category: .accessibility,
            subtitle: "Read-only flag indicating the user",
            keywords: [
                "accessibility",
                "accessibilitydifferentiatewithoutcolor",
                "color",
                "differentiate",
                "environmentvalues",
                "without",
            ],
        ) {
            AccessibilityDifferentiateWithoutColorShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-increase-contrast",
            title: "Increase / Differentiate Contrast",
            category: .accessibility,
            subtitle: "Read-only flag (.standard /",
            keywords: [
                "accessibility",
                "colorschemecontrast",
                "contrast",
                "differentiate",
                "environmentvalues",
                "increase",
            ],
        ) {
            AccessibilityIncreaseContrastShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-invert-colors",
            title: "Invert Colors Handling",
            category: .accessibility,
            subtitle: "Excludes media from Smart Invert and",
            keywords: [
                "accessibility",
                "accessibilityignoresinvertcolors",
                "accessibilityinvertcolors",
                "colors",
                "environmentvalues",
                "handling",
                "invert",
                "view",
            ],
        ) {
            AccessibilityInvertColorsShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-show-button-shapes",
            title: "Button Shapes / On-Off Labels",
            category: .accessibility,
            subtitle: "Read-only flag indicating the user",
            keywords: [
                "accessibility",
                "accessibilityshowbuttonshapes",
                "button",
                "environmentvalues",
                "labels",
                "off",
                "on",
                "shapes",
            ],
        ) {
            AccessibilityShowButtonShapesShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-large-content-viewer",
            title: "Large Content Viewer",
            category: .accessibility,
            subtitle: "Shows an enlarged HUD of an element's",
            keywords: ["accessibility", "accessibilityshowslargecontentviewer", "content", "large", "view", "viewer"],
        ) {
            AccessibilityLargeContentViewerShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-sort-priority",
            title: "Accessibility Sort Priority",
            category: .accessibility,
            subtitle: "Adjusts the order in which VoiceOver",
            keywords: ["accessibility", "accessibilitysortpriority", "priority", "sort", "view"],
        ) {
            AccessibilitySortPriorityShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-activation-point",
            title: "Accessibility Activation Point",
            category: .accessibility,
            subtitle: "Specifies the exact screen point",
            keywords: ["accessibility", "accessibilityactivationpoint", "activation", "point", "view"],
        ) {
            AccessibilityActivationPointShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-direct-touch",
            title: "Accessibility Direct Touch",
            category: .accessibility,
            subtitle: "Lets VoiceOver pass touches straight",
            keywords: ["accessibility", "accessibilitydirecttouch", "direct", "options", "touch", "view"],
        ) {
            AccessibilityDirectTouchShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-zoom-action",
            title: "Accessibility Zoom Action",
            category: .accessibility,
            subtitle: "Handles VoiceOver's zoom gesture so",
            keywords: ["accessibility", "accessibilityzoomaction", "action", "view", "zoom"],
        ) {
            AccessibilityZoomActionShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-drag-drop-point",
            title: "Accessibility Drag & Drop Points",
            category: .accessibility,
            subtitle: "Exposes drag-and-drop targets to",
            keywords: [
                "accessibility",
                "accessibilitydragpoint",
                "accessibilitydroppoint",
                "description",
                "drag",
                "drop",
                "point",
                "points",
            ],
        ) {
            AccessibilityDragDropPointShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-quick-action",
            title: "Accessibility Quick Action",
            category: .accessibility,
            subtitle: "Surfaces a quick action (prompt or",
            keywords: ["accessibility", "accessibilityquickaction", "action", "content", "quick", "style", "view"],
        ) {
            AccessibilityQuickActionShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-identifier",
            title: "Accessibility Identifier",
            category: .accessibility,
            subtitle: "Sets a stable, non-localized",
            keywords: ["accessibility", "accessibilityidentifier", "identifier", "view"],
        ) {
            AccessibilityIdentifierShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-responds-to-user-interaction",
            title: "Responds To User Interaction",
            category: .accessibility,
            subtitle: "Declares whether an element is",
            keywords: [
                "accessibility",
                "accessibilityrespondstouserinteraction",
                "interaction",
                "responds",
                "to",
                "user",
                "view",
            ],
        ) {
            AccessibilityRespondsToUserInteractionShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-speech-options",
            title: "Speech Options",
            category: .accessibility,
            subtitle: "Fine-tunes how VoiceOver pronounces",
            keywords: [
                "accessibility",
                "options",
                "speech",
                "speechadjustedpitch",
                "speechalwaysincludespunctuation",
                "speechannouncementsqueued",
                "speechspellsoutcharacters",
                "view",
            ],
        ) {
            AccessibilitySpeechOptionsShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-chart-descriptor",
            title: "Accessibility Chart Descriptor",
            category: .accessibility,
            subtitle: "Provides an audio-graph and",
            keywords: ["accessibility", "accessibilitychartdescriptor", "chart", "descriptor", "view"],
        ) {
            AccessibilityChartDescriptorShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-labeled-pair",
            title: "Accessibility Labeled Pair",
            category: .accessibility,
            subtitle: "Associates a label view with the",
            keywords: ["accessibility", "accessibilitylabeledpair", "id", "in", "labeled", "pair", "role", "view"],
        ) {
            AccessibilityLabeledPairShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-rotor-entry",
            title: "Accessibility Rotor Entry",
            category: .accessibility,
            subtitle: "Tags a view so a custom rotor",
            keywords: ["accessibility", "accessibilityrotorentry", "entry", "id", "in", "rotor", "view"],
        ) {
            AccessibilityRotorEntryShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-linked-group",
            title: "Accessibility Linked Group",
            category: .accessibility,
            subtitle: "Links accessibility elements that are",
            keywords: ["accessibility", "accessibilitylinkedgroup", "group", "id", "in", "linked", "view"],
        ) {
            AccessibilityLinkedGroupShowcase()
        },
        ShowcaseEntry(
            id: "accessibility-label-content",
            title: "Accessibility Label (View Builder)",
            category: .accessibility,
            subtitle: "Supplies an element's accessibility",
            keywords: ["accessibility", "accessibilitylabel", "builder", "content", "label", "view"],
        ) {
            AccessibilityLabelContentShowcase()
        },
    ]
}
