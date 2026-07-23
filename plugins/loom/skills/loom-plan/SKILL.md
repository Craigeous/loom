---
name: loom-plan
description: One-off planning pass — advance an ADR, spec, or slice-plan.
---

# loom-plan

Run a single **planner** pass, then stop.

**Installed-root bootstrap.** Resolve your installed plugin root through your
client's adapter contract (spec 10 → *Installed-root and helper binding*) before
reading `skills/loom-playbook/references/orchestration.md`; references below are
root-relative to that resolved root.

Focus: the workflow argument (if empty, advance the next thing per
`.docs/status/handoff.md` and `roadmap.md`).

1. Launch the **planner** role (Deep review profile) through your client's root
   role-launcher — see `roles/planner.md` and spec 07's role-launch mapping — with
   the focus and current `.docs/` context (research, approved specs/ADRs, status).
   Require a fresh, one-level, non-delegating cold child.
2. The role authors/revises an ADR, spec, or slice-plan from the playbook
   templates, sets `Status: Plan Review` (or `Draft` while working), and commits
   author-neutral. The planner is the sole writer of `spec/` and `ADR/`.
3. Verify the commit; report the artifact path and that it's ready for
   `loom-eval-plan`.
