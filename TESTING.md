# Testing

This plugin has two kinds of surface, and they're tested differently:

- **Code** — the ripple-check hook (`hooks/shaping-ripple.sh`) is a deterministic bash script. It is unit-tested.
- **Prompts** — the five skills are markdown an LLM interprets. Whether they *load and trigger* is verifiable; whether they produce *good* documents is a judgment call (the skills are deliberately GIGO). Those are covered by a manual checklist, not by asserting on LLM output.

Don't mistake a green suite for "the skills are good." The suite proves the plugin is **well-formed and the hook behaves correctly** — not that a framing doc it helps write is any good.

## Layer 1 — Deterministic suite (run on every change)

Fast, no LLM, no network. Requires `bash` and `jq`.

```bash
bash test/run.sh
```

What it covers:

| File | Covers |
|------|--------|
| `test/validate-structure.sh` | Manifests are valid JSON; plugin/marketplace names agree; every skill has exact-case `SKILL.md` with frontmatter whose `name` matches its directory and a non-empty `description`; `hooks.json` registers the `Write\|Edit` PostToolUse hook, uses `${CLAUDE_PLUGIN_ROOT}`, and has no hardcoded paths; expected skill count. |
| `test/test-hook.sh` | The hook blocks (exit 2 + checklist) **only** for `.md` files with `shaping: true` in the first 5 lines; ignores the flag past line 5, in non-`.md` files, in plain docs, on missing paths, and on empty input; degrades to a silent no-op when `jq` is absent. |

Run a single suite directly:

```bash
bash test/validate-structure.sh
bash test/test-hook.sh
```

Exit code is non-zero if any check fails, so it drops straight into CI or a pre-commit hook.

## Layer 2 — Deep validation (run periodically / before publishing)

Use the `plugin-dev:plugin-validator` agent for a broader pass — manifest schema, naming conventions, security review of the hook, and component discovery:

```
Validate the plugin at /Users/mae/Documents/shape-up/shaping-skills
```

This is slower and uses an agent, so it's not part of `run.sh`. Run it after structural changes or before a release.

## Layer 3 — Manual in-session checks (can't be scripted)

Load the plugin into a real session:

```bash
claude --plugin-dir /Users/mae/Documents/shape-up/shaping-skills
```

Then verify the things that only exist at runtime:

- [ ] `/help` lists all five skills as `shaping-skills:<name>`.
- [ ] Invoking one (e.g. `/shaping-skills:breadboarding`) loads its instructions.
- [ ] A skill is auto-selected when you describe a matching task without naming it (tests the `description` triggers).
- [ ] **Live hook fire:** create a `.md` file containing `shaping: true` in its frontmatter, edit it, and confirm the ripple checklist appears. Edit any other file and confirm silence.
- [ ] Skill *output quality* on a real transcript — subjective, eyeball it.

## When you change something

- Edit the hook script or its branches → `test/test-hook.sh` should still pass; add a case if you add a branch.
- Add/rename/remove a skill → update `EXPECTED_SKILLS` in `test/validate-structure.sh`.
- Change manifest fields → re-run Layer 1, then Layer 2 before publishing.
