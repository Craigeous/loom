# errata-and-settled-record

Status: Plan Review
Target specs: none (docs-only record-keeping slice; no frozen-spec edits)
Authority: post-M1-slice-1 alignment audit (2026-07-24); records outcomes into the
durable status/index docs per spec 03 (`Landed`/`Archived` on settlement) and appends to
the existing `progress.md` § "M0 errata" style. Adjudicates nothing.

## Context

M1 slice 1 `coord-identifier-boundaries` and the earlier `macos-dual-client-dogfood`
slice are **both settled** — the ADR-0023 publication receipts exist at
`.git/loom/publications/{coord-identifier-boundaries,macos-dual-client-dogfood}.json`
(`schema: loom-repository-bootstrap-publication-receipt/v1`, `verified_target_ref:
refs/heads/main`), and both settlement result SHAs are ancestors of the current
`origin/main` HEAD `00582aa` (coord's result SHA **is** `00582aa`; macOS's is
`2a4700d`). The durable record has not caught up: both archived slice-plans still read
`Status: Ready to Publish`, and `progress.md` / `handoff.md` / `roadmap.md` still say
"pending settlement". `handoff.md` also carries two **contradictory** NEXT ACTION lines
(one "publish this candidate", one "plan M1 slice 2"). A 2026-07-24 alignment audit
also surfaced four integrity/process errata and three doc-drift miscounts that the
honest record should carry.

This slice makes the durable record **honest and internally consistent**. It is
**docs-only record-keeping**: it changes no product code, no frozen spec, no ADR, no
transition `state.json`, and no publication receipt. It **records** that certain
deviations occurred; it does **not adjudicate** them (see Notes — deferred decisions).

### Out of scope (explicitly)

- No edits to `.docs/spec/**`, `.docs/ADR/**`, `state.json`, publication receipts, or
  any `plugins/loom/**` product/code/test/fixture file.
- No history rewrite and no commit re-authoring (errata are append-only facts).
- No adjudication of the ADR-0006-treatment or the direct-push-boundary questions —
  those are DECISIONS deferred to a remediation-2 spec/ADR cycle + owner (Notes).
- No full historical sweep of `handoff.md`'s deep archive-log tail; the bootstrap-review
  phrasing fix targets only the current-state descriptions enumerated in Step 6.

## Exact path boundary

This slice may touch **only** these paths, and nothing else:

1. `.docs/slice-plans/archive/macos-dual-client-dogfood.md` — **line 3 `Status:` only**
2. `.docs/slice-plans/archive/coord-identifier-boundaries.md` — **line 3 `Status:` only**
3. `.docs/slice-plans/README.md`
4. `.docs/evaluations/README.md`
5. `.docs/status/progress.md`
6. `.docs/status/handoff.md`
7. `.docs/status/roadmap.md`
8. `CLAUDE.md`
9. `.docs/slice-plans/errata-and-settled-record.md` (this plan file)

Any diff outside these nine paths is a scope violation. Within the two `archive/*.md`
files, **only the front-matter `Status:` line changes** — their bodies are untouched.

## Steps

1. **Flip the two archived-plan `Status:` lines to settled/terminal.** In both
   `.docs/slice-plans/archive/macos-dual-client-dogfood.md` and
   `.docs/slice-plans/archive/coord-identifier-boundaries.md`, change line 3 from
   `Status: Ready to Publish` to `Status: Archived` (the terminal state used by every
   other settled archived plan, e.g. `governance-baseline-reconciliation.md`,
   `macos-dogfood-program-amendment.md`). Change nothing else in those files.

2. **Update `.docs/slice-plans/README.md`.**
   - **Active plans** (currently the single line `(none)` under `## Active plans`): add
     an entry for this plan —
     `- [errata-and-settled-record.md](errata-and-settled-record.md) — Plan Review — docs-only record-keeping: flip the two settled archived plans to Archived, reconcile status/index docs to settled reality, append four audit errata + fix three doc-drift miscounts.`
   - **Archived plans**: in the `archive/coord-identifier-boundaries.md` entry, replace
     `` `Ready to Publish` (pending ADR-0023 publication settlement) `` with
     `` `Archived` (settled on `main` at `00582aa`; ADR-0023 receipt) ``.
   - In the `archive/macos-dual-client-dogfood.md` entry, replace
     `` `Ready to Publish` (pending ADR-0023 publication settlement) `` with
     `` `Archived` (settled on `main` at `2a4700d`; ADR-0023 receipt) ``, and correct the
     `48-case hook-wire-v1 fixture Cartesian product` phrase per Step 8 (12 cases; 48 files).

