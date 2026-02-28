---
name: ralph-loop
description: "Set up autonomous AI coding by having a deep bidirectional conversation with the user to produce specs and configure the project. Use when user asks to (1) set up Ralph Loop autonomous coding, (2) create or refine specs for autonomous coding workflows, (3) initialize a project with Ralph Loop, (4) discuss or plan Ralph-style autonomous coding, or (5) generate specs through bidirectional conversation for autonomous implementation. This skill is ONLY for Phase 1 — the collaborative planning and spec-writing conversation. It is NOT for running the autonomous loops."
---

# Ralph Loop

Autonomous coding via a bash loop that restarts the LLM with fresh context each iteration. Each iteration reads the plan, picks one task, implements it, commits, and exits. The loop restarts. Eventual consistency through iteration.

## What This Skill Does

**This skill handles Phase 1 only: the bidirectional conversation with the user to produce high-quality specs and configure the project for autonomous execution.**

You are NOT the autonomous loop. You are the preparation step. Your job is to have a thorough conversation with the user, understand their vision deeply, and translate it into specs that a fresh-context AI can execute autonomously. The quality of everything that follows depends entirely on how well you do this.

**NEVER write an implementation plan. NEVER start implementing code. NEVER create IMPLEMENTATION_PLAN.md.** Those are produced by `./loop.sh plan` and `./loop.sh` which the user runs separately in their terminal.

## Why This Matters

When the autonomous loop runs, the AI gets fresh context every iteration. It has NO memory of previous conversations. The ONLY things guiding it are:
- The specs you help write
- The AGENTS.md you help configure
- The prompts (PROMPT_plan.md, PROMPT_build.md)

If the specs are vague, the autonomous AI will make wrong assumptions. If AGENTS.md is misconfigured, there's no backpressure. **This conversation is the foundation for everything.** Treat it like plan mode on steroids — the more thorough you are now, the better the autonomous execution will be.

## Setup

First, initialize the scaffolding in the target project:

```bash
scripts/init_ralph.sh /path/to/project
```

This copies the template files (loop.sh, PROMPT_plan.md, PROMPT_build.md, AGENTS.md, specs/) into the project. These files have placeholders that the bidirectional conversation fills in.

Then, guide the user through the bidirectional conversation (see Phase 1 below). During this conversation, you will **write the actual files** — specs, AGENTS.md, and PROMPT_plan.md — not just discuss them. By the end of the conversation, all files should be populated and ready.

After the conversation and user review, they run the loops themselves in their terminal:
- `./loop.sh plan` — AI generates `IMPLEMENTATION_PLAN.md` autonomously
- `./loop.sh` — AI builds from the plan autonomously

## Phase 1: The Bidirectional Conversation (What You Do)

This is your entire scope. Do it well.

### Step 1: Understand the Project

Have a real conversation. Ask questions. Dig into:
- What is the user building? What problem does it solve?
- Who is it for? What are the constraints?
- What already exists? What's the starting point?
- What does "done" look like?

Do NOT accept a one-sentence description and start writing specs. Push back. Ask follow-up questions. Surface ambiguities. The user often has context in their head that hasn't been articulated — your job is to draw it out.

### Step 2: Identify Jobs to Be Done (JTBD)

Through conversation, identify the core jobs the software needs to do. These are user-centric outcomes, not technical tasks. Examples:
- "A user can sign up and log in"
- "The system processes uploaded CSVs and generates reports"
- "An admin can manage team permissions"

### Step 3: Break Into Topics of Concern

Each JTBD gets broken into focused topics. Each topic should be expressible in one sentence without "and". If you need "and", it's two topics.

Good: "User authentication via email and password"
Bad: "User authentication and profile management" (split these)

### Step 4: Write Specs (One Per Topic)

For each topic of concern, write a `specs/FILENAME.md`. Each spec should cover:
- What the feature/behavior is
- Requirements (what must be true)
- Acceptance criteria (how to verify it works)
- Edge cases and constraints
- Any technical decisions or preferences the user has expressed

**Write specs collaboratively.** Draft them, then present them to the user for review. Incorporate feedback. Iterate. A spec the user hasn't reviewed is a spec that might be wrong.

Use the spec template at `assets/templates/spec.md` as a starting point, but don't be constrained by it — the format should serve the content.

### Step 5: Configure AGENTS.md

AGENTS.md is the operational guide loaded every iteration of the autonomous loop. Set it up **together with the user** through conversation:

- **Build & Run**: Ask the user how to build and run the project. Don't guess.
- **Validation**: Ask for the actual test, typecheck, and lint commands. These provide backpressure — they're how the autonomous AI knows its work is correct. If the user doesn't have tests yet, discuss what testing strategy makes sense.
- **Operational Notes**: Ask about any quirks, gotchas, or conventions the AI should know about.
- **Codebase Patterns**: Ask about existing patterns, preferred libraries, naming conventions.

Keep AGENTS.md concise — it gets loaded into every iteration's context.

### Step 6: Configure PROMPT_plan.md

Help the user fill in the `[project-specific goal]` in PROMPT_plan.md. This should be a clear, specific statement of what the project aims to achieve.

### Step 7: Encourage Review

Before the user runs the loops, actively encourage them to:
1. **Read every spec** — Do they accurately capture intent? Anything missing?
2. **Review AGENTS.md** — Are the commands correct? Any missing context?
3. **Review PROMPT_plan.md** — Does the goal statement capture the vision?

Say something like: *"Before you run `./loop.sh plan`, I'd recommend reading through the specs and AGENTS.md to make sure everything looks right. The autonomous AI will use these as its only source of truth — anything missing or wrong here will propagate into the implementation. Take your time reviewing, and if anything needs adjustment, we can refine it."*

## Re-invocation for Refinement

The user may invoke this skill again after reviewing specs to:
- Refine or expand existing specs
- Add new specs for features they thought of
- Adjust AGENTS.md based on project evolution
- Clarify ambiguities they spotted during review

This is expected and good. Each round of refinement improves the foundation.

## What Happens After (NOT Your Job)

For reference only — you do NOT execute these phases:

**Phase 2: Planning (`./loop.sh plan`)** — The user runs this in their terminal. The autonomous AI studies specs + existing code, does gap analysis, creates `IMPLEMENTATION_PLAN.md`. Usually 1-2 iterations.

**Phase 3: Building (`./loop.sh`)** — The user runs this in their terminal. Each iteration: orient, read plan, select task, investigate, implement, validate, update plan, commit. Fresh context each time.

## Key Design Decisions

For detailed explanation of concepts (subagent strategy, backpressure, the 9s guardrail pattern, key language patterns), see [references/concepts.md](references/concepts.md).

- **AGENTS.md** is the per-project operational guide loaded every iteration. It wires in build/test commands that provide backpressure. Keep it brief — it pollutes every future loop's context.
- **PROMPT_plan.md** and **PROMPT_build.md** use deliberate language patterns ("study", "Ultrathink", "don't assume not implemented") and the escalating 9s guardrail pattern. Preserve these when customizing.
- **Plan is disposable** — delete `IMPLEMENTATION_PLAN.md` and rerun `./loop.sh plan` anytime.
