# Governance: reconcile the M0 record with reality (record-keeping only)

Status: Plan Review
Target specs: none (no spec edits — see Notes)
Authority: [ADR 0023](../ADR/0023-repository-self-hosting-bootstrap-transition.md),
[ADR 0024](../ADR/0024-macos-first-dual-client-dogfood-bootstrap-amendment.md)
Improvement slice: governance (living-doc record-keeping only; not on the ADR 0023
code-slice list and adds no product code — no bootstrap evidence package required)

## Context

Two independent post-M0 reviews (program-design review and implementation audit,
2026-07-24) found the design sound-with-issues and the implementation record split:
the dogfood slice audits clean, but the earlier ci-baseline/amendment stretch
carries unrecorded process deviations. This slice does **record-keeping only** — it
writes down what happened in the living docs. It changes no authority, edits no
frozen spec, and mutates no transition state. It rewrites no history and no ADR.

Two items the round-0 draft attempted here are **out of scope** and deferred to an
ADR-level decision (see Notes → "Deferred to ADR-level decision"): retiring
`client-floor-adapter-smoke`, and folding the ADR 0023 §7 single-session
publication precondition into a spec. Both are authority/design changes, not
record-keeping, and the plan evaluator ruled they require an accepted ADR. This
slice may only *record the observation and the owner question*, not enact either.

## Items

1. **Record early-stretch deviations (errata, no rewrite).** Add an "M0 errata"
   subsection to `.docs/status/progress.md` and a pointer line in
   `.docs/evaluations/README.md` stating plainly: (a) 13 commits in the
   `c7bd84d..a3cb007` range carry non-uniform identities (`loom@localhost`,
   `loom-recorder@invalid`, `loom@local`) in violation of ADR 0003; (b) merge
   commit `44f16a4` breaks the linear direct-push model; (c) ci-baseline landed
   via GitHub PR #3 (rebase-merge) while its settlement records
   `publication_mode: remote-direct`; (d) ci-baseline's in-tree evidence set is
   incomplete (no plan-eval, no evidence JSON). History is immutable; the record
   states what happened. No history is rewritten and no commit is re-authored.

2. **Make "M0 Landed" precise.** In `.docs/status/roadmap.md` and
   `.docs/status/progress.md`, state exactly what M0 covers: static reproducible
   baseline + macOS-arm64 behavioral dogfood (Codex cold-launch leg
   infrastructure-blocked, credentialless by design); Ubuntu/Intel obligations and
   public Codex support remain owed by ADR 0019 at release, not by M0.

3. **Branch/PR hygiene record + one owner question (recorded, not enacted).**
   Record in `.docs/status/progress.md` as facts already performed on 2026-07-24:
   PRs #1 and #2 closed; four redundant remote branches deleted. Additionally
   record the mechanical status of `loom/bootstrap-authority-b28a747`: it still
   exists on the remote (`git ls-remote --heads origin
   loom/bootstrap-authority-b28a747` → `b28a747…`) and a reference scan
   (`git grep -n bootstrap-authority-b28a747` over `.docs/` plus a scan of the
   transition `state.json` history) shows whether any state or evaluation record
   anchors it. Record that scan result as an errata fact; the keep-vs-delete
   **decision is deferred to the owner** — this slice does not delete the branch.

## Exact path boundary

Living docs only, all under `.docs/`:

- `.docs/slice-plans/governance-baseline-reconciliation.md` (this file, lifecycle)
- `.docs/slice-plans/README.md` (index entry)
- `.docs/status/progress.md` (errata subsection, M0 precision, hygiene record)
- `.docs/status/roadmap.md` (M0 precision)
- `.docs/evaluations/README.md` (errata pointer line)

No product code, no hooks, no schemas, **no ADR edits, no spec edits, no
transition-state / `state.json` mutation, and no remote-ref operations** (the PR
closes and branch deletes are recorded as already-performed facts, not actions of
this slice). `loom/bootstrap-authority-b28a747` is scanned and recorded only; its
fate is an owner decision.

## Verification

Each item has a named mechanical check; all must pass.

1. **Errata (item 1).**
   - `git grep -n "M0 errata" .docs/status/progress.md` returns the subsection
     heading.
   - The errata subsection names all four deviation classes; assert each with
     `git grep -nF -e "loom@localhost" -e "loom-recorder@invalid" -e "loom@local"
     -e "44f16a4" -e "PR #3" -e "remote-direct" .docs/status/progress.md`
     (all present).
   - The identity-violation count is stated as **13** and matches the tree:
     `git log --format='%ae' c7bd84d..a3cb007 | grep -Ec
     'loom@localhost|loom-recorder@invalid|loom@local'` → `13`
     (range is 69 commits total).
   - `git grep -n "M0 errata" .docs/evaluations/README.md` returns the pointer line.
2. **M0 precision (item 2).** `git grep -nF -e "macOS-arm64" -e "Codex cold-launch"
   -e "Ubuntu/Intel" .docs/status/roadmap.md .docs/status/progress.md` shows the
   scope qualifiers present in both docs; `git grep -n "M0 Landed"
   .docs/status/roadmap.md` still resolves.
3. **Hygiene record (item 3).** `git grep -nF -e "PR #1" -e "PR #2"
   -e "bootstrap-authority-b28a747" .docs/status/progress.md` shows the recorded
   facts; the recorded scan result matches a live
   `git grep -n bootstrap-authority-b28a747 .docs/` and the branch-existence probe
   `git ls-remote --heads origin loom/bootstrap-authority-b28a747` (currently
   `b28a747…`).
4. **Gate.** `scripts/check` green (docs + link stages), which also validates the
   internal reference links in the edited docs.

## Notes

- 2026-07-24 (round-0 revision): De-scoped to record-keeping only after plan-eval
  FAIL round 0 (`.docs/evaluations/governance-baseline-reconciliation-plan-eval.md`).
  Removed the two authority/design changes and their spec + transition-state edits;
  every surviving item is now a living-doc record with a named mechanical check;
  path boundary reduced to the five `.docs/` files actually edited.
- **Deferred to ADR-level decision (explicit owner question).** These two are not in
  this slice; they need an accepted ADR, and the owner must choose how to route them:
  1. *`client-floor-adapter-smoke`* is ADR 0023 §1/§7-eligible, named in specs
     03/04/05, and still present in the transition `allowed_slices` at seq 7, yet the
     ADR 0024 dogfood slices appear to deliver overlapping coverage (only partially —
     the Codex cold-launch leg is infrastructure-blocked, per item 2's M0 precision).
     Retiring
     it is a design decision reserved to an ADR (symmetric to ADR 0024, which
     required a full ADR + owner ratification + a bound state amendment to change the
     list in the *add* direction). **Owner question:** schedule
     `client-floor-adapter-smoke` and let it run, **or** author a new ADR that
     retires it on a coverage finding?
  2. *ADR 0023 §7 single-session publication precondition* (remote-direct is safe
     pre-M1/M2 only under single-owner, single-session, fresh-fetch operation). ADR
     0023 is immutable; recording this in a frozen spec is a spec change. **Owner
     question:** fold this precondition into the *same* planning cycle as (1) via one
     new ADR, or defer to M2 planning where the §7/M2 duplication is already owed?
- 2026-07-24 (draft): Drafted from the two review verdicts (design:
  sound-with-issues, 2 MAJOR / 3 MINOR; audit: violations-found in the early
  stretch, dogfood clean). De-scoping the ADR 0023 §7 / M2 duplication is
  deliberately excluded — that is an M2 planning concern.
</content>
</invoke>
