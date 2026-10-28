#!/usr/bin/env bash
# Runs a spec review against a fixture with a fixed reviewer report, answers its questions from a
# script, and scores how the questions are asked. See docs/testing.md, "Question probe".
#
# Usage: ./run-probe.sh [-n RUNS] [-r GIT_REF] [-m MODEL] [-e EFFORT] [-t MAX_TURNS]
#
# Without -r it tests the working tree; -r 5ffdda8 tests 0.1.0. Exits non-zero only for broken setup.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
RUNS=3
REF=""
MODEL="claude-opus-5-5"
EFFORT="high"
MAX_TURNS=30
MAX_FOLLOWUPS=8

while [ $# -gt 0 ]; do
    case "$1" in
        -n) RUNS="$2"; shift 2 ;;
        -r) REF="$2"; shift 2 ;;
        -m) MODEL="$2"; shift 2 ;;
        -e) EFFORT="$2"; shift 2 ;;
        -t) MAX_TURNS="$2"; shift 2 ;;
        -h|--help)
            echo "Usage: $0 [-n RUNS] [-r GIT_REF] [-m MODEL] [-e EFFORT] [-t MAX_TURNS]"
            exit 0
            ;;
        *) echo "unknown argument: $1" >&2; exit 2 ;;
    esac
done

command -v claude >/dev/null 2>&1 || { echo "HARNESS ERROR: claude not on PATH" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "HARNESS ERROR: jq not on PATH" >&2; exit 1; }

LABEL="${REF:-worktree}"
TIMESTAMP=$(date +%s)
OUTPUT_DIR="${TMPDIR:-/tmp}/dietpowers-tests/${TIMESTAMP}-$$/question-probe/${LABEL}"
PLUGIN_DIR="${TMPDIR:-/tmp}/qp-plugin-${TIMESTAMP}-$$"
mkdir -p "$OUTPUT_DIR" "$PLUGIN_DIR"

if [ -n "$REF" ]; then
    git -C "$REPO_DIR" archive "$REF" | tar -x -C "$PLUGIN_DIR"
else
    rsync -a --exclude .git --exclude .dietpowers "$REPO_DIR/" "$PLUGIN_DIR/"
fi
if [ ! -f "$PLUGIN_DIR/skills/adversarial-review/SKILL.md" ]; then
    echo "HARNESS ERROR: plugin copy has no skills/adversarial-review/SKILL.md ($PLUGIN_DIR)" >&2
    exit 1
fi
cp "$SCRIPT_DIR/fixed-report.md" "$PLUGIN_DIR/skills/adversarial-review/spec-reviewer.md"

TIMEOUT_BIN=$(command -v gtimeout || command -v timeout || true)
SPEC="docs/dietpowers/2026-10-27-store-totals-spec.md"
GOAL_TEXT="$(awk '/^## Goal/{f=1;next} /^## /{f=0} f' "$SCRIPT_DIR/fixture/$SPEC" | sed '/^$/d')"
FIRST_PROMPT="/dietpowers:adversarial-review spec $SPEC. You may commit the spec to this branch."

run_claude() {
    # $1 log file, $2 prompt, $3 session id or empty
    local resume=()
    [ -n "$3" ] && resume=(--resume "$3")
    ( cd "$WS" && ${TIMEOUT_BIN:+$TIMEOUT_BIN 900} claude -p "$2" ${resume[@]+"${resume[@]}"} \
        --plugin-dir "$PLUGIN_DIR" \
        --setting-sources project \
        --dangerously-skip-permissions \
        --model "$MODEL" \
        --effort "$EFFORT" \
        --max-turns "$MAX_TURNS" \
        --output-format stream-json \
        --verbose ) > "$1" 2>&1 || true
    if [ ! -s "$1" ]; then
        echo "HARNESS ERROR: no output at $1" >&2
        exit 1
    fi
}

last_text() {
    local text
    text=$(jq -r 'select(.type=="result") | .result // empty' "$1" | tail -c 20000)
    if [ -z "$text" ]; then
        text=$(jq -r 'select(.type=="assistant" and .parent_tool_use_id==null) | .message.content[]? | select(.type=="text") | .text' "$1")
    fi
    printf '%s' "$text"
}

for i in $(seq 1 "$RUNS"); do
    RUN_DIR="$OUTPUT_DIR/run-$i"
    mkdir -p "$RUN_DIR"
    # The workspace sits outside OUTPUT_DIR so its path carries no test or skill names.
    WS="${TMPDIR:-/tmp}/qp-ws-${TIMESTAMP}-$$-${i}"
    mkdir -p "$WS"
    cp -R "$SCRIPT_DIR/fixture/." "$WS/"
    ( cd "$WS" && git init -q && git checkout -q -b store-totals && git add -A \
        && git -c user.name=probe -c user.email=probe@example.invalid commit -q -m "Store totals spec" )

    turn=1
    run_claude "$RUN_DIR/stream-$turn.json" "$FIRST_PROMPT" ""
    SID=$(jq -r 'select(.type=="system" and .subtype=="init") | .session_id' "$RUN_DIR/stream-1.json" | head -1)
    if [ -z "$SID" ] || [ "$SID" = "null" ]; then
        echo "HARNESS ERROR: no session_id in $RUN_DIR/stream-1.json" >&2
        exit 1
    fi
    printf '%s\n' "$FIRST_PROMPT" > "$RUN_DIR/reply-1.txt"

    goal_sent=false
    while [ "$turn" -le "$MAX_FOLLOWUPS" ]; do
        text=$(last_text "$RUN_DIR/stream-$turn.json")
        reply_line=$(printf '%s\n' "$text" | grep 'Reply with' | tail -1)
        if printf '%s' "$reply_line" | grep -qF '**pause**'; then
            reply="add to open items"
        elif printf '%s' "$reply_line" | grep -qF '**continue**'; then
            break
        elif [ -n "$reply_line" ] && [ "$goal_sent" = false ] && printf '%s' "$text" | grep -qi 'goal'; then
            reply="$GOAL_TEXT as written"
            goal_sent=true
        else
            break
        fi
        turn=$((turn + 1))
        printf '%s\n' "$reply" > "$RUN_DIR/reply-$turn.txt"
        run_claude "$RUN_DIR/stream-$turn.json" "$reply" "$SID"
    done

    [ -d "$WS/.dietpowers/trackers" ] && cp -R "$WS/.dietpowers/trackers" "$RUN_DIR/trackers"

    python3 "$SCRIPT_DIR/score.py" "$RUN_DIR" "$turn"
    echo "run $i: $(tr '\n' ' ' < "$RUN_DIR/score.txt" | sed 's/  */ /g')"
done

echo "plugin: $LABEL  model: $MODEL  effort: $EFFORT  cli: $(claude --version 2>/dev/null)"
echo "logs:   $OUTPUT_DIR"
exit 0
