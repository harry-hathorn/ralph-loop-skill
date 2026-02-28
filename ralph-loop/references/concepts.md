# Ralph Loop Concepts

## Subagent Strategy

Main context = scheduler. Don't pollute it with expensive work.
- Fan out to parallel subagents for reads/searches (up to 500)
- Only 1 subagent for build/tests (backpressure control)
- Subagents for complex reasoning (debugging, architecture)

## Backpressure

Tests, typechecks, lints, and builds reject invalid work. The build prompt says "run tests" generically — AGENTS.md specifies the actual commands per project. This is how quality gates get wired in.

## The 9s Pattern (Guardrails)

PROMPT_build.md uses escalating numbers (99999, 999999, ...) for guardrails. Higher number = more critical invariant. These are instructions that must be followed regardless of other context.

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

Each iteration: `cat PROMPT.md | claude -p --dangerously-skip-permissions`

No marker file — Claude exits naturally, bash loop restarts. Git push after each iteration.

## Steering Ralph

- **Upstream**: Specs, prompts, utilities in codebase shape what gets generated
- **Downstream**: Backpressure via tests/builds rejects bad work
- **Observe and adjust**: Watch early iterations, add guardrails when Ralph fails a specific way
- **Plan is disposable**: Delete and regenerate cheaply with `./loop.sh plan`