3. **`.docs/status/roadmap.md` — mark M1 slice 1 + the M0 checkpoints settled.**
   - In the `## Repository improvement program (2026)` list, the `[x] coord-identifier-boundaries`
     M1 bullet (~line 19-22): replace `` `Ready to Publish` pending settlement `` with
     `settled on `main` at `00582aa` (ADR-0023 receipt)`; keep `next coord-lock-ownership,
     then coord-schema-cas`.
   - The paragraph beginning `M0 is authoritative at settled remote result 51b249e...`
     (~line 24-29): the sentence stating the program-amendment and `macos-dual-client-dogfood`
     checkboxes are `prospective until each candidate's ... settlement verify the exact
     publication` is now satisfied for `macos-dual-client-dogfood` — update it to state that
     `macos-dual-client-dogfood` is now settled (receipt; result `2a4700d`, target `main`),
     leaving ADR 0019's release-matrix caveat unchanged.

4. **`.docs/status/progress.md` § Current state — coord slice → settled/Landed.**
   - The `## Current state` first bullet header (~line 9): change
     `M1 slice 1 coord-identifier-boundaries COMPLETE (pending publication settlement)`
     to `M1 slice 1 coord-identifier-boundaries SETTLED (ADR-0023 receipt; result main 00582aa)`.
   - The sentence (~line 27) `Code-eval PASS round 0; Status: Ready to Publish (ADR 0023
     §4 — not Landed until remote settlement)`: change `Status: Ready to Publish (ADR 0023
     §4 — not Landed until remote settlement)` to `Status: Landed/Archived — settled on
     remote main at 00582aa (ADR-0023 publication receipt)`.
   - **Next action** (~line 35): confirm it reads `plan the M1 slice 2 coord-lock-ownership`
     (it already does) and add the one-clause precedence note that the remediation-1
     record-keeping (this slice) precedes it.

5. **`.docs/status/progress.md` § Current state — macOS slice → settled.** In the
   `macos-dual-client-dogfood` bullets (~line 61-93): replace each `Ready to Publish ...
   pending the protected ADR-0023 intent/receipt/settlement sequence` / `advances to
   Ready to Publish, not Landed, until fresh remote verification and receipt` phrasing
   with a statement that it is now **settled** (ADR-0023 publication receipt; result
   `2a4700d`, `verified_target_ref refs/heads/main`), preserving the unchanged
   release-obligation and `infrastructure-blocked` Codex-leg caveats verbatim.

6. **Bootstrap-review phrasing fix (degraded bootstrap, not the production command pair).**
   The bootstrap sealed-package review is **three cold auxiliary workers
   (correctness / tests / security)** per ADR 0023 §3 — evidence mode
   `loom-repository-bootstrap/v1`, "degraded bootstrap; not loom-local-review/v1" — **not**
   the production `/code-review` + `/security-review` mechanism (ADR 0010/0011). Correct
   the phrasing where it describes the two bootstrap slices' reviews:
   - `.docs/status/progress.md` ~line 22 (coord: `Bootstrap sealed-package review
     (/code-review + /security-review)`) and ~line 68 (macOS: `orchestrator-run
     /code-review + /security-review bootstrap review FAILed`).
   - `.docs/status/handoff.md` ~line 29 (coord: `Bootstrap /code-review+/security-review
     clean at 4 MINOR`) and the macOS bootstrap-review sentence in the "Where things
     stand" block (~line 55, `bootstrap /code-review FAILed round 0`).
   - `.docs/evaluations/README.md` line 33 (`orchestrator-run /code-review + /security-review
     findings`) and line 42 (`bootstrap /code-review+/security-review, 4 MINOR findings`).
   Replace each with wording naming the actual mechanism, e.g. `bootstrap review — three
   cold auxiliary workers (correctness/tests/security), loom-repository-bootstrap/v1
   degraded, not loom-local-review/v1 (ADR 0023 §3)`. Do **not** touch the many other
   `/code-review` + `/security-review` occurrences that correctly describe the production
   ADR 0010/0011 mechanism or its historical development.

