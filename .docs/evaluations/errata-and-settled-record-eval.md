# Evaluation: errata-and-settled-record (code review)

Verdict: PASS
Round: 0
Reviewed: diff `9aa60e8..d311a6c` (commit `d311a6c`) against the Approved plan
`.docs/slice-plans/errata-and-settled-record.md`, spec 03 (lifecycle terminal
states + recorder/root ownership), ADR 0023 §3/§4/§7, the repo history for every
cited SHA, both `.git/loom/publications/*.json` receipts, and the plan-eval
(`errata-and-settled-record-plan-eval.md`, PASS round 0). Pure-docs slice →
automated `/code-review` + `/security-review` correctly `skipped: docs-only`;
adjudicated directly.

## Gate

Re-ran `LOOM_DIFF_BASE=HEAD scripts/check` from repo root → exit 0. 452/452 Bats,
repository-metadata, shfmt, ShellCheck, bash-syntax, relative-links, Claude strict
plugin validation, and diff-whitespace all pass. Green.

## Scope (plan boundary — confirmed)

`git diff --name-only 9aa60e8..d311a6c` lists exactly the nine boundary paths and
nothing else: the two `archive/*.md` (Status line only), `slice-plans/README.md`,
`evaluations/README.md`, `status/{progress,handoff,roadmap}.md`, `CLAUDE.md`, and
the plan file. No `.docs/spec/**`, `.docs/ADR/**`, `state.json`, receipt, or
`plugins/loom/**` edit. Within both archive files only line 3 `Status:` changed.

## Steps implemented and factually correct

All 9 steps landed and every recorded fact was re-verified mechanically:

- Both archive plans now `Status: Archived`; `grep -rc 'Status: Ready to Publish'
  .docs/slice-plans/archive/` → 0 for both.
- **Erratum (a)** — `git show --stat 5e0b178 | grep 0006` confirms `5e0b178`
  modified Accepted `.docs/ADR/0006-*.md` (26 lines; message "updated ADR 0006")
  with no superseding ADR. RECORD-only; ADR-0006 treatment explicitly deferred.
- **Erratum (b)** — `0ae81c1` is NOT an ancestor of reviewed head `82d689f`
  (false) and IS an ancestor of published `00582aa` (true): rebase, not
  rebuild+re-review. Recorded, not adjudicated (direct-push/rebase boundary
  deferred to remediation-2).
- **Erratum (c)** — `0ae81c1` single-parent (`c8996731`), ancestor of
  `origin/main`; direct-push + red-main framed as an audit finding "not locally
  reconstructable." Accurate.
- **Erratum (d)** — `367584c/e2248d8/099c4f4/4189c02` each carry
  `loom@localhost`, are on `origin/loom/bootstrap-transition`, and are all OUTSIDE
  `c7bd84d..a3cb007`; they are the only 4 `loom@localhost` commits reachable on
  the transition branch, so "beyond the 13" is accurate.
- **Bootstrap-review correction** — the "/code-review + /security-review" mislabel
  is replaced by "three cold auxiliary workers (correctness/tests/security),
  loom-repository-bootstrap/v1 degraded … (ADR 0023 §3)" at all six enumerated
  sites (progress ×4, handoff ×4, evaluations/README ×4 markers present). The many
  production ADR 0010/0011 `/code-review` references in the archive-log tail are
  correctly left untouched.
- **48→12 miscount** — `rg '48-case'` across CLAUDE.md + status + README → none;
  corrected "12-case (2 clients × 2 events × 3 outcomes; 48 fixture files at
  4/case)" present in all four files.
- **Handoff NEXT ACTION** — the contradictory "publish this candidate" line is
  gone (`rg 'publish this candidate' handoff.md` → none); the two current-state
  NEXT ACTION lines (L34, L327) both resolve to "plan M1 slice 2
  `coord-lock-ownership`". Single consistent next action.
- **Settlement** — result SHAs `2a4700d` and `00582aa` are both reachable from
  `origin/main`; coord's result IS `00582aa`. Status flips to settled/Archived are
  legitimate.
- CLAUDE.md = 98 lines (≤ ~100). Plan indexed under `## Active plans`.

## No new error introduced

The slice does not itself repeat `/code-review` or the 48-case phrasing in any live
description. No stray "pending settlement" / "Ready to Publish" remains in the
current-state regions of `status/` or `slice-plans/README.md`.

## Findings

- [MINOR] `evaluations/README.md` L38/L49 retain "`Ready to Publish` pending
  ADR-0023 settlement" in the two code-evaluation index entries. This is defensible
  and was deliberately scoped out by the plan (Step 6 touches only the two
  bootstrap-phrasing lines there): those entries describe the immutable historical
  eval artifacts, which themselves still record "Ready to Publish" (e.g.
  `coord-identifier-boundaries-eval.md` L47). Rewriting them would make the index
  diverge from the artifacts it catalogs. Optional future breadcrumb ("now
  settled"); non-blocking.
- [MINOR] The `## Active plans` entry labels this slice `Plan Review` while its
  Status is now `Implemented`; the developer's finalize/archive pass moves it to
  `Archived` on Landed. Transient, expected.

## Verdict rationale

Zero BLOCKER, zero MAJOR. Gate green, scope confined, every erratum verified and
correctly RECORD-not-adjudicate with both decision questions deferred, all
corrections landed everywhere, no new error. PASS per severity.md.
