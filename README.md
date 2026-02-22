# Claude Agents

Three specialized subagents for Claude Code. A primary Claude Code session acts as orchestrator — it delegates work to these agents, integrates results, and communicates with the user.

## Agents

| Agent | File | Domain |
|-------|------|--------|
| **Build-Master** | `build-master.md` | Python/Node.js code, dependencies, tests, E2B sandbox execution |
| **DevOps/UI Specialist** | `devops-ui-specialist.md` | Podman containers, Containerfiles, HTML/CSS/Tailwind/ShadCN, Figma |
| **Scribe & Sys-Architect** | `scribe-sys-architect.md` | System prompts, CLAUDE.md, architecture docs, Promptfoo testing |

## MCP Stack

All agents are aware of the following MCP servers:

| MCP | Package | Purpose |
|-----|---------|---------|
| `filesystem` | `@modelcontextprotocol/server-filesystem` | Read/write files under `~/Desktop/Projects` |
| `podman` | `podman-mcp-server@latest` | Container lifecycle via rootless Podman socket |
| `e2b` | `~/.claude/scripts/e2b-mcp.sh` | Sandboxed code execution (E2B cloud) |
| `figma` | `figma-mcp` | Pull design tokens, inspect Figma files |

## Features

- **Inter-agent memory** — all agents read/write `~/Desktop/Projects/.claude/session_state.json` to share state across tasks (ports, dependencies, architectural decisions)
- **Hardware-aware** — build-master and devops-ui-specialist check system load before heavy operations and warn if load average > 4.0
- **Figma-first UI** — devops-ui-specialist pulls design tokens from Figma before writing any UI code
- **E2B sandbox** — build-master runs risky or experimental code in E2B cloud sandboxes before local execution

## Diagnostics

`mcp-doctor.sh` checks the full MCP stack and prints a color-coded PASS/FAIL table:

```bash
bash mcp-doctor.sh
```

Checks performed:
- Podman socket active (`systemctl --user`)
- E2B API key present in `~/.secrets`
- `npx` available on PATH
- Podman Docker socket responding (HTTP 200)
- `e2b-mcp.sh` exists and is executable
- `figma-mcp` resolves via npx
- All 4 MCPs declared in Claude Code, OpenCode, and Kilo Code configs

Exits `0` if all pass, `1` if any fail.

## Installation

Copy the agent `.md` files into `~/.claude/agents/`:

```bash
cp *.md ~/.claude/agents/
```

Claude Code picks them up automatically — no restart needed.

## Delegation Rules

```
System prompts / architecture / docs  →  scribe-sys-architect
Python / Node.js / tests / E2B        →  build-master
Containers / UI / Figma               →  devops-ui-specialist
```