7. **`.docs/status/handoff.md` — reconcile the contradictory NEXT ACTION lines + settle.**
   - The block header (~line 19) `M1 slice 1 coord-identifier-boundaries COMPLETE (pending
     publication settlement)` → `... SETTLED (ADR-0023 receipt; result main 00582aa)`.
   - Keep the coord block's `NEXT ACTION: plan M1 slice 2 coord-lock-ownership` (~line 32)
     but add the precedence clause `(after this remediation-1 record-keeping slice)`.
   - The macOS block (~line 53-71): replace the `Ready to Publish ... NEXT ACTION: publish
     this candidate` text with `settled (ADR-0023 receipt; result 2a4700d, target main)`.
     **Remove the stale `NEXT ACTION: publish this candidate`** line so the file carries a
     single, consistent next action: **M1 slice 2 `coord-lock-ownership`** (after the
     remediation slices). Also fix the coord `Status: Ready to Publish (ADR 0023 §4)` line
     (~line 31) to `Status: Landed/Archived — settled (ADR-0023 receipt)`.

8. **Fix the "48-case Cartesian product" miscount (it is 12 cases; 48 is the file count).**
   The `hook-wire-v1` product is **12 cases** (2 clients × 2 events × 3 outcomes); **48 is
   the fixture-file count** (4 files per case). Verified against the tree:
   `plugins/loom/hooks/fixtures/hook-wire-v1/` has 2 client dirs × 2 event dirs (`pre-compact`,
   `pre-tool-use`) × 3 outcomes = 12 case dirs and 48 files total. Correct every occurrence:
   - `CLAUDE.md` line 45: `48-case hooks/fixtures/hook-wire-v1/ Cartesian product` →
     `12-case (2 clients × 2 events × 3 outcomes; 48 fixture files at 4/case)
     hooks/fixtures/hook-wire-v1/ product`.
   - `.docs/status/progress.md` ~line 76-77: `48-case hook-wire-v1 fixture Cartesian product`
     → the corrected 12-case phrasing.
   - `.docs/status/handoff.md` ~line 60: `48-case hook-wire-v1 fixtures` → corrected.
   - `.docs/slice-plans/README.md` ~line 46: `48-case hook-wire-v1 fixture Cartesian product`
     (inside the macOS archive entry, handled in Step 2) → corrected.

