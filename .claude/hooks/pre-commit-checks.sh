#!/bin/bash
# Run full CI checks before git commit

# Read hook input from stdin
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# Only run checks for git commit commands
if [ -z "$COMMAND" ] || ! echo "$COMMAND" | grep -q 'git commit'; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}" || exit 0

# Ensure Ruby/bundler are available
export PATH="$HOME/.asdf/shims:$HOME/.asdf/bin:$PATH"

echo "=== Running Standard Ruby lint ==="
bundle exec standardrb 2>&1
LINT_EXIT=$?

echo ""
echo "=== Running RSpec tests ==="
bundle exec rspec 2>&1
TEST_EXIT=$?

echo ""
echo "=== Running Brakeman security scan ==="
bin/brakeman --no-pager 2>&1
BRAKEMAN_EXIT=$?

if [ $LINT_EXIT -ne 0 ] || [ $TEST_EXIT -ne 0 ] || [ $BRAKEMAN_EXIT -ne 0 ]; then
  echo ""
  echo "=== CI checks failed ==="
  [ $LINT_EXIT -ne 0 ] && echo "  - Lint: FAILED"
  [ $TEST_EXIT -ne 0 ] && echo "  - Tests: FAILED"
  [ $BRAKEMAN_EXIT -ne 0 ] && echo "  - Brakeman: FAILED"
  exit 2
fi

echo ""
echo "=== All CI checks passed ==="
