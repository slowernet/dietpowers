#!/usr/bin/env bash
# Emits the dev-only problem-log instruction as SessionStart context, with this session's id filled in.
set -euo pipefail
session_id=$(jq -r '.session_id // empty' 2>/dev/null || true)
session_id=${session_id:-unknown}
sed "s/SESSION_ID/${session_id}/" "${CLAUDE_PLUGIN_ROOT}/hooks/problem-log.md" \
  | jq -Rs '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: .}}'
