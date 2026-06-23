# Shape Up

Shape Up skills for Claude Code: shape the work before you build it, map how a system fits together, and turn raw conversations into the documents a team builds from.

This plugin packages the shaping and breadboarding skills from [rjs/shaping-skills](https://github.com/rjs/shaping-skills) (MIT), then adds four more of its own. Installing it brings every skill and the ripple-check hook in one step, so you skip the manual symlinking and `settings.json` editing.

## What it does

Shape Up is Basecamp's method for defining work before committing to it. This plugin brings six of its moves into Claude Code as skills.

The skills give your raw input a usable shape, but they will not judge whether the thinking behind that input is sound. Hand `/framing-doc` a sharp product conversation and a sharp frame comes back, far faster than writing one by hand. Hand it a rambling call and you get tidy nonsense, formatted just as nicely, so vetting the input stays your job.

Three limits worth knowing up front:

- Shape Up will not tell you whether an idea is worth building. Bring your own judgment.
- The skills produce documents and maps, not code. You build from those.
- The document skills need a real transcript. Without one, nothing useful comes out.

## Workflow

The work moves through stages, and each skill owns one. You frame the problem from your conversations, shape a solution against its requirements, breadboard the chosen shape into concrete affordances, slice the breadboard into demoable increments, and write the kickoff for whoever builds it. Once code exists, breadboard-reflection pulls the map back in line with what was actually built.

| Skill | Purpose |
| --- | --- |
| `/framing-doc` | Turn call transcripts into a framing doc: the problem worth solving, and why this one over the alternatives |
| `/shaping` | Work the problem and the candidate solutions together, with fit checks that show what each solution covers and what it leaves open |
| `/breadboarding` | Map a feature into its UI affordances, its code affordances, and the wiring between them |
| `/slicing` | Cut a finished breadboard into vertical demoable slices, then put them in build order |
| `/kickoff-doc` | Turn a kickoff-call transcript into a reference doc for whoever builds the project |
| `/breadboard-reflection` | Check a breadboard against the real code and fix the design smells that crept in |

The two document skills, `/framing-doc` and `/kickoff-doc`, are the steady ones. The four design skills are newer and rougher, so expect to steer them more.

## Quick Example

A new feature, from the first conversation to the builder handoff:

```text
/shape-up:framing-doc transcripts/discovery-call.vtt
/shape-up:shaping
/shape-up:breadboarding
/shape-up:slicing
/shape-up:kickoff-doc transcripts/kickoff-call.vtt
```

Auditing a breadboard after the implementation has moved on without it:

```text
/shape-up:breadboard-reflection
```

Invoke a skill by its namespaced name as shown here, or just describe what you are doing and let Claude pick the matching skill.

## The ripple-check hook

The plugin ships a `PostToolUse` hook. Whenever Claude writes or edits a `.md` file carrying `shaping: true` in its frontmatter, the hook prints a short checklist prompting you to re-check that the affordance tables and fit checks still hold, so a shaping doc stays consistent with itself after each edit. Every other file passes through untouched. The hook installs and switches on with the plugin, so there is nothing to wire up.

## Install

### In Claude Code

Run the two commands one at a time. The prompt takes a single slash command per submission, so let the first finish before you send the second:

```
/plugin marketplace add amaezey/shape-up
/plugin install shape-up@shape-up
```

### From a terminal

Both steps in one paste:

```bash
claude plugin marketplace add amaezey/shape-up && claude plugin install shape-up@shape-up
```

### A local checkout

To run a clone of the repo as your own copy:

```bash
claude --plugin-dir /path/to/shape-up
```

## Working on the plugin

This section is for changing the plugin, not using it.

The repo carries a test suite for the failures you will not notice until a user does: a malformed manifest, a skill missing its frontmatter, a hook that never fires. Run the suite before you commit:

```bash
bash test/run.sh
```

[TESTING.md](TESTING.md) documents the rest, including what the deterministic suite checks, how to run the `plugin-validator` agent, and the in-session checklist for confirming skills load.

## Repo layout

```
shape-up/
├── .claude-plugin/
│   ├── plugin.json          # Plugin manifest
│   └── marketplace.json     # Single-plugin marketplace entry
├── skills/
│   ├── shaping/              # SKILL.md + references/
│   ├── breadboarding/        # SKILL.md + references/
│   ├── breadboard-reflection/SKILL.md
│   ├── slicing/SKILL.md
│   ├── framing-doc/SKILL.md
│   └── kickoff-doc/SKILL.md
├── hooks/
│   ├── hooks.json            # Wires the ripple-check hook
│   └── shaping-ripple.sh
└── test/
    ├── run.sh                # Runs the full deterministic suite
    ├── validate-structure.sh
    ├── test-hook.sh
    └── lib.sh
```

## Credit

The original shaping and breadboarding skills and the ripple-check hook are by [rjs](https://github.com/rjs/shaping-skills), MIT-licensed. See the case study, [Shaping 0-1 with Claude Code](https://x.com/rjs/status/2020184079350563263), and the source project [rjs/tick](https://github.com/rjs/tick). This plugin repackages that work and extends it; the skills and tooling beyond the original scope are by Mae Kennedy.
