---
name: loom-eval-code
description: One-off blind review of an implemented slice's code.
---

# loom-eval-code

Run a single **code-evaluator** pass (blind), then stop.

**Installed-root bootstrap.** Resolve your installed plugin root through your
client's adapter contract (spec 10 → *Installed-root and helper binding*) before
reading `skills/loom-playbook/references/orchestration.md`; references below are
root-relative to that resolved root.

Target: the workflow argument (if empty, the next `Implemented` slice).

1. Gather the **blind inputs only**: the slice's commit diff, the slice-plan it was
   meant to satisfy, and the target spec(s). **No author/identity hint.**
2. Launch the **code-evaluator** role (Deep review profile). Run
   `bin/loom-launch-role <your-client> code-evaluator` — the sole client role
   launcher (spec 10 → *Versioned compatibility and capability mapping*) — to
   derive/validate the exact tier from the tracked compatibility matrix and
   enforce a fresh, one-level, non-delegating cold child (Codex: this performs
   the cold launch itself; Claude: launch natively per
   `roles/code-evaluator.md` / `agents/code-evaluator.md` using its printed
   configuration). Give it those blind inputs only.
3. The role **re-runs the gate** (doesn't trust the claim), writes
   `.docs/evaluations/<slice>-eval.md` (PASS/FAIL + severity), sets status
   (`Landed` on PASS, `In Progress` on FAIL — status line only), and commits
   author-neutral.
4. Verify the commit; report the verdict. On PASS, the next step is the
   developer's finalize pass (update `status/`, archive the plan) — run
   `loom-develop` in finalize mode or let `loom-run` handle it.
