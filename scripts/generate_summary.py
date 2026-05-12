#!/usr/bin/env python3
"""Regenerate skills/SUMMARY.md from the SKILL.md files in skills/.

Usage:
    python scripts/generate_summary.py            # write SUMMARY.md
    python scripts/generate_summary.py --check    # exit non-zero if out of date
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SKILLS_DIR = ROOT / "skills"
SUMMARY_PATH = SKILLS_DIR / "SUMMARY.md"


def extract_title(skill_md: Path) -> str:
    """Return the human-readable title from a SKILL.md.

    Priority: frontmatter `title:` > frontmatter `name:` (humanised) > first H1.
    """
    text = skill_md.read_text(encoding="utf-8")

    fm_match = re.match(r"^---\n(.*?)\n---\n", text, re.DOTALL)
    if fm_match:
        fm = fm_match.group(1)
        title_match = re.search(r"^title:\s*(.+)$", fm, re.MULTILINE)
        if title_match:
            return title_match.group(1).strip().strip('"').strip("'")
        name_match = re.search(r"^name:\s*(.+)$", fm, re.MULTILINE)
        if name_match:
            name = name_match.group(1).strip().strip('"').strip("'")
            return " ".join(w.capitalize() for w in name.split("-"))

    body = text[fm_match.end():] if fm_match else text
    h1_match = re.search(r"^#\s+(.+)$", body, re.MULTILINE)
    if h1_match:
        return h1_match.group(1).strip()

    return skill_md.parent.name


def build_summary() -> str:
    lines = ["# Summary", "", "* [Vios Research Skills](SKILL.md)", "", "## Skills", ""]
    skill_dirs = sorted(p for p in SKILLS_DIR.iterdir() if p.is_dir())
    for d in skill_dirs:
        skill_md = d / "SKILL.md"
        if not skill_md.exists():
            print(f"warning: {d} has no SKILL.md — skipping", file=sys.stderr)
            continue
        title = extract_title(skill_md)
        rel = f"{d.name}/SKILL.md"
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
