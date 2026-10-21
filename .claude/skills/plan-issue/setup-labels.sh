#!/usr/bin/env bash
# Create or update the GitHub labels used by the plan-issue workflow.
# Idempotent: uses --force, so re-running updates color/description in place.
#
# Usage: setup-labels.sh [--repo owner/name]

set -euo pipefail

REPO=""

usage() {
  echo "Usage: $0 [--repo owner/name]" >&2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      if [[ $# -lt 2 || -z "$2" ]]; then
        echo "error: --repo requires a value" >&2
        usage
        exit 1
      fi
      REPO="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

repo_args=()
if [[ -n "$REPO" ]]; then
  repo_args=(--repo "$REPO")
fi

# Status family: blues
# Type family: oranges/yellows
# Epic: purple
create_label() {
  local name="$1" color="$2" desc="$3"
  gh label create "$name" \
    --color "$color" \
    --description "$desc" \
    --force \
    ${repo_args[@]+"${repo_args[@]}"}
}

create_label "status:backlog"     "c5def5" "Not yet ready to work"
create_label "status:ready"       "1d76db" "All blockers closed; can be picked up"
create_label "status:in-progress" "0052cc" "Being worked on"
create_label "status:blocked"     "003a8c" "Waiting on another issue"
create_label "status:needs-info"  "7fb3e6" "Needs a human decision or more info"

create_label "type:feature" "f9a825" "New functionality"
create_label "type:bug"     "e65100" "Something is broken or behaves incorrectly"
create_label "type:chore"   "ffb74d" "Maintenance, tooling, or housekeeping"
create_label "type:docs"    "ffd54f" "Documentation changes"
create_label "type:spike"   "ff8f00" "Time-boxed investigation to answer a question"

create_label "epic" "5319e7" "Parent issue that groups sub-issues"

echo "Labels configured${REPO:+ for $REPO}."
