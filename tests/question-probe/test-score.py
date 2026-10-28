#!/usr/bin/env python3
"""Tests for score.py's check 2: which tool calls count as recording the goal."""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from score import writes_goal  # noqa: E402

T = ".dietpowers/trackers/2026-10-28-store-totals-spec-review.md"
GOAL = '- Goal: "The totals must be correct for every store."'

CASES = [
    ("Write with the goal", ("tool", "Write", {"file_path": T, "content": GOAL}), True),
    ("Edit with the goal", ("tool", "Edit", {"file_path": T, "new_string": GOAL}), True),
    ("Bash heredoc write", ("tool", "Bash", {"command": f"cat > {T} <<'EOF'\n{GOAL}\nEOF"}), True),
    ("Bash python write, escaped quote",
     ("tool", "Bash", {"command": f"python3 - <<'EOF'\np='{T}'\ns=s.replace('- Goal:\\n', '- Goal: \\\"The totals must be correct\\\"')\nEOF"}), True),
    ("Bash grep read", ("tool", "Bash", {"command": f'grep -n "Goal: correct" {T}'}), False),
    ("Bash sed print read", ("tool", "Bash", {"command": f'sed -n "/Goal: correct/p" {T}'}), False),
    ("Write with a placeholder", ("tool", "Write", {"file_path": T, "content": "- Goal: (recorded at step 5)"}), False),
    ("Write with an empty Goal", ("tool", "Write", {"file_path": T, "content": "- Goal:\n- Second pass: pending"}), False),
    ("Write outside the trackers", ("tool", "Write", {"file_path": "notes.md", "content": GOAL}), False),
    ("Read of the tracker", ("tool", "Read", {"file_path": T}), False),
]

failed = 0
for name, event, want in CASES:
    got = writes_goal(event)
    if got != want:
        failed += 1
        print(f"FAIL: {name}: got {got}, want {want}")
if failed:
    sys.exit(1)
print(f"PASS: {len(CASES)} writes_goal cases")
