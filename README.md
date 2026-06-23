# Shape Up

A Claude Code plugin for doing [Shape Up](https://basecamp.com/shapeup) work with Claude: shaping problems and solutions before you build, mapping how a system fits together, and turning messy call transcripts into documents your team can actually use.

It packages the shaping and breadboarding skills from [rjs/shaping-skills](https://github.com/rjs/shaping-skills) (MIT) as a plugin, so the skills and the ripple-check hook install in one step. No symlinking, no editing `settings.json`. From there it adds a few more skills of its own.

## What it's good for (and what it isn't)

Shape Up gives Claude six skills that structure your thinking at different stages of a project. They take what you hand them and give it a usable shape. What they don't do is decide whether your thinking is any good.

That gap matters most for the document skills. Feed `/framing-doc` a thoughtful product conversation and you get back a clean frame in a fraction of the time it would take to write by hand. Feed it a rambling, half-baked call and you get a clean document built on rambling, half-baked ideas. Garbage in, garbage out, and the output looks polished either way, so judging the input is on you.

A few things it won't do:

- It won't tell you whether your idea is worth building. Use your own judgment, or something like office-hours, for that.
- It won't write your code or run your project. It produces documents and maps; you build from them.
- The document skills need a real transcript to work from. No transcript, nothing useful comes out.

## The skills

Invoke a skill by name (`/shape-up:shaping`) or just describe what you're doing and let Claude pick the one that matches.

### Working from a conversation

- `/framing-doc` turns one or more call transcripts into a framing document: the problem worth solving, and why this one rather than the alternatives.
- `/kickoff-doc` turns a kickoff-call transcript into a reference doc for whoever builds the thing, capturing what got shaped and agreed.

### Shaping and designing with Claude

These are newer and rougher than the document skills. Expect to steer them more.

- `/shaping` works the problem and the candidate solutions together before you commit, with fit checks that show what each approach solves and what it leaves open.
- `/breadboarding` maps a feature into its UI affordances, code affordances (handlers, queries, services, stores), and the wiring between them, in one view. Good for understanding existing code or designing something new.
- `/slicing` takes a finished breadboard and cuts it into vertical, demo-able slices so you know what to build first.
- `/breadboard-reflection` checks an existing breadboard against the real code and fixes the design smells that crept in.

## How they fit together

A full pass through a project tends to run like this:

1. You have a few product conversations. `/framing-doc` distills them into the problem to solve.
2. `/shaping` pins down requirements and weighs solutions until one fits.
3. `/breadboarding` turns the chosen shape into a concrete map of affordances and wiring.
4. `/slicing` breaks that map into build-and-demo increments.
5. `/kickoff-doc` writes up the handoff for whoever builds it.
6. Once code exists, `/breadboard-reflection` keeps the map honest as the implementation drifts.

You won't always need all six, or that exact order. Reach for whichever one fits where you are.

## The ripple-check hook

The plugin ships a `PostToolUse` hook. Whenever Claude writes or edits a `.md` file that has `shaping: true` in its frontmatter, the hook prints a short checklist prompting you to re-check that the affordance tables and fit checks still hold. It's a nudge to keep a shaping doc consistent with itself after an edit. Every other file passes through untouched. The hook installs and turns on with the plugin, so there's nothing to wire up.

## Install

### In Claude Code

Run these as two separate commands. The prompt takes one slash command at a time, so paste the first, let it finish, then paste the second:

```
/plugin marketplace add amaezey/shape-up
/plugin install shape-up@shape-up
```

### From your terminal

One paste, both steps:

```bash
claude plugin marketplace add amaezey/shape-up && claude plugin install shape-up@shape-up
```

### Loading a local checkout

If you've cloned the repo and want to run your own copy:

```bash
claude --plugin-dir /path/to/shape-up
```

## Working on the plugin itself

This section is only for people changing the plugin, not using it.

The repo has a test suite that catches the things that break a plugin in ways you won't notice until a user hits them: malformed manifests, missing skill frontmatter, a hook that doesn't fire when it should. Run it before you commit:

```bash
bash test/run.sh
```

[TESTING.md](TESTING.md) covers the rest: what the deterministic suite checks, how to run the `plugin-validator` agent, and the manual in-session checklist for confirming skills actually load.

## What's in the repo

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
