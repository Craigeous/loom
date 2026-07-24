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

1. Launch the **planner** role (Deep review profile). Run
   `bin/loom-launch-role <your-client> planner` — the sole client role launcher
   (spec 10 → *Versioned compatibility and capability mapping*) — to
   derive/validate the exact tier from the tracked compatibility matrix and
   enforce a fresh, one-level, non-delegating cold child (Codex: this performs
   the cold launch itself; Claude: launch natively per `roles/planner.md` /
   `agents/planner.md` using its printed configuration). Give it the focus and
   current `.docs/` context (research, approved specs/ADRs, status).
2. The role authors/revises an ADR, spec, or slice-plan from the playbook
   templates, sets `Status: Plan Review` (or `Draft` while working), and commits
   author-neutral. The planner is the sole writer of `spec/` and `ADR/`.
3. Verify the commit; report the artifact path and that it's ready for
   `loom-eval-plan`.
