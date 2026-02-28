---
name: ralph-loop
description: "Autonomous AI coding workflow that trades tokens for mental horsepower. Guide users through setting up Ralph Loops - bidirectional planning, creating specs/implementation plans, writing the prompt, and running the bash loop. Use when user asks to (1) Set up Ralph Loops for autonomous coding, (2) Create spec.md, implementation_plan.md, or prompt.md files, (3) Initialize autonomous coding workflows, (4) Set up AI agent loops for feature implementation, (5) Run Ralph or similar autonomous coding requests"
---

# Ralph Loop

Autonomous AI coding workflow that treats specs and implementation plans as the source of truth, avoiding context rot through fresh context each iteration.

## Core Principle

Ralph Loops = trading tokens for mental horsepower. Each LLM instance is a unit of intelligence you can spawn as many as you can afford.

## Quick Start

```bash
# Initialize Ralph Loop files in your project
scripts/init_ralph.sh /path/to/your/project

# This creates:
# - specs/spec.md (feature specification)
# - specs/implementation_plan.md (task checklist)
# - specs/prompt.md (loop instructions)
# - run.sh (bash loop script)
```

## Workflow

### Step 1: Bidirectional Planning

**CRITICAL: Do not skip this step.**

You and Claude ask each other questions until you're both on the exact same page. This reveals implicit assumptions that become bugs.

Ask questions like:
- "What are the edge cases for this feature?"
- "How should we handle errors?"
- "What's the expected user flow?"
- "Are there any constraints I should know about?"

**Do NOT manually write specs.** Generate them through conversation.

### Step 2: Create the Specification

Edit `specs/spec.md` with:
- Feature name
- Problem statement
- Requirements (as a list)
- Constraints (if any)

Keep it BRIEF. The spec must stay below the dumb zone (~100k tokens for Opus 4.5).

### Step 3: Create the Implementation Plan

Edit `specs/implementation_plan.md` with checkboxed tasks:

```markdown
# Implementation Plan

- [ ] Create data model
- [ ] Build import API
- [ ] Add category logic
- [ ] Create dashboard UI
- [ ] Write tests
```

Each bullet = one task. Let Ralph decide priority, don't number them.

### Step 4: Write the Prompt

Edit `specs/prompt.md` with repository context:

```markdown
# Ralph Loop Instructions

## Study Phase
1. Study `specs/spec.md` thoroughly
2. Study `specs/implementation_plan.md` thoroughly

## Repository Context
- Project structure: src/, tests/, docs/
- Framework: React + TypeScript
- Testing: Vitest

## Task Execution
3. Pick the highest leverage unchecked task
4. Complete the task (writing actual code, not just planning)
5. Write tests or verify the implementation works
6. Update the implementation plan to mark the task complete

## Critical Rules
- DO NOT skip ahead - do ONE task per loop iteration
- If you encounter ambiguity, make a pragmatic decision and note it
- Always update the implementation plan after completing a task
- Focus on working code over perfect architecture

## After Task Completion
**CRITICAL: After updating the implementation plan, create the done marker and exit.**
1. Write the done marker file: `echo "done" > .ralph-loop-complete`
2. Exit the session - the Ralph Loop script will detect the marker and continue
```

**Do NOT tell it which task to do.** Let the agent decide.

**IMPORTANT:** The marker file pattern (`echo "done" > .ralph-loop-complete`) is required for the loop to work. The `run.sh` script monitors for this file to know when Claude has completed its task.

### Step 5: Run While Watching

```bash
./run.sh
```

The script uses a marker file pattern to detect task completion:
- Claude creates `.ralph-loop-complete` when done
- The script monitors for this file and terminates Claude when it appears
- This ensures clean context for each iteration

WATCH intently at first. If Ralph goes off track:
1. Stop the loop (Ctrl+C)
2. Edit the spec
3. Restart the loop

This teaches you model behavior and creates a bulletproof spec.

### Step 6: Go Autonomous

Once Ralph looks on track, you can walk away. Come back to:
- Run all tests
- Skim the code
- Decide whether to change specs and restart

## Three Modes

### Production Mode
- Full bidirectional planning
- Complete spec and implementation plan
- Run while watching, adjust as needed
- Test thoroughly, read every line

### Exploration Mode
- 5 minutes brain dump
- Quick spec (don't worry too much)
- Launch and walk away
- Best for: back burner projects, token utilization before reset

### Brute Force Testing
- Every attack vector (security)
- Every user action (UI)
- Give Claude browser access for e2e tests

## Critical Rules

1. **One task per loop** - Not "build feature e2e", just "create data model"
2. **Keep specs brief** - Avoid context rot during loops
3. **Don't use the Anthropic plugin** - It runs the loop inside Claude (wrong)
4. **Plan before running** - Learn screwdriver before power drill
5. **Read every line** - Sign off on spec and plan before running
6. **Use the marker file** - The prompt must write `.ralph-loop-complete` and exit - this is non-negotiable for the loop to work

## Common Mistakes

- **Plugin loop**: Loop runs inside Claude = same context rot
- **Blind running**: Letting it run without watching first
- **Too much context**: Spec too big = dumb zone every loop
- **Multiple tasks**: One thing per loop, then restart
- **Skipping planning**: Manual specs miss implicit assumptions
- **No marker file**: Forgetting to have Claude write `.ralph-loop-complete` and exit = infinite hang

## Resources

- **templates/**: Template files for spec.md, implementation_plan.md, prompt.md, run.sh
- **best-practices.md**: Detailed explanation of Ralph Loop principles and patterns

★ Insight ─────────────────────────────────────
- **Context as Static Allocation**: Traditional agentic coding treats context as something to be managed and trimmed. Ralph treats it as static - spec + plan = source of truth, not conversation history.
- **The Plugin Problem**: The bash loop must control Claude, not vice versa. Anthropic's Ralph plugin runs inside Claude, defeating the purpose.
- **The Marker File Pattern**: Claude CLI cannot reliably signal completion and exit programmatically. The solution is a marker file (`.ralph-loop-complete`) that Claude writes when done; the bash script monitors for this file and terminates Claude. This ensures clean context for each iteration.
- **Planning Leverage**: "The more you put into the plan, the more you get out of Ralph." The skill isn't running the loop - it's architecting a good plan.
─────────────────────────────────────────────────
