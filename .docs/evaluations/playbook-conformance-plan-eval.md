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

---

# Re-evaluation: playbook-conformance (slice-plan) — resolving PASS

Verdict: PASS
Round: 1
Reviewed against: same authority as round 1 — ADR 0026 §2/§3/§4.0, ADR 0025 §B.2,
ADR 0020 §1/§Consequences, spec 03 (lines 37-38, 326, 342-348, §Ready-to-Publish/
§Landed), spec 05 (§Fresh-per-run 139-152). Re-review over worktree HEAD `61c4e59`
(branch `slice/playbook-conformance`); the two round-1 findings, exhaustiveness,
triage correctness, and class eligibility re-verified mechanically with `rg` /
`git hash-object`.

## Findings

- [RESOLVED — was BLOCKER] Lifecycle miss `loom-playbook/SKILL.md:38`. Now (a) in
  the Path allowlist (body-only; frontmatter confirmed closing at line 4, line 38
  is a table row well below it), (b) a FIX row in the Pattern-A census, and (c)
  Step 2 directs inserting `Ready to Publish` between `(code review)` and `Landed`.
  A new bare-lifecycle Verification #1 grep (`\(code review\) *→ *Landed`) now
  mechanically surfaces exactly this class — reproduced: it returns
  `loom-playbook/SKILL.md:38` and `status-machine.md:59`, both FIX rows.
- [RESOLVED — was MAJOR] Local-`main` misses `parallelism.md:150` and `:402`. Both
  now enumerated in Step 4 and as Pattern-C FIX rows; the preserve-vs-fix ambiguity
  is resolved explicitly ("keep the read-under-the-lock, drop the
  authoritative-local-`main` wording"), matching the `orchestration.md:340`
  reconciliation. The Notes cross-scan census (lines 461-472) now names them, so the
  completeness claim is true.
- [MINOR] `orchestration.md:10` ("a role finishes + commits + sets a status") uses
  the same universal phrasing the plan narrows at `orchestration.md:24-25`. It is
  covered by the Pattern-B catch-all LEAVE ("handoff-doctrine hits"); I judge the
  LEAVE defensible — line 10 is an abstract description of the handoff-completion
  state the orchestrator observes (a commit landed + status advanced, regardless of
  who physically committed), not an operational "the evaluator commits" instruction
  like 24-25. Worth folding for full internal consistency, but not gate-failing.
- [MINOR — carried] Step-anchor line numbers remain advisory; the census greps are
  the load-bearing detector, so this does not affect execution.

## Verification performed (mechanical, at HEAD `61c4e59`)

- **Exhaustiveness — reproduced the six census greps myself.** Pattern A
  (`rg -n 'Landed'`): **9 hits**, all 9 are census FIX rows — matches the census
  exactly, zero un-triaged. Pattern C
  (`rg -n 'local .*main|does not push|authoritative.*main|commit.*to.*main'`):
  **10 hits** (`parallelism.md:78/121/123/126/150/379/402`,
  `orchestration.md:340/354/373`), each triaged — 7 FIX, 3 LEAVE — zero un-triaged.
  Pattern B (`rg -n 'commit' roles skills`): every evaluator-context hit
  (`code-evaluator.md:62-64/69`, `plan-evaluator.md:56-58/63`,
  `loom-eval-code/SKILL.md:29/31`, `loom-eval-plan/SKILL.md:31/32`,
  `loom-run/SKILL.md:98`, `orchestration.md:24-25`) is a FIX row; producer/rubric/
  orchestrator hits are LEFT and the remainder falls under the catch-all LEAVE.
  I found **no** un-triaged hit for any of the three patterns.
- **Scope beyond the census greps.** Pattern B scans only `roles`+`skills`, so I
  additionally checked `plugins/loom/agents/*.md` and `plugins/loom/commands/*.md`
  (Patterns A/C already scan all of `plugins/loom` and returned nothing there):
  the two evaluator agent files are thin `Read roles/…` wrappers with no
  commit/status/eval-write prose, and the command bodies carry no
  commit/`.docs/evaluations`/`Landed` drift. No missed evaluator-self-commit copy.
- **Triage correctness spot-checks.** Producer self-commits are correctly LEFT
  (`planner.md:30/32`, `developer.md:40/42/43`, `researcher.md:34-37` — spec 03:
  producers commit their own work); only the evaluator writing/committing under
  `.docs/evaluations` is FIXed (spec 03 §Evaluation-run validity, spec 05
  §Fresh-per-run). Working-base uses of `main` are correctly LEFT
  (`parallelism.md:121/379` "worktrees from local `main`"; `:78` index-bucket
  main-only, ADR 0008/0014 coordination, orthogonal to ADR 0020 landing authority).
  No FIX overcorrects the real `Landed` final state: every Pattern-A FIX inserts
  `Ready to Publish` before `Landed` or corrects the `Landed` row meaning to
  "remote result verified + receipt recorded" — the `Landed → Archived` tail is
  preserved. No LEAVE hides a real drift (the sole borderline, `orchestration.md:10`,
  noted MINOR above).
- **Class eligibility still holds after scope grew.** All four frontmatter SKILL
  files (`loom-eval-code`, `loom-eval-plan`, `loom-run`, and the newly-added
  `loom-playbook`) close `---` at line 4; every named edit is body prose below it.
  Ledger blobs verified byte-identical: `git hash-object` returns
  `56d74dfc61…` (0026 eval) and `967200c2…` (0026 acceptance). No
  `*.sh`/`bin`/hooks/`*.bats`/`*.json`/`scripts/**`/`spec/**`/non-0026-ADR path in
  the allowlist.

## Notes

Both round-1 findings are resolved with the exact remedies the FAIL required, and
the newly-comprehensive census reproduces cleanly with zero un-triaged hits. The
one residual (`orchestration.md:10`) is a MINOR consistency nit, not a blocker.

Round basis: resolving PASS closes the round-1 FAIL and retains its round number
(spec 03:344-346, status-machine.md:41-42) — Round 1, not advanced. (The
launch prompt's "round 0" framing is superseded by the eval-file ledger and the
counting authority: the first FAIL moves a fresh artifact from round 0 to round 1.)
