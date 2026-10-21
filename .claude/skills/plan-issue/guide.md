# Setting up a repo for the issue tracker

This guide sets up a GitHub repo to track work as issues with the status labels and the plan-issue skill. Run the steps in order. Each step ends with a check.

Conventions (label names, comment format, commit format, blocking) live in `issueconventions.md` next to this file. This guide covers setup only.

## 1. Prerequisites

Check the tools:

```bash
gh --version          # need 2.94+ for sub-issues, 2.102+ for --add-blocked-by
git --version
```

Log in with a token that has the `repo` scope:

```bash
gh auth login
gh auth status       # must list 'repo' under Token scopes
```

Let git use gh for HTTPS credentials:

```bash
gh auth setup-git
```

Set a repo-local git identity. Run these inside the target repo. To keep your real email out of commits, use GitHub's noreply address. Get your user id with `gh api user --jq .id`, then:

```bash
git config user.name "Your Name"
git config user.email "<user-id>+<username>@users.noreply.github.com"
git config --get user.email    # check
```

Check: `gh auth status` shows `repo`, and `git config --get user.email` prints the address you chose.

## 2. Create and push the repo

From the local project folder, which must already have at least one commit:

```bash
git init -b main          # skip if already a repo
git add <files>           # explicit paths, not git add -A on a fresh tree you have not reviewed
git commit -m "Initial commit"
gh repo create <owner>/<repo> --private --source . --push
```

Use `--public` or `--internal` instead of `--private` if needed. `--source .` links the local folder to the new remote, and `--push` pushes the commits.

Check: `git remote -v` shows the new repo, and `gh repo view --web` opens it. Use `gh repo view` without `--web` if you prefer the terminal.

## 3. Create the status and type labels

From the repo root (or any folder, with `--repo`):

```bash
.claude/skills/plan-issue/setup-labels.sh                       # uses the repo of the current folder
.claude/skills/plan-issue/setup-labels.sh --repo owner/name     # explicit repo
.claude/skills/plan-issue/setup-labels.sh --help                # usage
```

The script creates or updates the `status:*`, `type:*` and `epic` labels. It is idempotent: re-running it updates colors and descriptions in place.

Optional: delete GitHub's default labels (`bug`, `enhancement`, `documentation`, and so on) that you do not use:

```bash
gh label list --limit 100
gh label delete <name> --yes
```

Check: `gh label list --limit 100` shows `status:backlog`, `status:ready`, `status:in-progress`, `status:blocked`, `status:needs-info`, the five `type:*` labels, and `epic`.

## 4. Install the plan-issue skill

Copy the plan-issue folder into the target repo:

```bash
mkdir -p <target>/.claude/skills
cp -r .claude/skills/plan-issue <target>/.claude/skills/
```

Optional companions, if you want them. Copy each folder that exists in the source repo:

```bash
cp -r .claude/skills/mountain-of-work .claude/skills/captain-claude .claude/skills/bookworm <target>/.claude/skills/
cp .claude/agents/soldier.md .claude/agents/librarian.md <target>/.claude/agents/
```

`soldier` is the worker agent that the work skills launch. `librarian` is used by the wiki skills. Copy them only if you copy the skills that use them.

Check: `ls <target>/.claude/skills/plan-issue` lists `issueconventions.md`, `setup-labels.sh` and `SKILL.md`. Skills and agents are project-level, so they only apply inside that repo.

## 5. Optional: GitHub Projects board

A board is a view over the labels. The labels stay the source of truth. Do not move cards by hand as the only record.

Add the project scope to the gh login:

```bash
gh auth refresh -s project
```

Create a Projects v2 board for the repo in the GitHub web UI. Make a single-select field named `Status`, with one option per status label: `backlog`, `ready`, `in-progress`, `blocked`, `needs-info`. Add the repo's issues to the board. Set the board's Status to match each issue's `status:*` label.

Check: a sample issue's board Status matches its `status:*` label.

## 6. Verification checklist

Run these from the target repo:

- [ ] `gh --version` is 2.94+ (2.102+ if you use `--add-blocked-by`)
- [ ] `gh auth status` lists the `repo` scope
- [ ] `git config --get user.email` gives the address you chose
- [ ] `git remote -v` points to the new repo, and `git status` is clean after the first push
- [ ] `gh label list --limit 100` shows all status, type and `epic` labels
- [ ] `.claude/skills/plan-issue/SKILL.md`, `issueconventions.md` and `setup-labels.sh` exist in the repo
- [ ] `gh issue list --state open --label status:ready` runs without error (an empty list is fine)
- [ ] Optional: a test issue created with `gh issue create --title "Test" --body "test"` gets `status:backlog` added, then closed and deleted in the web UI

## 7. Troubleshooting for old gh versions

- **`--parent` or `--add-sub-issue` is not a flag** (gh older than 2.94): use the REST endpoint from `issueconventions.md`:
  ```bash
  gh api -X POST repos/<owner>/<repo>/issues/<parent>/sub_issues -F sub_issue_id=<child-db-id>
  ```
  Get the child's database id with `gh api repos/<owner>/<repo>/issues/<child> --jq .id`. Without sub-issues at all, put `Part of #<parent>` at the top of the child body.
- **`--add-blocked-by` is not a flag** (gh older than 2.102): use the REST endpoint:
  ```bash
  gh api -X POST repos/<owner>/<repo>/issues/<n>/dependencies/blocked_by -F issue_id=<blocker-db-id>
  ```
  The `issue_id` is the blocker's database id, not its number. Always write `Blocked by: #m` in the body as well.
- **Upgrade gh**: see https://cli.github.com, then re-run `gh --version`.
- **`gh auth refresh -s project` fails**: run `gh auth login` again and grant the project scope in the browser step.
- **`setup-labels.sh` fails with an unknown argument**: it accepts only `--repo owner/name` and `--help`.
