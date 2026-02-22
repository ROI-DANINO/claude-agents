# Agent Orchestration Guide

This environment uses three specialized subagents. The Primary Claude Code session acts as
orchestrator — it delegates, integrates results, and communicates with the user.

## Delegation Rules

| Task Type | Delegate To |
|-----------|-------------|
| System prompt writing, architecture docs, CLAUDE.md, project scaffolding, Promptfoo testing | `scribe-sys-architect` |
| Python/Node.js code, pip/npm/uv, runtime logic, tests, E2B sandboxed execution | `build-master` |
| Podman/Docker, Containerfiles, podman-compose, UI/HTML/CSS/Tailwind/ShadCN, Figma | `devops-ui-specialist` |

## When to Delegate vs. Handle Directly

**Handle directly** (no subagent needed):
- Reading files, grep searches, explaining existing code
- Answering questions, short research tasks
- Simple single-file edits outside a specialized domain

**Always delegate**:
- Any task that writes or runs code
- Any container operation
- Any UI component implementation
- System prompt authoring or architectural design

## Handoff Protocol

1. Primary receives user task
2. Identify domain from table above
3. Invoke subagent via Task tool — always include: full file paths, requirements, constraints, and any relevant context from prior turns
4. Subagent returns result; Primary integrates it and confirms with user
5. If a subagent outputs `DELEGATE: <agent-name>`, relay the task to the named agent with the original context

## Cross-Agent Workflows (example)

**"Build and containerize a Python API":**
1. `build-master` → writes the Python application code
2. `devops-ui-specialist` → writes the Containerfile and podman-compose manifest using the code from step 1
3. Primary → confirms with user

**"Design and test a system prompt":**
1. `scribe-sys-architect` → drafts the system prompt
2. `scribe-sys-architect` → runs Promptfoo eval against it
3. Primary → reports results to user

## MCP Tool Availability Per Agent

| Agent | Available MCP Tools |
|-------|-------------------|
| `scribe-sys-architect` | filesystem, Bash (`npx promptfoo@latest`) |
| `build-master` | filesystem, Bash, `mcp__e2b__*` (with local Bash fallback) |
| `devops-ui-specialist` | filesystem, Bash, `mcp__podman__*` (via Docker-compat socket), `mcp__figma__*` |

## MCP Stack

All four MCPs are configured globally and available in Claude Code, OpenCode, and Kilo Code from any directory under `~/Desktop/Projects`.

| MCP | Package | Purpose | Config Key |
|-----|---------|---------|------------|
| **filesystem** | `@modelcontextprotocol/server-filesystem` | Read/write files under `~/Desktop/Projects` | `filesystem` |
| **podman** | `podman-mcp-server@latest` | Container lifecycle via rootless Podman socket | `podman` |
| **e2b** | `~/.claude/scripts/e2b-mcp.sh` | Sandboxed code execution (E2B cloud) | `e2b` |
| **figma** | `figma-mcp` | Pull design tokens and inspect Figma files | `figma` |

**Config locations (all tools read from these):**

| Tool | MCP Config File |
|------|----------------|
| Claude Code | `~/.claude/settings.json` |
| OpenCode | `~/.config/opencode/opencode.json` |
| Kilo Code | `~/.config/kilo/config.json` |

**Inter-agent shared memory:** `~/Desktop/Projects/.claude/session_state.json`
All agents read this at task start and write key decisions (ports, deps, architecture) at task end.

**Diagnostics:** Run `~/.claude/scripts/mcp-doctor.sh` to verify all MCPs are live.

## Environment Reference

| Resource | Location |
|----------|----------|
| Python | `/usr/bin/python3` (3.14.2) |
| Node.js | `/usr/bin/node` |
| Podman socket (rootless) | `/run/user/1000/podman/podman.sock` |
| Docker socket symlink | `/var/run/docker.sock` |
| E2B API key | `~/.secrets` → `$E2B_API_KEY` |
| Agent definitions | `~/.claude/agents/` |
| MCP server configs | `~/.claude/settings.json` → `mcpServers` |
| Session state | `~/Desktop/Projects/.claude/session_state.json` |
| MCP diagnostics | `~/.claude/scripts/mcp-doctor.sh` |

## Activating the Podman Socket

If Podman MCP tools fail, activate the socket first:
```bash
systemctl --user enable --now podman.socket
# Verify:
ls -la /run/user/1000/podman/podman.sock
```
