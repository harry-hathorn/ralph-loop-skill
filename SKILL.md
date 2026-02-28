---
name: ralph-loop
description: "Autonomous AI coding workflow using fresh context per iteration. Use when user asks to (1) Set up Ralph Loops, (2) Create spec.md, implementation_plan.md, or prompt.md files, (3) Initialize autonomous coding workflows, (4) Run Ralph or similar autonomous coding requests"
---

# Ralph Loop

Trade tokens for mental horsepower. Each LLM instance = one unit of intelligence. Spawn as many as you can afford.

## Quick Start

```bash
scripts/init_ralph.sh /path/to/project
# Creates: specs/spec.md, specs/implementation_plan.md, specs/prompt.md, run.sh
```

## Workflow

### 1. Bidirectional Planning (REQUIRED)

Ask questions back and forth until both parties agree. Reveals implicit assumptions that become bugs.

**Do NOT manually write specs.** Generate through conversation.

### 2. Create spec.md

```markdown
# Feature: [Name]

## Problem
[One sentence]

## Requirements
- [ ] Requirement 1
- [ ] Requirement 2

## Constraints
- [Any constraints]
```

Keep it brief. Under ~100k tokens total.

### 3. Create implementation_plan.md

```markdown
# Implementation Plan

- [ ] Create data model
- [ ] Build API
- [ ] Add UI
- [ ] Write tests
```

One bullet = one task. Let Ralph decide priority.

### 4. Create prompt.md

```markdown
# Ralph Loop Instructions

## Study Phase
1. Read specs/spec.md
2. Read specs/implementation_plan.md

## Repository Context
[Add: project structure, framework, testing setup]

## Execution
3. Pick highest-leverage unchecked task
4. Complete the task (write actual code)
5. Verify it works
6. Mark task complete in implementation_plan.md

## After Completion (CRITICAL)
1. Write marker: `echo "done" > .ralph-loop-complete`
2. Exit immediately

Rules: ONE task per loop. No skipping ahead.
```

### 5. Run While Watching

```bash
./run.sh
```

The script monitors `.ralph-loop-complete` to know when Claude finished.

**Watch intently at first.** If Ralph goes off track: stop, edit spec, restart.

### 6. Go Autonomous

Once on track, walk away. Return to: run tests, skim code, adjust specs if needed.

## Key Patterns

- **Marker file pattern**: Claude writes `.ralph-loop-complete`, bash script terminates Claude, fresh context next iteration
- **One task per loop**: Not "build feature", just "create data model"
- **Spec = source of truth**: Not conversation history
- **Bash controls Claude**: Not Claude controlling the loop (plugin approach = wrong)

## Common Mistakes

- Skipping planning → manual specs miss assumptions
- Too much context → dumb zone every loop
- Multiple tasks per loop → worse results
- No marker file → infinite hang
- Plugin loop → same context rot
