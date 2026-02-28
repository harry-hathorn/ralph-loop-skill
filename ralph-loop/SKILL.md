---
name: ralph-loop
description: "Autonomous AI coding workflow using fresh context per iteration. Use when user asks to (1) set up Ralph Loop autonomous coding, (2) create specs or prompts for autonomous coding workflows, (3) initialize a project with Ralph Loop, (4) discuss or plan Ralph-style autonomous coding, or (5) generate specs through bidirectional conversation for autonomous implementation"
---

# Ralph Loop

Autonomous coding via a bash loop that restarts Claude with fresh context each iteration. Each iteration reads the plan, picks one task, implements it, commits, and exits. The loop restarts. Eventual consistency through iteration.

## Setup

Initialize in a target project:

```bash
scripts/init_ralph.sh /path/to/project
```

After init, guide the user through:
1. Edit `PROMPT_plan.md` — replace `[project-specific goal]` with their actual goal
2. Edit `AGENTS.md` — replace `[test command]`, `[typecheck command]`, `[lint command]` with real commands
3. Generate specs in `specs/` (one per topic of concern — see Phase 1 below)
4. `./loop.sh plan` — Ralph generates `IMPLEMENTATION_PLAN.md`
5. `./loop.sh` — Ralph builds from the plan

## Three Phases

### Phase 1: Define Requirements (human + LLM conversation)

Generate specs through bidirectional discussion — do NOT manually write them.

1. Discuss project ideas, identify Jobs to Be Done (JTBD)
2. Break each JTBD into topics of concern (one sentence without "and")
3. Write `specs/FILENAME.md` for each topic — one spec per topic, focused on requirements and acceptance criteria

### Phase 2: Planning (`./loop.sh plan`)

Ralph studies specs + existing code, does gap analysis, creates `IMPLEMENTATION_PLAN.md`. No implementation. Usually 1-2 iterations.

### Phase 3: Building (`./loop.sh`)

Each iteration: orient, read plan, select task, investigate, implement, validate, update plan, update AGENTS.md, commit. Fresh context each time.

## Key Design Decisions

For detailed explanation of concepts (subagent strategy, backpressure, the 9s guardrail pattern, key language patterns), see [references/concepts.md](references/concepts.md).

- **AGENTS.md** is the per-project operational guide loaded every iteration. It wires in build/test commands that provide backpressure. Keep it brief — it pollutes every future loop's context.
- **PROMPT_plan.md** and **PROMPT_build.md** use deliberate language patterns ("study", "Ultrathink", "don't assume not implemented") and the escalating 9s guardrail pattern. Preserve these when customizing.
- **Plan is disposable** — delete `IMPLEMENTATION_PLAN.md` and rerun `./loop.sh plan` anytime.
