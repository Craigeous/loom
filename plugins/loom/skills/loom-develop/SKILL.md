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

1. Launch the **developer** role (Standard profile) through your client's root
   role-launcher — see `roles/developer.md` and spec 07's role-launch mapping —
   with the slice-plan path and target specs. Require a fresh, one-level,
   non-delegating cold child.
2. The role sets `In Progress`, implements exactly the plan's scope, runs the full
   gate (format → lint → test), records evidence, sets `Implemented`, and commits
   author-neutral (a clean single-slice commit — the code evaluator reads its
   diff). If the plan is wrong/ambiguous it stops, leaves a `## Notes` question,
   sets `Needs Clarification` — it never edits specs/ADRs.
3. Verify the commit and resulting status; report readiness for `loom-eval-code`.
