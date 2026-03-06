List all open dependabot PRs and merge any that are safe (all CI checks passing).

Steps:
1. List open PRs authored by dependabot with their CI status and mergeability.
2. For each PR, check if all status checks have conclusion "SUCCESS" and mergeable is "MERGEABLE".
3. Merge all fully green PRs immediately using `gh pr merge <number> --merge`.
4. For any PRs with failing checks, investigate the failure logs with `gh run view <run_id> --log-failed` to determine if the failure is a pre-existing issue unrelated to the dependency bump (e.g., brakeman version warning).
5. If failures are caused by a stale dependency that another open dependabot PR fixes, merge the fix PR first, then comment `@dependabot rebase` on the blocked PRs to trigger a rebase.
6. Report a final summary of what was merged and what still needs attention.
