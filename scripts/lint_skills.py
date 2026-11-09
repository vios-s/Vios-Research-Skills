#!/usr/bin/env python3
"""Lint SKILL.md frontmatter across the skills/ directory.

Checks:
  - YAML frontmatter exists and parses.
  - Only fields allowed by the Agent Skills spec (agentskills.io) appear at
    the top level; library fields (category, version, author) live under
    `metadata`, whose values must be strings.
  - Required fields present: name, description, metadata.category.
  - `name` matches the folder name and the spec's charset (kebab-case, <= 64).
  - `description` is 100-1024 chars and starts with "Use this skill".
  - `compatibility`, if present, is at most 500 chars.
  - `metadata.category` is one of the recognised pipeline stages.
  - SKILL.md body contains an H1 and stays under 500 lines.

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

# Top-level fields allowed by the Agent Skills spec. `skills-ref validate`
# rejects anything else, and strict clients (claude.ai, VS Code) may too.
ALLOWED_FIELDS = {
    "name", "description", "license", "compatibility", "metadata", "allowed-tools",
}
REQUIRED_FIELDS = ("name", "description")
NAME_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
NAME_MAX_CHARS = 64
DESCRIPTION_MIN_CHARS = 100
DESCRIPTION_MAX_CHARS = 1024
COMPATIBILITY_MAX_CHARS = 500
BODY_MAX_LINES = 500
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
    "Lab Operations",
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

    unexpected = sorted(set(fm) - ALLOWED_FIELDS)
    if unexpected:
        errors.append(
            f"unexpected top-level field(s) {', '.join(unexpected)}; "
            "move them under `metadata:`"
        )

    metadata = fm.get("metadata") or {}
    if not isinstance(metadata, dict):
        errors.append("`metadata` must be a mapping")
        metadata = {}
    for key, value in metadata.items():
        if not isinstance(value, str):
            errors.append(f"metadata.{key} must be a string (quote it)")
    if "category" not in metadata:
        errors.append("missing required field: `metadata.category`")

    name = str(fm.get("name", ""))
    if name and (not NAME_RE.match(name) or len(name) > NAME_MAX_CHARS):
        errors.append(
            f"name `{name}` must be lowercase kebab-case, <= {NAME_MAX_CHARS} chars"
        )

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
        if len(desc) > DESCRIPTION_MAX_CHARS:
            errors.append(
                f"description too long ({len(desc)} chars, max {DESCRIPTION_MAX_CHARS})"
            )
        if not desc.startswith(DESCRIPTION_PREFIX):
            errors.append(f'description should start with "{DESCRIPTION_PREFIX}"')

    compat = fm.get("compatibility")
    if compat is not None and len(str(compat)) > COMPATIBILITY_MAX_CHARS:
        errors.append(f"compatibility exceeds {COMPATIBILITY_MAX_CHARS} chars")

    category = metadata.get("category", "")
    if category and category not in VALID_CATEGORIES:
        valid = ", ".join(f'"{c}"' for c in sorted(VALID_CATEGORIES))
        errors.append(f'unknown category "{category}". Valid values: {valid}')

    body = text[fm_match.end():]
    if not re.search(r"^#\s+\S", body, re.MULTILINE):
        errors.append("body does not contain an H1 heading")
    if len(body.splitlines()) > BODY_MAX_LINES:
        errors.append(
            f"body is over {BODY_MAX_LINES} lines; move detail into references/"
        )

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
