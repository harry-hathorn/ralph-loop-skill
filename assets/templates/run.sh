#!/bin/bash
# Ralph Loop - Autonomous AI Coding
# See: https://github.com/geoffreyhuntley/ralph-wiggum

set -e

# Marker file that signals task completion
MARKER_FILE=".ralph-loop-complete"

echo "🤖 Ralph Loop Starting..."
echo "📖 Studying specs/spec.md and specs/implementation_plan.md"
echo ""

# Clean up any stale marker
rm -f "$MARKER_FILE"

while true; do
  echo "🚀 Starting new iteration..."

  # Run Claude in background, saving PID
  cat specs/prompt.md | claude --dangerously-skip-permissions &
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

  # Clean up marker for next iteration
  rm -f "$MARKER_FILE"

  # Small delay between iterations
  echo ""
  echo "─────────────────────────────────────────────────────────────"
  echo "Loop iteration complete. Brief pause before next iteration..."
  echo "─────────────────────────────────────────────────────────────"
  echo ""
  sleep 2
done
