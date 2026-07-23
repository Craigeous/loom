#!/usr/bin/env bash
# git-identity-guard.sh — PreToolUse hook guard (ADR 0003 policy; spec 08 wire)
#
# POLICY (unchanged from the original ADR 0003 design; Claude-path semantics are
# preserved exactly): blocks git commands that override the uniform commit
# identity. Reads tool_input.command; a detected override BLOCKS, everything
# else ALLOWS (fail-open on unparseable/ambiguous shell quoting — this is
# defense in depth, not a complete shell parser or security boundary).
#
# Override paths blocked:
#   --author= / --author <value>
#   -c user.name= / -c user.email= / any -c user.*=
#   -c GIT_AUTHOR*= / -c GIT_COMMITTER*=
#   GIT_AUTHOR_NAME= / GIT_AUTHOR_EMAIL= / GIT_COMMITTER_NAME= / GIT_COMMITTER_EMAIL=
#
# De-quote transform (flag-vs-text discrimination):
#   Stage A: remove backslash-escaped quote chars (\" and \')
#   Stage B: strip contents of 'single' and "double" quoted segments
#   Stage C: fail-open if odd quote count remains (unparseable quoting)
# All override checks run on $STRIPPED, never on the raw command.
#
# WIRE (spec 08 -> Hook normalization and output adapters): this single physical
# hook, reached through the one shared plugins/loom/hooks/hooks.json manifest,
# selects its client wire adapter at runtime from whichever of PLUGIN_ROOT
# (Codex) or CLAUDE_PLUGIN_ROOT (Claude) resolves to a validated physical loom
# plugin root. An unresolved/ambiguous root, invalid input JSON, or a
# wrong-typed tool_input.command fails closed through the fixed reason "Loom
# hook input invalid for pre-tool-use." A missing tool_input.command (no Bash
# target to evaluate) allows, matching the original ADR 0003 behavior exactly.
#
# jq 1.6+ is a hard runtime floor (spec 10); there is deliberately no
# grep/sed fallback for JSON parsing here — root/type validation both require
# real JSON semantics that a text fallback cannot provide correctly.

EVENT="pre-tool-use"
INVALID_REASON="Loom hook input invalid for ${EVENT}."

