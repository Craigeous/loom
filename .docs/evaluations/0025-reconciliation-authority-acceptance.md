# Owner acceptance: ADR 0025 — Reconciliation Authority

Status: Accepted
Accepted-at: 2026-07-25
Accepted-by: owner (repository owner, spec 03 owner-acceptance authority)

## What is accepted

ADR `0025-reconciliation-authority-plugin-root-no-bypass-landing.md`, revised
commit `1fc8cd0413747a8be81acfbcb5f6c38f22c54703`
(blob `df9692f5b0b2411c1a3435fff059a4567fdd9584`).

## Basis

- Cold blind plan-evaluation (`bootstrap-ratification: degraded`), round 0:
  PASS with 3 MINOR, then a resolving PASS after the three MINORs were folded
  in — recorded in `.docs/evaluations/0025-reconciliation-authority-eval.md`
  (blob `0e1c4d6604e2831d256b02844b3504e5a4581334`,
  SHA-256 `354d7c6735e364c09091db90ce2a1b3681d6e490c4db5840c86deef96f02f597`).
- The evaluation is advisory; this owner acceptance is the dispositive gate per
  spec 03 and ADR 0025's own self-bootstrap clause.

## Decisions accepted

- **A.** The plugin-root location of record is `./plugins/loom`; ADR 0025
  formally supersedes ADR 0006 on that point. ADR 0006 keeps its original
  `Accepted`/`Date: 2026-06-08`, gains a forward-pointer note, and its body is
  restored to the pre-rewrite text of `5e0b178^` in the reconciliation step.
- **B.** No direct-push bypass: during the bootstrap, every commit advancing
  `origin/main` lands through the ADR 0023 §7 ceremony. A persistent
  `docs-governance/v1` slice class is authorized via one append-only §6
  transition-state successor; docs-governance slices prove §7 with a blind
  plan-eval + a distinct cold docs code-eval + the `scripts/check` gate (no
  three-finder package). Prior direct-pushes are recorded pre-rule deviations,
  not rewritten.

## Activation and landing

Per ADR 0025's self-bootstrap: this acceptance activates exactly one §6 ledger
successor (`adr-0025-no-bypass-target-landing/v1`) on
`refs/loom/bootstrap-transition`, which never advances `main`. This acceptance
record, the eval verdict record, ADR 0025's `Status: Accepted` flip, and all
reconciliation edits reach `main` solely as the first `docs-governance/v1` §7
slice.
