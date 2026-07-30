#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: run-grok.sh <task brief>" >&2
  echo "   or: printf '%s' '<task brief>' | run-grok.sh" >&2
}

if (( $# > 0 )); then
  task_brief="$*"
elif [[ ! -t 0 ]]; then
  task_brief="$(sed -e 's/[[:space:]]*$//' < /dev/stdin)"
else
  usage
  exit 64
fi

if [[ -z "${task_brief//[[:space:]]/}" ]]; then
  usage
  exit 64
fi

grok_bin="${GROK_BIN:-grok}"
if [[ "$grok_bin" == */* ]]; then
  if [[ ! -x "$grok_bin" ]]; then
    echo "delegate-to-grok: executable not found: $grok_bin" >&2
    exit 127
  fi
elif ! command -v "$grok_bin" >/dev/null 2>&1; then
  echo "delegate-to-grok: '$grok_bin' is not available on PATH" >&2
  exit 127
fi

max_turns="${GROK_MAX_TURNS:-8}"
if [[ ! "$max_turns" =~ ^[1-9][0-9]*$ ]]; then
  echo "delegate-to-grok: GROK_MAX_TURNS must be a positive integer" >&2
  exit 64
fi

reasoning_effort="${GROK_REASONING_EFFORT:-low}"
case "$reasoning_effort" in
  none|low|medium|high|xhigh|max) ;;
  *)
    echo "delegate-to-grok: unsupported GROK_REASONING_EFFORT: $reasoning_effort" >&2
    exit 64
    ;;
esac

execution_rules="Complete only the bounded task in the prompt. Do not commit, push, deploy, publish, send messages, change repository configuration, or edit unrelated files. Preserve pre-existing user changes. Stop and report the ambiguity instead of inventing requirements. Run only relevant targeted checks."

grok_args=(
  --cwd "$PWD"
  --always-approve
  --no-memory
  --disable-web-search
  --no-subagents
  --max-turns "$max_turns"
  --reasoning-effort "$reasoning_effort"
  --rules "$execution_rules"
)

if [[ -n "${GROK_MODEL:-}" ]]; then
  grok_args+=(--model "$GROK_MODEL")
fi

exec "$grok_bin" "${grok_args[@]}" -p "$task_brief"