# --- root validation shared by both client bindings (spec 10) ---
_loom_hook_validate_root() {
    local candidate="$1" relpath="$2" canon manifest name version
    [ -n "$candidate" ] || return 1
    case "$candidate" in
    /*) ;;
    *) return 1 ;;
    esac
    [ -d "$candidate" ] || return 1
    canon=$(CDPATH='' cd -- "$candidate" 2>/dev/null && pwd -P) || return 1
    manifest="$canon/$relpath"
    [ -f "$manifest" ] || return 1
    name=$(jq -r '.name // empty' "$manifest" 2>/dev/null) || return 1
    version=$(jq -r '.version // empty' "$manifest" 2>/dev/null) || return 1
    [ "$name" = "loom" ] && [ "$version" = "0.2.0" ] || return 1
}

# _loom_hook_select_client — prints "claude" or "codex" and returns 0 only
# when exactly one of PLUGIN_ROOT (Codex)/CLAUDE_PLUGIN_ROOT (Claude) validates.
# Both valid (ambiguous) or neither valid (missing/mismatched) returns 1.
_loom_hook_select_client() {
    local codex_ok=1 claude_ok=1
    _loom_hook_validate_root "${PLUGIN_ROOT:-}" ".codex-plugin/plugin.json" && codex_ok=0
    _loom_hook_validate_root "${CLAUDE_PLUGIN_ROOT:-}" ".claude-plugin/plugin.json" && claude_ok=0
    if [ "$codex_ok" -eq 0 ] && [ "$claude_ok" -eq 0 ]; then
        return 1
    elif [ "$codex_ok" -eq 0 ]; then
        printf 'codex'
        return 0
    elif [ "$claude_ok" -eq 0 ]; then
        printf 'claude'
        return 0
    else
        return 1
    fi
}

# _loom_hook_sanitize_reason <reason> — bounds/normalizes a policy reason to
# the spec 08 contract (single UTF-8 line, control-character-free, <=512 bytes).
_loom_hook_sanitize_reason() {
    local reason="$1" bytes
    case "$reason" in
    *$'\n'*)
        printf 'Loom hook policy returned an invalid reason.'
        return
        ;;
    esac
    if printf '%s' "$reason" | LC_ALL=C grep -q '[[:cntrl:]]'; then
        printf 'Loom hook policy returned an invalid reason.'
        return
    fi
    bytes=$(printf '%s' "$reason" | wc -c | tr -d ' ')
    if [ "$bytes" -gt 512 ]; then
        printf 'Loom hook policy returned an invalid reason.'
        return
    fi
    printf '%s' "$reason"
}

# _loom_hook_allow — exit 0, empty stdout/stderr (identical for both clients).
_loom_hook_allow() {
    exit 0
}

# _loom_hook_block <client> <reason> — emits the exact client wire envelope.
_loom_hook_block() {
    local client="$1" reason reason_json
    reason=$(_loom_hook_sanitize_reason "$2")
    case "$client" in
    codex)
        reason_json=$(jq -Rn --arg r "$reason" '$r')
        printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":%s}}\n' "$reason_json"
        exit 0
        ;;
    *)
        printf '%s\n' "$reason" >&2
        exit 2
        ;;
    esac
}

# --- resolve client (spec 10 root binding) ---
CLIENT=$(_loom_hook_select_client) || _loom_hook_block "claude" "$INVALID_REASON"

# --- read all stdin ---
INPUT=$(cat)

# --- validate JSON shape ---
if ! printf '%s' "$INPUT" | jq -e . >/dev/null 2>&1; then
    _loom_hook_block "$CLIENT" "$INVALID_REASON"
fi

# tool_input.command must be absent (no target — allow) or a string.
CMD_TYPE=$(printf '%s' "$INPUT" | jq -r '(.tool_input.command // null) | type' 2>/dev/null)
case "$CMD_TYPE" in
string | null) ;;
*) _loom_hook_block "$CLIENT" "$INVALID_REASON" ;;
esac

CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# --- empty command → allow (fail open; no Bash target to evaluate) ---
if [ -z "$CMD" ]; then
    _loom_hook_allow
fi

# --- Stage A: remove backslash-escaped quote characters ---
DEESC=$(printf '%s' "$CMD" | sed -e 's/\\"//g' -e "s/\\\\'//g")

# --- Stage B: strip contents (and delimiters) of quoted segments ---
STRIPPED=$(printf '%s' "$DEESC" | sed -e "s/'[^']*'//g" -e 's/"[^"]*"//g')

# --- Stage C: fail-open backstop on unresolvable (odd) quote count ---
DQ=$(printf '%s' "$STRIPPED" | tr -cd '"' | wc -c | tr -d ' ')
SQ=$(printf '%s' "$STRIPPED" | tr -cd "'" | wc -c | tr -d ' ')
if [ $((DQ % 2)) -ne 0 ] || [ $((SQ % 2)) -ne 0 ]; then
    _loom_hook_allow
fi

# --- git-word / env-var gate: only proceed for git-bearing commands ---
IS_GIT=0
if printf '%s' "$STRIPPED" | grep -qE '(^|[^[:alnum:]_./-])git([[:space:]]|$)'; then
    IS_GIT=1
fi
if printf '%s' "$STRIPPED" | grep -qE '(GIT_AUTHOR_(NAME|EMAIL)|GIT_COMMITTER_(NAME|EMAIL))='; then
    IS_GIT=1
fi
if [ "$IS_GIT" -eq 0 ]; then
    _loom_hook_allow
fi

# --- Override detection (all on $STRIPPED) ---

if printf '%s' "$STRIPPED" | grep -qE -- '--author([[:space:]]|=)'; then
    _loom_hook_block "$CLIENT" "loom identity guard: blocked --author override (ADR 0003 requires the uniform commit identity)."
fi

if printf '%s' "$STRIPPED" | grep -qE -- '-c[[:space:]]+user\.[A-Za-z]+='; then
    _loom_hook_block "$CLIENT" "loom identity guard: blocked -c user.* override (ADR 0003 requires the uniform commit identity)."
fi

if printf '%s' "$STRIPPED" | grep -qE -- '-c[[:space:]]+(GIT_AUTHOR|GIT_COMMITTER)[A-Z_]*='; then
    _loom_hook_block "$CLIENT" "loom identity guard: blocked -c GIT_AUTHOR*/GIT_COMMITTER* override (ADR 0003 requires the uniform commit identity)."
fi

if printf '%s' "$STRIPPED" | grep -qE '(GIT_AUTHOR_(NAME|EMAIL)|GIT_COMMITTER_(NAME|EMAIL))='; then
    _loom_hook_block "$CLIENT" "loom identity guard: blocked GIT_AUTHOR_*/GIT_COMMITTER_* env override (ADR 0003 requires the uniform commit identity)."
fi

# --- No override detected → allow ---
_loom_hook_allow
