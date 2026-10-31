#!/usr/bin/env python3
"""Scores one question-probe run: writes questions.md and score.txt into the run directory.

Usage: score.py RUN_DIR TURNS
"""
import json, os, re, sys


def writes_goal(e):
    if e[0] != "tool":
        return False
    name, inp = e[1], e[2]
    if name in ("Write", "Edit", "MultiEdit"):
        if ".dietpowers/trackers/" not in str(inp.get("file_path", "")):
            return False
        body = str(inp.get("content", "")) + str(inp.get("new_string", "")) + json.dumps(inp.get("edits", []))
    elif name == "Bash":
        body = str(inp.get("command", ""))
        if ".dietpowers/trackers/" not in body:
            return False
        if not re.search(r">|\btee\b|\bpython3?\b|\bsd\b|\bsed -i", body):
            return False
    else:
        return False
    # The fixture's Goal says the totals "must be correct"; a placeholder does not.
    return re.search(r"Goal:[ \t]*(?!\\n)(?:(?!\\n)[^\n])*correct", body) is not None


def main(run_dir, turns):
    events = []  # ("text", str) or ("tool", name, input) or ("reply", str), in order
    for t in range(1, turns + 1):
        rp = os.path.join(run_dir, f"reply-{t}.txt")
        if os.path.exists(rp):
            events.append(("reply", open(rp).read().strip()))
        for line in open(os.path.join(run_dir, f"stream-{t}.json")):
            try:
                ev = json.loads(line)
            except ValueError:
                continue
            if ev.get("type") != "assistant" or ev.get("parent_tool_use_id") is not None:
                continue
            for c in ev.get("message", {}).get("content", []) or []:
                if c.get("type") == "text" and c.get("text", "").strip():
                    events.append(("text", c["text"]))
                elif c.get("type") == "tool_use":
                    events.append(("tool", c.get("name"), c.get("input") or {}))

    def reply_line(text):
        lines = [l for l in text.splitlines() if "Reply with" in l]
        return lines[-1] if lines else ""

    with open(os.path.join(run_dir, "questions.md"), "w") as q:
        n = 0
        for e in events:
            if e[0] == "reply":
                q.write(f"> partner (scripted): {e[1]}\n\n")
            elif e[0] == "text":
                n += 1
                tag = " [QUESTION]" if "Reply with" in e[1] else ""
                q.write(f"## Message {n}{tag}\n\n{e[1].strip()}\n\n")

    def first(pred):
        for i, e in enumerate(events):
            if pred(e):
                return i
        return None

    first_q = first(lambda e: e[0] == "text" and "Reply with" in e[1])
    first_finding_q = first(lambda e: e[0] == "text" and "**pause**" in reply_line(e[1]))
    read_aq = first(lambda e: e[0] == "tool" and (
        (e[1] == "Read" and str(e[2].get("file_path", "")).endswith("shared/asking-questions.md"))
        or (e[1] == "Bash" and "asking-questions.md" in str(e[2].get("command", "")))))

    goal_w = first(writes_goal)

    def before(a, b):
        return a is not None and (b is None or a < b)

    c1 = "pass" if before(read_aq, first_q) else "fail"
    c2 = "pass" if before(goal_w, first_finding_q) else "fail"
    oi = os.path.join(run_dir, "trackers", "open-items.md")
    oi_text = open(oi).read() if os.path.exists(oi) else ""
    c4a = "pass" if ("UTC" in oi_text or "local time" in oi_text) else "fail"
    with open(os.path.join(run_dir, "score.txt"), "w") as s:
        s.write(f"check 1 (asking-questions.md read before first question): {c1}\n")
        s.write(f"check 2 (Goal: written before first finding question): {c2}\n")
        s.write("check 3 (absent-trigger finding asked, why it could arise, deferral offered): manual\n")
        s.write(f"check 4 (log finding in open-items.md): {c4a}; (one-line notice, no question): manual\n")
        s.write("check 5 (no unexplained 'ledger roll-up', no unquoted 'the draft'/'this goal'/'item N'): manual\n")
        s.write("check 6 (each question says how many remain): manual\n")


if __name__ == "__main__":
    main(sys.argv[1], int(sys.argv[2]))
