# Ralph Loop

AI writes code while you sleep.

## How It Works

```
┌─────────────────────────────────────────┐
│  1. You write a plan (spec.md)          │
│  2. Script starts Claude                 │
│  3. Claude does ONE task                 │
│  4. Claude writes marker file            │
│  5. Script kills Claude                  │
│  6. Repeat with fresh Claude             │
└─────────────────────────────────────────┘
```

## Why It Works

**Fresh start each time** — Claude forgets everything between tasks. No confusion buildup.

**Plan is king** — The spec file is the truth. Not the chat history.

**One thing at a time** — Small tasks. Clear goals. Better code.

## Quick Start

```bash
./scripts/init_ralph.sh /your/project
# Edit specs/spec.md and specs/implementation_plan.md
# Run ./run.sh
```

## The Secret Sauce

A marker file (`.ralph-loop-complete`) tells the script when Claude is done. Script kills Claude. Fresh Claude starts. Repeat forever.

## Files

| File | Purpose |
|------|---------|
| `spec.md` | What to build |
| `implementation_plan.md` | Checklist of tasks |
| `prompt.md` | Instructions for Claude |
| `run.sh` | The loop script |

## Rules

1. Write specs together (you + AI), not alone
2. One task per loop
3. Watch closely at first, then walk away