9. **Append four audit errata to `.docs/status/progress.md` § "M0 errata".** Add after the
   existing `**Branch/PR hygiene (performed 2026-07-24).**` paragraph and **before** the
   `## Accepted decisions (ADRs)` heading, in the established append-only errata style
   (no history rewrite, no re-authoring). Each item is a verified fact; each carries its
   mechanical proof:

   - **(a) ADR 0006 rewritten in place post-acceptance — integrity erratum.** Commit
     `5e0b178` ("Build M1 scaffold …") modified the already-accepted
     `.docs/ADR/0006-distribution-self-marketplace.md` (26 lines changed; message notes
     "updated ADR 0006") **without a superseding ADR**. This violates ADR immutability
     (supersede, never rewrite). The ADR is immutable; this is **acknowledged, not
     corrected** — recording it does not re-open the ADR. Any correction is a new ADR
     cycle (deferred; Notes). Proof: `git show --stat 5e0b178 | grep 0006`.

   - **(b) coord-identifier-boundaries published from a rebased, not rebuilt+re-reviewed,
     head.** ADR 0023 §7 step 4 requires, on a moved target, discard-and-rebuild from the
     new exact base then re-run §3/§4. The reviewed head was `82d689f` (base `c899673`);
     the published head `00582aa` is that slice **rebased** onto `origin/main 0ae81c1`
     (Linux CI fix). Instead of a rebuild + fresh review, a **byte-identical-diff argument
     + re-gate** was substituted (loom-coord reviewed diff byte-identical pre/post rebase;
     rebased head re-gated green 452/452). This is disclosed honestly in the transition
     `state.json` `rebase_note` but was **absent from `.docs/`**; recorded here for the
     durable record. Proof: `git merge-base --is-ancestor 0ae81c1 82d689f` → false;
     `... 00582aa` → true; `rebase_note` in `state.json` at `origin/loom/bootstrap-transition`.

   - **(c) Code-bearing Linux CI fix direct-pushed to `main` outside the slice/review/
     settlement path.** `0ae81c1` ("Fix Linux CI: GNU stat -f …") is a code change that
     landed directly on `main` (single-parent linear commit) with no slice plan, no
     bootstrap review, and no publication settlement; per the audit, hosted `main` stayed
     red ~6h and the macOS dogfood settlement `32c5315` was recorded while hosted CI was
     failing. The CI-timing detail is an audit finding (not locally reconstructable);
     the direct-push and single-parent shape are verifiable. Proof:
     `git log -1 --format='%P' 0ae81c1` (one parent `c8996731`);
     `git merge-base --is-ancestor 0ae81c1 origin/main` → true.

   - **(d) Four additional non-uniform-identity commits on the transition branch itself.**
     Beyond the 13 counted in erratum (a) of the `c7bd84d..a3cb007` range, four commits on
     `origin/loom/bootstrap-transition` carry `Loom <loom@localhost>` (ADR 0003 non-uniform
     identity), and each is **outside** that earlier range: `367584c` ("Initialize protected
     Loom bootstrap transition state"), `e2248d8` ("Authorize macOS dual-client dogfood
     slices"), `099c4f4` ("Prepare ci baseline publication intent"), `4189c02` ("Settle ci
     baseline publication"). Proof: for each SHA, `git log -1 --format='%ae'` →
     `loom@localhost`, and `git merge-base --is-ancestor <sha> origin/loom/bootstrap-transition`
     → true while the SHA is not in `git rev-list c7bd84d..a3cb007`.

## Verification

Mechanical checks, all from repo root, expected results named:

1. **Scope confined.** `git diff --stat HEAD~1 HEAD` (after commit) lists **only** the
   nine paths in the boundary; no `.docs/spec/`, `.docs/ADR/`, `state.json`, receipt, or
   `plugins/loom/` path appears.
2. **Archive Status lines terminal.**
   `grep -h '^Status:' .docs/slice-plans/archive/{macos-dual-client-dogfood,coord-identifier-boundaries}.md`
   → both `Status: Archived`; and
   `grep -rc 'Status: Ready to Publish' .docs/slice-plans/archive/` → `0` for these two files.
3. **No stale "pending settlement" / "Ready to Publish" left in the current-state docs.**
   `rg -n 'pending publication settlement|pending ADR-0023 publication settlement|NEXT ACTION: publish this candidate' .docs/status/ .docs/slice-plans/README.md`
   → no matches. `rg -n 'publish this candidate' .docs/status/handoff.md` → no match
   (the contradictory NEXT ACTION line is gone).
4. **Single consistent next action.** `rg -n 'NEXT ACTION' .docs/status/handoff.md`
   resolves to `M1 slice 2 coord-lock-ownership` (after remediation); no
   publish-this-candidate line remains.
5. **Miscount corrected everywhere.** `rg -n '48-case' CLAUDE.md .docs/status/ .docs/slice-plans/README.md`
   → no matches; `rg -n '12-case|2 clients × 2 events × 3 outcomes' CLAUDE.md .docs/status/progress.md .docs/status/handoff.md .docs/slice-plans/README.md`
   → present in each.
6. **Bootstrap-review phrasing corrected.**
   `rg -n 'loom-repository-bootstrap/v1|three cold auxiliary' .docs/status/progress.md .docs/status/handoff.md .docs/evaluations/README.md`
   → present at each edited location; the production `/code-review` + `/security-review`
   references describing ADR 0010/0011 remain untouched.
7. **Errata SHAs exist.** `for s in 5e0b178 82d689f 00582aa 0ae81c1 32c5315 367584c
   e2248d8 099c4f4 4189c02; do git cat-file -t $s; done` → nine `commit` lines.
8. **CLAUDE.md still within bound.** `wc -l CLAUDE.md` → ≤ ~100 (currently 98; the edit
   is in-place text substitution, no net line growth).
9. **This plan is indexed.**
   `rg -n 'errata-and-settled-record' .docs/slice-plans/README.md` → matched under
   `## Active plans`.
10. **Repo gate green.** `scripts/check` exits 0.

## Notes

- **Deferred DECISIONS (this slice records, does not adjudicate).** Two of the errata
  raise questions that are *decisions*, not record-keeping, and are **out of scope**
  here — deferred to a **remediation-2 spec/ADR cycle + owner**:
  1. **ADR-0006 treatment** — whether the in-place post-acceptance rewrite (erratum a)
     needs a corrective superseding ADR, a documented exception, or stands acknowledged.
     ADRs are immutable; only a new ADR cycle can act. This slice merely records that it
     occurred.
  2. **Direct-push boundary** — whether code-bearing direct pushes to `main` outside the
     slice/review/settlement path (erratum c) and the rebase-vs-rebuild substitution
     (erratum b) require a tightened spec/ADR rule or a process guard. This slice merely
     records that they occurred.
- **Framing note for the evaluator.** The publication receipts record
  `verified_target_ref: refs/heads/main`; the settlements landed on `main` (both result
  SHAs are ancestors of `origin/main` HEAD `00582aa`). The
  `origin/loom/bootstrap-transition` branch holds the protected transition ledger
  (`state.json` + intents), not the settled code — hence this slice reconciles the record
  against `main`, which is where the slices landed.
- No spec, ADR, `state.json`, receipt, or product/code file is touched by this slice.
