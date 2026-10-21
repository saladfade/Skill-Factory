# Issue tracker: GitHub

Issues and specs for this repo live as GitHub issues. Use the `gh` CLI for all operations.

## Conventions

- **Create an issue**: `gh issue create --title "..." --body "..."`. Use a heredoc for multi-line bodies.
- **Read an issue**: `gh issue view <number> --json number,title,body,labels,comments`.
- **List issues**: `gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'` with appropriate `--label` and `--state` filters.
- **Make an issue a sub-issue of a parent**: `gh issue create --parent <parent> ...`, or `gh issue edit <parent> --add-sub-issue <child>` afterwards (`gh` 2.94+). Older `gh`: `gh api --method POST repos/<owner>/<repo>/issues/<parent>/sub_issues -F sub_issue_id=<child-db-id>` (database id, as in **Blocking** below). Without sub-issues, put `Part of #<parent>` at the top of the child body.
- **Comment on an issue**: `gh issue comment <number> --body "..."`
- **Apply / remove labels**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **Close**: `gh issue close <number> --comment "..."`

Infer the repo from `git remote -v`; `gh` does this automatically when run inside a clone.

## Kanban (labels)

Columns: `status:backlog` → `status:ready` → `status:in-progress` → closed (Done). Two side states: `status:blocked` (waiting on another issue) and `status:needs-info` (needs a human decision or more info).

- Every open issue has exactly one `status:*` label.
- Transitions swap the label in one command, e.g.:
  - backlog → ready: `gh issue edit <n> --remove-label status:backlog --add-label status:ready`
  - ready → in-progress: `gh issue edit <n> --remove-label status:ready --add-label status:in-progress`
  - any → blocked: `gh issue edit <n> --remove-label <current> --add-label status:blocked`
  - any → needs-info: `gh issue edit <n> --remove-label <current> --add-label status:needs-info`
  - in-progress → Done: `gh issue close <n> --comment "..."`
- Type labels: `type:feature`, `type:bug`, `type:chore`, `type:docs`, `type:spike` (time-boxed investigation).
- `epic` marks a parent issue that groups sub-issues. It is not a status.
- Create or update the labels with `.claude/skills/plan-issue/setup-labels.sh` (idempotent; `--repo owner/name` optional).

## Blocking

An issue is blocked by another when the other must close first.

- **Add / remove** (gh 2.102+): `gh issue edit <n> --add-blocked-by <m>` / `--remove-blocked-by <m>`.
- **REST fallback**: `POST repos/O/R/issues/N/dependencies/blocked_by -F issue_id=<db id>`. Get the db id with `gh api repos/O/R/issues/<m> --jq .id`. Note: the db id of the blocker, not its number.
- **List blockers**: `gh api repos/O/R/issues/N/dependencies/blocked_by`. Issues this one blocks: `gh api repos/O/R/issues/N/dependencies/blocking`.
- **Body line**: also write `Blocked by: #m` in the issue body (see the template below).
- **Labels**: an issue with open blockers gets `status:blocked`. Keep it until all blockers are closed, then switch to `status:ready`.

## Issue body template

```markdown
## Context
Why this exists and what it touches.

## Acceptance criteria
- [ ] Verifiable outcome 1
- [ ] Verifiable outcome 2

## Blocked by
#m (or "None")

## Out of scope
- Things explicitly not part of this issue
```

## Working an issue

1. List ready work: `gh issue list --state open --label status:ready`.
2. Pick one and set it in progress: `gh issue edit <n> --remove-label status:ready --add-label status:in-progress`.
3. Do the work, satisfying every acceptance criterion and nothing in Out of scope.
4. Commit with `Closes #<n>` in the message. Stage only your own paths (`git add <own paths>`) and commit only them (`git commit -m "..." -- <own paths>`), so no other staged file gets swept in. Never reset, amend, rebase, or revert commits you did not make.
5. Comment a summary: `gh issue comment <n> --body "..."`.
6. Remove every `status:*` label, then close: `gh issue edit <n> --remove-label status:in-progress` and `gh issue close <n>`. A closed issue must carry no `status:*` label.
7. Unblock dependents: for each issue in `gh api repos/O/R/issues/<n>/dependencies/blocking`, if all of its blockers are now closed, switch it from `status:blocked` to `status:ready`.

## When a skill says "publish to the issue tracker"

Create a GitHub issue.

## When a skill says "fetch the relevant ticket"

Read it as in **Read an issue** above.
