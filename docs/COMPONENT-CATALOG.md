# Component catalog

The full coverage map. Every box is a planned showcase; checked boxes are built. This is the contract for "all native components" — if something native is missing here, open an issue.

Legend: `[ ]` planned · `[~]` in progress · `[x]` shipped.

## 1. Text and labels

- [ ] Text — weight, design, style, color, line limit, truncation, multiline alignment, markdown
- [ ] Label — title + icon, label styles (titleAndIcon, titleOnly, iconOnly)
- [ ] TextField — styles, axis (multiline), prompt, formatting, submit label
- [ ] SecureField
- [ ] TextEditor — styling, find/replace
- [ ] Link / shareLink
- [ ] AttributedString rendering

## 2. Buttons and actions

- [ ] Button — roles (.destructive, .cancel), button styles (.bordered, .borderedProminent, .plain, .glass), control size, tint
- [ ] Menu — primary action, sections, nested menus, menu styles
- [ ] Toggle — switch / button / checkbox styles, tint
- [ ] Stepper
- [ ] EditButton / RenameButton / PasteButton
- [ ] ControlGroup

## 3. Selection and input

- [ ] Picker — automatic, inline, menu, segmented, wheel, palette, navigationLink styles
- [ ] DatePicker — compact, graphical, wheel; date / time / both; ranges
- [ ] MultiDatePicker
- [ ] ColorPicker — opacity on/off
- [ ] Slider — range, step, min/max labels
- [ ] Gauge — styles (accessoryCircular, linearCapacity, etc.)
- [ ] ProgressView — linear, circular, determinate / indeterminate

## 4. Containers and layout

- [ ] Stacks — HStack, VStack, ZStack, alignment, spacing
- [ ] LazyVStack / LazyHStack — pinned headers
- [ ] Grid / GridRow
- [ ] LazyVGrid / LazyHGrid — adaptive / fixed / flexible columns
- [ ] ScrollView — axes, indicators, scroll position, scroll targets, paging
- [ ] List — styles (plain, grouped, inset, sidebar), selection, swipe actions, edit mode, sections
- [ ] Form — sections, grouped layout
- [ ] Table — columns, sorting, selection (iPad / Mac)
- [ ] Section — header / footer, collapsible
- [ ] GroupBox / DisclosureGroup
- [ ] ViewThatFits
- [ ] Spacer / Divider

## 5. Navigation

- [ ] NavigationStack — path binding, programmatic navigation, navigationDestination
- [ ] NavigationSplitView — two / three column, column visibility, balanced / prominent styles
- [ ] NavigationLink — value-based and destination-based
- [ ] TabView — tabs, sidebar adaptable, page style with index dots
- [ ] Toolbar — placements, ToolbarItemGroup, ToolbarSpacer, principal / bottom bars
- [ ] searchable — suggestions, scopes, tokens
- [ ] Navigation bar title display modes

## 6. Presentation

- [ ] sheet — detents, drag indicator, presentation background, corner radius, interactive dismiss
- [ ] fullScreenCover
- [ ] popover — arrow edge, adaptive presentation
- [ ] alert — buttons, roles, text field in alert
- [ ] confirmationDialog
- [ ] inspector (iPad / Mac)
- [ ] fileImporter / fileExporter / photosPicker

## 7. Media and shapes

- [ ] Image — resizable, scaledToFit/Fill, symbolRenderingMode, variableValue
- [ ] SF Symbols — rendering modes, symbol effects (bounce, pulse, variableColor, wiggle)
- [ ] AsyncImage — phases, placeholder
- [ ] Shapes — Rectangle, RoundedRectangle, Capsule, Circle, Ellipse, custom Path
- [ ] Canvas — immediate-mode drawing
- [ ] Gradients — linear, radial, angular, mesh
- [ ] Materials — ultraThin → thick, regular

## 8. Indicators and feedback

- [ ] ContentUnavailableView — search variant, custom
- [ ] ProgressView / Gauge (cross-referenced)
- [ ] Redaction — placeholder / privacy, skeleton loading
- [ ] Haptics — sensoryFeedback

## 9. Modifiers reference

- [ ] Layout — frame, padding, offset, position, fixedSize, layoutPriority, alignmentGuide
- [ ] Appearance — foregroundStyle, background, overlay, border, clipShape, cornerRadius, mask, shadow, opacity
- [ ] Transforms — rotationEffect, scaleEffect, rotation3DEffect, projectionEffect
- [ ] Effects — blur, brightness, contrast, saturation, colorMultiply, blendMode, hueRotation
- [ ] Behaviour — disabled, allowsHitTesting, contentShape, zIndex
- [ ] safeAreaInset, ignoresSafeArea, containerRelativeFrame

## 10. Effects and styling (iOS 26)

- [ ] Liquid Glass — glassEffect, GlassEffectContainer, glass button styles, morphing transitions
- [ ] scrollEdgeEffectStyle / backgroundExtensionEffect
- [ ] Animations — implicit, explicit withAnimation, spring / bouncy / smooth, phaseAnimator, keyframeAnimator
- [ ] Transitions — opacity, slide, scale, move, asymmetric, matchedGeometryEffect, custom
- [ ] Symbol effects

## 11. Accessibility

- [ ] accessibilityLabel / Value / Hint / Traits
- [ ] Dynamic Type — sizeCategory, ScaledMetric
- [ ] accessibilityElement / children / combine
- [ ] Custom rotors and accessibility actions
- [ ] accessibilityFocus, Reduce Motion, Reduce Transparency, Increase Contrast

## 12. Charts (Swift Charts)

- [ ] BarMark / LineMark / AreaMark / PointMark / RuleMark / RectangleMark
- [ ] SectorMark (pie / donut)
- [ ] Axis customization, scales, legends, foregroundStyle grouping
- [ ] Chart selection, scrolling, annotations

## 13. Gestures

- [ ] TapGesture / LongPressGesture
- [ ] DragGesture
- [ ] MagnifyGesture / RotateGesture
- [ ] Gesture composition — simultaneously, sequenced, exclusively

## 14. Environment and data flow (reference)

- [ ] State / Binding / @Observable / Environment / @Bindable
- [ ] AppStorage / SceneStorage
- [ ] preferenceKey, environment values, focusState
