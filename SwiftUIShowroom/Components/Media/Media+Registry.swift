import SwiftUI

extension ShowcaseRegistry {
    static let mediaEntries: [ShowcaseEntry] = [
        ShowcaseEntry(
            id: "image",
            title: "Image",
            category: .media,
            subtitle: "Displays a bitmap, asset, system",
            keywords: ["image"],
        ) {
            ImageShowcase()
        },
        ShowcaseEntry(
            id: "sf-symbol",
            title: "SF Symbol Image",
            category: .media,
            subtitle: "Renders an SF Symbol with rendering",
            keywords: ["image", "sf", "symbol", "systemname"],
        ) {
            SfSymbolShowcase()
        },
        ShowcaseEntry(
            id: "symbol-effect",
            title: "Symbol Effect",
            category: .media,
            subtitle: "Animates an SF Symbol with bounce,",
            keywords: ["effect", "isactive", "options", "symbol", "symboleffect", "view"],
        ) {
            SymbolEffectShowcase()
        },
        ShowcaseEntry(
            id: "async-image",
            title: "AsyncImage",
            category: .media,
            subtitle: "Asynchronously loads and displays a",
            keywords: ["async", "asyncimage", "image"],
        ) {
            AsyncImageShowcase()
        },
        ShowcaseEntry(
            id: "rectangle",
            title: "Rectangle",
            category: .media,
            subtitle: "A rectangular shape filling its",
            keywords: ["rectangle"],
        ) {
            RectangleShowcase()
        },
        ShowcaseEntry(
            id: "rounded-rectangle",
            title: "RoundedRectangle",
            category: .media,
            subtitle: "A rectangle with rounded corners,",
            keywords: ["rectangle", "rounded", "roundedrectangle"],
        ) {
            RoundedRectangleShowcase()
        },
        ShowcaseEntry(
            id: "unevenrounded-rectangle",
            title: "UnevenRoundedRectangle",
            category: .media,
            subtitle: "A rectangle with independently",
            keywords: ["rectangle", "unevenrounded", "unevenroundedrectangle"],
        ) {
            UnevenroundedRectangleShowcase()
        },
        ShowcaseEntry(
            id: "capsule",
            title: "Capsule",
            category: .media,
            subtitle: "A pill shape — a rectangle whose",
            keywords: ["capsule"],
        ) {
            CapsuleShowcase()
        },
        ShowcaseEntry(
            id: "circle",
            title: "Circle",
            category: .media,
            subtitle: "A circle inscribed in its frame,",
            keywords: ["circle"],
        ) {
            CircleShowcase()
        },
        ShowcaseEntry(
            id: "ellipse",
            title: "Ellipse",
            category: .media,
            subtitle: "An ellipse inscribed in its frame,",
            keywords: ["ellipse"],
        ) {
            EllipseShowcase()
        },
        ShowcaseEntry(
            id: "path",
            title: "Path",
            category: .media,
            subtitle: "A custom 2D outline built from",
            keywords: ["path"],
        ) {
            PathShowcase()
        },
        ShowcaseEntry(
            id: "canvas",
            title: "Canvas",
            category: .media,
            subtitle: "Immediate-mode 2D drawing surface",
            keywords: ["canvas"],
        ) {
            CanvasShowcase()
        },
        ShowcaseEntry(
            id: "linear-gradient",
            title: "LinearGradient",
            category: .media,
            subtitle: "A gradient that interpolates colors",
            keywords: ["gradient", "linear", "lineargradient"],
        ) {
            LinearGradientShowcase()
        },
        ShowcaseEntry(
            id: "radial-gradient",
            title: "RadialGradient",
            category: .media,
            subtitle: "A gradient that interpolates colors",
            keywords: ["gradient", "radial", "radialgradient"],
        ) {
            RadialGradientShowcase()
        },
        ShowcaseEntry(
            id: "angular-gradient",
            title: "AngularGradient",
            category: .media,
            subtitle: "A gradient that sweeps colors around",
            keywords: ["angular", "angulargradient", "gradient"],
        ) {
            AngularGradientShowcase()
        },
        ShowcaseEntry(
            id: "elliptical-gradient",
            title: "EllipticalGradient",
            category: .media,
            subtitle: "A radial-style gradient whose rings",
            keywords: ["elliptical", "ellipticalgradient", "gradient"],
        ) {
            EllipticalGradientShowcase()
        },
        ShowcaseEntry(
            id: "mesh-gradient",
            title: "MeshGradient",
            category: .media,
            subtitle: "A 2D grid of positioned colors",
            keywords: ["gradient", "mesh", "meshgradient"],
        ) {
            MeshGradientShowcase()
        },
        ShowcaseEntry(
            id: "material",
            title: "Material (Blur)",
            category: .media,
            subtitle: "A translucent blur backdrop",
            keywords: ["blur", "material"],
        ) {
            MaterialShowcase()
        },
        ShowcaseEntry(
            id: "container-relative-shape",
            title: "ContainerRelativeShape",
            category: .media,
            subtitle: "An adaptive shape that inherits its",
            keywords: ["container", "containerrelativeshape", "relative", "shape"],
        ) {
            ContainerRelativeShapeShowcase()
        },
        ShowcaseEntry(
            id: "video-player",
            title: "VideoPlayer",
            category: .media,
            subtitle: "VideoPlayer (AVKit) embeds an",
            keywords: ["player", "video", "videoplayer"],
        ) {
            VideoPlayerShowcase()
        },
        ShowcaseEntry(
            id: "color-view",
            title: "Color (as View)",
            category: .media,
            subtitle: "SwiftUI treats Color as a View, so it",
            keywords: ["as", "color", "view"],
        ) {
            ColorViewShowcase()
        },
    ]
}
