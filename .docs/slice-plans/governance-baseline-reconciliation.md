# Governance: reconcile program authority, record, and reality after M0

Status: Draft
Target specs: [03-artifact-lifecycle.md](../spec/03-artifact-lifecycle.md),
[04-orchestrator.md](../spec/04-orchestrator.md),
[05-blind-evaluation.md](../spec/05-blind-evaluation.md)
Authority: [ADR 0023](../ADR/0023-repository-self-hosting-bootstrap-transition.md),
[ADR 0024](../ADR/0024-macos-first-dual-client-dogfood-bootstrap-amendment.md)
Improvement slice: governance (docs + transition state only; not on the ADR 0023
code-slice list and adds no product code — no bootstrap evidence package required)

## Context

Two independent post-M0 reviews (program-design review and implementation audit,
2026-07-24) found the design sound-with-issues and the implementation record split:
the dogfood slice audits clean, but the earlier ci-baseline/amendment stretch
carries unrecorded process deviations, and one authority reference dangles. This
slice reconciles text, state, and record. It rewrites no history and no ADR.

## Items

1. **Retire `client-floor-adapter-smoke` (dangling authority).** It is eligible in
   ADR 0023 §1/§7 and named in specs 03/04/05, still present in the transition
   `allowed_slices`, but absent from the improvement plan (superseded by the ADR
   0024 dogfood slices, which delivered its coverage). Root records a remove-only
   transition successor deleting it from `allowed_slices`; planner amends the
   living eligibility text in specs 03/04/05 (frozen-spec cycle) to mark it
   "retired — superseded by ADR 0024 dogfood evidence"; plan gains a one-line note.
2. **Record early-stretch deviations (errata, no rewrite).** Add an "M0 errata"
   subsection to `.docs/status/progress.md` and a pointer in
   `.docs/evaluations/README.md` stating plainly: (a) 13 commits in
   `c7bd84d..a3cb007` carry non-uniform identities (`loom@localhost`,
   `loom-recorder@invalid`, `loom@local`) in violation of ADR 0003; (b) merge
   commit `44f16a4` breaks the linear direct-push model; (c) ci-baseline landed
   via GitHub PR #3 (rebase-merge) while its settlement records
   `publication_mode: remote-direct`; (d) ci-baseline's in-tree evidence set is
   incomplete (no plan-eval, no evidence JSON). History is immutable; the record
   must say what happened.
3. **State the bootstrap single-session precondition.** ADR 0023 §7's remote-direct
   publication is safe before M1/M2 only because bootstrap runs single-owner,
   single-session, from a fresh remote fetch. ADR 0023 is immutable; record the
   precondition in spec 04's bootstrap subsection (frozen-spec cycle) with a
   back-reference.
4. **Make "M0 Landed" precise.** Roadmap/progress state exactly what M0 covers:
   static reproducible baseline + macOS-arm64 behavioral dogfood (Codex cold-launch
   leg infrastructure-blocked, credentialless by design); Ubuntu/Intel obligations
   and public Codex support remain owed by ADR 0019 at release, not by M0.
5. **Branch/PR hygiene record + one decision.** Record in progress.md: PRs #1/#2
   closed, four redundant remote branches deleted (2026-07-24). Owner gate: verify
   whether any transition-state or evaluation record references
   `loom/bootstrap-authority-b28a747`; delete it only if unreferenced, else keep
   and document its anchor role.

## Exact path boundary

`.docs/slice-plans/governance-baseline-reconciliation.md` (this file, lifecycle),
`.docs/slice-plans/README.md`, `.docs/repository-improvement-plan.md` (item-1
note only), `.docs/spec/03-artifact-lifecycle.md`, `.docs/spec/04-orchestrator.md`,
`.docs/spec/05-blind-evaluation.md` (eligibility/precondition lines only),
`.docs/status/{progress,roadmap,handoff}.md`, `.docs/evaluations/README.md`, and
the transition branch `state.json` (root-owned remove-only successor). No product
code, no hooks, no schemas, no ADR edits.

## Verification

1. `rg client-floor-adapter-smoke` over `.docs/spec/` shows only "retired" glosses;
   transition `allowed_slices` no longer contains it; replay stays monotonic with
   predecessor chain intact.
2. Spec amendments pass a blind plan evaluation (frozen-spec cycle, specs 03/04/05
   re-approved).
3. `scripts/check` green (docs/link stages).
4. progress.md errata lists exactly the four deviation classes with commit SHAs.

## Notes

- 2026-07-24: Drafted from the two review verdicts (design: sound-with-issues,
  2 MAJOR / 3 MINOR; audit: violations-found in the early stretch, dogfood clean).
  De-scoping the ADR 0023 §7 / M2 duplication is deliberately excluded — that is
  an M2 planning concern, not governance.
