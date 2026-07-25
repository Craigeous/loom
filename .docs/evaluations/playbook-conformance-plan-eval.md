# Evaluation: playbook-conformance (slice-plan)

Verdict: FAIL
Round: 1
Reviewed against: ADR 0026 (staging blob `914090db`, §2/§3/§4.0), ADR 0025 §B.2,
ADR 0023 §7, ADR 0020 §1/§Consequences, spec 03 (lines 37-38, 308-310, 326,
§Ready-to-Publish/§Landed), spec 05 (§Fresh-per-run 144-152, §Deterministic
recording 294-298); plan-eval + severity rubrics. Live tree at worktree HEAD
`538d900` (branch `slice/playbook-conformance`); drifts confirmed by `rg`/`git
hash-object`.

## Findings

- [BLOCKER] **Cross-scan miss — lifecycle drift in a file not in the allowlist.**
  `plugins/loom/skills/loom-playbook/SKILL.md:38` carries the byte-identical stale
  slice-plan lifecycle string the plan corrects elsewhere:
  `… Implemented → (code review) → Landed → Archived` (missing `Ready to Publish`).
  Step 2 fixes this exact string in `status-machine.md:58-59` but never touches this
  copy. The file is (a) **absent from the Path allowlist** (§ Path allowlist,
  lines 295-316), (b) **not surfaced by the Step 5 lifecycle grep** — that pattern
  requires `PASS`/`set` adjacent to `Landed`, and line 38 has neither (verified: the
  grep returns no match on this file), and (c) **not caught by Verification #1's
  grep** for the same reason. So the plan's own cross-scan + verification machinery
  cannot detect it, and executing the plan literally ships a playbook whose main
  SKILL summary contradicts the corrected `status-machine.md` — the precise
  drift class this slice exists to remove — while Verification reports complete.
  The file has frontmatter closing at line 4; line 38 is body prose, so it is a
  legal in-class target. Add it to the allowlist (body-only) and correct line 38.

- [MAJOR] **Cross-scan miss + preserve-vs-fix ambiguity — local-`main` drift.**
  `parallelism.md:150` ("Re-read Active/claim state from **current local `main`**
  (the authoritative snapshot…)") is **byte-identical** to `orchestration.md:340`,
  which Step 4 enumerates and reconciles; `parallelism.md:402` ("authoritative
  re-check … against current local `main`") is the same claim-authority drift in a
  table row. Neither line is enumerated in Step 4, and the planner's cross-scan
  result (lines 224-228) names only `orchestration.md:340` for local-`main` while
  asserting completeness ("all three drifts CONFIRMED PRESENT"). Per spec 03 line
  326 ("Dispatch never derives … claims … from local `main`") these are the same
  drift and warrant the identical reconciliation the plan gives 340
  ("coordination/claim state is read under the lock, but landing/current-authority
  is never derived from local `main`"). Step 4 simultaneously instructs "preserve
  the lock/claim coordination model," so an independent reader could reasonably
  leave 150/402 unfixed, shipping `parallelism.md` divergent from the corrected
  `orchestration.md`. (Not a BLOCKER only because the Step 5 local-`main` grep
  *does* surface 150/402 and the catch-all directs the same correction — but the
  ambiguity and the false completeness claim need explicit resolution.)

- [MINOR] Step-anchor line numbers drift by one in places (plan-evaluator "step 3
  line 54 / step 4 lines 56-59" → actually 55/58; similar for code-evaluator).
  Non-load-bearing given Step 5 re-greps, but the developer should trust the grep,
  not the cited line.
- [MINOR] Context (line 21) cites "worktree HEAD `06246d0`"; actual HEAD is
  `538d900` (this plan's own commit) with `06246d0` its parent. Harmless.
- [MINOR] `status-machine.md`/`loom-playbook/SKILL.md:36` say "ADR … → Approved
  (then immutable)"; spec 03 reserves `Accepted` for ADRs. Step 2 adds the
  `Accepted` token but does not clearly direct fixing the ADR→`Approved` lifecycle
  wording. Optional to fold while in these files.

## Required changes (for FAIL)

1. Add `plugins/loom/skills/loom-playbook/SKILL.md` (body-only; frontmatter closes
   line 4) to the Path allowlist and correct the line-38 slice-plan lifecycle
   string to include `Ready to Publish` between `(code review)` and `Landed`,
   matching the `status-machine.md:58-59` correction. Extend Verification #1 with a
   grep that would catch a bare `… → Landed → Archived` lifecycle string (no `PASS`
   adjacency) so this class is mechanically detectable.
2. Enumerate `parallelism.md:150` and `parallelism.md:402` in Step 4 and apply the
   same reconciliation given to `orchestration.md:340`; resolve the preserve-vs-fix
   ambiguity by stating that the claim-read-under-lock stays but the
   "local `main` authoritative" framing is removed. Update the planner cross-scan
   result note (lines 224-228) to include them so its completeness claim is true.

## Notes

Confirmed sound (no re-litigation needed on revision):
- **Class eligibility (PASS).** Every enumerated `plugins/loom` target is a
  prose-body `.md` under an ADR-0026-in-class path. The only three frontmatter
  files (`loom-eval-code`, `loom-eval-plan`, `loom-run` SKILL.md) all close `---`
  at line 4; every named edit (lines 27-31, 29-31, 98-99) is below it, and the
  "git diff touches no `---` line" constraint is stated load-bearing (Verification
  #4, Notes "Frontmatter is the disqualifier"). No `*.sh`/`bin`/hooks/`*.bats`/
  `*.json`/`scripts/**`/`spec/**`/non-0026-ADR path appears. Adding
  `loom-playbook/SKILL.md` (body-only) keeps this clean.
- **Drift reality + fidelity.** All three named drifts exist at the cited
  locations (lifecycle: loom-run:99, loom-eval-code:29, code-evaluator:59,
  developer:13, commit-convention:78, status-machine:16/29/58; self-commit:
  plan-evaluator:44/55/58, code-evaluator:43/59/62, loom-eval-code:28,
  loom-eval-plan:29-31, loom-run:98; local-main: parallelism:123 + the two missed
  above, orchestration:340). Each proposed correction is faithful to spec 03
  (37-38, 308-310, 326), spec 05 (144-152, 294-298), and ADR 0020 §1 — no
  overcorrection; the self-commit fix correctly preserves loom-coord coordination.
  The self-commit cross-scan is complete (producer-role commits, e.g.
  loom-develop/planner/developer, are correctly left out of scope).
- **Bundling ADR-0026 landing (PASS).** Carrying the accepted ADR to `main` as the
  payload of this remediation slice is authorized by ADR 0026 §5.5 and §Consequences
  ("carries this accepted ADR to main"); no split required.
- **Fixed inputs verified byte-identical:** ADR 0026 body blob `914090db`; ledger
  records `56d74dfc` (eval) and `967200c2` (acceptance); ADR 0026 absent from HEAD
  as claimed.

Round basis: first review, merits FAIL ⇒ round 1 per status-machine.md
("the first FAIL moves it to round 1").
