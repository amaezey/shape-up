# Shape Up

Shape Up skills for Claude Code: shape work before you build it, map how a system fits together, and turn meeting transcripts into documents a team can build from.

The plugin packages the shaping and breadboarding skills from [rjs/shaping-skills](https://github.com/rjs/shaping-skills), MIT-licensed, and adds four more. Installing brings every skill and its hook together in one step, with no manual symlinking or `settings.json` editing.

## What it does

Shape Up is Basecamp's method for defining work before committing to it. The plugin turns six parts of the method into Claude Code skills.

The skills structure your input into a document; they will not judge whether the thinking behind it is sound. Hand `/framing-doc` a well-thought-through conversation and the frame reflects it, produced faster than writing one by hand. Hand it a rambling call and you get a well-formatted document built on nothing, so vetting the input is still your job.

The plugin has limits:

- It will not tell you whether an idea is worth building. Bring your own judgment.
- The skills produce documents and maps to build from, not code.
- The document skills need a transcript, and produce nothing without one.

## Workflow

Each skill is a stage of the work. You frame the problem from your conversations, shape a solution against its requirements, breadboard the chosen shape into concrete affordances, slice the breadboard into demoable increments, and write the kickoff for whoever builds it. Once code exists, breadboard-reflection pulls the map back in line with the implementation.

| Skill | Purpose |
| --- | --- |
| `/framing-doc` | Turn call transcripts into a framing doc: the problem worth solving, and why this one over the alternatives |
| `/shaping` | Work the problem and the candidate solutions together, with fit checks that show what each solution covers and what it leaves open |
| `/breadboarding` | Map a feature into its UI affordances, its code affordances, and the wiring between them |
| `/slicing` | Cut a finished breadboard into vertical demoable slices, then put them in build order |
| `/kickoff-doc` | Turn a kickoff-call transcript into a reference doc for whoever builds the project |
| `/breadboard-reflection` | Check a breadboard against the code and fix the design smells that crept in |

`/framing-doc` and `/kickoff-doc` each take a transcript and return one structured document, so you can rely on the shape of what comes back. The four design skills are open-ended, so their output varies and you redraft more often.

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

Invoke a skill by its namespaced name as shown here, or describe what you are doing and let Claude pick the matching skill.

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

## Testing

How to test the plugin. Only relevant if you are modifying your own copy.

The repo carries a test suite for the failures you will not notice until a user does: a malformed manifest, a skill missing its frontmatter, a hook that never fires. Run it before you commit:

```bash
bash test/run.sh
```

[TESTING.md](TESTING.md) covers the full approach: what the deterministic suite checks, how to run the `plugin-validator` agent, and the in-session checklist for confirming skills load.

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

The original shaping and breadboarding skills and the ripple-check hook are by [rjs](https://github.com/rjs/shaping-skills), MIT-licensed. See the case study, [Shaping 0-1 with Claude Code](https://x.com/rjs/status/2020184079350563263), and the source project [rjs/tick](https://github.com/rjs/tick). The plugin repackages that work and extends it; the skills and tooling beyond the original scope are by Mae Kennedy.
