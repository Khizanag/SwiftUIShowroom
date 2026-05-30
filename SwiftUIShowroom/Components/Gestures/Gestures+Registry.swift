import SwiftUI

extension ShowcaseRegistry {
    static let gesturesEntries: [ShowcaseEntry] = [
        ShowcaseEntry(
            id: "tap-gesture",
            title: "Tap Gesture",
            category: .gestures,
            subtitle: "Recognizes one or more taps (or",
            keywords: ["gesture", "tap", "tapgesture"],
        ) {
            TapGestureShowcase()
        },
        ShowcaseEntry(
            id: "spatial-tap-gesture",
            title: "Spatial Tap Gesture",
            category: .gestures,
            subtitle: "Recognizes taps and reports the tap",
            keywords: ["gesture", "spatial", "spatialtapgesture", "tap"],
        ) {
            SpatialTapGestureShowcase()
        },
        ShowcaseEntry(
            id: "long-press-gesture",
            title: "Long Press Gesture",
            category: .gestures,
            subtitle: "Succeeds when the user presses and",
            keywords: ["gesture", "long", "longpressgesture", "press"],
        ) {
            LongPressGestureShowcase()
        },
        ShowcaseEntry(
            id: "drag-gesture",
            title: "Drag Gesture",
            category: .gestures,
            subtitle: "Tracks a continuous dragging motion,",
            keywords: ["drag", "draggesture", "gesture"],
        ) {
            DragGestureShowcase()
        },
        ShowcaseEntry(
            id: "magnify-gesture",
            title: "Magnify Gesture",
            category: .gestures,
            subtitle: "Recognizes a pinch and tracks the",
            keywords: ["gesture", "magnify", "magnifygesture"],
        ) {
            MagnifyGestureShowcase()
        },
        ShowcaseEntry(
            id: "rotate-gesture",
            title: "Rotate Gesture",
            category: .gestures,
            subtitle: "Recognizes a two-finger rotation and",
            keywords: ["gesture", "rotate", "rotategesture"],
        ) {
            RotateGestureShowcase()
        },
        ShowcaseEntry(
            id: "rotate-gesture-3d",
            title: "Rotate Gesture 3D",
            category: .gestures,
            subtitle: "Recognizes 3D rotation, tracking",
            keywords: ["3d", "gesture", "rotate", "rotategesture3d"],
        ) {
            RotateGesture3dShowcase()
        },
        ShowcaseEntry(
            id: "spatial-event-gesture",
            title: "Spatial Event Gesture",
            category: .gestures,
            subtitle: "Tracks multiple simultaneous spatial",
            keywords: ["event", "gesture", "spatial", "spatialeventgesture"],
        ) {
            SpatialEventGestureShowcase()
        },
        ShowcaseEntry(
            id: "simultaneous-gesture",
            title: "Simultaneous Gesture Composition",
            category: .gestures,
            subtitle: "Combines two gestures so both can",
            keywords: ["composition", "gesture", "simultaneous", "simultaneousgesture"],
        ) {
            SimultaneousGestureShowcase()
        },
        ShowcaseEntry(
            id: "sequenced-gesture",
            title: "Sequenced Gesture Composition",
            category: .gestures,
            subtitle: "Runs a second gesture only after the",
            keywords: ["composition", "gesture", "sequenced", "sequencegesture"],
        ) {
            SequencedGestureShowcase()
        },
        ShowcaseEntry(
            id: "exclusive-gesture",
            title: "Exclusive Gesture Composition",
            category: .gestures,
            subtitle: "Recognizes two gestures but lets only",
            keywords: ["composition", "exclusive", "exclusivegesture", "gesture"],
        ) {
            ExclusiveGestureShowcase()
        },
        ShowcaseEntry(
            id: "gesture-state",
            title: "Gesture State (@GestureState + updating)",
            category: .gestures,
            subtitle: "A property wrapper holding transient",
            keywords: ["gesture", "gesturestate", "state", "updating"],
        ) {
            GestureStateShowcase()
        },
        ShowcaseEntry(
            id: "gesture-modifier",
            title: "Gesture Attach Modifiers (.gesture / .highPriorityGesture / .simultaneousGesture)",
            category: .gestures,
            subtitle: "View modifiers that attach a gesture",
            keywords: [
                "attach",
                "gesture",
                "highprioritygesture",
                "including",
                "modifier",
                "modifiers",
                "simultaneousgesture",
                "view",
            ],
        ) {
            GestureModifierShowcase()
        },
        ShowcaseEntry(
            id: "defers-system-gestures",
            title: "Defers System Gestures",
            category: .gestures,
            subtitle: "Asks the system to delay its own edge",
            keywords: ["defers", "deferssystemgestures", "gestures", "on", "system", "view"],
        ) {
            DefersSystemGesturesShowcase()
        },
        ShowcaseEntry(
            id: "window-drag-gesture",
            title: "Window Drag Gesture",
            category: .gestures,
            subtitle: "Recognizes a drag and moves the",
            keywords: ["drag", "gesture", "window", "windowdraggesture"],
        ) {
            WindowDragGestureShowcase()
        },
        ShowcaseEntry(
            id: "pencil-gesture",
            title: "Apple Pencil Gestures (double-tap & squeeze)",
            category: .gestures,
            subtitle: "Responds to Apple Pencil double-tap",
            keywords: ["apple", "double", "gesture", "gestures", "onpencildoubletap", "pencil", "perform", "squeeze"],
        ) {
            PencilGestureShowcase()
        },
        ShowcaseEntry(
            id: "long-touch-gesture",
            title: "Long Touch Gesture (tvOS)",
            category: .gestures,
            subtitle: "Recognizes a long touch on the tvOS",
            keywords: [
                "gesture",
                "long",
                "minimumduration",
                "onlongtouchgesture",
                "ontouchingchanged",
                "perform",
                "touch",
                "tvos",
            ],
        ) {
            LongTouchGestureShowcase()
        },
        ShowcaseEntry(
            id: "hand-gesture-shortcut",
            title: "Hand Gesture Shortcut",
            category: .gestures,
            subtitle: "Maps a system hand gesture (e.g.",
            keywords: ["gesture", "hand", "handgestureshortcut", "isenabled", "shortcut", "view"],
        ) {
            HandGestureShortcutShowcase()
        },
    ]
}
