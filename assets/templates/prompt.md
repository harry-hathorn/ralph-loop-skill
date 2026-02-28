# Ralph Loop Instructions

## Study Phase
1. Study `specs/spec.md` thoroughly
2. Study `specs/implementation_plan.md` thoroughly

## Repository Context
[Add repository-specific information here:
- Project structure
- Coding conventions
- Tech stack
- Important patterns or practices]

## Task Execution
3. Pick the highest leverage unchecked task from the implementation plan
4. Complete the task (writing actual code, not just planning)
5. Write tests or verify the implementation works
6. Update the implementation plan to mark the task complete

## Critical Rules
- DO NOT skip ahead - do ONE task per loop iteration
- If you encounter ambiguity, make a pragmatic decision and note it
- Always update the implementation plan after completing a task
- If a task reveals new work, add it to the implementation plan first
- Focus on working code over perfect architecture

## After Task Completion
**CRITICAL: After updating the implementation plan, create the done marker and exit.**
1. Write the done marker file: `echo "done" > .ralph-loop-complete`
2. Exit the session - the Ralph Loop script will detect the marker and continue

Do not wait for user input. Do not ask for confirmation. This is essential for Ralph Loops to work correctly - each iteration must start with a clean context window, avoiding context rot.
