0a. Study `specs/*` with up to 250 parallel subagents to learn the application specifications.
0b. Study @IMPLEMENTATION_PLAN.md (if present) to understand the plan so far.
0c. Study `src/lib/*` with up to 250 parallel subagents to understand shared utilities & components.
0d. For reference, the application source code is in `src/*`.

1. Study @IMPLEMENTATION_PLAN.md (if present; it may be incorrect) and use up to 500 subagents to study existing source code in `src/*` and compare it against `specs/*`. Use a subagent to analyze findings and create/update @IMPLEMENTATION_PLAN.md. Ultrathink. Consider searching for TODO, minimal implementations, placeholders, skipped/flaky tests, and inconsistent patterns. Study @IMPLEMENTATION_PLAN.md to determine starting point for research and keep it up to date with items considered complete/incomplete using subagents.

## Task Granularity — CRITICAL

Each checkbox in the plan will be executed as ONE iteration by a fresh-context AI. The AI gets dumb when it tries to do too much. Tasks MUST be atomic — as small as possible.

**Rules for task sizing:**
- Each `- [ ]` checkbox = ONE file or ONE small cohesive change
- A task like "Project Setup" is TOO BIG. Break it into: "Create config files", "Create directory structure", "Install dependencies", etc.
- A task like "SID Synth" is TOO BIG if it means implementing oscillators + ADSR + LFO + quantization. Break it into: "SID oscillator waveforms", "SID ADSR envelope", "SID LFO modulation", "SID 8-bit quantization"
- If a task touches more than 2-3 files, it's probably too big — split it
- If you can describe a task only with "and" (X and Y and Z), split it into X, Y, Z
- Tests for a module are part of that module's task, not a separate task

**Ordering:** Arrange tasks in logical dependency order — each task should only depend on tasks above it. The build loop picks the next logical task, not "highest priority."

IMPORTANT: Plan only. Do NOT implement anything. Do NOT assume functionality is missing; confirm with code search first. Treat `src/lib` as the project's standard library for shared utilities and components. Prefer consolidated, idiomatic implementations there over ad-hoc copies.

ULTIMATE GOAL: We want to achieve [project-specific goal]. Consider missing elements and plan accordingly. If an element is missing, search first to confirm it doesn't exist, then if needed author the specification at specs/FILENAME.md. If you create a new element then document the plan to implement it in @IMPLEMENTATION_PLAN.md using a subagent.

## Loop Control (write EXACTLY ONE marker at end of iteration)
- More analysis needed: `echo "continue" > .loop-complete`
- Plan is complete and stable: `echo "exit" > .loop-complete`
