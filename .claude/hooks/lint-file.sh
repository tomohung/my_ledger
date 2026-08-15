#!/bin/bash
# Lint a single Ruby file after Edit/Write
# CLAUDE_FILE_PATH is set by Claude Code hooks

if [ -z "$CLAUDE_FILE_PATH" ]; then
  exit 0
fi

if echo "$CLAUDE_FILE_PATH" | grep -qE '\.rb$'; then
  cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}" || exit 0
  bundle exec standardrb "$CLAUDE_FILE_PATH" 2>&1
fi
