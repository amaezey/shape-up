# Testing

The plugin has two kinds of surface, and each is tested differently:

- **Code**: the ripple-check hook (`hooks/shaping-ripple.sh`) is a deterministic bash script, and it is unit-tested.
- **Prompts**: the five skills are markdown an LLM interprets. Whether they *load and trigger* is verifiable; whether they produce *good* documents is a judgment call (the skills are deliberately GIGO). A manual checklist covers both, rather than asserting on LLM output.

Don't mistake a green suite for "the skills are good." The suite proves the plugin is **well-formed and the hook behaves correctly**. It says nothing about whether a framing doc the plugin helps write is any good.

## Layer 1: deterministic suite

Run this on every change. It needs only `bash` and `jq`, and never calls an LLM or the network.

```bash
bash test/run.sh
```

What the suite covers:

| File | Covers |
|------|--------|
| `test/validate-structure.sh` | Manifests are valid JSON; plugin and marketplace names agree; every skill has an exact-case `SKILL.md` whose frontmatter `name` matches its directory and carries a non-empty `description`; `hooks.json` registers the `Write\|Edit` PostToolUse hook, uses `${CLAUDE_PLUGIN_ROOT}`, and has no hardcoded paths; the skill count is as expected. |
| `test/test-hook.sh` | The hook blocks (exit 2 plus a checklist) **only** for `.md` files with `shaping: true` in the first 5 lines; it ignores the flag past line 5, in non-`.md` files, in plain docs, on missing paths, and on empty input; it degrades to a silent no-op when `jq` is absent. |

Run a single suite directly:

```bash
bash test/validate-structure.sh
bash test/test-hook.sh
```

The exit code is non-zero when any check fails, so the suite drops straight into CI or a pre-commit hook.

## Layer 2: deep validation

Run periodically, or before publishing. The `plugin-dev:plugin-validator` agent makes a broader pass that checks manifest schema, naming conventions, the hook's security, and component discovery:

```
Validate the plugin at /Users/mae/Documents/shape-up/shape-up
```

Layer 2 is slower and uses an agent, so it stays out of `run.sh`. Run it after structural changes or before a release.

## Layer 3: manual in-session checks

Some behaviour only exists at runtime and can't be scripted. Load the plugin into a live session:

```bash
claude --plugin-dir /Users/mae/Documents/shape-up/shape-up
```

Then check:

- [ ] `/help` lists all five skills as `shape-up:<name>`.
- [ ] Invoking one (e.g. `/shape-up:breadboarding`) loads its instructions.
- [ ] A skill is auto-selected when you describe a matching task without naming it, which tests the `description` triggers.
- [ ] **Live hook fire:** create a `.md` file containing `shaping: true` in its frontmatter, edit it, and confirm the ripple checklist appears. Edit any other file and confirm silence.
- [ ] Skill *output quality* on a sample transcript: subjective, so eyeball it.

## When you change something

- If you edit the hook script or its branches, `test/test-hook.sh` should still pass. Add a case when you add a branch.
- When you add, rename, or remove a skill, update `EXPECTED_SKILLS` in `test/validate-structure.sh`.
- After changing manifest fields, re-run Layer 1, then Layer 2 before publishing.
