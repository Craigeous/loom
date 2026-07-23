---
name: loom-status
description: Print a summary of loom's .docs/ state for this repo — scan only, no writes.
---

# loom-status

Scan and report — no agents, no writes.

**Installed-root bootstrap.** Resolve your installed plugin root through your
client's adapter contract (spec 10 → *Installed-root and helper binding*) before
reading `skills/loom-playbook/references/status-machine.md` for the statuses;
references below are root-relative to that resolved root.

1. Determine init mode via the classifier in
   `skills/loom-playbook/references/init-detection.md` (read-only).
2. Scan `.docs/` for gated artifacts and their `Status:` lines (research, ADR,
   spec, slice-plans, evaluations), plus `git status`/`git log`.
3. Print a summary: init mode; roadmap target (from `.docs/status/roadmap.md`);
   in-flight artifacts by status; what the dispatch table says the next action is;
   any blockers or round-limit escalations; working-tree cleanliness.
4. Stop. Do not change anything.
