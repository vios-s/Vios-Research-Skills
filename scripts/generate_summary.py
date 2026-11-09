#!/usr/bin/env python3
"""Regenerate skills/SUMMARY.md from the SKILL.md files in skills/.

Skills are grouped by the `metadata.category` frontmatter field. The category order
is defined by CATEGORY_ORDER below; unknown categories go to a trailing
"Uncategorised" group. Within each category, skills are sorted alphabetically.

Usage:
    python scripts/generate_summary.py            # write SUMMARY.md
    python scripts/generate_summary.py --check    # exit non-zero if out of date
"""

from __future__ import annotations

import argparse
import re
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SKILLS_DIR = ROOT / "skills"
SUMMARY_PATH = SKILLS_DIR / "SUMMARY.md"

# Canonical pipeline order for categories.
# Skills whose category doesn't appear here land in "Uncategorised".
CATEGORY_ORDER = [
    "Discovery & Monitoring",
    "Reading & Analysis",
    "Ideation & Hypothesis",
    "Methodology",
    "Domain: Medical Imaging",
    "Domain: Plant Phenotyping",
    "Domain: Causality",
    "Domain: Computer Vision",
    "Writing",
    "Review & Dissemination",
    "Lab Operations",
    "Community & Infrastructure",
]


def parse_frontmatter(text: str) -> dict[str, str]:
    fm_match = re.match(r"^---\n(.*?)\n---\n", text, re.DOTALL)
    if not fm_match:
        return {}
    fm: dict[str, str] = {}
    for line in fm_match.group(1).splitlines():
        # Nested keys (e.g. `metadata:` -> `  category: ...`) are flattened;
        # a top-level key of the same name wins.
        m = re.match(r"^(\s*)(\w[\w-]*):\s*(.+)$", line)
        if m and (not m.group(1) or m.group(2) not in fm):
            fm[m.group(2)] = m.group(3).strip().strip('"').strip("'")
    return fm


def extract_title(skill_md: Path) -> str:
    text = skill_md.read_text(encoding="utf-8")
    fm = parse_frontmatter(text)

    if "title" in fm:
        return fm["title"]
    if "name" in fm:
        return " ".join(w.capitalize() for w in fm["name"].split("-"))

    fm_match = re.match(r"^---\n(.*?)\n---\n", text, re.DOTALL)
    body = text[fm_match.end():] if fm_match else text
    h1 = re.search(r"^#\s+(.+)$", body, re.MULTILINE)
    if h1:
        return h1.group(1).strip()

    return skill_md.parent.name


def build_summary() -> str:
    buckets: dict[str, list[tuple[str, str]]] = defaultdict(list)

    for d in sorted(p for p in SKILLS_DIR.iterdir() if p.is_dir()):
        skill_md = d / "SKILL.md"
        if not skill_md.exists():
            print(f"warning: {d} has no SKILL.md — skipping", file=sys.stderr)
            continue
        text = skill_md.read_text(encoding="utf-8")
        fm = parse_frontmatter(text)
        category = fm.get("category", "Uncategorised")
        title = extract_title(skill_md)
        buckets[category].append((title, f"{d.name}/SKILL.md"))

    lines = ["# Summary", "", "* [Vios Research Skills](SKILL.md)", ""]

    ordered = [c for c in CATEGORY_ORDER if c in buckets]
    extra = sorted(c for c in buckets if c not in CATEGORY_ORDER)

    for category in ordered + extra:
        lines.append(f"## {category}")
        lines.append("")
        for title, rel in buckets[category]:
            lines.append(f"* [{title}]({rel})")
        lines.append("")

    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--check",
        action="store_true",
        help="Exit non-zero if SUMMARY.md is out of date.",
    )
    args = parser.parse_args()

    new = build_summary()

    if args.check:
        if not SUMMARY_PATH.exists():
            print(f"error: {SUMMARY_PATH} does not exist", file=sys.stderr)
            return 1
        current = SUMMARY_PATH.read_text(encoding="utf-8")
        if current.strip() != new.strip():
            print(
                "error: skills/SUMMARY.md is out of date. "
                "Run `python scripts/generate_summary.py` and commit.",
                file=sys.stderr,
            )
            print("--- expected ---")
            print(new)
            return 1
        return 0

    SUMMARY_PATH.write_text(new, encoding="utf-8")
    print(f"wrote {SUMMARY_PATH}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
