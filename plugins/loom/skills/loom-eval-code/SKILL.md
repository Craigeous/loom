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
2. Launch the **code-evaluator** role (Deep review profile) through your client's
   root role-launcher — see `roles/code-evaluator.md` and spec 07's role-launch
   mapping — with those inputs. Require a fresh, one-level, non-delegating cold
   child.
3. The role **re-runs the gate** (doesn't trust the claim), writes
   `.docs/evaluations/<slice>-eval.md` (PASS/FAIL + severity), sets status
   (`Landed` on PASS, `In Progress` on FAIL — status line only), and commits
   author-neutral.
4. Verify the commit; report the verdict. On PASS, the next step is the
   developer's finalize pass (update `status/`, archive the plan) — run
   `loom-develop` in finalize mode or let `loom-run` handle it.
