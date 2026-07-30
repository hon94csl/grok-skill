#!/usr/bin/env bash
set -euo pipefail

repository_url="${GROK_SKILL_REPOSITORY:-https://github.com/hon94csl/grok-skill.git}"
install_root="${GROK_SKILL_INSTALL_ROOT:-${XDG_DATA_HOME:-$HOME/.local/share}/grok-skill}"
scope="user"
project_dir="$PWD"

usage() {
  cat <<'EOF'
Install Delegate to Grok for Codex and Claude Code.

Usage:
  install.sh                 Install for the current user
  install.sh --project [DIR] Install only for one Git project
  install.sh --help          Show this help

Environment overrides:
  GROK_SKILL_REPOSITORY      Repository URL used for clone/update
  GROK_SKILL_INSTALL_ROOT    Local checkout directory
EOF
}

while (( $# > 0 )); do
  case "$1" in
    --project)
      scope="project"
      if (( $# > 1 )) && [[ "$2" != --* ]]; then
        project_dir="$2"
        shift
      fi
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "delegate-to-grok installer: unknown argument: $1" >&2
      usage >&2
      exit 64
      ;;
  esac
  shift
done

for command_name in cat dirname git grep ln mkdir readlink; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "delegate-to-grok installer: required command not found: $command_name" >&2
    exit 127
  fi
done

install_parent="$(dirname "$install_root")"
mkdir -p "$install_parent"

if [[ -d "$install_root/.git" ]]; then
  current_origin="$(git -C "$install_root" remote get-url origin 2>/dev/null || true)"
  if [[ "$current_origin" != "$repository_url" ]]; then
    echo "delegate-to-grok installer: existing checkout has a different origin:" >&2
    echo "  $install_root" >&2
    echo "  expected: $repository_url" >&2
    echo "  actual:   ${current_origin:-<none>}" >&2
    exit 73
  fi
  echo "Updating Delegate to Grok..."
  git -C "$install_root" pull --ff-only
elif [[ -e "$install_root" ]]; then
  echo "delegate-to-grok installer: install path exists but is not a Git checkout:" >&2
  echo "  $install_root" >&2
  echo "Move it aside or set GROK_SKILL_INSTALL_ROOT to another path." >&2
  exit 73
else
  echo "Downloading Delegate to Grok..."
  git clone --depth 1 "$repository_url" "$install_root"
fi

install_root="$(cd "$install_root" && pwd -P)"
skill_source="$install_root/delegate-to-grok"
if [[ ! -f "$skill_source/SKILL.md" || ! -x "$skill_source/scripts/run-grok.sh" ]]; then
  echo "delegate-to-grok installer: downloaded skill is incomplete: $skill_source" >&2
  exit 65
fi

link_skill() {
  local destination="$1"
  local parent
  parent="$(dirname "$destination")"
  mkdir -p "$parent"

  if [[ -L "$destination" ]]; then
    local existing_target
    existing_target="$(readlink "$destination")"
    if [[ "$existing_target" == "$skill_source" ]]; then
      echo "Already installed: $destination"
      return
    fi
    echo "delegate-to-grok installer: refusing to replace existing symlink:" >&2
    echo "  $destination -> $existing_target" >&2
    exit 73
  fi

  if [[ -e "$destination" ]]; then
    echo "delegate-to-grok installer: refusing to replace existing path:" >&2
    echo "  $destination" >&2
    exit 73
  fi

  ln -s "$skill_source" "$destination"
  echo "Installed: $destination"
}

if [[ "$scope" == "project" ]]; then
  project_root="$(git -C "$project_dir" rev-parse --show-toplevel 2>/dev/null || true)"
  if [[ -z "$project_root" ]]; then
    echo "delegate-to-grok installer: --project requires a directory inside a Git repository" >&2
    exit 64
  fi

  codex_destination="$project_root/.agents/skills/delegate-to-grok"
  claude_destination="$project_root/.claude/skills/delegate-to-grok"
  link_skill "$codex_destination"
  link_skill "$claude_destination"

  git_common_dir="$(git -C "$project_root" rev-parse --git-common-dir)"
  if [[ "$git_common_dir" != /* ]]; then
    git_common_dir="$project_root/$git_common_dir"
  fi
  exclude_file="$git_common_dir/info/exclude"
  for ignore_path in \
    "/.agents/skills/delegate-to-grok" \
    "/.claude/skills/delegate-to-grok"
  do
    if ! grep -Fqx "$ignore_path" "$exclude_file" 2>/dev/null; then
      printf '%s\n' "$ignore_path" >> "$exclude_file"
    fi
  done

  echo "Installed for project: $project_root"
else
  link_skill "$HOME/.agents/skills/delegate-to-grok"
  link_skill "$HOME/.claude/skills/delegate-to-grok"
  echo "Installed for the current user."
fi

if ! command -v grok >/dev/null 2>&1; then
  echo
  echo "Grok Build is not on PATH. Install it before using the skill:"
  echo "  https://docs.x.ai/build/overview"
fi

echo
echo "Restart Codex or Claude Code if the skill does not appear immediately."
