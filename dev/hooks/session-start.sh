#!/usr/bin/env bash
# Emits the dev-only problem-log note as SessionStart context, with session id and model filled in.
set -euo pipefail
input=$(cat || true)
session_id=$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null || true)
model=$(printf '%s' "$input" | jq -r '.model // empty' 2>/dev/null || true)
session_id=${session_id:-unknown}
model=${model:-"your exact model ID"}
sed -e "s/SESSION_ID/${session_id}/" -e "s/MODEL_ID/${model}/" "${CLAUDE_PLUGIN_ROOT}/hooks/problem-log.md" \
  | jq -Rs '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: .}}'
