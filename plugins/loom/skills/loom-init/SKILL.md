---
name: loom-init
description: Initialize or align this repo to loom's conventions.
---

# loom-init

Set up (or re-align) this repo for loom, then stop.

**Installed-root bootstrap.** Resolve your installed plugin root through your
client's adapter contract (spec 10 → *Installed-root and helper binding*) before
reading `skills/loom-playbook/references/orchestration.md` (Init-mode detection)
and `docs-layout.md`; references below are root-relative to that resolved root.

1. Detect init mode by running the classifier in
   `skills/loom-playbook/references/init-detection.md`
   (Greenfield / Unaligned / Initialized).
2. **Greenfield:** run the scaffold/seed/gate body in
   `skills/loom-playbook/references/greenfield.md`. Commit author-neutral.
   **Unaligned:** run the alignment body in
   `skills/loom-playbook/references/unaligned.md` — study the repo, scaffold +
   gate (per `greenfield.md`), descriptively back-fill `spec/` (no decisions),
   seed `status/`; leaves the repo ready to resume as Initialized. Commit
   author-neutral.
3. **Initialized:** resume per
   `skills/loom-playbook/references/initialized.md` — present the state-derived
   menu, then re-apply the current playbook idempotently (auto-apply clean
   merges, recommend for conflicts, never clobber). Commit author-neutral if
   re-application writes anything.
4. Report what was created/changed and the next step (usually `loom-run`).
