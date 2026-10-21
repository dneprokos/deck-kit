#!/usr/bin/env python3
"""Validate the deck-kit Claude Code plugin.

Checks the plugin manifest + marketplace manifest agree on name / version,
that field types match Claude Code's loader schema, that every skill carries
the required frontmatter, that no private/scrubbed token regressed into the
tree, that skill scripts are invoked via ${CLAUDE_PLUGIN_ROOT}, and that the
asset set, skeleton script, and archetype catalog stay consistent.

Run from the repo root:

    python3 scripts/validate_plugin.py

Exits non-zero on any failure (CI gate). Prints one line per check.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SEMVER = re.compile(r"^\d+\.\d+\.\d+$")

errors: list[str] = []
checks = 0


def check(ok: bool, ok_msg: str, fail_msg: str) -> bool:
    global checks
    checks += 1
    if ok:
        print(f"  ok   {ok_msg}")
    else:
        print(f"  FAIL {fail_msg}")
        errors.append(fail_msg)
    return ok


def load_json(rel: str):
    path = ROOT / rel
    if not path.exists():
        errors.append(f"{rel} is missing")
        return None
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        errors.append(f"{rel} is not valid JSON: {exc}")
        return None


def read_frontmatter(path: Path) -> dict[str, str]:
    """Top-level scalar keys of a leading --- YAML frontmatter block."""
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---"):
        return {}
    end = text.find("\n---", 3)
    if end == -1:
        return {}
    block = text[3:end]
    fm: dict[str, str] = {}
    for line in block.splitlines():
        m = re.match(r"^([A-Za-z_][\w-]*):\s*(.*)$", line)
        if m:
            fm[m.group(1)] = m.group(2).strip()
    return fm


def main() -> int:
    print("== manifests ==")
    plugin = load_json(".claude-plugin/plugin.json")
    market = load_json(".claude-plugin/marketplace.json")
    if plugin is None or market is None:
        for e in errors:
            print(f"  FAIL {e}")
        print(f"\nFAILED: {len(errors)} error(s)")
        return 1

    name = plugin.get("name", "")
    version = plugin.get("version", "")
    desc = plugin.get("description", "")
    check(name == "deck-kit", "plugin name is 'deck-kit'", f"plugin name is {name!r}, expected 'deck-kit'")
    check(bool(SEMVER.match(version)), f"plugin version {version!r} is semver", f"plugin version {version!r} is not semver X.Y.Z")
    check(len(desc) >= 50, f"plugin description present ({len(desc)} chars)", f"plugin description too short ({len(desc)} chars)")
    check(bool(plugin.get("license")), "plugin declares a license", "plugin.json has no license")
    auth = plugin.get("author")
    auth_name = auth if isinstance(auth, str) else (auth.get("name") if isinstance(auth, dict) else None)
    check(bool(auth_name), "plugin declares an author", "plugin.json has no author")

    # Claude Code's loader rejects the object form for these fields.
    repo = plugin.get("repository")
    check(repo is None or isinstance(repo, str),
          "plugin repository is a string (or absent)",
          "plugin.json `repository` must be a STRING URL, not an object {type,url}")
    check(plugin.get("homepage") is None or isinstance(plugin.get("homepage"), str),
          "plugin homepage is a string (or absent)", "plugin.json `homepage` must be a string")
    check(auth is None or isinstance(auth, (str, dict)),
          "plugin author is a string or object (or absent)", "plugin.json `author` must be a string or object")

    print("== marketplace ==")
    check(market.get("name") == "deck-kit",
          "marketplace name is 'deck-kit' (matches the plugin — one-plugin marketplace)",
          f"marketplace name is {market.get('name')!r}, expected 'deck-kit'")
    plugins = market.get("plugins", [])
    entry = next((p for p in plugins if p.get("name") == "deck-kit"), None)
    if check(entry is not None, "marketplace lists the 'deck-kit' plugin", "marketplace.json has no plugin named 'deck-kit'"):
        check(entry.get("version") == version,
              f"marketplace version matches plugin.json ({version}) — lockstep",
              f"marketplace version {entry.get('version')!r} != plugin.json {version!r} — bump BOTH")
        check(bool(entry.get("description")), "marketplace entry has a description", "marketplace 'deck-kit' entry has no description")
        check(entry.get("source") == "./", "marketplace entry source is './'",
              f"marketplace 'deck-kit' source is {entry.get('source')!r}, expected './'")

    # package.json version lockstep + pinned playwright.
    pkg = load_json("package.json")
    if pkg is not None:
        check(pkg.get("version") == version,
              f"package.json version matches plugin.json ({version})",
              f"package.json version {pkg.get('version')!r} != plugin.json {version!r}")
        pw = (pkg.get("devDependencies") or {}).get("playwright", "")
        check(bool(re.match(r"^\d", pw)),
              f"playwright is pinned exactly ({pw})",
              f"playwright must be pinned exactly (no ^/~), got {pw!r}")

    # --- skills: frontmatter, naming, no SKILL.md in _shared ---
    print("== skills ==")
    skills_dir = ROOT / "skills"
    skill_specs = sorted(skills_dir.glob("*/SKILL.md"))
    check(len(skill_specs) == 2 and {s.parent.name for s in skill_specs} == {"deck-plan", "deck-build"},
          "exactly the two skills deck-plan + deck-build exist",
          f"expected skills deck-plan + deck-build, found {[s.parent.name for s in skill_specs]}")
    for skill_md in skill_specs:
        base = skill_md.parent.name
        fm = read_frontmatter(skill_md)
        check(fm.get("name") == base,
              f"skill '{base}' has matching name frontmatter",
              f"skill '{base}': frontmatter name is {fm.get('name')!r}, expected {base!r}")
        check(len(fm.get("description", "")) >= 100,
              f"skill '{base}' has a rich description ({len(fm.get('description', ''))} chars)",
              f"skill '{base}' description too short for reliable triggering")
        check(bool(re.match(r"^[a-z0-9-]+$", base)),
              f"skill dir '{base}' matches ^[a-z0-9-]+$",
              f"skill dir '{base}' must match ^[a-z0-9-]+$")
    check((skills_dir / "_shared").is_dir() and not (skills_dir / "_shared" / "SKILL.md").exists(),
          "_shared is reference-only (no SKILL.md)",
          "_shared is missing or contains a SKILL.md (it would register as a skill)")

    # --- commands: frontmatter description present ---
    print("== commands ==")
    cmd_files = sorted((ROOT / "commands").glob("*.md"))
    check({c.stem for c in cmd_files} == {"plan", "build", "audit"},
          "commands are exactly plan / build / audit",
          f"expected commands plan+build+audit, found {[c.stem for c in cmd_files]}")
    for c in cmd_files:
        fm = read_frontmatter(c)
        check(bool(fm.get("description")), f"command '{c.stem}' has a description",
              f"command '{c.stem}' has no description frontmatter")

    # --- forbidden tokens: the scrub must never regress ---
    # These are the private-data / dead-branch markers scrubbed out when the
    # public plugin was extracted. Scope: everything shipped to users.
    print("== forbidden tokens ==")
    FORBIDDEN = re.compile(
        r"kyrylo|sulimovskyi|fwdays|evoplay|Own Brand|excalidraw|"
        r"ПОКАЗУЮ|Я В КАДРІ|ЗАКАДРОВИЙ|genkovi4|gnk\.link|"
        r"~/\.claude/skills|/Users/",
        re.IGNORECASE,
    )
    SCAN_DIRS = ("skills", "commands", "scripts", "assets", "examples", "tests")
    SCAN_EXT = {".md", ".html", ".css", ".js", ".mjs", ".sh", ".json", ".py"}
    offenders: list[str] = []
    for d in SCAN_DIRS:
        base = ROOT / d
        if not base.is_dir():
            continue
        for f in sorted(base.rglob("*")):
            if not f.is_file() or f.suffix not in SCAN_EXT:
                continue
            if "node_modules" in f.parts or ".audit" in f.parts:
                continue
            if f.name == "validate_plugin.py":
                continue  # this file names the forbidden tokens
            for i, line in enumerate(f.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
                if FORBIDDEN.search(line):
                    offenders.append(f"{f.relative_to(ROOT)}:{i}")
    check(not offenders,
          f"no forbidden tokens in {'/'.join(SCAN_DIRS)}",
          "forbidden token(s) regressed at: " + ", ".join(offenders[:20]))

    # --- script invocations go through ${CLAUDE_PLUGIN_ROOT} ---
    # A skill installed from the marketplace lives in the plugin cache; any
    # other path form (relative `scripts/…`, `~/…`) breaks on install.
    print("== script invocation paths ==")
    bad_calls: list[str] = []
    CALL_RE = re.compile(r"(?:bash|node|python3)\s+(?!\"?\$\{CLAUDE_PLUGIN_ROOT\})[\"']?[\w~./-]*scripts/")
    for f in sorted((ROOT / "skills").rglob("*.md")) + sorted((ROOT / "commands").glob("*.md")):
        for i, line in enumerate(f.read_text(encoding="utf-8").splitlines(), 1):
            if CALL_RE.search(line):
                bad_calls.append(f"{f.relative_to(ROOT)}:{i}")
    check(not bad_calls,
          "all script invocations in skills/commands use ${CLAUDE_PLUGIN_ROOT}",
          "script invocation without ${CLAUDE_PLUGIN_ROOT} at: " + ", ".join(bad_calls))

    # --- markdown relative links resolve ---
    print("== links ==")
    LINK_RE = re.compile(r"\[[^\]]*\]\(([^)]+)\)")
    link_files = sorted((ROOT / "skills").rglob("*.md")) + [ROOT / "README.md"]
    n_links = 0
    broken: list[str] = []
    for f in link_files:
        if not f.exists():
            continue
        for m in LINK_RE.finditer(f.read_text(encoding="utf-8")):
            target = m.group(1).strip()
            if target.startswith(("http://", "https://", "#")) or "<" in target:
                continue
            path_part = target.split("#", 1)[0]
            if not path_part or not (path_part.endswith(".md") or path_part.endswith("/")):
                continue
            n_links += 1
            if not (f.parent / path_part).exists():
                broken.append(f"{f.relative_to(ROOT)} → {target}")
    check(not broken,
          f"all {n_links} relative doc links resolve",
          "broken relative links:\n        " + "\n        ".join(broken))

    # --- asset ↔ skeleton consistency ---
    # new-skeleton.sh copies named files out of assets/; a rename on either
    # side must not drift.
    print("== asset ↔ skeleton consistency ==")
    skeleton = (ROOT / "scripts" / "new-skeleton.sh").read_text(encoding="utf-8")
    asset_files = {p.name for p in (ROOT / "assets").iterdir() if p.is_file()}
    # Directory refs ($ASSETS/themes/<name>.css) are covered by the theme check.
    referenced = {r for r in re.findall(r"\$ASSETS/([\w.-]+)", skeleton)
                  if not (ROOT / "assets" / r).is_dir()}
    missing = sorted(referenced - asset_files)
    unused = sorted(asset_files - referenced)
    check(not missing,
          f"every asset referenced by new-skeleton.sh exists ({len(referenced)} refs)",
          f"new-skeleton.sh references missing assets: {missing}")
    check(not unused,
          "every file in assets/ is copied by new-skeleton.sh",
          f"assets/ files never copied by new-skeleton.sh: {unused}")

    # --- theme completeness ---
    # assets/themes/cyberpunk.css is the reference token set; every shipped
    # theme must define all of it (Gate 2 enforces the same on decks).
    print("== themes ==")
    themes_dir = ROOT / "assets" / "themes"
    token_re = re.compile(r"^\s*(--[a-z0-9-]+)\s*:", re.M)
    reference = themes_dir / "cyberpunk.css"
    check(reference.is_file(), "reference theme assets/themes/cyberpunk.css exists",
          "assets/themes/cyberpunk.css missing")
    if reference.is_file():
        required = set(token_re.findall(reference.read_text(encoding="utf-8")))
        for theme in sorted(themes_dir.glob("*.css")):
            gaps = sorted(required - set(token_re.findall(theme.read_text(encoding="utf-8"))))
            check(not gaps, f"theme {theme.stem} defines all {len(required)} tokens",
                  f"theme {theme.stem} missing tokens: {gaps}")

    # --- archetype catalog ↔ blueprint coverage ---
    # Every archetype in the plan-side catalog must have a build-side
    # blueprint heading, and vice versa. Names are the deck-spec contract.
    print("== archetype coverage ==")
    catalog_text = (ROOT / "skills" / "deck-plan" / "references" / "archetype-catalog.md").read_text(encoding="utf-8")
    catalog = set(re.findall(r"^\| `([a-z0-9-]+)` \|", catalog_text, re.M))
    blueprint_names: set[str] = set()
    for rel in ("archetypes.md", "archetypes-lecture.md", "archetypes-talk.md"):
        text = (ROOT / "skills" / "deck-build" / "references" / rel).read_text(encoding="utf-8")
        blueprint_names |= set(re.findall(r"^## (?:\d+ · |Workshop-specific · )([a-z0-9-]+)", text, re.M))
    check(catalog == blueprint_names,
          f"archetype catalog matches blueprints exactly ({len(catalog)} archetypes)",
          f"catalog/blueprint drift — only in catalog: {sorted(catalog - blueprint_names)}, "
          f"only in blueprints: {sorted(blueprint_names - catalog)}")

    # --- _shared no-orphan: every shared reference is pointed to ---
    print("== _shared no-orphan ==")
    doc_pool = sorted((ROOT / "skills").rglob("*.md"))
    for sf in sorted((ROOT / "skills" / "_shared").glob("*.md")):
        referrers = [p for p in doc_pool if p != sf and sf.name in p.read_text(encoding="utf-8")]
        check(bool(referrers),
              f"_shared/{sf.name} is referenced by {len(referrers)} file(s)",
              f"_shared/{sf.name} is an orphan — nothing under skills/ points to it")

    # --- fixture spec parses against the deck-spec grammar ---
    print("== eval fixtures ==")
    SPEC_LINE = re.compile(r"^\d{2}\. [a-z][a-z0-9-]* · [^·]+ · [^·]+ · [^·]+$")
    fixture_spec = ROOT / "skills" / "deck-build" / "evals" / "files" / "fixture-spec" / ".planning" / "deck-spec.md"
    if check(fixture_spec.exists(), "deck-build fixture spec exists", f"{fixture_spec.relative_to(ROOT)} is missing"):
        plan_lines = [l for l in fixture_spec.read_text(encoding="utf-8").splitlines() if re.match(r"^\d{2}\.", l)]
        bad = [l for l in plan_lines if not SPEC_LINE.match(l)]
        check(plan_lines and not bad,
              f"fixture spec has {len(plan_lines)} valid slide-plan lines",
              f"fixture spec slide-plan lines violate the grammar: {bad or 'none found'}")
        fixture_archetypes = {l.split(" · ")[0].split(". ")[1] for l in plan_lines if SPEC_LINE.match(l)}
        check(fixture_archetypes <= catalog,
              "fixture spec archetypes all exist in the catalog",
              f"fixture spec uses archetypes not in the catalog: {sorted(fixture_archetypes - catalog)}")

    print()
    if errors:
        print(f"FAILED: {len(errors)} error(s) out of {checks} checks")
        return 1
    print(f"PASSED: {checks} checks")
    return 0


if __name__ == "__main__":
    # Windows consoles default to a legacy code page; force UTF-8 output so
    # the check marks and arrows in messages don't raise UnicodeEncodeError.
    sys.stdout.reconfigure(encoding="utf-8")
    sys.exit(main())
