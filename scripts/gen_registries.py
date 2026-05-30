#!/usr/bin/env python3
"""Regenerate per-category ShowcaseRegistry files deterministically from the work-list.

Usage: python3 scripts/gen_registries.py <categoryKey> [<categoryKey> ...]

Only components whose showcase file actually exists on disk are registered, so this is
safe to run after any generation wave. Hand-written exemplar entries are preserved.
"""
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WORKLIST = json.load(open(os.path.join(ROOT, "docs/specs/worklist.json")))

# Pre-existing, hand-written showcases that are excluded from the work-list.
EXEMPLARS = {
    "buttons": [
        {"id": "button", "title": "Button", "struct": "ButtonShowcase",
         "subtitle": "Styles, roles, control size, tint",
         "keywords": ["button", "action", "bordered", "prominent", "glass", "role", "tint"]},
        {"id": "toggle", "title": "Toggle", "struct": "ToggleShowcase",
         "subtitle": "Switch, button, and checkbox styles",
         "keywords": ["toggle", "switch", "checkbox", "on", "off", "boolean"]},
    ],
    "selection": [
        {"id": "picker", "title": "Picker", "struct": "PickerShowcase",
         "subtitle": "Every native picker style",
         "keywords": ["picker", "menu", "segmented", "wheel", "inline", "palette", "selection"]},
    ],
}


def short(text, limit=38):
    text = re.sub(r"\s+", " ", text or "").strip()
    if len(text) <= limit:
        return text
    return text[:limit].rsplit(" ", 1)[0]


def keywords_for(cid, api, title):
    tokens = set(cid.split("-"))
    tokens |= set(re.findall(r"[a-z0-9]+", (api or "").lower()))
    tokens |= set(re.findall(r"[a-z0-9]+", title.lower()))
    tokens.discard("")
    return sorted(tokens)[:8]


def keywords_line(keywords):
    inline = ", ".join(f'"{k}"' for k in keywords)
    if len(f"            keywords: [{inline}],") <= 118:
        return [f"            keywords: [{inline}],"]
    lines = ["            keywords: ["]
    lines += [f'                "{k}",' for k in keywords]
    lines.append("            ],")
    return lines


def entry_swift(key, item):
    return "\n".join([
        "        ShowcaseEntry(",
        f'            id: "{item["id"]}",',
        f'            title: "{item["title"]}",',
        f"            category: .{key},",
        f'            subtitle: "{item["subtitle"]}",',
        *keywords_line(item["keywords"]),
        "        ) {",
        f'            {item["struct"]}()',
        "        },",
    ])


def generate(key):
    folder = next((w["folder"] for w in WORKLIST if w["key"] == key), key.capitalize())
    spec_path = os.path.join(ROOT, f"docs/specs/by-category/{key}.json")
    by_id = {}
    if os.path.exists(spec_path):
        by_id = {c["id"]: c for c in json.load(open(spec_path))["components"]}

    entries = list(EXEMPLARS.get(key, []))
    for work in [w for w in WORKLIST if w["key"] == key]:
        path = os.path.join(ROOT, f"SwiftUIShowroom/Components/{folder}/{work['struct']}.swift")
        if not os.path.exists(path):
            print(f"  skip (no file): {work['struct']}")
            continue
        spec = by_id.get(work["id"], {})
        entries.append({
            "id": work["id"],
            "title": work["title"],
            "struct": work["struct"],
            "subtitle": short(spec.get("summary", work["title"])),
            "keywords": keywords_for(work["id"], spec.get("api", ""), work["title"]),
        })

    body = "\n".join(entry_swift(key, e) for e in entries)
    text = (
        "import SwiftUI\n\n"
        "extension ShowcaseRegistry {\n"
        f"    static let {key}Entries: [ShowcaseEntry] = [\n"
        f"{body}\n"
        "    ]\n"
        "}\n"
    )
    out = os.path.join(ROOT, f"SwiftUIShowroom/Components/{folder}/{folder}+Registry.swift")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    open(out, "w").write(text)
    print(f"wrote {folder}+Registry.swift: {len(entries)} entries")


if __name__ == "__main__":
    for key in sys.argv[1:]:
        generate(key)
