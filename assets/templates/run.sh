#!/bin/bash
# Ralph Loop - runs Claude with fresh context each iteration
# See: https://github.com/ghuntley/how-to-ralph-wiggum

set -e
MARKER_FILE=".ralph-loop-complete"

echo "Ralph Loop starting..."
rm -f "$MARKER_FILE"

while true; do
  echo "Starting iteration..."

  cat specs/prompt.md | claude --dangerously-skip-permissions &
  CLAUDE_PID=$!

  echo "Waiting for task completion..."
  while [ ! -f "$MARKER_FILE" ]; do
    if ! kill -0 "$CLAUDE_PID" 2>/dev/null; then
      echo "Claude exited unexpectedly"
      break
    fi
    sleep 1
  done

  sleep 1

  if kill -0 "$CLAUDE_PID" 2>/dev/null; then
    echo "Task complete, terminating Claude..."
    kill "$CLAUDE_PID" 2>/dev/null || true
    wait "$CLAUDE_PID" 2>/dev/null || true
  fi

  rm -f "$MARKER_FILE"
  echo "───────────────────────────────────────"
  sleep 2
done
