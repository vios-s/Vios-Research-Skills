#!/usr/bin/env python3
"""Check the eidf-job skill against the Job templates bundled with it.

Ported from vios-s/EIDF_Template (tests/test_skill_path.py). The eidf-job
skill fills the templates in skills/eidf-job/templates/ with no script involved — an assistant copies a
template and substitutes placeholders per SKILL.md's Step 4 table. That path
has its own failure mode: a placeholder that exists in a template but is
missing from the table gets left behind, and a literal `<FOO>` either makes
kubectl reject the file or ships a nonsense label.

So this asserts the table and the templates agree, then fills every template
the way the skill says to and checks the result is deployable.

    python scripts/check_eidf_job.py
"""
import os
import re
import subprocess
import sys
import tempfile

import yaml

SKILL_DIR = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "skills", "eidf-job")
SKILL = os.path.join(SKILL_DIR, "SKILL.md")
TEMPLATE_DIR = os.path.join(SKILL_DIR, "templates")

TEMPLATES = [
    "CUDA/job.template.yaml", "CUDA/job.interactive.yaml",
    "PyTorch_Docker/job.template.yaml",
    "vllm/job.template.yaml", "vllm/job.interactive.yaml",
    "vllm/service.template.yaml",
]

# An account that exercises the distinction: '_' is legal in a label value
# but not in a resource name, so the two substitutions genuinely differ.
ACCOUNT = "ada_lovelace"
SAFE = "ada-lovelace"
FILL = {
    "<USERNAME>": ACCOUNT,
    "<USERNAME_SAFE>": SAFE,
    "<USER_ID>": "5001",
    "<GROUP_ID>": "5001",
    "<RESEARCH_PROJECT>": "mri_recon",
    "<PULL_SECRET>": "eidf105-ecir-read-robot",
    "<COMMAND>": "python train.py",
    "<MODEL>": "Qwen/Qwen2.5-7B-Instruct",
}
# Not a value substitution — the skill deletes this marker line when no
# secret is needed (Step 6).
DROP_LINE_MARKERS = ["<SECRET_ENV_HOOK>"]


def documented_placeholders():
    """Placeholders SKILL.md's Step 4 *table* tells the assistant to fill.

    Table rows only — deliberately not the surrounding prose. Scanning the
    whole section would let a passing mention in a paragraph count as
    "documented", which is not what an assistant works from when filling a
    template, and would let a placeholder silently drop out of the table.
    """
    text = open(SKILL, encoding="utf-8").read()
    section = text[text.index("## Step 4"):]
    section = section[:section.index("\n## ")]
    rows = [ln for ln in section.splitlines()
            if ln.startswith("|") and not ln.startswith("|---")]
    return set(re.findall(r"`(<[A-Z_]+>)`", "\n".join(rows)))


# The templates' header comments say "replace every <PLACEHOLDER>" — prose
# about placeholders, not one itself. Cannot just skip comment lines, since
# `# <SECRET_ENV_HOOK>` is a real marker the wizard substitutes into.
PROSE = {"<PLACEHOLDER>"}


def template_placeholders(path):
    found = set(re.findall(r"<[A-Z_]+>", open(path, encoding="utf-8").read()))
    return found - PROSE


def fill(path):
    out = []
    for line in open(path, encoding="utf-8"):
        if any(m in line for m in DROP_LINE_MARKERS):
            continue
        for k, v in FILL.items():
            line = line.replace(k, v)
        out.append(line)
    return "".join(out)


def server_dry_run(path, namespace="eidf105ns"):
    try:
        p = subprocess.run(
            ["kubectl", "-n", namespace, "create", "--dry-run=server",
             "-f", path], capture_output=True, text=True, timeout=60)
    except (OSError, subprocess.TimeoutExpired):
        return None
    if p.returncode == 0:
        return []
    err = p.stderr.strip() or p.stdout.strip()
    if "Unable to connect" in err or "refused" in err:
        return None
    return [ln for ln in err.splitlines()
            if ln.strip() and not ln.startswith("Warning:")]


def main():
    documented = documented_placeholders()
    failures = 0

    # 1. Every placeholder in every template must be documented, or an
    #    assistant following the skill will silently leave it behind.
    for rel in TEMPLATES:
        used = template_placeholders(os.path.join(TEMPLATE_DIR, rel))
        undocumented = used - documented
        if undocumented:
            failures += 1
            print(f"[FAIL] {rel}: placeholder(s) not in SKILL.md Step 4: "
                  f"{', '.join(sorted(undocumented))}")

    # 2. Filling as documented must leave nothing behind and deploy clean.
    for rel in TEMPLATES:
        path = os.path.join(TEMPLATE_DIR, rel)
        text = fill(path)
        problems = []
        leftover = set(re.findall(r"<[A-Z_]+>", text)) - PROSE
        if leftover:
            problems.append(f"leftover {', '.join(sorted(leftover))}")
        try:
            doc = yaml.safe_load(text)
        except yaml.YAMLError as exc:
            problems.append(f"does not parse: {str(exc).splitlines()[0]}")
            doc = None

        if doc:
            labels = (doc.get("metadata") or {}).get("labels") or {}
            # The whole point of the two-placeholder split: the name is
            # folded, the owner label is not.
            name = (doc.get("metadata") or {}).get("generateName") \
                or (doc.get("metadata") or {}).get("name") or ""
            if ACCOUNT in name:
                problems.append(
                    f"name {name!r} contains the raw account — resource "
                    f"names cannot hold '_'")
            if doc.get("kind") != "Service" and labels.get("owner") != ACCOUNT:
                problems.append(
                    f"owner label is {labels.get('owner')!r}, expected the "
                    f"real account {ACCOUNT!r}")
            with tempfile.NamedTemporaryFile("w", suffix=".yaml",
                                             delete=False) as f:
                f.write(text)
                tmp = f.name
            server = server_dry_run(tmp)
            os.unlink(tmp)
            for line in (server or [])[:2]:
                problems.append(f"server rejected: {line.strip()}")

        if problems:
            failures += 1
            print(f"[FAIL] {rel}")
            for p in problems:
                print(f"       - {p}")
        else:
            print(f"[ok]   {rel}")

    print(f"\n{failures} problem(s) on the skill path")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
