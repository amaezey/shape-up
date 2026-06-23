# Shape Up

A Claude Code **plugin** for working in the [Shape Up](https://basecamp.com/shapeup) way with an LLM — shaping problems and solutions, breadboarding systems, and turning conversations into framing and kickoff docs.

It starts from the shaping and breadboarding skills by [rjs/shaping-skills](https://github.com/rjs/shaping-skills) (MIT), repackaged as a plugin so the skills and the ripple-check hook install together with no manual symlinking or `settings.json` editing — and is being extended from there with more Shape Up tooling.

## What's inside

### Document skills — for collaborative work

These turn transcripts of real conversations into structured shaping documents. They're **extremely GIGO (garbage in, garbage out)** — they format and distill, they don't evaluate whether the thinking is sound. Good input → big time savings. Bad input → a nicely formatted bad document.

- **`/framing-doc`** — Turn conversation transcripts into a framing document that captures the problem worth solving and why it was chosen over alternatives.
- **`/kickoff-doc`** — Turn a shaped project kickoff transcript into a reference document for the builder, capturing what was shaped and agreed.

### Solo skills — more experimental

For working with Claude directly on shaping and design.

- **`/shaping`** — Iterate on both the problem (requirements) and solution (shapes) before committing to implementation, with fit checks to see what's solved and what isn't.
- **`/breadboarding`** — Map a system into UI affordances, code affordances, and wiring in one view.
- **`/breadboard-reflection`** — Sync an existing breadboard to the implementation, then find and fix design smells.
- **`/slicing`** — Break a completed breadboard into vertical, demo-able implementation slices (V1–V9) and plan build order.

> Skills are namespaced by plugin, so they're invoked as `/shape-up:shaping`, `/shape-up:breadboarding`, etc. (or picked automatically when their description matches the task).

## Ripple-check hook

The plugin includes a `PostToolUse` hook (`hooks/shaping-ripple.sh`). When Claude writes or edits a `.md` file with `shaping: true` in its frontmatter, it prompts a checklist — update affordance tables, fit checks, work streams, etc. All other files pass through silently. Because it ships with the plugin, it activates automatically once the plugin is enabled — no `settings.json` changes needed.

## Install

### Claude Code

```
/plugin marketplace add amaezey/shape-up
/plugin install shape-up@shape-up
```

**Or load directly for testing:**

```bash
claude --plugin-dir /path/to/shape-up
```

## Testing

```bash
bash test/run.sh    # fast deterministic suite: manifests, frontmatter, hook behavior
```

See [TESTING.md](TESTING.md) for the full layered approach (deterministic suite, the
`plugin-validator` agent, and the manual in-session checklist for skill loading).

## Structure

```
shape-up/
├── .claude-plugin/
│   ├── plugin.json          # Plugin manifest
│   └── marketplace.json     # Single-plugin marketplace entry
├── skills/
│   ├── shaping/              # SKILL.md + references/ (spikes, documents)
│   ├── breadboarding/        # SKILL.md + references/ (examples, mermaid, chunking, whiteboard)
│   ├── breadboard-reflection/SKILL.md
│   ├── slicing/SKILL.md
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

The original shaping and breadboarding skills and the ripple-check hook are by [rjs](https://github.com/rjs/shaping-skills), MIT-licensed. See the case study: [Shaping 0-1 with Claude Code](https://x.com/rjs/status/2020184079350563263) and the source project [rjs/tick](https://github.com/rjs/tick). This plugin packages that work and extends it; new skills and tooling beyond the original scope are by Mae Kennedy.
