# Contributing

Thanks for helping make SwiftUIShowroom complete. Adding a component is deliberately a small, repeatable recipe.

## Ground rules

- SwiftUI only. Reach for UIKit / AppKit only when SwiftUI genuinely cannot show the thing.
- No third-party dependencies. This is a native reference.
- Every user-facing string goes through the String Catalog — no hardcoded literals in shell code.
- All visual values come from the `DesignSystem` namespace. No inline fonts, colors, spacing, or frame sizes.
- `swiftlint lint --strict` must pass with zero violations, and the build must be warning-free.

## Adding a new component showcase

1. **Find its category** in [docs/COMPONENT-CATALOG.md](docs/COMPONENT-CATALOG.md). Create the page under `Components/<Category>/<Component>Showcase.swift`.
2. **Define a `Config`** value type holding every property you want the reader to change.
3. **Build the page on `ShowcaseScreen`**, supplying four things:
   - a live preview that applies `Config` to the real component,
   - a control panel built from the `Showcase*` control building blocks,
   - a `StateGallery` covering the component's meaningful states,
   - a `generatedCode(for:)` string that prints the current configuration.
4. **Register it** by adding a `ShowcaseEntry` to the catalog with a stable `id`, title, category, and search tags.
5. **Tick the box** in the coverage catalog.

That is the whole flow — no navigation wiring, no manual file references (synchronized Folders pick up new files automatically).

## Showcasing native APIs the house style normally bans

The app shell follows the production conventions (no `NavigationLink`, no inline fonts, etc.). But showcase pages exist to demonstrate native APIs — including those. Inside `Components/` you may use any native API directly. Where a SwiftLint custom rule would fire, add a single targeted disable with a reason:

```swift
// swiftlint:disable:next no_navigation_link — showcasing NavigationLink itself
NavigationLink("Detail", value: item)
```

Never use a blanket file-level disable, and never disable a rule in the app shell.

## State coverage

A showcase is not done until it covers the states that matter for that component. As a baseline, consider: default, disabled, loading, empty, error, focused, selected, and long-content. Skip the ones that genuinely do not apply and note why.

## Commits

- Conventional style: `feat: add Slider showcase`, `fix: correct Picker code generation`.
- Imperative mood, under 72 characters, no trailing period.
- One logical change per commit. No AI attribution lines.

## Accessibility

Every interactive element needs an accessibility label. Showcases must remain usable with VoiceOver, Dynamic Type, and Reduce Motion. Looping animations are gated behind Reduce Motion.
