---
name: loom-develop
description: One-off development pass — implement an approved slice-plan.
---

# loom-develop

Run a single **developer** pass, then stop.

**Installed-root bootstrap.** Resolve your installed plugin root through your
client's adapter contract (spec 10 → *Installed-root and helper binding*) before
reading `skills/loom-playbook/references/orchestration.md`; references below are
root-relative to that resolved root.

Target: the workflow argument (if empty, the next `Approved` slice-plan).

1. Launch the **developer** role (Standard profile). Run
   `bin/loom-launch-role <your-client> developer` — the sole client role
   launcher (spec 10 → *Versioned compatibility and capability mapping*) — to
   derive/validate the exact tier from the tracked compatibility matrix and
   enforce a fresh, one-level, non-delegating cold child (Codex: this performs
   the cold launch itself; Claude: launch natively per `roles/developer.md` /
   `agents/developer.md` using its printed configuration). Give it the
   slice-plan path and target specs.
2. The role sets `In Progress`, implements exactly the plan's scope, runs the full
   gate (format → lint → test), records evidence, sets `Implemented`, and commits
   author-neutral (a clean single-slice commit — the code evaluator reads its
   diff). If the plan is wrong/ambiguous it stops, leaves a `## Notes` question,
   sets `Needs Clarification` — it never edits specs/ADRs.
3. Verify the commit and resulting status; report readiness for `loom-eval-code`.
