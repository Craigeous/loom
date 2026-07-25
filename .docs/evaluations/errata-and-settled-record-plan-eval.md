# Evaluation: errata-and-settled-record

Verdict: PASS
Round: 0
Reviewed against: spec 03 (lifecycle terminal states + recorder/root ownership),
ADR 0023 §3/§4/§7 (bootstrap auxiliary review, settlement, moved-target rebuild),
the two publication receipts in `.git/loom/publications/`, `origin/loom/bootstrap-transition`
`state.json`, the repo history for every cited SHA, the `hook-wire-v1` fixture tree,
and the two `*-review-findings.md` artifacts; plus the plan-eval + severity rubrics.

## Summary

A docs-only record-keeping slice. Every factual claim it asserts was verified
mechanically and holds; scope is confined to nine docs paths with no spec/ADR/
state.json/receipt/product edit; the two decision-bearing errata (ADR-0006 in-place
rewrite, direct-push/rebase-vs-rebuild boundary) are recorded and their adjudication
correctly deferred to a remediation-2 spec/ADR cycle + owner. Status flips are
legitimate now that settlement is verified. No BLOCKER, no MAJOR. Findings are
verification-precision nits only.

### Factual claims verified (all pass)

- **(a)** `5e0b178` modified Accepted `.docs/ADR/0006-*.md` in place (26 lines; message
  "updated ADR 0006"; `Status: Accepted` in both parent and child) with no superseding
  ADR. Confirmed.
- **(b)** Reviewed head `82d689f` (base contains `c899673`); `0ae81c1` is NOT an ancestor
  of `82d689f` and IS an ancestor of `00582aa`; the `rebase_note` is present verbatim in
  `state.json` on `origin/loom/bootstrap-transition`. ADR 0023 §7 step 4 does require
  discard-and-rebuild + re-run §3/§4 on a moved target — so the rebase + byte-identical-diff
  substitution is a genuine deviation, correctly recorded (not adjudicated).
- **(c)** `0ae81c1` is single-parent (`c8996731`), touches `scripts/macos-dual-client-dogfood`,
  is an ancestor of `main`; the CI-timing/red-main detail is honestly scoped as an audit
  finding "not locally reconstructable."
- **(d)** `367584c/e2248d8/099c4f4/4189c02` each carry `loom@localhost`, are on the
  transition branch, and are outside `c7bd84d..a3cb007`; the pre-existing "13" count in that
  69-commit range is confirmed, so the "beyond the 13" framing is accurate.
- **Settlement/target:** both receipts carry `verified_target_ref: refs/heads/main` with
  results `00582aa`/`2a4700d`; both are ancestors of `main`; coord's result IS `00582aa`.
  Reconciling against `main` (not the transition branch) is correct.
- **48→12:** the tree is 2 clients × 2 events × 3 outcomes = 12 cases × 4 files = 48 files;
  the "48-case Cartesian product" phrasing is the miscount and the fix is exact.
- **Bootstrap-review phrasing:** the actual `*-review-findings.md` artifacts document
  "three cold, non-delegating auxiliary workers (correctness, tests, security)" under
  `loom-repository-bootstrap/v1` / "degraded bootstrap; not loom-local-review/v1"
  (ADR 0023 §3). The `/code-review + /security-review` labels in the status/index docs are
  the mislabels; Step 6 restates history accurately and correctly scopes out the production
  ADR 0010/0011 occurrences. The plan does NOT repeat the error it fixes.
- **Status flips:** spec 03 defines `Landed` = remote result verified + receipt recorded,
  `Archived` = plan under `archive/`; 28 existing archived plans already use `Archived`.
  Both conditions are met, so the flips are legitimate.

## Findings

- [MINOR] Verification #4 ("`rg -n 'NEXT ACTION' .docs/status/handoff.md` resolves to
  `M1 slice 2 coord-lock-ownership`") is mechanically imprecise: the handoff archive-log
  tail holds ~40 historical `NEXT ACTION` lines, so this command returns many matches
  rather than a single resolution. The load-bearing check (no `publish this candidate`
  remains) is already covered by Verification #3. Suggest scoping #4 to the current-state
  block.
- [MINOR] Verification #3's `pending publication settlement` alternative is defeated by
  line-wrapping: `progress.md` (~L8-9) and `handoff.md` (~L325-326) wrap
  "pending / publication settlement" across a newline, so a line-oriented `rg` silently
  passes even where the phrase persists. Use `rg -U` (multiline). Note that `handoff.md`
  L325-326 sits in the archive-log tail the plan intentionally leaves untouched, so the
  fix is to *scope* the check, not to assert a blanket zero.
- [MINOR] No mechanical check confirms the many current-state `Ready to Publish`
  occurrences (`progress.md` 27/62/65/92; `handoff.md` 31/67; `roadmap.md` 21) are
  transformed — Verification #2 only sweeps `archive/`. Because archive-tail L325
  legitimately retains the phrase, add a *scoped* (not blanket) sweep of the current-state
  regions. The Step edits themselves quote exact old→new strings, so this is a self-audit
  gap, not an edit-correctness defect.
- [MINOR] Context labels `00582aa` as "the current `origin/main` HEAD"; committing this
  plan advanced `main` to `a5ca17b`, so the label is now point-in-time stale. The
  load-bearing claims (coord's result IS `00582aa`; both result SHAs reachable from `main`)
  remain true, so this does not affect the reconciliation.

## Notes

The plan meets the bar for a record-keeping slice: it records deviations and defers every
authority question. The MINORs concern the reliability of the plan's own verification
harness (line-wrapping / archive-tail noise defeating a couple of the named `rg` checks),
not the accuracy of any recorded fact or the confinement of scope. A developer following
the numbered steps — which quote exact strings — will produce the intended, honest record;
tightening the four verification commands to scope past the archive-log tail and use `-U`
for wrapped phrases would let the harness prove what the edits already do.
