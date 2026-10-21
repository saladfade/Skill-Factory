# Skill-Factory

Claude Code project skills for GitHub-Issues-based planning, agent orchestration, and wiki upkeep.

## Skills

| Skill | Invocation | Model | Purpose |
|---|---|---|---|
| [plan-issue](#plan-issue) | Model or `/plan-issue` | Session default | Turn multi-session work into a GitHub epic with dependency-linked sub-issues |
| [mountain-of-work](#mountain-of-work) | `/mountain-of-work` only | Session default | Plan work with a Haiku agent, then run chosen ready issues with soldiers |
| [captain-claude](#captain-claude) | `/captain-claude` only | Opus | Run a task or issue set end to end in dependency waves, with inspection |
| [bookworm](#bookworm) | Model or `/bookworm` | Session default | Record content into the repo's wiki or library, after other work is done |

The worker agents `soldier` and `librarian` live in `.claude/agents/` and run on Haiku.

### plan-issue

Turns complex work (more than one session, or three or more separable deliverables) into a tracked GitHub epic. Slices are vertical, each has acceptance criteria, and blockers form a DAG. It only plans: it creates issues and never implements them.

- **Invocation**: model or `/plan-issue`.
- **Agents**: none directly. `mountain-of-work` and `captain-claude` run it through a Haiku planner.
- **Files** (`.claude/skills/plan-issue/`):
  - `SKILL.md`: the planning steps.
  - `issueconventions.md`: labels, body template, commit format, blocking.
  - `setup-labels.sh`: creates or updates the status, type and `epic` labels (idempotent).
  - `guide.md`: one-time repo setup.

### mountain-of-work

Plans a body of work into issues, then runs the issues you pick. The main session does not read code: a Haiku agent plans, and one `soldier` per chosen issue does the work in parallel.

- **Invocation**: `/mountain-of-work` only (`disable-model-invocation`).
- **Agents**: one Haiku planner (`general-purpose`), then one `soldier` per chosen issue.
- **Files** (`.claude/skills/mountain-of-work/`): `SKILL.md`.

### captain-claude

Runs a free-text task or a set of issues end to end. It plans complex tasks, builds dependency waves, dispatches Haiku soldiers, inspects each result, and escalates failures to Sonnet and then to the user. It never edits files itself.

- **Invocation**: `/captain-claude` only (`disable-model-invocation`).
- **Model**: Opus (set in the skill frontmatter).
- **Agents**: Haiku planner, `Explore` scouts for reading, `soldier` for WORK and INSPECT, optional Sonnet `soldier` for a second failure.
- **Files** (`.claude/skills/captain-claude/`): `SKILL.md`.

### bookworm

Records content into the repo's library or wiki. It identifies what to record, waits until the rest of the prompt is finished, then hands off to the `librarian` agent, which discovers the library and writes the pages.

- **Invocation**: model or `/bookworm`, for example "add this to the wiki".
- **Agents**: `librarian` (Haiku).
- **Files** (`.claude/skills/bookworm/`):
  - `SKILL.md`: the hand-off steps.
  - `reference.md`: a fallback LLM-wiki layout, used only where the repo's own rules are silent.

## Kanban tracker

Work is tracked as GitHub issues. The `status:*` labels are the columns of a kanban board:

| Column | Label | List the column |
|---|---|---|
| Backlog | `status:backlog` | `gh issue list --state open --label status:backlog` |
| Ready | `status:ready` | `gh issue list --state open --label status:ready` |
| In progress | `status:in-progress` | `gh issue list --state open --label status:in-progress` |
| Blocked | `status:blocked` | `gh issue list --state open --label status:blocked` |
| Needs info | `status:needs-info` | `gh issue list --state open --label status:needs-info` |
| Done | closed, no `status:*` label | `gh issue list --state closed` |

- Every open issue has exactly one `status:*` label. A closed issue has none.
- Create the labels once with `.claude/skills/plan-issue/setup-labels.sh`.
- Full conventions (transitions, comment and commit format, blocking commands) are in [`.claude/skills/plan-issue/issueconventions.md`](.claude/skills/plan-issue/issueconventions.md).

## Install into another repo

To use the planning skills in another repo, follow [`.claude/skills/plan-issue/guide.md`](.claude/skills/plan-issue/guide.md). It covers prerequisites, creating the labels, copying the skill folders and agents, and a verification checklist. Skills and agents are project-level, so they apply only inside the repo they are copied into.

## Third-party skills

The following skills under `.claude/skills/` come from [mattpocock/skills](https://github.com/mattpocock/skills), licensed under MIT:

- diagnosing-bugs
- grilling
- grill-me
- prototype
- research
- writing-for-agents
