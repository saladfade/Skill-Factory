---
name: plan-issue
description: Turn complex multi-step or multi-session work into a tracked GitHub epic with vertically sliced, dependency-linked sub-issues. Use when work needs more than one session or has 3+ separable deliverables, or when the user says "plan this" or "break this into issues".
argument-hint: "[work description]"
---

Plan the work in $ARGUMENTS as GitHub issues. This skill plans only: it creates issues and never implements them. If $ARGUMENTS is empty, ask what to plan (interactive) or return a `QUESTIONS:` block (non-interactive).

## Step 0: Preflight

Read `${CLAUDE_SKILL_DIR}/issueconventions.md` before any `gh` action. It defines the labels, body template, commands and blocking mechanics. Follow it.

- Run `git remote -v` and confirm it points to GitHub. Run `gh auth status` and confirm a logged-in account.
- Run `gh label list` and confirm the status labels from the conventions exist. If any is missing, run `${CLAUDE_SKILL_DIR}/setup-labels.sh` (see `${CLAUDE_SKILL_DIR}/guide.md`).

Done when the remote, auth and label checks all pass. If the remote or auth check fails, stop and report it.

## Step 1: Decide whether issues are warranted

Issues pay off when the work spans more than one session or has 3 or more separable deliverables. If it meets neither bar, say so in one sentence and stop.

## Step 2: Gather context

- Read the files and docs the work touches. Note the existing patterns and constraints.
- List open issues with the command in the conventions. Match their titles and bodies against the work. Reference an overlapping issue instead of duplicating it.

Done when you can name the files each planned slice will touch.

## Step 3: Clarify

- **Interactive**: ask with AskUserQuestion until each slice's scope and acceptance can be stated without guessing.
- **Non-interactive** (run by a subagent, or told "non-interactive"): create nothing. Return a numbered `QUESTIONS:` block, with a recommended answer for each question.

## Step 4: Slice vertically

Each slice must:

- cut end to end through every layer it needs and deliver observable value
- be verifiable on its own through its acceptance criteria
- fit one agent session
- overlap minimally in files with its siblings

Also apply these rules:

- No horizontal layer slices, such as "all the models" then "all the UI".
- Unknowns become `type:spike` slices.
- Dependencies form a DAG with no cycles.
- Very large work may use sub-epics, to a maximum depth of 2.

Done when every slice passes the checks above and the blocked-by graph has no cycle.

## Step 5: Approve

- **Interactive**: show a table (slice, type, blocked by, acceptance summary) and wait for approval before creating anything.
- **Non-interactive**: skip this step.

## Step 6: Create the issues

Create the epic first. Then create the children in topological order, so every blocker exists before its dependents.

- Use the body template and labels from the conventions. Pass multi-line bodies through a heredoc.
- Attach each child to its parent as the conventions describe.
- Add the blocked-by links and the `Blocked by:` body line as the conventions describe.
- Set each status label per the conventions: ready when no blocker is open, blocked otherwise.

Done when every planned slice exists as an issue and every blocked-by link resolves.

## Step 7: Report

Return the epic URL and a table with columns #, title, type, status and blocked by. Name the issues that are ready now.
