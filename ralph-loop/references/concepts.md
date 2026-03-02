# Ralph Loop Concepts

## Subagent Strategy

Main context = scheduler. Don't pollute it with expensive work.
- Fan out to parallel subagents for reads/searches (up to 500)
- Only 1 subagent for build/tests (backpressure control)
- Subagents for complex reasoning (debugging, architecture)

## Backpressure

Tests, typechecks, lints, and builds reject invalid work. The build prompt says "run tests" generically — AGENTS.md specifies the actual commands per project. This is how quality gates get wired in.

## The 9s Pattern (Guardrails)

PROMPT_build.md uses escalating numbers (99999, 999999, ...) for guardrails. These are instructions that must be followed regardless of other context. The guardrails are consolidated to avoid diluting the critical one-task constraint — fewer but more focused.

## Key Language Patterns

These phrasings are deliberate and should be preserved:
- "study" (not "read") — deeper engagement with code
- "don't assume not implemented" — prevents duplicate work
- "using parallel subagents" / "up to N subagents" — controls fan-out
- "Ultrathink" — triggers extended reasoning
- "capture the why" — documentation quality
- "resolve them or document them" — nothing gets ignored

## Loop Mechanics

`loop.sh` supports two modes via arguments:

| Usage | Mode | What happens |
|---|---|---|
| `./loop.sh plan` | Planning | Uses PROMPT_plan.md, gap analysis only |
| `./loop.sh plan 5` | Planning | Max 5 iterations |
| `./loop.sh` | Building | Uses PROMPT_build.md, implements from plan |
| `./loop.sh 20` | Building | Max 20 iterations |
| `./loop.sh --push` | Building | Push to remote after each iteration |
| `./loop.sh plan --push` | Planning | Push to remote after each iteration |

Each iteration, the loop prepends an iteration number and constraint reminder, pipes the prompt, and backgrounds Claude:
```
{ echo "# ITERATION N — ..."; cat PROMPT.md; } | claude --dangerously-skip-permissions &
```

Claude runs in interactive mode (no `-p`) so the TUI is visible and the user can observe progress. The loop polls for a `.loop-complete` marker file — when Claude writes it (`continue` or `exit`), the loop kills the Claude process and either starts the next iteration or stops. A `trap` handler ensures Ctrl+C cleanly kills both the loop and any running Claude process. Push is opt-in (`--push`) to avoid hanging on SSH password prompts.

## One-Task Enforcement

The loop's entire value proposition depends on fresh context per iteration. When the AI implements multiple tasks in one go, it defeats this pattern — context accumulates, mistakes compound, and the commit history becomes unreviewable.

### The Bundling Problem

The AI naturally wants to read everything and build a complete mental model. This makes it drift into "whole project" mode. Worse, if plan items are coarse-grained (e.g., "Project Setup" that includes configs + directory structure + source scaffolds + tests + dependency install), the AI treats the entire bucket as "one task" and checks off 5+ boxes in a single iteration. The fix is two-sided:

1. **Atomic plan items** — PROMPT_plan.md enforces that tasks are atomic — as small as possible. Each checkbox = one file or one small cohesive change. "Project Setup" becomes 3-4 separate checkboxes. The AI can't bundle what's already been split.
2. **One-checkbox enforcement** — PROMPT_build.md counts checkboxes, not conceptual tasks. "If you check off more than one box, you have done too much."

### Task Selection

The build prompt says "next logical task" not "highest priority." The AI should pick the task whose dependencies are already done, in the natural order the plan presents them. This prevents the AI from jumping around and doing foundation + advanced work in one pass.

### Structural Techniques

1. **Scope header** — The first line of PROMPT_build.md is an unmissable constraint: "ONE checkbox. ONE commit. Then EXIT." The loop also prepends an iteration-specific reminder before the prompt body.
2. **Narrowed study phase** — The workflow reads the plan FIRST (to pick one task), then only specs relevant to that task. This replaces the previous "study all specs with 500 subagents" approach that primed broad exploration.
3. **Declaration checkpoint** — Step 1 forces the AI to state the EXACT checkbox text before making any changes. This creates a commitment point.
4. **Scope guard in implement step** — Step 2 explicitly warns: "If you notice adjacent work that would be easy to do while you're here — STOP. That's a different checkbox for a different iteration."
5. **Update step counts boxes** — Step 4 says "you should be checking off exactly ONE box."
6. **Inline exit** — The EXIT/STOP is step 5 in the workflow. "STOP. This is the end of your iteration. Do not continue working."
7. **Explicit DO NOT section** — Anti-patterns are called out: don't check off multiple boxes, don't bundle related work, don't study all specs, don't keep working after commit.

## Steering Ralph

- **Upstream**: Specs, prompts, utilities in codebase shape what gets generated
- **Downstream**: Backpressure via tests/builds rejects bad work
- **Observe and adjust**: Watch early iterations, add guardrails when Ralph fails a specific way
- **Plan is disposable**: Delete and regenerate cheaply with `./loop.sh plan`
