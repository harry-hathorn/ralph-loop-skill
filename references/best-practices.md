# Ralph Loop Best Practices

## Core Principle

Ralph Loops trade tokens for mental horsepower. Each LLM instance is a unit of intelligence you can spawn as many as you can afford. The bottleneck becomes your attention and time.

## How Ralph Loops Work

1. **Static Context Allocation** - Treat context windows as static, not something to be trimmed
2. **Source of Truth** - Specs and implementation plan ARE the source of truth, not previous context
3. **Fresh Context** - Each loop starts with clean context, avoiding context rot and compaction
4. **Task-by-Task** - One task per loop, then restart

## The "Dumb Zone"

Around 100k tokens used in context for Opus 4.5, performance starts rapidly dropping. Ralph loops stay below this by:
- Keeping specs and implementation plans brief
- One focused task per loop
- Treating spec/plan as source of truth instead of conversation history

## The Marker File Pattern

A critical implementation detail that makes Ralph Loops work reliably:

**Problem**: Claude CLI cannot reliably signal completion and exit programmatically. Simply asking it to exit doesn't work consistently.

**Solution**: The marker file pattern:
1. The bash script runs Claude in the background and captures its PID
2. Claude writes a marker file (`.ralph-loop-complete`) when its task is done
3. The script monitors for this file and terminates Claude when it appears
4. The marker is cleaned up for the next iteration

```bash
# Script side (run.sh)
MARKER_FILE=".ralph-loop-complete"
cat specs/prompt.md | claude --dangerously-skip-permissions &
CLAUDE_PID=$!

# Wait for marker file
while [ ! -f "$MARKER_FILE" ]; do
  if ! kill -0 "$CLAUDE_PID" 2>/dev/null; then
    break  # Claude exited unexpectedly
  fi
  sleep 1
done

# Terminate Claude and clean up
kill "$CLAUDE_PID" 2>/dev/null || true
rm -f "$MARKER_FILE"
```

```markdown
<!-- Prompt side (prompt.md) -->
## After Task Completion
**CRITICAL:** After updating the implementation plan:
1. Write the marker: `echo "done" > .ralph-loop-complete`
2. Exit immediately - the script will detect the marker and continue
```

This pattern ensures each loop iteration starts with a clean context window, avoiding context rot.

## Critical Setup Steps

### 1. Bidirectional Planning (NON-SKIPPABLE)

You and Claude ask each other questions until you're both on the exact same page. This reveals implicit assumptions Claude made that would become bugs.

**Do NOT manually write specs.** Generate them through conversation, then review and edit every single line and sign off.

### 2. Create a PIN (Project Information Note)

A markdown file with lookup tables linking to specific features with descriptions. Helps the agent find context instead of hallucinating.

### 3. Write the Prompt

Surprisingly simple:
- Study spec.md thoroughly
- Study implementation_plan.md thoroughly
- Pick the highest leverage unchecked task
- Complete the task
- Write an unbiased unit test

**Do NOT tell it which task to do.** Let the agent decide what's most important.

### 4. Run While Watching

Run the loop and WATCH intently at first. If Ralph goes off track:
- Stop the loop
- Edit the spec
- Restart the loop

This teaches you model behavior and creates a bulletproof spec.

### 5. One Mission Per Loop

Each loop should have ONE goal. Not "build this feature e2e" or "implement feature X and Y."

One thing → test passes → update plan → next loop.

## What Ralph Loops Fix

**Context Rot:**
- Traditional agentic coding: same session grows, compaction occurs, summaries poison context
- Ralph loops: fresh context each time, spec/plan as source of truth

**Mold the Clay on the Pottery Wheel**
- The conversation builds context, not just the final output

## Three Ways to Use Ralph Loops

### 1. Production Mode (Most Difficult)
- Full spec and implementation plan
- Bidirectional planning completed
- Run while watching, adjust as needed
- Test thoroughly, read every line of code
- Best for: Well-defined features you want to ship autonomously

### 2. Exploration Mode (No Downsides)
- 5 minutes brain dumping into Claude
- Quick spec and tasks (not worrying too much)
- Launch Ralph loop and walk away
- Best for: Back burner projects, research tasks, MVPs, spikes
- Perfect for: Using up tokens before daily reset

### 3. Brute Force Testing
- **Security:** Every attack vector systematically
- **UI:** Every user-facing action (login, checkout, search, forms)
- Give Claude browser access for end-to-end testing
- Best for: Overnight comprehensive testing

## Common Mistakes

### Using the Anthropic Plugin
The plugin runs the loop INSIDE Claude Code. This is wrong.
- **Correct:** Bash loop controls Claude Code (starts, stops, restarts)
- **Plugin:** Claude Code controls the loop (same context, same rot)

### Skipping the Planning
Most people skip straight to the loop. This is like using a power drill before learning to use a screwdriver.

### Letting It Run Blindly
Don't just let it run autonomously from the start. Watch, adjust, THEN trust.

### Too Much Context
If spec is too big, Ralph suffers from context rot during every loop. Keep specs brief.

### Multiple Tasks Per Loop
One task per loop. Sequential execution creates worse results.

### Forgetting the Marker File
The prompt must include instructions to write `.ralph-loop-complete` and exit. Without this, the loop will hang forever waiting for a marker that never appears.

## Downsides to Consider

1. **Not Token Efficient** - Parallel loops = exponential token use
2. **Quality Trade-off** - Reduced attention = potential quality reduction
3. **Spec Size Risk** - Too big = context rot during loops
4. **Bug Poisoning** - Bad test or bug can derail future loops
5. **Planning Difficulty** - Knowing exactly what you want is hard

## Cost

~$10/hour using Sonnet when done correctly.

If you're spending more, you're not preparing enough before running the loop.

## Final Wisdom

"The more you put into the plan, the more you get out of Ralph."

- Learn to use a screwdriver before the power drill
- Markdown files matter more than the loop itself
- Done correctly, can ship massive features autonomously
