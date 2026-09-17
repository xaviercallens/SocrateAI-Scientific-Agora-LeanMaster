#!/usr/bin/env bash
# Make the LeanMaster skills available to EVERY Claude Code session of this user (any project):
#   bash tools/install_skills.sh            # symlink into ~/.claude/skills
#   bash tools/install_skills.sh --copy     # copy instead (for machines where the repo may move)
# Project-level use needs nothing: sessions started inside this repo load .claude/skills automatically.
set -eu
SRC="$(cd "$(dirname "$0")/.." && pwd)/.claude/skills"
DST="$HOME/.claude/skills"; mkdir -p "$DST"
for d in "$SRC"/*/; do
  n="$(basename "$d")"
  if [ "${1:-}" = "--copy" ]; then mkdir -p "$DST/$n" && cp "$d/SKILL.md" "$DST/$n/SKILL.md"
  else ln -sfn "${d%/}" "$DST/$n"; fi
  echo "installed skill: $n"
done
echo "Start a new Claude Code session (or run /skills) to see them; invoke with /<skill-name>."
