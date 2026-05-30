import SwiftUI

extension ShowcaseRegistry {
    static let effectsEntries: [ShowcaseEntry] = [
        ShowcaseEntry(
            id: "glass-effect",
            title: "Glass Effect",
            category: .effects,
            subtitle: "Applies the Liquid Glass material to",
            keywords: ["effect", "glass", "glasseffect", "in", "view"],
        ) {
            GlassEffectShowcase()
        },
        ShowcaseEntry(
            id: "glass-effect-container",
            title: "Glass Effect Container",
            category: .effects,
            subtitle: "Groups multiple glass shapes so they",
            keywords: ["container", "effect", "glass", "glasseffectcontainer"],
        ) {
            GlassEffectContainerShowcase()
        },
        ShowcaseEntry(
            id: "glass-effect-id-morph",
            title: "Glass Effect ID (Morph)",
            category: .effects,
            subtitle: "Assigns a stable identity to a glass",
            keywords: ["effect", "glass", "glasseffectid", "id", "in", "morph", "view"],
        ) {
            GlassEffectIdMorphShowcase()
        },
        ShowcaseEntry(
            id: "glass-effect-union",
            title: "Glass Effect Union",
            category: .effects,
            subtitle: "Merges several glass shapes sharing",
            keywords: ["effect", "glass", "glasseffectunion", "id", "namespace", "union", "view"],
        ) {
            GlassEffectUnionShowcase()
        },
        ShowcaseEntry(
            id: "glass-effect-transition",
            title: "Glass Effect Transition",
            category: .effects,
            subtitle: "Controls how a glass shape animates",
            keywords: ["effect", "glass", "glasseffecttransition", "transition", "view"],
        ) {
            GlassEffectTransitionShowcase()
        },
        ShowcaseEntry(
            id: "glass-button-style",
            title: "Glass Button Style",
            category: .effects,
            subtitle: "Renders a button with Liquid Glass",
            keywords: ["button", "buttonstyle", "glass", "glassprominent", "style"],
        ) {
            GlassButtonStyleShowcase()
        },
        ShowcaseEntry(
            id: "scroll-edge-effect-style",
            title: "Scroll Edge Effect Style",
            category: .effects,
            subtitle: "Configures the soft/hard blur-fade",
            keywords: ["edge", "effect", "for", "scroll", "scrolledgeeffectstyle", "style", "view"],
        ) {
            ScrollEdgeEffectStyleShowcase()
        },
        ShowcaseEntry(
            id: "scroll-edge-effect-hidden",
            title: "Scroll Edge Effect Hidden",
            category: .effects,
            subtitle: "Hides the scroll edge blur-fade",
            keywords: ["edge", "effect", "for", "hidden", "scroll", "scrolledgeeffecthidden", "view"],
        ) {
            ScrollEdgeEffectHiddenShowcase()
        },
        ShowcaseEntry(
            id: "background-extension-effect",
            title: "Background Extension Effect",
            category: .effects,
            subtitle: "Mirrors and blurs a view into",
            keywords: ["background", "backgroundextensioneffect", "effect", "extension", "isenabled", "view"],
        ) {
            BackgroundExtensionEffectShowcase()
        },
        ShowcaseEntry(
            id: "implicit-animation",
            title: "Implicit Animation (animation:value:)",
            category: .effects,
            subtitle: "Animates view changes implicitly",
            keywords: ["animation", "implicit", "value", "view"],
        ) {
            ImplicitAnimationShowcase()
        },
        ShowcaseEntry(
            id: "with-animation",
            title: "withAnimation",
            category: .effects,
            subtitle: "Explicitly animates state changes",
            keywords: ["animation", "with", "withanimation"],
        ) {
            WithAnimationShowcase()
        },
        ShowcaseEntry(
            id: "spring-bouncy-smooth-snappy",
            title: "Spring Animations (bouncy/smooth/snappy)",
            category: .effects,
            subtitle: "Physically based spring animation",
            keywords: ["animation", "animations", "bouncy", "smooth", "snappy", "spring"],
        ) {
            SpringBouncySmoothSnappyShowcase()
        },
        ShowcaseEntry(
            id: "phase-animator",
            title: "Phase Animator",
            category: .effects,
            subtitle: "Cycles a view through a sequence of",
            keywords: ["animation", "animator", "content", "phase", "phaseanimator", "trigger", "view"],
        ) {
            PhaseAnimatorShowcase()
        },
        ShowcaseEntry(
            id: "keyframe-animator",
            title: "Keyframe Animator",
            category: .effects,
            subtitle: "Drives complex multi-track animations",
            keywords: [
                "animator",
                "content",
                "initialvalue",
                "keyframe",
                "keyframeanimator",
                "keyframes",
                "trigger",
                "view",
            ],
        ) {
            KeyframeAnimatorShowcase()
        },
        ShowcaseEntry(
            id: "transition",
            title: "Transition",
            category: .effects,
            subtitle: "Animates how a view is inserted into",
            keywords: ["anytransition", "transition", "view"],
        ) {
            TransitionShowcase()
        },
        ShowcaseEntry(
            id: "asymmetric-transition",
            title: "Asymmetric Transition",
            category: .effects,
            subtitle: "Uses different transitions for view",
            keywords: ["anytransition", "asymmetric", "insertion", "removal", "transition"],
        ) {
            AsymmetricTransitionShowcase()
        },
        ShowcaseEntry(
            id: "matched-geometry-effect",
            title: "Matched Geometry Effect",
            category: .effects,
            subtitle: "Animates a view morphing between two",
            keywords: ["anchor", "effect", "geometry", "id", "in", "issource", "matched", "matchedgeometryeffect"],
        ) {
            MatchedGeometryEffectShowcase()
        },
        ShowcaseEntry(
            id: "custom-transition",
            title: "Custom Transition",
            category: .effects,
            subtitle: "A user-defined transition",
            keywords: ["custom", "protocol", "transition"],
        ) {
            CustomTransitionShowcase()
        },
        ShowcaseEntry(
            id: "symbol-effects-removed",
            title: "Symbol Effects Removed",
            category: .effects,
            subtitle: "Removes inherited symbol effects from",
            keywords: ["effects", "removed", "symbol", "symboleffectsremoved", "view"],
        ) {
            SymbolEffectsRemovedShowcase()
        },
        ShowcaseEntry(
            id: "content-transition",
            title: "Content Transition",
            category: .effects,
            subtitle: "Animates content changes in place",
            keywords: ["content", "contenttransition", "transition", "view"],
        ) {
            ContentTransitionShowcase()
        },
        ShowcaseEntry(
            id: "material-background",
            title: "Material Background",
            category: .effects,
            subtitle: "Applies a system blur material as a",
            keywords: ["background", "material", "shapestyle", "ultrathinmaterial"],
        ) {
            MaterialBackgroundShowcase()
        },
        ShowcaseEntry(
            id: "color-filter-effects",
            title: "Color Filter Effects",
            category: .effects,
            subtitle: "Per-pixel color adjustment filters",
            keywords: [
                "brightness",
                "color",
                "colormultiply",
                "contrast",
                "effects",
                "filter",
                "grayscale",
                "huerotation",
            ],
        ) {
            ColorFilterEffectsShowcase()
        },
        ShowcaseEntry(
            id: "shader-effect",
            title: "Metal Shader Effect",
            category: .effects,
            subtitle: "Applies a custom Metal stitchable",
            keywords: ["coloreffect", "distortioneffect", "effect", "layereffect", "metal", "shader", "view"],
        ) {
            ShaderEffectShowcase()
        },
        ShowcaseEntry(
            id: "scroll-transition",
            title: "Scroll Transition",
            category: .effects,
            subtitle: "Applies visual effects to a view as a",
            keywords: ["axis", "scroll", "scrolltransition", "transition", "view"],
        ) {
            ScrollTransitionShowcase()
        },
        ShowcaseEntry(
            id: "geometry-visual-effect",
            title: "Geometry-Driven Visual Effect",
            category: .effects,
            subtitle: "Applies visual effects (offset,",
            keywords: ["driven", "effect", "geometry", "view", "visual", "visualeffect"],
        ) {
            GeometryVisualEffectShowcase()
        },
        ShowcaseEntry(
            id: "safe-area-bar",
            title: "Safe Area Bar",
            category: .effects,
            subtitle: "Places a floating bar of content",
            keywords: ["alignment", "area", "bar", "content", "edge", "safe", "safeareabar", "spacing"],
        ) {
            SafeAreaBarShowcase()
        },
    ]
}
