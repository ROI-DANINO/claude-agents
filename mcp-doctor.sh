#!/usr/bin/env bash
# mcp-doctor.sh — Health check for the MCP environment
# Exits 0 if all checks pass, 1 if any fail.

set -euo pipefail

GREEN="\033[0;32m"
RED="\033[0;31m"
BOLD="\033[1m"
RESET="\033[0m"

pass() { printf "${GREEN}PASS${RESET}"; }
fail() { printf "${RED}FAIL${RESET}"; }

declare -a LABELS=()
declare -a RESULTS=()
declare -a DETAILS=()

record() {
    local label="$1"
    local result="$2"
    local detail="$3"
    LABELS+=("$label")
    RESULTS+=("$result")
    DETAILS+=("$detail")
}

check_podman_socket() {
    local label="Podman Socket (systemctl --user)"
    local status
    status=$(systemctl --user is-active podman.socket 2>/dev/null || true)
    if [[ "$status" == "active" ]]; then
        record "$label" "PASS" "podman.socket is active"
    else
        record "$label" "FAIL" "podman.socket status: ${status:-unknown} (run: systemctl --user enable --now podman.socket)"
    fi
}

check_e2b_key() {
    local label="E2B API Key (~/.secrets)"
    local secrets_file="$HOME/.secrets"
    if [[ ! -f "$secrets_file" ]]; then
        record "$label" "FAIL" "~/.secrets file not found"
        return
    fi
    local key
    key=$(bash -c "source \"$secrets_file\" 2>/dev/null && printf '%s' \"\${E2B_API_KEY:-}\"" 2>/dev/null || true)
    if [[ -n "$key" ]]; then
        record "$label" "PASS" "E2B_API_KEY is set (${#key} chars)"
    else
        record "$label" "FAIL" "E2B_API_KEY is empty or not defined in ~/.secrets"
    fi
}

check_filesystem_mcp() {
    local label="Filesystem MCP (npx available)"
    if command -v npx &>/dev/null; then
        local npx_path
        npx_path=$(command -v npx)
        record "$label" "PASS" "npx found at $npx_path"
    else
        record "$label" "FAIL" "npx not found in PATH — install Node.js"
    fi
}

check_podman_mcp() {
    local label="Podman MCP (Docker socket)"
    local socket_path="/run/user/1000/podman/podman.sock"
    if [[ ! -S "$socket_path" ]]; then
        record "$label" "FAIL" "Socket not found: $socket_path"
        return
    fi
    local http_code
    http_code=$(curl --silent --max-time 3 \
        --unix-socket "$socket_path" \
        --output /dev/null \
        --write-out "%{http_code}" \
        "http://localhost/v1.41/info" 2>/dev/null || true)
    if [[ "$http_code" =~ ^2[0-9]{2}$ ]]; then
        record "$label" "PASS" "Docker socket responded HTTP $http_code"
    else
        record "$label" "FAIL" "Docker socket at $socket_path returned HTTP '${http_code:-no response}'"
    fi
}

check_e2b_mcp() {
    local label="E2B MCP (e2b-mcp.sh)"
    local script="$HOME/.claude/scripts/e2b-mcp.sh"
    if [[ -f "$script" && -x "$script" ]]; then
        record "$label" "PASS" "$script exists and is executable"
    elif [[ -f "$script" ]]; then
        record "$label" "FAIL" "$script exists but is NOT executable (run: chmod +x $script)"
    else
        record "$label" "FAIL" "$script not found"
    fi
}

check_figma_mcp() {
    local label="Figma MCP (npx resolution)"
    if ! command -v npx &>/dev/null; then
        record "$label" "FAIL" "npx not found — cannot check Figma MCP"
        return
    fi
    local output
    output=$(npx -y figma-mcp --version 2>/dev/null || echo "unreachable")
    if [[ "$output" == "unreachable" ]]; then
        record "$label" "FAIL" "figma-mcp is unreachable via npx"
    else
        record "$label" "PASS" "figma-mcp resolved (output: ${output:0:60})"
    fi
}

check_tool_config() {
    local label="$1"
    local config_file="$2"
    local expected_mcps=("e2b" "podman" "filesystem" "figma")

    if [[ ! -f "$config_file" ]]; then
        record "$label" "FAIL" "$config_file not found"
        return
    fi

    local missing=()
    for mcp in "${expected_mcps[@]}"; do
        if ! python3 -c "import json; d=json.load(open('$config_file')); block=d.get('mcp', d.get('mcpServers',{})); assert '$mcp' in block" 2>/dev/null; then
            missing+=("$mcp")
        fi
    done

    if [[ ${#missing[@]} -eq 0 ]]; then
        record "$label" "PASS" "all 4 MCPs present (e2b, podman, filesystem, figma)"
    else
        record "$label" "FAIL" "missing MCPs: ${missing[*]}"
    fi
}

printf "\n${BOLD}MCP Environment Health Check${RESET}\n"
printf "Date: %s\n\n" "$(date '+%Y-%m-%d %H:%M:%S')"

check_podman_socket
check_e2b_key
check_filesystem_mcp
check_podman_mcp
check_e2b_mcp
check_figma_mcp
check_tool_config "Claude Code config"  "$HOME/.claude/settings.json"
check_tool_config "OpenCode config"     "$HOME/.config/opencode/opencode.json"
check_tool_config "Kilo Code config"    "$HOME/.config/kilo/config.json"

check_sync_script() {
    local label="Sync script (sync-agents.sh)"
    local script="$HOME/.claude/scripts/sync-agents.sh"
    if [[ -f "$script" && -x "$script" ]]; then
        record "$label" "PASS" "$script exists and is executable"
    elif [[ -f "$script" ]]; then
        record "$label" "FAIL" "$script exists but is NOT executable (run: chmod +x $script)"
    else
        record "$label" "FAIL" "$script not found"
    fi
}

check_sync_script

max_len=0
for label in "${LABELS[@]}"; do
    (( ${#label} > max_len )) && max_len=${#label}
done

printf "${BOLD}%-*s   %-4s   %s${RESET}\n" "$max_len" "Check" "Stat" "Detail"
printf '%*s\n' $(( max_len + 40 )) '' | tr ' ' '-'

any_fail=0
for i in "${!LABELS[@]}"; do
    label="${LABELS[$i]}"
    result="${RESULTS[$i]}"
    detail="${DETAILS[$i]}"
    if [[ "$result" == "PASS" ]]; then
        status_str="$(pass)"
    else
        status_str="$(fail)"
        any_fail=1
    fi
    printf "%-*s   %b   %s\n" "$max_len" "$label" "$status_str" "$detail"
done

printf '\n'
if (( any_fail == 0 )); then
    printf "${GREEN}${BOLD}All checks passed.${RESET}\n\n"
    exit 0
else
    printf "${RED}${BOLD}One or more checks failed. See details above.${RESET}\n\n"
    exit 1
fi
