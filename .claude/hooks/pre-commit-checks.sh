#!/bin/bash
# Run full CI checks before git commit
cd /Users/tomohung/Projects/my_ledger

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
