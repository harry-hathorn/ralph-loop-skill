#!/bin/bash
# Usage: ./loop.sh [plan] [max_iterations] [--push]
# Examples:
#   ./loop.sh              # Build mode, unlimited iterations
#   ./loop.sh 20           # Build mode, max 20 iterations
#   ./loop.sh plan         # Plan mode, unlimited iterations
#   ./loop.sh plan 5       # Plan mode, max 5 iterations
#   ./loop.sh --push       # Build mode, push after each iteration
#   ./loop.sh plan --push  # Plan mode, push after each iteration

PUSH=false

# Parse arguments
ARGS=()
for arg in "$@"; do
    if [ "$arg" = "--push" ]; then
        PUSH=true
    else
        ARGS+=("$arg")
    fi
done

if [ "${ARGS[0]}" = "plan" ]; then
    MODE="plan"
    PROMPT_FILE="PROMPT_plan.md"
    MAX_ITERATIONS=${ARGS[1]:-0}
elif [[ "${ARGS[0]}" =~ ^[0-9]+$ ]]; then
    MODE="build"
    PROMPT_FILE="PROMPT_build.md"
    MAX_ITERATIONS=${ARGS[0]}
else
    MODE="build"
    PROMPT_FILE="PROMPT_build.md"
    MAX_ITERATIONS=0
fi

ITERATION=0
CURRENT_BRANCH=$(git branch --show-current)
MARKER_FILE=".loop-complete"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Mode:   $MODE"
echo "Prompt: $PROMPT_FILE"
echo "Branch: $CURRENT_BRANCH"
echo "Push:   $PUSH"
[ $MAX_ITERATIONS -gt 0 ] && echo "Max:    $MAX_ITERATIONS iterations"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Verify prompt file exists
if [ ! -f "$PROMPT_FILE" ]; then
    echo "Error: $PROMPT_FILE not found"
    exit 1
fi

# Clean up any stale marker
rm -f "$MARKER_FILE"

while true; do
    if [ $MAX_ITERATIONS -gt 0 ] && [ $ITERATION -ge $MAX_ITERATIONS ]; then
        echo "Reached max iterations: $MAX_ITERATIONS"
        break
    fi

    ITERATION=$((ITERATION + 1))
    echo -e "\n======================== LOOP $ITERATION ========================\n"

    # Run Claude in interactive mode (background) with the prompt
    cat "$PROMPT_FILE" | claude --dangerously-skip-permissions &
    CLAUDE_PID=$!

    # Wait for the marker file to appear (signals task completion)
    echo "⏳ Waiting for task completion (watching for $MARKER_FILE)..."
    while [ ! -f "$MARKER_FILE" ]; do
        # Check if Claude process is still running
        if ! kill -0 "$CLAUDE_PID" 2>/dev/null; then
            echo "⚠️  Claude process exited unexpectedly"
            break
        fi
        sleep 1
    done

    # Claude should have written the marker - give it a moment to finish
    sleep 1

    # Terminate Claude gracefully if still running
    if kill -0 "$CLAUDE_PID" 2>/dev/null; then
        echo "📋 Task complete, terminating Claude session..."
        kill "$CLAUDE_PID" 2>/dev/null || true
        wait "$CLAUDE_PID" 2>/dev/null || true
    fi

    # Check marker content to decide whether to continue or exit
    MARKER_CONTENT=$(cat "$MARKER_FILE" 2>/dev/null || echo "continue")
    rm -f "$MARKER_FILE"

    if [ "$MARKER_CONTENT" = "exit" ]; then
        echo ""
        echo "✅ Loop exit requested - all work complete"
        break
    fi

    if [ "$PUSH" = true ]; then
        git push origin "$CURRENT_BRANCH" || {
            echo "Failed to push. Creating remote branch..."
            git push -u origin "$CURRENT_BRANCH"
        }
    fi

    echo ""
    echo "─────────────────────────────────────────────────────────────"
    echo "Loop iteration complete. Brief pause before next iteration..."
    echo "─────────────────────────────────────────────────────────────"
    sleep 2
done
