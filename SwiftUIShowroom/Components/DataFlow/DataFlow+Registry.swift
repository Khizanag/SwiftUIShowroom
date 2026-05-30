import SwiftUI

extension ShowcaseRegistry {
    static let dataFlowEntries: [ShowcaseEntry] = [
        ShowcaseEntry(
            id: "state",
            title: "@State",
            category: .dataFlow,
            subtitle: "A property wrapper for transient,",
            keywords: ["state"],
        ) {
            StateShowcase()
        },
        ShowcaseEntry(
            id: "binding",
            title: "@Binding",
            category: .dataFlow,
            subtitle: "A two-way reference to a source of",
            keywords: ["binding"],
        ) {
            BindingShowcase()
        },
        ShowcaseEntry(
            id: "observable-macro",
            title: "@Observable (Observation macro)",
            category: .dataFlow,
            subtitle: "A macro that makes a reference type",
            keywords: ["macro", "observable", "observation"],
        ) {
            ObservableMacroShowcase()
        },
        ShowcaseEntry(
            id: "bindable",
            title: "@Bindable",
            category: .dataFlow,
            subtitle: "A property wrapper that creates",
            keywords: ["bindable"],
        ) {
            BindableShowcase()
        },
        ShowcaseEntry(
            id: "environment-value",
            title: "@Environment (key path)",
            category: .dataFlow,
            subtitle: "Reads a built-in or custom",
            keywords: ["environment", "key", "path", "value"],
        ) {
            EnvironmentValueShowcase()
        },
        ShowcaseEntry(
            id: "environment-values",
            title: "EnvironmentValues",
            category: .dataFlow,
            subtitle: "The collection of all environment",
            keywords: ["environment", "environmentvalues", "values"],
        ) {
            EnvironmentValuesShowcase()
        },
        ShowcaseEntry(
            id: "environment-modifier-keypath",
            title: ".environment(_:_:) (key path writer)",
            category: .dataFlow,
            subtitle: "Sets a value for a writable",
            keywords: ["environment", "key", "keypath", "modifier", "path", "view", "writer"],
        ) {
            EnvironmentModifierKeypathShowcase()
        },
        ShowcaseEntry(
            id: "environment-modifier-observable",
            title: ".environment(_:) (Observable injector)",
            category: .dataFlow,
            subtitle: "Injects an @Observable object into",
            keywords: ["environment", "injector", "modifier", "observable", "view"],
        ) {
            EnvironmentModifierObservableShowcase()
        },
        ShowcaseEntry(
            id: "transform-environment",
            title: ".transformEnvironment(_:transform:)",
            category: .dataFlow,
            subtitle: "Mutates an existing environment value",
            keywords: ["environment", "transform", "transformenvironment", "view"],
        ) {
            TransformEnvironmentShowcase()
        },
        ShowcaseEntry(
            id: "environment-key",
            title: "EnvironmentKey",
            category: .dataFlow,
            subtitle: "The protocol that defines a custom",
            keywords: ["environment", "environmentkey", "key"],
        ) {
            EnvironmentKeyShowcase()
        },
        ShowcaseEntry(
            id: "entry-macro",
            title: "@Entry",
            category: .dataFlow,
            subtitle: "A macro that generates a custom entry",
            keywords: ["entry", "macro"],
        ) {
            EntryMacroShowcase()
        },
        ShowcaseEntry(
            id: "appstorage",
            title: "@AppStorage",
            category: .dataFlow,
            subtitle: "A property wrapper that reads and",
            keywords: ["appstorage"],
        ) {
            AppstorageShowcase()
        },
        ShowcaseEntry(
            id: "default-app-storage",
            title: ".defaultAppStorage(_:)",
            category: .dataFlow,
            subtitle: "Sets the UserDefaults store that",
            keywords: ["app", "default", "defaultappstorage", "storage", "view"],
        ) {
            DefaultAppStorageShowcase()
        },
        ShowcaseEntry(
            id: "scenestorage",
            title: "@SceneStorage",
            category: .dataFlow,
            subtitle: "A property wrapper for lightweight",
            keywords: ["scenestorage"],
        ) {
            ScenestorageShowcase()
        },
        ShowcaseEntry(
            id: "focus-state",
            title: "@FocusState",
            category: .dataFlow,
            subtitle: "A property wrapper that reads and",
            keywords: ["focus", "focusstate", "state"],
        ) {
            FocusStateShowcase()
        },
        ShowcaseEntry(
            id: "focused-modifier",
            title: ".focused(_:) / .focused(_:equals:)",
            category: .dataFlow,
            subtitle: "Modifiers that associate a focusable",
            keywords: ["equals", "focused", "modifier", "view"],
        ) {
            FocusedModifierShowcase()
        },
        ShowcaseEntry(
            id: "is-focused-environment",
            title: ".isFocused (Environment)",
            category: .dataFlow,
            subtitle: "A read-only environment value",
            keywords: ["environment", "environmentvalues", "focused", "is", "isfocused"],
        ) {
            IsFocusedEnvironmentShowcase()
        },
        ShowcaseEntry(
            id: "focused-value",
            title: "@FocusedValue",
            category: .dataFlow,
            subtitle: "Reads a value published by the",
            keywords: ["focused", "focusedvalue", "value"],
        ) {
            FocusedValueShowcase()
        },
        ShowcaseEntry(
            id: "focused-binding",
            title: "@FocusedBinding",
            category: .dataFlow,
            subtitle: "Reads a Binding published by the",
            keywords: ["binding", "focused", "focusedbinding"],
        ) {
            FocusedBindingShowcase()
        },
        ShowcaseEntry(
            id: "focused-scene-value-modifier",
            title: ".focusedValue / .focusedSceneValue",
            category: .dataFlow,
            subtitle: "Publishes a value or binding into",
            keywords: ["focused", "focusedscenevalue", "focusedvalue", "modifier", "scene", "value", "view"],
        ) {
            FocusedSceneValueModifierShowcase()
        },
        ShowcaseEntry(
            id: "preference-key",
            title: "PreferenceKey",
            category: .dataFlow,
            subtitle: "A protocol defining a typed value",
            keywords: ["key", "preference", "preferencekey"],
        ) {
            PreferenceKeyShowcase()
        },
        ShowcaseEntry(
            id: "preference-modifier",
            title: ".preference(key:value:)",
            category: .dataFlow,
            subtitle: "Sets a value for a custom",
            keywords: ["key", "modifier", "preference", "value", "view"],
        ) {
            PreferenceModifierShowcase()
        },
        ShowcaseEntry(
            id: "on-preference-change",
            title: ".onPreferenceChange(_:perform:)",
            category: .dataFlow,
            subtitle: "Runs a closure in the container",
            keywords: ["change", "on", "onpreferencechange", "perform", "preference", "view"],
        ) {
            OnPreferenceChangeShowcase()
        },
        ShowcaseEntry(
            id: "transform-preference",
            title: ".transformPreference(_:_:)",
            category: .dataFlow,
            subtitle: "Modifies the value of a PreferenceKey",
            keywords: ["preference", "transform", "transformpreference", "view"],
        ) {
            TransformPreferenceShowcase()
        },
        ShowcaseEntry(
            id: "anchor-preference",
            title: ".anchorPreference(key:value:transform:)",
            category: .dataFlow,
            subtitle: "Reports a geometric Anchor (bounds,",
            keywords: ["anchor", "anchorpreference", "key", "preference", "transform", "value", "view"],
        ) {
            AnchorPreferenceShowcase()
        },
        ShowcaseEntry(
            id: "overlay-preference-value",
            title: ".overlayPreferenceValue / .backgroundPreferenceV",
            category: .dataFlow,
            subtitle: "Builds an overlay or background using",
            keywords: ["backgroundpreferencev", "overlay", "overlaypreferencevalue", "preference", "value", "view"],
        ) {
            OverlayPreferenceValueShowcase()
        },
        ShowcaseEntry(
            id: "on-change",
            title: ".onChange(of:initial:_:)",
            category: .dataFlow,
            subtitle: "Runs an action when an observed",
            keywords: ["change", "initial", "of", "on", "onchange", "view"],
        ) {
            OnChangeShowcase()
        },
        ShowcaseEntry(
            id: "on-receive",
            title: ".onReceive(_:perform:)",
            category: .dataFlow,
            subtitle: "Runs an action when a Combine",
            keywords: ["on", "onreceive", "perform", "receive", "view"],
        ) {
            OnReceiveShowcase()
        },
        ShowcaseEntry(
            id: "state-object",
            title: "@StateObject (legacy)",
            category: .dataFlow,
            subtitle: "A property wrapper that instantiates",
            keywords: ["legacy", "object", "state", "stateobject"],
        ) {
            StateObjectShowcase()
        },
        ShowcaseEntry(
            id: "observed-object",
            title: "@ObservedObject (legacy)",
            category: .dataFlow,
            subtitle: "Observes an externally-owned",
            keywords: ["legacy", "object", "observed", "observedobject"],
        ) {
            ObservedObjectShowcase()
        },
        ShowcaseEntry(
            id: "environment-object",
            title: "@EnvironmentObject / .environmentObject(_:) (leg",
            category: .dataFlow,
            subtitle: "Reads an ObservableObject injected",
            keywords: ["environment", "environmentobject", "leg", "object"],
        ) {
            EnvironmentObjectShowcase()
        },
        ShowcaseEntry(
            id: "namespace",
            title: "@Namespace",
            category: .dataFlow,
            subtitle: "A dynamic property that vends a",
            keywords: ["namespace"],
        ) {
            NamespaceShowcase()
        },
        ShowcaseEntry(
            id: "focused-object",
            title: "@FocusedObject (legacy)",
            category: .dataFlow,
            subtitle: "Reads an ObservableObject published",
            keywords: ["focused", "focusedobject", "legacy", "object"],
        ) {
            FocusedObjectShowcase()
        },
    ]
}
