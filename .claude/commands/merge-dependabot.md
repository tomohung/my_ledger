List all open dependabot PRs and merge any that are safe (all CI checks passing).

Steps:
1. List open PRs authored by dependabot with their CI status and mergeability. If mergeable is "UNKNOWN", query the PR again; GitHub computes it lazily.
2. For each PR, check if all status checks have conclusion "SUCCESS" and mergeable is "MERGEABLE".
3. Merge fully green PRs one at a time using `gh pr merge <number> --merge --match-head-commit <sha>`, so only the commit that passed CI gets merged.
4. For any PRs with failing checks, find the failed step with `gh run view <run_id> --json jobs`, then read the logs with `gh run view <run_id> --log-failed` (the error is often above the post-job cleanup, so don't rely on `tail`) to determine if the failure is a pre-existing issue unrelated to the dependency bump (e.g., brakeman version warning, Ruby version unavailable on the runner image in `Set up Ruby`). Check every failing run before calling it a shared cause.
5. If failures are caused by a stale dependency that another open dependabot PR fixes, merge the fix PR first, then comment `@dependabot rebase` on the blocked PRs to trigger a rebase.
6. If the shared cause has no fixing PR (e.g., `.ruby-version` needs a bump), explain it and propose a fix, and wait for the user's approval, since it can affect production. When approved, update every reference (`.ruby-version`, `Dockerfile`, `config/deploy.yml`), run rspec, standardrb and brakeman locally, merge to main directly (no PR), then comment `@dependabot rebase` on the blocked PRs.
7. Watch the blocked PRs with Monitor until they are rebased and CI has finished. Compare each head against the fix commit, because old checks stay visible until the rebase lands. Apply steps 2-3 to the ones that turn green. If a bump itself breaks CI, leave it open and report it.
8. Merging a PR can make others conflict on `Gemfile.lock`. If a PR conflicts, or dependabot did not respond to a rebase request, comment `@dependabot rebase` again and wait for CI to rerun.
9. `ci.yml` only runs on pull requests, so nothing tests main after merging. Pull main and run `bundle install`, rspec, standardrb and brakeman locally to verify the combined result.
10. Report a final summary of what was merged and what still needs attention, including anything verified only by older CI runs.

Local environment notes:
- asdf ignores `.ruby-version`; Ruby comes from `~/.tool-versions`. Use `ASDF_RUBY_VERSION=<version>` to test another version.
- The pre-commit hook runs under that global Ruby, and fails without visible output if newly merged gems are missing. Run `bundle install` under the global Ruby first. The hook matches the literal text of the commit command anywhere in a Bash command, including diagnostics.
- If `asdf install ruby` can't find a new version, the plugin's ruby-build may be outdated.
