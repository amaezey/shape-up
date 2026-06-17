---
title: When the skill-creator triggering-optimization loop applies (and when it cannot)
date: 2026-06-17
category: tooling-decisions
module: shape-up plugin / skill descriptions
problem_type: tooling_decision
component: tooling
severity: medium
applies_when:
  - Optimizing a skill's frontmatter description for triggering accuracy
  - Deciding whether to run the skill-creator description-optimization loop (run_loop.py)
  - The skill encodes a methodology the model can already approximate (shaping, breadboarding, planning, review)
tags: [skill-creator, skill-triggering, description-optimization, claude-code-cli, methodology-skills, run-loop]
---

# When the skill-creator triggering-optimization loop applies (and when it cannot)

## Context

While tuning the `description` fields of the shape-up plugin's skills (`shaping`, `breadboarding`, etc.), we tried the skill-creator's description-optimization loop (`scripts/run_loop.py`). It optimizes the one string that controls triggering — Claude decides whether to use a skill from its name + description alone, without reading the body — by scoring candidate descriptions against a labeled eval set of should-trigger / should-not-trigger queries.

Two runs failed, and the captured baseline scored an identical, suspicious `precision=100% recall=0% accuracy=50%` for both skills. Investigation showed the harness was **not** broken — it was the wrong instrument for these skills.

## Guidance

**The loop can only produce a useful optimization gradient for skills whose task the model genuinely cannot do without them.** It detects a "trigger" by installing the skill as a command and watching a headless `claude -p` run for the model autonomously firing the `Skill` tool. For *methodology / knowledge* skills (shaping, breadboarding, planning, code review), the model believes it can just do the task directly with Bash + reasoning, so it never consults the skill — recall is pinned at ~0% **regardless of how good the description is**. With no gradient, the loop cannot optimize, and any "best" description it reports is noise.

Decision rule:

- **Use the loop** for *capability* skills — a niche file-format transform, a specialized API, a domain procedure the model has no prior knowledge of. There, triggering really is gated by the description, so the score moves.
- **Do not use the loop** for methodology skills. Instead, hand-author the description per the skill-creator's written principles (specific + deliberately "pushy" to fight under-triggering + explicit sibling disambiguation), and validate triggering by **interactive dogfooding**, not headless one-shot — headless `claude -p` is a pessimistic floor that doesn't reflect how skills surface in a real multi-turn session.

Do not "fix" a 0%-recall result by rewriting the eval queries into artificial skill-seeking phrasings — that optimizes for the test, not for how anyone actually asks.

## Why This Matters

A full run is ~600 headless `claude -p` calls on Opus across two skills. Mistaking an inherent property (methodology skills under-trigger in one-shot mode) for a description bug burns that compute and produces a confidently-wrong "optimized" description. Knowing the boundary up front saves the spend and routes you to the right method (hand-author + dogfood).

## When to Apply

- Before running `run_loop.py` on any skill — first ask: *could the model do this task without the skill?* If yes, the loop won't help.
- When a triggering eval shows ~0% recall across candidates with high precision — that's the signature of "model wings the task," not a bad description.

## Examples

Diagnostic that proved detection works but the task-doability is the real variable (all via headless `claude -p ... --output-format stream-json`, watching for a `Skill` tool_use):

- A **made-up, impossible** task — "framombulate the xyzzy records" — **fired the `Skill` tool**. Detection works.
- "map how the search feature works in the code — affordances and wiring" → **no trigger** (model went straight to Bash).
- "I want a proper breadboard of the checkout flow: the affordance tables and the wiring diagram" → **no trigger**, even though it names the exact artifact.
- "let's shape the billing revamp — work through requirements and compare approaches with a fit check" → **no trigger**, even naming the methodology.

Operational gotchas for when the loop *is* the right tool:

```bash
# 1. Use Python 3.10+ — the scripts use `str | None` unions.
#    System python3 (3.9) dies at import: TypeError: unsupported operand type(s) for |
# 2. Run from a dir containing .claude/ (so the temp command installs locally),
#    with PYTHONPATH set to the skill-creator dir.
# 3. Run loops SEQUENTIALLY — two concurrent loops saturate the Opus rate limit,
#    and improve_description's single `claude -p` call then times out at 300s.
cd <project-with-.claude>
PYTHONPATH=<skill-creator-dir> python3.13 -m scripts.run_loop \
  --eval-set evals.json --skill-path <skill-dir> \
  --model opus --max-iterations 5 --report none --verbose
```

## Related

- skill-creator skill: `scripts/run_loop.py`, `scripts/run_eval.py` (`run_single_query` is the per-query trigger probe), `scripts/improve_description.py`
- shape-up skill descriptions were ultimately hand-authored (commit "Rewrite skill descriptions for triggering"), not loop-optimized.
