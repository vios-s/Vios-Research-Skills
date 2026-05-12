#!/usr/bin/env python3
"""Lint SKILL.md frontmatter across the skills/ directory.

Checks:
  - YAML frontmatter exists and parses.
  - Required fields present: name, description, category.
  - `name` matches the folder name (kebab-case).
  - `description` is at least 100 chars and starts with "Use this skill".
  - `category` is one of the recognised pipeline stages.
  - SKILL.md body contains an H1.

Exits non-zero with a summary of failures.

Note: skips skills/SKILL.md (the library-overview page, not a real skill).
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("error: PyYAML required. `pip install pyyaml`", file=sys.stderr)
    sys.exit(2)

ROOT = Path(__file__).resolve().parent.parent
SKILLS_DIR = ROOT / "skills"

REQUIRED_FIELDS = ("name", "description", "category")
DESCRIPTION_MIN_CHARS = 100
DESCRIPTION_PREFIX = "Use this skill"

VALID_CATEGORIES = {
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
    "Community & Infrastructure",
}


def lint_skill(skill_md: Path) -> list[str]:
    errors: list[str] = []
    text = skill_md.read_text(encoding="utf-8")

    fm_match = re.match(r"^---\n(.*?)\n---\n", text, re.DOTALL)
    if not fm_match:
        errors.append("missing YAML frontmatter (--- fences)")
        return errors

    try:
        fm = yaml.safe_load(fm_match.group(1)) or {}
    except yaml.YAMLError as e:
        errors.append(f"YAML parse error: {e}")
        return errors

    for field in REQUIRED_FIELDS:
        if field not in fm:
            errors.append(f"missing required frontmatter field: `{field}`")

    folder_name = skill_md.parent.name
    if fm.get("name") and fm["name"] != folder_name:
        errors.append(
            f"frontmatter `name: {fm['name']}` does not match folder name `{folder_name}`"
        )

    desc = str(fm.get("description", ""))
    if desc:
        if len(desc) < DESCRIPTION_MIN_CHARS:
            errors.append(
                f"description too short ({len(desc)} chars, need >= {DESCRIPTION_MIN_CHARS})"
            )
        if not desc.startswith(DESCRIPTION_PREFIX):
            errors.append(f'description should start with "{DESCRIPTION_PREFIX}"')

    category = fm.get("category", "")
    if category and category not in VALID_CATEGORIES:
        valid = ", ".join(f'"{c}"' for c in sorted(VALID_CATEGORIES))
        errors.append(f'unknown category "{category}". Valid values: {valid}')

    body = text[fm_match.end():]
    if not re.search(r"^#\s+\S", body, re.MULTILINE):
        errors.append("body does not contain an H1 heading")

    return errors


def main() -> int:
    failures: dict[Path, list[str]] = {}

    skill_files = sorted(SKILLS_DIR.glob("*/SKILL.md"))
    if not skill_files:
        print("error: no skills found under skills/*/SKILL.md", file=sys.stderr)
        return 1

    for skill_md in skill_files:
        errors = lint_skill(skill_md)
        if errors:
            failures[skill_md] = errors

    if failures:
        print(f"\n{len(failures)} skill(s) failed lint:\n", file=sys.stderr)
        for path, errors in failures.items():
            rel = path.relative_to(ROOT)
            print(f"  {rel}", file=sys.stderr)
            for e in errors:
                print(f"    - {e}", file=sys.stderr)
        return 1

    print(f"{len(skill_files)} skill(s) passed lint")
    return 0


if __name__ == "__main__":
    sys.exit(main())
