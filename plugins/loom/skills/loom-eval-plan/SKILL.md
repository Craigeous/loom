---
name: loom-eval-plan
description: One-off blind review of a research note or planning artifact.
---

# loom-eval-plan

Run a single **plan-evaluator** pass (blind), then stop.

**Installed-root bootstrap.** Resolve your installed plugin root through your
client's adapter contract (spec 10 → *Installed-root and helper binding*) before
reading `skills/loom-playbook/references/orchestration.md`; references below are
root-relative to that resolved root.

Target: the workflow argument (if empty, the next artifact at `Plan Review` or
`Research Review`).

1. Gather the **blind inputs only**: the artifact and its authority (slice-plan →
   spec(s)+ADRs; spec → ADRs; ADR → research/problem; research note → its cited
   sources). **Do not pass any author/identity hint.**
2. Launch the **plan-evaluator** role (Deep review profile). Run
   `bin/loom-launch-role <your-client> plan-evaluator` — the sole client role
   launcher (spec 10 → *Versioned compatibility and capability mapping*) — to
   derive/validate the exact tier from the tracked compatibility matrix and
   enforce a fresh, one-level, non-delegating cold child (Codex: this performs
   the cold launch itself; Claude: launch natively per
   `roles/plan-evaluator.md` / `agents/plan-evaluator.md` using its printed
   configuration). Give it those blind inputs only.
3. The role **produces its verdict** (PASS/FAIL + severity findings) to its
   confined scratch/output workspace, then returns — it does not write into
   `.docs/evaluations/`, set the status line, or commit. The recorder/root
   installs the verdict under `.docs/evaluations/<name>-eval.md`, makes the
   status transition (`Approved` on PASS, `Draft` on FAIL), and commits
   author-neutral.
4. Verify the recorder's commit; report the verdict and resulting status.
