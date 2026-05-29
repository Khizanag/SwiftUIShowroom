# Architecture

How SwiftUIShowroom is put together, and why. The guiding principle: **adding a component must be cheap, and every showcase must feel identical to use.**

## Layers

```
App        →  entry point, root view, coordinator-based navigation
Catalog    →  the registry of components: id, title, category, tags, destination
Showcase   →  the reusable framework every component page is built from
Components →  the actual component pages, grouped by category
Design     →  DesignSystem tokens + shared UI building blocks
```

A component page depends on `Showcase` and `Design`. It never depends on another component page. The `Catalog` knows about every page but pages do not know about the catalog — navigation is resolved through factories.

## The showcase framework

We deliberately avoid a heavy generic "schema-driven" engine. Each showcase is a normal SwiftUI view holding its own configuration in `@State`. The framework supplies the *consistent scaffolding*, not the content:

- `ShowcaseScreen` — the standard vertical layout: live preview, control panel, state gallery, generated code. Every page composes this.
- **Control building blocks** — labelled wrappers (`ShowcaseToggle`, `ShowcasePicker`, `ShowcaseSlider`, `ShowcaseColorControl`, `ShowcaseStepper`, `ShowcaseTextControl`) that bind to a page's config and render a uniform control panel.
- `StateGallery` — renders the component once per state with a caption.
- `CodeBlock` — monospaced, copyable source with a copy button.

This keeps each showcase honest and idiomatic — what a reader copies is real SwiftUI, not output from an abstraction. It also matches the house preference for boring, readable patterns over clever ones.

## Configuration and code generation

Each showcase owns a small `Config` value type describing its mutable properties. Two things derive from it:

1. The **live preview**, by applying the config to the real component.
2. The **generated code**, via a `generatedCode(for:)` computed string. Plain interpolation — no AST, no formatter dependency. What you see configured is what the string prints.

Because the config is the single source of truth, the preview and the code can never drift apart.

## The catalog and navigation

- `ComponentCategory` — the top-level taxonomy (see [COMPONENT-CATALOG.md](COMPONENT-CATALOG.md)).
- `ShowcaseEntry` — one per component: stable `id`, display title, category, search tags, and a factory closure returning its page.
- Browsing and search read the registry; they do not import component views directly.

Navigation uses the house **coordinator pattern**: an `AppCoordinator` owning per-context navigation state, `Screen` / `Sheet` / `Cover` enums, and factories mapping each case to a view. On iPad and macOS the browser is a `NavigationSplitView` (sidebar + detail); on iPhone and tvOS it is a stack; watchOS uses its own compact list. The app's own navigation is itself meant to be exemplary.

## Platform strategy

One multiplatform app target. Platform differences are handled three ways, in order of preference:

1. **Adaptive layout** — let SwiftUI adapt (e.g. `NavigationSplitView` collapses on iPhone).
2. **Availability gating** — `#if os(...)` / `if #available(...)` around platform-only APIs, always labelled in the UI so the reader knows why something is absent.
3. **Platform-specific variants** — when a component genuinely differs, show each variant rather than hiding the difference.

## Design system

All visual values flow through the `DesignSystem` namespace — `Color`, `Font`, `Spacing`, `CornerRadius`, `Shadow`, `Size`. No hardcoded fonts, colors, spacing, or frame sizes in showcase code. This is enforced by SwiftLint custom rules (see the repo `.swiftlint.yml`).

## A note on the house navigation rules

This project's production-app conventions normally ban `NavigationLink`, `.navigationDestination` in child views, raw `.onTapGesture` navigation, and inline fonts. SwiftUIShowroom's **own shell** follows those rules. But the showroom's *purpose* is to demonstrate native APIs — including the ones production code avoids. So **demo content is exempt**: showcase pages may use any native API directly, with a brief `// swiftlint:disable:next` and a one-line reason where a custom rule would otherwise fire. The exemption is scoped to `Components/` and never applies to the app shell.

## Quality bar

- `swiftlint lint --strict` passes with zero violations.
- Zero compiler warnings.
- Dark Mode, Dynamic Type, Reduce Motion, Reduce Transparency, VoiceOver supported throughout.
- Localization-ready via String Catalogs — no hardcoded user-facing strings in shell code.
