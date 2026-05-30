import SwiftUI

extension ShowcaseRegistry {
    static let modifiersEntries: [ShowcaseEntry] = [
        ShowcaseEntry(
            id: "frame-fixed",
            title: "Frame (Fixed Size)",
            category: .modifiers,
            subtitle: "Proposes a fixed width and/or height",
            keywords: ["alignment", "fixed", "frame", "height", "size", "view", "width"],
        ) {
            FrameFixedShowcase()
        },
        ShowcaseEntry(
            id: "frame-flexible",
            title: "Frame (Flexible / Min-Ideal-Max)",
            category: .modifiers,
            subtitle: "Constrains a view between minimum,",
            keywords: ["alignment", "flexible", "frame", "ideal", "idealheight", "idealwidth", "max", "maxheight"],
        ) {
            FrameFlexibleShowcase()
        },
        ShowcaseEntry(
            id: "padding",
            title: "Padding",
            category: .modifiers,
            subtitle: "Adds space around the view along the",
            keywords: ["padding", "view"],
        ) {
            PaddingShowcase()
        },
        ShowcaseEntry(
            id: "offset",
            title: "Offset",
            category: .modifiers,
            subtitle: "Shifts the view's rendered position",
            keywords: ["offset", "view", "x", "y"],
        ) {
            OffsetShowcase()
        },
        ShowcaseEntry(
            id: "position",
            title: "Position",
            category: .modifiers,
            subtitle: "Centers the view at an absolute point",
            keywords: ["position", "view", "x", "y"],
        ) {
            PositionShowcase()
        },
        ShowcaseEntry(
            id: "fixed-size",
            title: "Fixed Size",
            category: .modifiers,
            subtitle: "Fixes the view at its ideal size on",
            keywords: ["fixed", "fixedsize", "horizontal", "size", "vertical", "view"],
        ) {
            FixedSizeShowcase()
        },
        ShowcaseEntry(
            id: "layout-priority",
            title: "Layout Priority",
            category: .modifiers,
            subtitle: "Sets the relative priority a view has",
            keywords: ["layout", "layoutpriority", "priority", "view"],
        ) {
            LayoutPriorityShowcase()
        },
        ShowcaseEntry(
            id: "alignment-guide",
            title: "Alignment Guide",
            category: .modifiers,
            subtitle: "Overrides how a view reports its",
            keywords: ["alignment", "alignmentguide", "computevalue", "guide", "view"],
        ) {
            AlignmentGuideShowcase()
        },
        ShowcaseEntry(
            id: "safe-area-inset",
            title: "Safe Area Inset",
            category: .modifiers,
            subtitle: "Insets the view's safe area by an",
            keywords: ["alignment", "area", "content", "edge", "inset", "safe", "safeareainset", "spacing"],
        ) {
            SafeAreaInsetShowcase()
        },
        ShowcaseEntry(
            id: "safe-area-padding",
            title: "Safe Area Padding",
            category: .modifiers,
            subtitle: "Extends the safe area by a fixed",
            keywords: ["area", "padding", "safe", "safeareapadding", "view"],
        ) {
            SafeAreaPaddingShowcase()
        },
        ShowcaseEntry(
            id: "container-relative-frame",
            title: "Container Relative Frame",
            category: .modifiers,
            subtitle: "Sizes a view relative to its nearest",
            keywords: ["alignment", "container", "containerrelativeframe", "frame", "relative", "view"],
        ) {
            ContainerRelativeFrameShowcase()
        },
        ShowcaseEntry(
            id: "ignores-safe-area",
            title: "Ignores Safe Area",
            category: .modifiers,
            subtitle: "Lets the view extend under the safe",
            keywords: ["area", "edges", "ignores", "ignoressafearea", "safe", "view"],
        ) {
            IgnoresSafeAreaShowcase()
        },
        ShowcaseEntry(
            id: "foreground-style",
            title: "Foreground Style",
            category: .modifiers,
            subtitle: "Sets the style (color, hierarchical",
            keywords: ["foreground", "foregroundstyle", "style", "view"],
        ) {
            ForegroundStyleShowcase()
        },
        ShowcaseEntry(
            id: "background",
            title: "Background",
            category: .modifiers,
            subtitle: "Layers a style or view behind the",
            keywords: ["alignment", "background", "content", "fillstyle", "in", "view"],
        ) {
            BackgroundShowcase()
        },
        ShowcaseEntry(
            id: "overlay",
            title: "Overlay",
            category: .modifiers,
            subtitle: "Layers a style or view in front of",
            keywords: ["alignment", "content", "fillstyle", "in", "overlay", "view"],
        ) {
            OverlayShowcase()
        },
        ShowcaseEntry(
            id: "border",
            title: "Border",
            category: .modifiers,
            subtitle: "Draws a rectangular border of the",
            keywords: ["border", "view", "width"],
        ) {
            BorderShowcase()
        },
        ShowcaseEntry(
            id: "clip-shape",
            title: "Clip Shape",
            category: .modifiers,
            subtitle: "Clips the view to the outline of any",
            keywords: ["clip", "clipshape", "shape", "style", "view"],
        ) {
            ClipShapeShowcase()
        },
        ShowcaseEntry(
            id: "clipped",
            title: "Clipped",
            category: .modifiers,
            subtitle: "Clips the view to its own bounding",
            keywords: ["antialiased", "clipped", "view"],
        ) {
            ClippedShowcase()
        },
        ShowcaseEntry(
            id: "corner-radius",
            title: "Corner Radius (Deprecated)",
            category: .modifiers,
            subtitle: "Clips the view to a rounded rectangle",
            keywords: ["antialiased", "corner", "cornerradius", "deprecated", "radius", "view"],
        ) {
            CornerRadiusShowcase()
        },
        ShowcaseEntry(
            id: "mask",
            title: "Mask",
            category: .modifiers,
            subtitle: "Uses the alpha channel of a mask view",
            keywords: ["alignment", "mask", "view"],
        ) {
            MaskShowcase()
        },
        ShowcaseEntry(
            id: "shadow",
            title: "Shadow",
            category: .modifiers,
            subtitle: "Draws a drop shadow behind the view",
            keywords: ["color", "radius", "shadow", "view", "x", "y"],
        ) {
            ShadowShowcase()
        },
        ShowcaseEntry(
            id: "opacity",
            title: "Opacity",
            category: .modifiers,
            subtitle: "Sets the transparency of the view and",
            keywords: ["opacity", "view"],
        ) {
            OpacityShowcase()
        },
        ShowcaseEntry(
            id: "tint",
            title: "Tint",
            category: .modifiers,
            subtitle: "Overrides the accent color for",
            keywords: ["tint", "view"],
        ) {
            TintShowcase()
        },
        ShowcaseEntry(
            id: "rotation-effect",
            title: "Rotation Effect (2D)",
            category: .modifiers,
            subtitle: "Rotates the view in 2D by an angle",
            keywords: ["2d", "anchor", "effect", "rotation", "rotationeffect", "view"],
        ) {
            RotationEffectShowcase()
        },
        ShowcaseEntry(
            id: "scale-effect",
            title: "Scale Effect",
            category: .modifiers,
            subtitle: "Scales the view by independent x/y",
            keywords: ["anchor", "effect", "scale", "scaleeffect", "view"],
        ) {
            ScaleEffectShowcase()
        },
        ShowcaseEntry(
            id: "rotation-3d-effect",
            title: "Rotation 3D Effect",
            category: .modifiers,
            subtitle: "Rotates the view in 3D around an",
            keywords: ["3d", "anchor", "anchorz", "axis", "effect", "perspective", "rotation", "rotation3deffect"],
        ) {
            Rotation3dEffectShowcase()
        },
        ShowcaseEntry(
            id: "projection-effect",
            title: "Projection Effect",
            category: .modifiers,
            subtitle: "Applies an arbitrary 3D",
            keywords: ["effect", "projection", "projectioneffect", "view"],
        ) {
            ProjectionEffectShowcase()
        },
        ShowcaseEntry(
            id: "transform-effect",
            title: "Transform Effect (2D Affine)",
            category: .modifiers,
            subtitle: "Applies a 2D affine transform",
            keywords: ["2d", "affine", "effect", "transform", "transformeffect", "view"],
        ) {
            TransformEffectShowcase()
        },
        ShowcaseEntry(
            id: "blur",
            title: "Blur",
            category: .modifiers,
            subtitle: "Applies a Gaussian blur to the view's",
            keywords: ["blur", "opaque", "radius", "view"],
        ) {
            BlurShowcase()
        },
        ShowcaseEntry(
            id: "brightness",
            title: "Brightness",
            category: .modifiers,
            subtitle: "Adds a constant to each color",
            keywords: ["brightness", "view"],
        ) {
            BrightnessShowcase()
        },
        ShowcaseEntry(
            id: "contrast",
            title: "Contrast",
            category: .modifiers,
            subtitle: "Multiplies the color separation from",
            keywords: ["contrast", "view"],
        ) {
            ContrastShowcase()
        },
        ShowcaseEntry(
            id: "saturation",
            title: "Saturation",
            category: .modifiers,
            subtitle: "Adjusts color intensity; 0 produces",
            keywords: ["saturation", "view"],
        ) {
            SaturationShowcase()
        },
        ShowcaseEntry(
            id: "grayscale",
            title: "Grayscale",
            category: .modifiers,
            subtitle: "Desaturates the view toward gray by",
            keywords: ["grayscale", "view"],
        ) {
            GrayscaleShowcase()
        },
        ShowcaseEntry(
            id: "color-invert",
            title: "Color Invert",
            category: .modifiers,
            subtitle: "Inverts each color channel of the",
            keywords: ["color", "colorinvert", "invert", "view"],
        ) {
            ColorInvertShowcase()
        },
        ShowcaseEntry(
            id: "color-multiply",
            title: "Color Multiply",
            category: .modifiers,
            subtitle: "Multiplies the view's colors by a",
            keywords: ["color", "colormultiply", "multiply", "view"],
        ) {
            ColorMultiplyShowcase()
        },
        ShowcaseEntry(
            id: "hue-rotation",
            title: "Hue Rotation",
            category: .modifiers,
            subtitle: "Shifts every color's hue around the",
            keywords: ["hue", "huerotation", "rotation", "view"],
        ) {
            HueRotationShowcase()
        },
        ShowcaseEntry(
            id: "blend-mode",
            title: "Blend Mode",
            category: .modifiers,
            subtitle: "Sets how the view composites with the",
            keywords: ["blend", "blendmode", "mode", "view"],
        ) {
            BlendModeShowcase()
        },
        ShowcaseEntry(
            id: "compositing-group",
            title: "Compositing Group",
            category: .modifiers,
            subtitle: "Renders the view and its children as",
            keywords: ["compositing", "compositinggroup", "group", "view"],
        ) {
            CompositingGroupShowcase()
        },
        ShowcaseEntry(
            id: "drawing-group",
            title: "Drawing Group (Metal)",
            category: .modifiers,
            subtitle: "Flattens the view into an offscreen",
            keywords: ["colormode", "drawing", "drawinggroup", "group", "metal", "opaque", "view"],
        ) {
            DrawingGroupShowcase()
        },
        ShowcaseEntry(
            id: "disabled",
            title: "Disabled",
            category: .modifiers,
            subtitle: "Disables user interaction for the",
            keywords: ["disabled", "view"],
        ) {
            DisabledShowcase()
        },
        ShowcaseEntry(
            id: "allows-hit-testing",
            title: "Allows Hit Testing",
            category: .modifiers,
            subtitle: "Controls whether the view",
            keywords: ["allows", "allowshittesting", "hit", "testing", "view"],
        ) {
            AllowsHitTestingShowcase()
        },
        ShowcaseEntry(
            id: "content-shape",
            title: "Content Shape",
            category: .modifiers,
            subtitle: "Defines the hit-testing (and",
            keywords: ["content", "contentshape", "eofill", "shape", "view"],
        ) {
            ContentShapeShowcase()
        },
        ShowcaseEntry(
            id: "z-index",
            title: "Z-Index",
            category: .modifiers,
            subtitle: "Sets the front-to-back stacking order",
            keywords: ["index", "view", "z", "zindex"],
        ) {
            ZIndexShowcase()
        },
        ShowcaseEntry(
            id: "aspect-ratio",
            title: "Aspect Ratio",
            category: .modifiers,
            subtitle: "Constrains the view's dimensions to a",
            keywords: ["aspect", "aspectratio", "contentmode", "ratio", "view"],
        ) {
            AspectRatioShowcase()
        },
        ShowcaseEntry(
            id: "scaled-to-fit-fill",
            title: "Scaled To Fit / Fill",
            category: .modifiers,
            subtitle: "Scales the view to fit inside (or",
            keywords: ["fill", "fit", "scaled", "scaledtofill", "scaledtofit", "to", "view"],
        ) {
            ScaledToFitFillShowcase()
        },
        ShowcaseEntry(
            id: "redacted",
            title: "Redacted",
            category: .modifiers,
            subtitle: "Applies a redaction (such as a",
            keywords: ["reason", "redacted", "unredacted", "view"],
        ) {
            RedactedShowcase()
        },
        ShowcaseEntry(
            id: "hidden",
            title: "Hidden",
            category: .modifiers,
            subtitle: "Hides the view unconditionally while",
            keywords: ["hidden", "view"],
        ) {
            HiddenShowcase()
        },
    ]
}
