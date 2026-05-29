import SwiftUI

extension ShowcaseRegistry {
    static let chartsEntries: [ShowcaseEntry] = [
        ShowcaseEntry(
            id: "chart-container",
            title: "Chart",
            category: .charts,
            subtitle: "The SwiftUI view that hosts marks and",
            keywords: ["chart", "container"],
        ) {
            ChartContainerShowcase()
        },
        ShowcaseEntry(
            id: "bar-mark",
            title: "BarMark",
            category: .charts,
            subtitle: "Represents data as rectangular bars;",
            keywords: ["bar", "barmark", "mark"],
        ) {
            BarMarkShowcase()
        },
        ShowcaseEntry(
            id: "line-mark",
            title: "LineMark",
            category: .charts,
            subtitle: "Connects data points with line",
            keywords: ["line", "linemark", "mark"],
        ) {
            LineMarkShowcase()
        },
        ShowcaseEntry(
            id: "area-mark",
            title: "AreaMark",
            category: .charts,
            subtitle: "Fills the region under a line or",
            keywords: ["area", "areamark", "mark"],
        ) {
            AreaMarkShowcase()
        },
        ShowcaseEntry(
            id: "point-mark",
            title: "PointMark",
            category: .charts,
            subtitle: "Plots individual data points as",
            keywords: ["mark", "point", "pointmark"],
        ) {
            PointMarkShowcase()
        },
        ShowcaseEntry(
            id: "rule-mark",
            title: "RuleMark",
            category: .charts,
            subtitle: "Draws a horizontal or vertical",
            keywords: ["mark", "rule", "rulemark"],
        ) {
            RuleMarkShowcase()
        },
        ShowcaseEntry(
            id: "rectangle-mark",
            title: "RectangleMark",
            category: .charts,
            subtitle: "Fills rectangular cells defined by",
            keywords: ["mark", "rectangle", "rectanglemark"],
        ) {
            RectangleMarkShowcase()
        },
        ShowcaseEntry(
            id: "sector-mark",
            title: "SectorMark",
            category: .charts,
            subtitle: "Renders a pie or donut sector sized",
            keywords: ["mark", "sector", "sectormark"],
        ) {
            SectorMarkShowcase()
        },
        ShowcaseEntry(
            id: "bar-plot",
            title: "BarPlot (vectorized)",
            category: .charts,
            subtitle: "Vectorized bar content that plots an",
            keywords: ["bar", "barplot", "plot", "vectorized"],
        ) {
            BarPlotShowcase()
        },
        ShowcaseEntry(
            id: "line-plot",
            title: "LinePlot (vectorized / function)",
            category: .charts,
            subtitle: "Vectorized line content for whole",
            keywords: ["function", "line", "lineplot", "plot", "vectorized"],
        ) {
            LinePlotShowcase()
        },
        ShowcaseEntry(
            id: "area-plot",
            title: "AreaPlot (vectorized / function)",
            category: .charts,
            subtitle: "Vectorized area content for whole",
            keywords: ["area", "areaplot", "function", "plot", "vectorized"],
        ) {
            AreaPlotShowcase()
        },
        ShowcaseEntry(
            id: "point-plot",
            title: "PointPlot (vectorized)",
            category: .charts,
            subtitle: "Vectorized point content for plotting",
            keywords: ["plot", "point", "pointplot", "vectorized"],
        ) {
            PointPlotShowcase()
        },
        ShowcaseEntry(
            id: "sector-plot",
            title: "SectorPlot (vectorized)",
            category: .charts,
            subtitle: "Vectorized sector content that",
            keywords: ["plot", "sector", "sectorplot", "vectorized"],
        ) {
            SectorPlotShowcase()
        },
        ShowcaseEntry(
            id: "rule-rectangle-plot",
            title: "RulePlot & RectanglePlot (vectorized)",
            category: .charts,
            subtitle: "Vectorized rule and rectangle content",
            keywords: ["plot", "rectangle", "rectangleplot", "rule", "ruleplot", "vectorized"],
        ) {
            RuleRectanglePlotShowcase()
        },
        ShowcaseEntry(
            id: "chart3d",
            title: "Chart3D",
            category: .charts,
            subtitle: "A three-dimensional chart container",
            keywords: ["chart3d"],
        ) {
            Chart3dShowcase()
        },
        ShowcaseEntry(
            id: "chart-axis-customization",
            title: "Axis Customization",
            category: .charts,
            subtitle: "Customizes axis ticks, grid lines,",
            keywords: ["axis", "axismarks", "chart", "customization"],
        ) {
            ChartAxisCustomizationShowcase()
        },
        ShowcaseEntry(
            id: "chart-scales",
            title: "Scales & Domains",
            category: .charts,
            subtitle: "Controls the mapping from data to",
            keywords: ["chart", "chartxscale", "domains", "scales"],
        ) {
            ChartScalesShowcase()
        },
        ShowcaseEntry(
            id: "chart-foreground-style-scale",
            title: "Foreground Style Scale & Legend Grouping",
            category: .charts,
            subtitle: "Maps categorical or continuous data",
            keywords: ["chart", "chartforegroundstylescale", "foreground", "grouping", "legend", "scale", "style"],
        ) {
            ChartForegroundStyleScaleShowcase()
        },
        ShowcaseEntry(
            id: "chart-selection",
            title: "Chart Selection & Scrolling Annotations",
            category: .charts,
            subtitle: "Adds interactive value selection",
            keywords: ["annotations", "chart", "chartxselection", "scrolling", "selection"],
        ) {
            ChartSelectionShowcase()
        },
        ShowcaseEntry(
            id: "surface-plot",
            title: "SurfacePlot (3D surface)",
            category: .charts,
            subtitle: "3D-only chart content that renders a",
            keywords: ["3d", "plot", "surface", "surfaceplot"],
        ) {
            SurfacePlotShowcase()
        },
        ShowcaseEntry(
            id: "chart-overlay-background",
            title: "Chart Overlay & Background (ChartProxy)",
            category: .charts,
            subtitle: "Overlays or backs the plot area with",
            keywords: ["background", "chart", "chartoverlay", "chartproxy", "overlay"],
        ) {
            ChartOverlayBackgroundShowcase()
        },
    ]
}
