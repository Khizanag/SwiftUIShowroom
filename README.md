# SwiftUIShowroom

An interactive, multiplatform reference for **every native SwiftUI component** — each one live-configurable, shown across all of its states, with copy-paste code generated from whatever you configure.

Built for everyone who touches a SwiftUI interface: iOS and macOS developers, QA and test engineers, designers, product owners, and the merely curious. Browse a component, flip every property it has, watch it update in real time, see how it behaves in every state, and copy the exact code.

> Status: **307 showcases shipped across all 14 categories** — Text, Buttons, Selection, Containers, Navigation, Presentation, Media, Indicators, Modifiers, Effects, Accessibility, Charts, Gestures, and Data Flow. Builds warning-free for iOS / iPadOS / macOS / tvOS. See [docs/COMPONENT-CATALOG.md](docs/COMPONENT-CATALOG.md) for the coverage map.

## Why this exists

The existing SwiftUI catalogs are useful but each leaves a gap:

- Most show components with **system defaults** only — you cannot flip every property and watch the result.
- Most skip **state coverage** — disabled, loading, empty, error, focused, selected — the states that actually break in production.
- Few generate **copy-paste code** for the configuration you are looking at.

SwiftUIShowroom is built around exactly those three things.

## What makes a showcase

Every component page is the same shape, so once you learn one you know them all:

1. **Live preview** — the real native component, reacting to your configuration.
2. **Control panel** — every property the component exposes, wired to live controls (toggles, pickers, sliders, color wells, steppers).
3. **State gallery** — the component rendered in each meaningful state side by side.
4. **Generated code** — ready-to-paste SwiftUI source for the current configuration.

## Who it's for

| Audience | What they get |
|---|---|
| iOS / macOS developers | Exact API usage, every modifier, copy-paste code, edge-case states |
| QA / test engineers | Every state of every control in one place to design test matrices |
| Designers | A faithful, interactive view of the native design language across platforms |
| Product owners / Scrum masters | A shared vocabulary for what the platform offers out of the box |
| Newcomers | A guided, hands-on tour of SwiftUI without writing a line first |

## Platforms

Multiplatform from day one: **iOS, iPadOS, macOS, tvOS, watchOS**. Components that differ per platform are shown with their platform-specific variants, and platform-only components are gated and labelled.

- Minimum deployment: **iOS 26 / iPadOS 26 / macOS 26 / tvOS 26 / watchOS 26**.
- This unlocks the latest controls, modifiers, and the Liquid Glass design system as first-class showcases.

## Requirements

- Xcode 26 or later.
- A Mac running a recent macOS for building the macOS and Catalyst targets.

## Getting started

```bash
git clone git@github.com:Khizanag/SwiftUIShowroom.git
cd SwiftUIShowroom
open SwiftUIShowroom.xcodeproj
```

Select a destination and run. The app opens on the component browser; pick a category, pick a component, start configuring.

## Project layout

```
SwiftUIShowroom/
  App/            App entry, root view, coordinator navigation
  Design/         DesignSystem tokens + reusable UI components
  Showcase/       The reusable showcase framework (preview + controls + state gallery + code)
  Catalog/        Component registry, categories, search
  Components/     One folder per component category, one showcase per component
  Resource/       Assets, String Catalog
  Utility/        Cross-cutting extensions and helpers
docs/             Architecture and the component coverage checklist
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the design rationale.

## Contributing

Coverage is a community effort — adding a component is intentionally cheap and consistent. Read [CONTRIBUTING.md](CONTRIBUTING.md) for the recipe and the house conventions.

## License

[MIT](LICENSE).
