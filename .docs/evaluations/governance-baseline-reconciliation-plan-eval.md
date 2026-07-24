# Evaluation: governance-baseline-reconciliation (slice-plan)

Verdict: FAIL
Round: 0
Reviewed against: ADR 0023 (§1 closed-list/remove-only, §6 transition-state rules,
§7), ADR 0024 §3/§5, specs 03/04/05 (frozen-spec amendment cycle), spec 03
lifecycle; plan-eval + severity rubrics. Facts checked mechanically against the
repo object database and the protected transition ref
(`origin/loom/bootstrap-transition` tip `32c53154`, seq 7, phase active).

## Findings

- [BLOCKER] Item 1 retires `client-floor-adapter-smoke` on a supersession the cited
  authority never adopted. The transition state at seq 7 still lists the slice in
  `allowed_slices` (verified), and it is named eligible in specs 03 (line 113), 04
  (line 93), 05 (line 92). The plan's justification — "superseded by the ADR 0024
  dogfood slices, which delivered its coverage" — is not supported by ADR 0024:
  that ADR *added* two slices, left the M0 list (including
  `client-floor-adapter-smoke`) intact, and states its progressive-retirement and
  other §6 rules "otherwise remain intact" (0024 §3 final paragraph, Consequences).
  It is further contradicted by this plan's own item 4, which concedes the dogfood
  coverage is partial (Codex cold-launch leg infrastructure-blocked; Ubuntu/Intel
  obligations still owed). Deciding that a §1-named, still-eligible slice is now
  redundant is a design decision reserved to an accepted ADR — the symmetric case
  to ADR 0024, which required a full accepted ADR + owner ratification + a bound
  state amendment merely to change the list in the *add* direction. A governance
  slice-plan cannot make that judgment, and it drives an irreversible (append-only)
  removal on the protected ref plus three frozen-spec edits.

- [BLOCKER] Item 1's transition-state mutation is not executable as written. "Root
  records a remove-only transition successor deleting it from `allowed_slices`" omits
  every ADR 0023 §6 control for the most-gated operation in the program: fresh
  verify current tip = seq 7 / `32c53154`, sole parent = that tip, sequence → 8,
  complete cumulative state repeating immutable program/config fields and the
  `adr-0024-macos-dogfood/v1` amendment byte-for-byte, ref protection re-check,
  non-force push, and fresh fetch-back verification by exact object ID before it has
  authority. ADR 0023 also defines *no* write procedure that produces a bare,
  result-less removal — every existing successor (seq 1–7) coupled removal to a
  settlement result or the 0024 amendment. An independent reader cannot safely
  perform this mutation from the plan.

- [MAJOR] Not single-purpose. Item 1 (a protected-ref mutation plus three
  frozen-spec amendments requiring 03/04/05 re-approval) is bundled with lightweight
  living-doc record-keeping (items 2, 4, 5) and a separate spec amendment (item 3).
  The whole slice's approval rides on its most contentious, heaviest item. Split
  item 1 out (and, per the blockers, route it through an ADR); items 2–5 are a
  coherent reconcile-the-record slice on their own.

- [MAJOR] Verification incomplete. The Verification section covers item 1 (V1) and
  item 2 (V4), but items 4 (precise "M0 Landed" in roadmap/progress) and 5
  (branch/PR hygiene record + owner-gate decision) have no named check, and item 3's
  bootstrap-precondition text has only "passes plan eval" (V2), not a mechanical
  presence/back-reference check. Rubric requires verification named for each item.

- [MINOR] The "Exact path boundary" is framed entirely as filesystem paths, but two
  items perform remote-ref operations outside that frame: the transition-successor
  push (item 1) and the branch deletion(s) (item 5). Scope the remote operations
  explicitly rather than reducing them to "the transition branch state.json."

- [MINOR] Item 5's owner gate on `loom/bootstrap-authority-b28a747` (confirmed to
  exist on the remote) should state the mechanical "unreferenced" check (e.g. `rg`
  across `.docs/` plus the transition state history) so the delete/keep decision is
  reproducible rather than judgment-only.

## Required changes (for FAIL)

1. Remove item 1 from this slice, or replace its basis. Retiring an eligible,
   §1-named slice on a supersession theory requires an accepted ADR that (a) finds
   `client-floor-adapter-smoke`'s coverage actually delivered — reconciled with item
   4's admission that the dogfood leg is partial — and (b) authorizes the removal.
   This governance plan may record the *observation* that the slice appears
   superseded and recommend an ADR; it may not enact the removal or the "retired"
   spec edits.
2. If any transition-successor write survives review, specify the full ADR 0023 §6
   procedure: verified predecessor tip (`32c53154`, seq 7), sole parent, sequence
   increment to 8, complete cumulative state with the immutable amendment preserved,
   protection re-verification, non-force push, and fresh fetch-back validation.
3. Split the contentious/heavyweight authority change from the record-keeping so the
   slice is single-purpose.
4. Name a mechanical verification for every item, including items 3, 4, and 5.
5. Extend the boundary to cover remote-ref operations (transition push, branch
   deletes) and make item 5's "unreferenced" test mechanical.

## Notes

The exemption line ("not on the ADR 0023 code-slice list, adds no product code — no
bootstrap evidence package required") is correct *for the docs portions*: a docs-only
governance change goes through the normal plan-evaluator lifecycle (this review),
not the §3/§4 three-finder code-evidence package, since ADR 0023 §1 governs
code-bearing slices. The reasoning is incomplete, however: it is used to wave away
the item-1 transition-ref mutation, which is itself one of the most heavily gated
operations in ADR 0023 (§6) and is not exempt from those controls or from the
authority question above. Items 2 and 4's factual anchors check out — the referenced
commits `c7bd84d`, `a3cb007`, `44f16a4` exist and the `c7bd84d..a3cb007` range is
non-empty (69 commits, of which the plan cites a 13-commit identity-violation
subset) — so the errata items 2/4/5 are sound in substance; the blockers are
confined to item 1.
