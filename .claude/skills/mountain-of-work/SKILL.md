---
name: mountain-of-work
description: Plan a body of work into GitHub issues with a Haiku agent, then run chosen ready issues with soldier agents. Invoked by the user as /mountain-of-work.
argument-hint: [work description]
disable-model-invocation: true
---

Plan and run the work described in $ARGUMENTS. The main session never plans or reads code itself. It relays questions, shows the plan, and dispatches workers.

## Step 1: Get the work description

If $ARGUMENTS is empty, ask the user what work to plan and wait for the answer.

Done when you hold a non-empty work description.

## Step 2: Plan with a Haiku agent

Spawn ONE Agent with `model: haiku` and `subagent_type: general-purpose`. Its prompt must contain:

- the work description, verbatim
- the repo path: `/home/leandro/Documents/Skill-Factory`
- an instruction to read `.claude/skills/plan-issue/SKILL.md` and `.claude/skills/plan-issue/issueconventions.md` and follow them in non-interactive mode
- an instruction to finish with either a `QUESTIONS:` block or a summary table (#, title, type, status, blocked by) plus the epic link

Keep the agent ID returned by Agent. Step 3 addresses it with SendMessage.

Done when the agent returns.

## Step 3: Answer its questions

If the agent returns a `QUESTIONS:` block, show its numbered questions to the user, each with the recommended answer, and wait for the user's answers. Send the answers to the same agent with SendMessage. Repeat until the agent returns a summary table.

Done when the agent returns a summary table.

## Step 4: Show the plan and choose

Show the epic link, then a table with columns #, title, type, status and blocked by. Bold the rows whose status is `status:ready`.

Ask with AskUserQuestion, offering these options:

- "Start all ready"
- "Pick specific issues" (then ask which ready issue numbers)
- "Don't start now" (then stop)

Done when the user has chosen and you know the exact issue numbers to start.

## Step 5: Run the chosen issues

For each chosen issue, spawn a `soldier` agent (`subagent_type: soldier`) with `run_in_background: true`. Spawn them all in one response so they run in parallel. Each prompt states the issue number and mode, for example: "Issue number: 12. Mode: WORK."

If a soldier returns a `QUESTIONS:` block, show its questions to the user and wait for the answers. Then spawn a new soldier for that issue with the answers added to its prompt.

Done when every soldier has returned a final report.

## Step 6: Report

Give the user one line per issue: its issue number, status (DONE, BLOCKED or QUESTIONS), and commit hash if any. Then offer `/captain-claude` for full multi-wave orchestration.

Done when the report is shown.
