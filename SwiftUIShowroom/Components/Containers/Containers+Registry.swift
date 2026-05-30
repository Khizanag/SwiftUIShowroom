import SwiftUI

extension ShowcaseRegistry {
    static let containersEntries: [ShowcaseEntry] = [
        ShowcaseEntry(
            id: "hstack",
            title: "HStack",
            category: .containers,
            subtitle: "A view that arranges its subviews in",
            keywords: ["hstack"],
        ) {
            HstackShowcase()
        },
        ShowcaseEntry(
            id: "vstack",
            title: "VStack",
            category: .containers,
            subtitle: "A view that arranges its subviews in",
            keywords: ["vstack"],
        ) {
            VstackShowcase()
        },
        ShowcaseEntry(
            id: "zstack",
            title: "ZStack",
            category: .containers,
            subtitle: "A view that overlays its subviews,",
            keywords: ["zstack"],
        ) {
            ZstackShowcase()
        },
        ShowcaseEntry(
            id: "lazyvstack",
            title: "LazyVStack",
            category: .containers,
            subtitle: "A vertical stack that lazily creates",
            keywords: ["lazyvstack"],
        ) {
            LazyvstackShowcase()
        },
        ShowcaseEntry(
            id: "lazyhstack",
            title: "LazyHStack",
            category: .containers,
            subtitle: "A horizontal stack that lazily",
            keywords: ["lazyhstack"],
        ) {
            LazyhstackShowcase()
        },
        ShowcaseEntry(
            id: "grid",
            title: "Grid",
            category: .containers,
            subtitle: "A container that arranges other views",
            keywords: ["grid"],
        ) {
            GridShowcase()
        },
        ShowcaseEntry(
            id: "grid-row",
            title: "GridRow",
            category: .containers,
            subtitle: "A horizontal row in a two-dimensional",
            keywords: ["grid", "gridrow", "row"],
        ) {
            GridRowShowcase()
        },
        ShowcaseEntry(
            id: "lazyvgrid",
            title: "LazyVGrid",
            category: .containers,
            subtitle: "A grid that grows vertically, lazily",
            keywords: ["lazyvgrid"],
        ) {
            LazyvgridShowcase()
        },
        ShowcaseEntry(
            id: "lazyhgrid",
            title: "LazyHGrid",
            category: .containers,
            subtitle: "A grid that grows horizontally,",
            keywords: ["lazyhgrid"],
        ) {
            LazyhgridShowcase()
        },
        ShowcaseEntry(
            id: "grid-item",
            title: "GridItem",
            category: .containers,
            subtitle: "A description of a single column (or",
            keywords: ["grid", "griditem", "item"],
        ) {
            GridItemShowcase()
        },
        ShowcaseEntry(
            id: "scrollview",
            title: "ScrollView",
            category: .containers,
            subtitle: "A scrollable container that lets",
            keywords: ["scrollview"],
        ) {
            ScrollviewShowcase()
        },
        ShowcaseEntry(
            id: "scrollview-reader",
            title: "ScrollViewReader",
            category: .containers,
            subtitle: "A view that provides programmatic",
            keywords: ["reader", "scrollview", "scrollviewreader"],
        ) {
            ScrollviewReaderShowcase()
        },
        ShowcaseEntry(
            id: "list",
            title: "List",
            category: .containers,
            subtitle: "A container that presents rows of",
            keywords: ["list"],
        ) {
            ListShowcase()
        },
        ShowcaseEntry(
            id: "table",
            title: "Table",
            category: .containers,
            subtitle: "A container presenting rows of data",
            keywords: ["table"],
        ) {
            TableShowcase()
        },
        ShowcaseEntry(
            id: "table-column",
            title: "TableColumn",
            category: .containers,
            subtitle: "A column that displays a value or",
            keywords: ["column", "table", "tablecolumn"],
        ) {
            TableColumnShowcase()
        },
        ShowcaseEntry(
            id: "form",
            title: "Form",
            category: .containers,
            subtitle: "A container for grouping controls",
            keywords: ["form"],
        ) {
            FormShowcase()
        },
        ShowcaseEntry(
            id: "section",
            title: "Section",
            category: .containers,
            subtitle: "A grouping of content with an",
            keywords: ["section"],
        ) {
            SectionShowcase()
        },
        ShowcaseEntry(
            id: "groupbox",
            title: "GroupBox",
            category: .containers,
            subtitle: "A stylized container that visually",
            keywords: ["groupbox"],
        ) {
            GroupboxShowcase()
        },
        ShowcaseEntry(
            id: "disclosure-group",
            title: "DisclosureGroup",
            category: .containers,
            subtitle: "A container that shows or hides its",
            keywords: ["disclosure", "disclosuregroup", "group"],
        ) {
            DisclosureGroupShowcase()
        },
        ShowcaseEntry(
            id: "group",
            title: "Group",
            category: .containers,
            subtitle: "A transparent container that collects",
            keywords: ["group"],
        ) {
            GroupShowcase()
        },
        ShowcaseEntry(
            id: "viewthatfits",
            title: "ViewThatFits",
            category: .containers,
            subtitle: "A container that picks the first",
            keywords: ["viewthatfits"],
        ) {
            ViewthatfitsShowcase()
        },
        ShowcaseEntry(
            id: "spacer",
            title: "Spacer",
            category: .containers,
            subtitle: "A flexible space that expands along",
            keywords: ["spacer"],
        ) {
            SpacerShowcase()
        },
        ShowcaseEntry(
            id: "divider",
            title: "Divider",
            category: .containers,
            subtitle: "A visual line that separates content;",
            keywords: ["divider"],
        ) {
            DividerShowcase()
        },
        ShowcaseEntry(
            id: "labeled-content",
            title: "LabeledContent",
            category: .containers,
            subtitle: "A container pairing a label with a",
            keywords: ["content", "labeled", "labeledcontent"],
        ) {
            LabeledContentShowcase()
        },
        ShowcaseEntry(
            id: "geometry-reader",
            title: "GeometryReader",
            category: .containers,
            subtitle: "A container view that defines its",
            keywords: ["geometry", "geometryreader", "reader"],
        ) {
            GeometryReaderShowcase()
        },
        ShowcaseEntry(
            id: "layout",
            title: "Layout (custom layout)",
            category: .containers,
            subtitle: "A protocol for defining a custom",
            keywords: ["custom", "layout"],
        ) {
            LayoutShowcase()
        },
        ShowcaseEntry(
            id: "outline-group",
            title: "OutlineGroup",
            category: .containers,
            subtitle: "A container that computes views and",
            keywords: ["group", "outline", "outlinegroup"],
        ) {
            OutlineGroupShowcase()
        },
        ShowcaseEntry(
            id: "table-row",
            title: "TableRow",
            category: .containers,
            subtitle: "A row that represents a single data",
            keywords: ["row", "table", "tablerow"],
        ) {
            TableRowShowcase()
        },
    ]
}
