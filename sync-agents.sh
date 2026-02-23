#!/usr/bin/env bash
# sync-agents.sh — Deploy agent files from this repo to live locations.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

AGENTS_DEST="$HOME/.claude/agents"
CLAUDE_MD_DEST="$HOME/Desktop/Projects/CLAUDE.md"
SCRIPTS_DEST="$HOME/.claude/scripts"

echo "Deploying agent files from $SCRIPT_DIR..."

mkdir -p "$AGENTS_DEST"
mkdir -p "$SCRIPTS_DEST"

cp "$SCRIPT_DIR/build-master.md"          "$AGENTS_DEST/build-master.md"          && echo "  ✓ build-master.md → $AGENTS_DEST/"
cp "$SCRIPT_DIR/devops-ui-specialist.md"  "$AGENTS_DEST/devops-ui-specialist.md"  && echo "  ✓ devops-ui-specialist.md → $AGENTS_DEST/"
cp "$SCRIPT_DIR/scribe-sys-architect.md"  "$AGENTS_DEST/scribe-sys-architect.md"  && echo "  ✓ scribe-sys-architect.md → $AGENTS_DEST/"
cp "$SCRIPT_DIR/gitops-manager.md"        "$AGENTS_DEST/gitops-manager.md"        && echo "  ✓ gitops-manager.md → $AGENTS_DEST/"
cp "$SCRIPT_DIR/CLAUDE.md"                "$CLAUDE_MD_DEST"                       && echo "  ✓ CLAUDE.md → $CLAUDE_MD_DEST"
cp "$SCRIPT_DIR/mcp-doctor.sh"            "$SCRIPTS_DEST/mcp-doctor.sh"           && echo "  ✓ mcp-doctor.sh → $SCRIPTS_DEST/"
cp "$SCRIPT_DIR/sync-agents.sh"           "$SCRIPTS_DEST/sync-agents.sh"          && echo "  ✓ sync-agents.sh → $SCRIPTS_DEST/"

cp -r "$SCRIPT_DIR/scaffolds"             "$AGENTS_DEST/scaffolds"                && echo "  ✓ scaffolds/ → $AGENTS_DEST/scaffolds/"

chmod +x "$SCRIPTS_DEST/mcp-doctor.sh"
chmod +x "$SCRIPTS_DEST/sync-agents.sh"

cd "$SCRIPT_DIR"

if git diff --quiet && git diff --cached --quiet; then
    echo "Repo has no changes to commit."
    exit 0
fi

git add build-master.md devops-ui-specialist.md scribe-sys-architect.md gitops-manager.md CLAUDE.md mcp-doctor.sh sync-agents.sh scaffolds/
git commit -m "chore: update agent prompts and CLAUDE.md

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
git push

echo "Done. Pushed to $(git remote get-url origin)"
