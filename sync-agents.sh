#!/usr/bin/env bash
# sync-agents.sh — Copy updated agent prompts and CLAUDE.md to the agents repo and push.

set -euo pipefail

AGENTS_SRC="$HOME/.claude/agents"
CLAUDE_MD="$HOME/Desktop/Projects/CLAUDE.md"
AGENTS_REPO="$HOME/Desktop/Projects/agents"

echo "Syncing agent files to $AGENTS_REPO..."

cp "$AGENTS_SRC/build-master.md"          "$AGENTS_REPO/build-master.md"
cp "$AGENTS_SRC/devops-ui-specialist.md"  "$AGENTS_REPO/devops-ui-specialist.md"
cp "$AGENTS_SRC/scribe-sys-architect.md"  "$AGENTS_REPO/scribe-sys-architect.md"
cp "$CLAUDE_MD"                            "$AGENTS_REPO/CLAUDE.md"

cd "$AGENTS_REPO"

if git diff --quiet && git diff --cached --quiet; then
    echo "Nothing changed — repo is already up to date."
    exit 0
fi

git add build-master.md devops-ui-specialist.md scribe-sys-architect.md CLAUDE.md
git commit -m "chore: sync agent prompts and CLAUDE.md

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
git push

echo "Done. Pushed to $(git remote get-url origin)"
