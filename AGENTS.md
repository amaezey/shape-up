# AGENTS.md

Guidance for AI agents working in this repository.

## What this is

**shape-up** — a Claude Code plugin packaging Shape Up skills (shaping, breadboarding, slicing, framing/kickoff docs) plus a ripple-check hook. The plugin manifest is `.claude-plugin/plugin.json`; everything else is discovered from it.

## Layout

```
.claude-plugin/   plugin.json + marketplace.json (manifests)
skills/<name>/    one skill per dir, each a SKILL.md with name+description frontmatter
  └ references/   depth-on-demand files a skill points to (loaded only when needed)
hooks/            hooks.json wires shaping-ripple.sh (PostToolUse on Write|Edit)
test/             deterministic suite (run.sh) — structure, frontmatter, hook behavior
docs/solutions/   documented solutions to past problems (see below)
```

## Conventions

- **Skills** are `skills/<name>/SKILL.md`. The frontmatter `description` is the entire trigger mechanism (the body isn't read until the skill fires), so keep it specific and disambiguated from sibling skills. Keep bodies lean; move depth to `references/` with a pointer.
- **Affordance vocabulary** is unified across skills: **UI Affordances / Code Affordances / Data Stores**. Don't reintroduce "Non-UI".
- **Shaping documents** carry `shaping: true` frontmatter, which the ripple-check hook keys on. The hook is advisory (stderr + exit 2), never destructive.
- **Tests**: run `bash test/run.sh` after changing skills, manifests, or the hook. `EXPECTED_SKILLS` in `test/validate-structure.sh` tracks the skill count — bump it when adding/removing a skill.

## Documented solutions

`docs/solutions/` holds documented solutions to past problems (bugs, best practices, tooling decisions, workflow patterns), organized by category with YAML frontmatter (`module`, `tags`, `problem_type`, `component`). Relevant when implementing or debugging in a documented area — a quick search there can surface prior investigation, dead ends, and rationale before you start.
