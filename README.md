# Shaping Skills

A Claude Code **plugin** bundling skills for shaping and breadboarding — the methodology from [Shape Up](https://basecamp.com/shapeup) adapted for working with an LLM.

Originally a collection of standalone skills by [rjs/shaping-skills](https://github.com/rjs/shaping-skills); packaged here as a plugin so the skills and the ripple-check hook install together, with no manual symlinking or `settings.json` editing.

## What's inside

### Document skills — for collaborative work

These turn transcripts of real conversations into structured shaping documents. They're **extremely GIGO (garbage in, garbage out)** — they format and distill, they don't evaluate whether the thinking is sound. Good input → big time savings. Bad input → a nicely formatted bad document.

- **`/framing-doc`** — Turn conversation transcripts into a framing document that captures the problem worth solving and why it was chosen over alternatives.
- **`/kickoff-doc`** — Turn a shaped project kickoff transcript into a reference document for the builder, capturing what was shaped and agreed.

### Solo skills — more experimental

For working with Claude directly on shaping and design.

- **`/shaping`** — Iterate on both the problem (requirements) and solution (shapes) before committing to implementation, with fit checks to see what's solved and what isn't.
- **`/breadboarding`** — Map a system into UI affordances, code affordances, and wiring in one view. Good for slicing into vertical scopes.
- **`/breadboard-reflection`** — Sync an existing breadboard to the implementation, then find and fix design smells.

> Skills are namespaced by plugin, so they're invoked as `/shaping-skills:shaping`, `/shaping-skills:breadboarding`, etc. (or picked automatically when their description matches the task).

## Ripple-check hook

The plugin includes a `PostToolUse` hook (`hooks/shaping-ripple.sh`). When Claude writes or edits a `.md` file with `shaping: true` in its frontmatter, it prompts a checklist — update affordance tables, fit checks, work streams, etc. All other files pass through silently. Because it ships with the plugin, it activates automatically once the plugin is enabled — no `settings.json` changes needed.

## Install

**From a marketplace (local clone):**

```bash
# In Claude Code:
/plugin marketplace add /path/to/shaping-skills
/plugin install shaping-skills@shaping-skills
```

**Or load directly for testing:**

```bash
claude --plugin-dir /path/to/shaping-skills
```

## Testing

```bash
bash test/run.sh    # fast deterministic suite: manifests, frontmatter, hook behavior
```

See [TESTING.md](TESTING.md) for the full layered approach (deterministic suite, the
`plugin-validator` agent, and the manual in-session checklist for skill loading).

## Structure

```
shaping-skills/
├── .claude-plugin/
│   ├── plugin.json          # Plugin manifest
│   └── marketplace.json     # Single-plugin marketplace entry
├── skills/
│   ├── shaping/SKILL.md
│   ├── breadboarding/SKILL.md
│   ├── breadboard-reflection/SKILL.md
│   ├── framing-doc/SKILL.md
│   └── kickoff-doc/SKILL.md
├── hooks/
│   ├── hooks.json           # Wires the ripple-check hook
│   └── shaping-ripple.sh
└── test/
    ├── run.sh               # Runs the full deterministic suite
    ├── validate-structure.sh
    ├── test-hook.sh
    └── lib.sh
```

## Credit

Skills and hook by [rjs](https://github.com/rjs/shaping-skills). See the case study: [Shaping 0-1 with Claude Code](https://x.com/rjs/status/2020184079350563263) and the source project [rjs/tick](https://github.com/rjs/tick).
