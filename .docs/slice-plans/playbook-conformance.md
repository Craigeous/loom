# playbook-conformance

Status: Plan Review
Slice type: docs-governance
Class: docs-governance/v1
Target specs: 03-artifact-lifecycle.md, 05-blind-evaluation.md (authority only — not edited)
Authority: ADR 0026 §2/§3/§4 (broadened `docs-governance/v1` prose-body path capability +
frontmatter carve-out), ADR 0025 §B.2, ADR 0023 §7, ADR 0020, spec 03, spec 05.

## Context

This is the deferred **remediation-3 (playbook-conformance)** work that ADR 0026 named
("Out of scope, deferred") and authorized a lawful §7 landing path for. It is the first
`docs-governance/v1` §7 slice to exercise ADR 0026's **broadened** class — editing the
**prose bodies** of non-executable Markdown under `plugins/loom/`.

Two things happen here:

1. **Land ADR 0026 into `main`.** ADR 0026 was authored/ratified on a staging branch and
   owner-accepted, but is **not yet in `origin/main`** (worktree HEAD `06246d0` does not
   contain the ADR file). Per ADR 0026 §5.5 the accepted document reaches `main` as the
   payload of a docs-governance §7 slice — this one. Its blind plan-eval verdict and owner
   acceptance are the two pre-placed records already in the worktree.
2. **Fix three prompt/documentation drifts** the audit's Theme-B findings identified between
   the shipped playbook prose and the accepted specs/ADRs (ADR 0020 remote-first landing;
   spec 03/05 evaluator/recorder separation). These are pure prose corrections.

**In scope:** prose-body edits to the named `plugins/loom/**/*.md` files (and the
cross-scan siblings carrying the identical drift — see Step 5 / Notes); the ADR 0026 file +
ADR/README index; the two pre-placed 0026 evaluation records + the evaluations index; this
plan + the slice-plans index; `.docs/status/{progress,handoff}.md`.

**Explicitly out of scope (do NOT touch):**
- **Any YAML frontmatter** — the `---`-delimited header block of any `plugins/loom/**/*.md`
  file. Per ADR 0026 §3 (frontmatter carve-out) and §4.0, a change to any frontmatter field
  makes the slice code-bearing and the docs code-eval **MUST FAIL**. Only three target files
  carry frontmatter: `plugins/loom/skills/loom-eval-code/SKILL.md`,
  `plugins/loom/skills/loom-eval-plan/SKILL.md`, `plugins/loom/skills/loom-run/SKILL.md` —
  edit **only** their body text below the closing `---`.
- Any executable/test/schema/manifest: `*.sh`, `plugins/loom/bin/*`, `plugins/loom/hooks/**`,
  `*.bats`, any test path/fixture, `*.json` (schemas/manifests/catalogs), `scripts/**`.
- `.docs/spec/**` and any ADR other than `0026-*`.
- The `Land`-workflow *mechanical* redesign to ADR 0020's mode state machine (ADR 0020
  §Consequences defers this to a later spec 03/04 planning amendment) — Step 4 corrects the
  false authority claims in prose and points to ADR 0020, it does **not** invent new procedure.
- The reconciliation `slice-plans/README` Active-region residual and the test-301 flake —
  both are tracked follow-ups recorded by Step 6, not fixed here.

## Steps

### Step 1 — Land ADR 0026 acceptance

1a. **Introduce the ADR 0026 file at Accepted.** The file is absent from HEAD; source its body
byte-for-byte from the accepted content and change **only** the Status line:
```
git show b2614ce:.docs/ADR/0026-docs-governance-plugin-prompt-doc-scope.md \
  > .docs/ADR/0026-docs-governance-plugin-prompt-doc-scope.md
```
(that content is blob `914090db014cb9462d16da9992c73e98fbc1d4c9`, the plan-evaluated/owner-accepted
revision), then edit its line 3 `Status: Plan Review` → `Status: Accepted`. Change nothing else
in the body — it is an accepted, immutable ADR. (The ADR body starts with `# 0026 — …`; it has
**no** YAML frontmatter, so the frontmatter constraint is not implicated for this file.)

1b. **ADR index → Accepted.** In `.docs/ADR/README.md`: add a `0026` entry to the `## Accepted`
list (immediately after the `0025` entry, line 40), summarizing the narrow supersession of
ADR 0025 §B.2's path allowlist (broaden `docs-governance/v1` to admit prose-body Markdown under
`plugins/loom/`; frontmatter categorically out-of-class; capability amendment with
`allowed_slices` UNCHANGED). The staged `## In Review` entry (present at `b2614ce` in
`README.md`, blob context) is the source text — adapt it to Accepted form (drop its trailing
"On acceptance, move to the Accepted list and annotate…" instruction). Leave `## In Review` as
`None.` **Annotate the `0025` entry** to note ADR 0026 narrowly supersedes its §B.2 path
allowlist (per the staged entry's own instruction).

1c. **Include the two pre-placed 0026 records as-is.** `git add` (do not modify):
- `.docs/evaluations/0026-docs-governance-plugin-prompt-doc-scope-eval.md` (blob
  `56d74dfc61c9a8fafcf2627fb61355f4b9f56078` — MUST stay byte-identical)
- `.docs/evaluations/0026-docs-governance-plugin-prompt-doc-scope-acceptance.md` (blob
  `967200c287ad0ad4f5166b4862ac449206e1e337` — MUST stay byte-identical)

1d. **Evaluations index.** In `.docs/evaluations/README.md` `## Current program evaluations`,
add two entries for the 0026 plan-eval verdict and owner acceptance, paralleling the existing
`0025` entries (lines 50-54): plan-eval `bootstrap-ratification: degraded`, PASS round 0 with
the frontmatter-carve-out MINOR folded → resolving PASS (advisory); owner acceptance dispositive,
Accepted 2026-07-25.

### Step 2 — Lifecycle drift: code-eval PASS ≠ `Landed` (audit Theme-B finding 1)

**Reality to conform to** (authority: spec 03 lines 37-38 & §"`Ready to Publish`"/"`Landed` and
cleanup"; ADR 0020 §1 and the `Ready to Publish` state it adds): a code-eval **PASS advances the
slice to `Ready to Publish`** (code evaluation passed; claim and evidence retained pending
publication). **`Landed` is later and stronger** — it requires the configured-remote result to be
independently verified and a publication receipt recorded; it is reached by the orchestrator's
landing helper, not asserted on code-eval PASS. Correct the stale "set `Landed` on PASS" prose at:

- `plugins/loom/skills/loom-eval-code/SKILL.md` line 29 — "(`Landed` on PASS, `In Progress` on
  FAIL — status line only)" → PASS advances to `Ready to Publish` (FAIL → `In Progress`
  unchanged). **Body edit only — this file has frontmatter; do not touch lines 1-4.**
- `plugins/loom/roles/code-evaluator.md` line 59 — "Set the slice-plan status: `Landed` on PASS
  …" → the recorder sets `Ready to Publish` on PASS (see Step 3 for the who-sets/who-commits
  correction that also lands in this sentence). Also correct step-4/line-33's implicit downstream
  wording if it references `Landed` as the PASS target.
- `plugins/loom/skills/loom-run/SKILL.md` line 99 — "On a `Landed` code-eval PASS, launch the
  developer's finalize pass" → dispatch on a **code-eval PASS** (status now `Ready to Publish`);
  the finalize/land sequence follows ADR 0020 (publish → verify remote → receipt → `Landed`).
  **Body edit only — this file has frontmatter.**
- `plugins/loom/skills/loom-playbook/references/status-machine.md` — the status semantics are
  stale here and **missing tokens**. In the `## Statuses` table (lines 8-19) and `## Dispatch
  table` (lines 21-31) and `## Lifecycles` (lines 54-66):
  - Add rows/tokens for **`Ready to Publish`** (code evaluation passed; claim + evidence retained
    pending publication; next actor: orchestrator landing helper), **`Accepted`** (ADR/spec
    approval; the artifact lifecycles at line 56-57 already use it in prose but it is absent from
    the table), and **`Living`** (the perpetual status of the three `status/` docs, the spec
    index, and `09-open-questions.md` — currently used but untabled).
  - Correct the slice-plan lifecycle string (lines 58-59) so **code-eval PASS → `Ready to
    Publish` → (publish/verify/receipt) → `Landed` → `Archived`**, and the `Landed` row/meaning
    (line 16) to "configured remote result independently verified and receipt recorded" (not
    "code approved; finalize underway"). Keep spec 03 as the single-source pointer.

**Cross-scan siblings carrying the identical drift** (Step 5; fold the same correction in):
- `plugins/loom/roles/developer.md` line 13 — "A slice's code-eval returned PASS (`Landed`) —
  run the finalize pass" → the PASS target is `Ready to Publish`; correct the `(Landed)`
  equivalence. Do **not** redesign finalize-pass timing beyond this token correction; if the
  precise finalize/land ordering under ADR 0020 is ambiguous in this sentence, correct the stale
  token and NOTE the residual rather than inventing sequence.
- `plugins/loom/skills/loom-playbook/references/commit-convention.md` line 78 — the example
  commit message `Evaluate week-rollover slice: PASS (Landed)` encodes the stale equivalence →
  change the parenthetical to `(Ready to Publish)`.

### Step 3 — Evaluator self-commit drift (audit Theme-B finding 2)

**Reality to conform to** (authority: spec 03 §"Evaluation-run validity": "The deterministic
recorder installs a valid verdict under `.docs/evaluations/`, makes the allowed status
transition, and the orchestrator commits the handoff. **The evaluator itself never mutates the
checkout.**"; spec 05 §"Fresh per-run workspace" lines 139-152: the evaluator "has no
managed-checkout write path, and may write only to a unique confined output directory and private
scratch"; the **root** re-verifies immutable inputs, performs the spec-03 status transition, and
commits the verdict/status author-neutrally). The shipped role prose wrongly instructs the
**evaluator** to write the eval file into `.docs/evaluations/`, set the status line, and commit.
Correct it so the evaluator **produces its verdict to its confined scratch/output workspace and
returns** — it does **not** write into `.docs/`, does **not** set status, and does **not** commit;
the recorder/root installs the verdict, makes the status transition, and commits.

- `plugins/loom/roles/plan-evaluator.md` — step 2 (line 44, "Write the verdict to
  `.docs/evaluations/…`"), step 3 (line 54, "Set the artifact's status line"), step 4 (lines
  56-59, "Commit … and stop … Verify after committing"): rewrite so the evaluator writes its
  verdict to the confined output workspace and returns the bounded verdict; the recorder/root
  installs it, performs the `Approved`-on-PASS / `Draft`-on-FAIL transition, and commits. Keep
  the round-counting rule and the blind-contract text intact.
- `plugins/loom/roles/code-evaluator.md` — step 4 (line 43, "Write the verdict to
  `.docs/evaluations/…`"), step 5 (line 59, sets status — the same sentence Step 2 corrects for
  the PASS target), step 6 (lines 62-65, "Commit … and stop … Verify after committing"): same
  rewrite — evaluator writes to confined scratch and returns; recorder/root records the verdict,
  transitions to `Ready to Publish` (PASS) / `In Progress` (FAIL), and commits. Preserve the
  gate-rerun requirement and adjudication text.

**Cross-scan siblings carrying the identical drift** (Step 5; fold the same correction in):
- `plugins/loom/skills/loom-eval-code/SKILL.md` lines 27-31 — "The role … writes
  `.docs/evaluations/<slice>-eval.md` …, sets status …, and commits author-neutral" +
  "Verify the commit" → the role produces the verdict to scratch and returns; the recorder/root
  records + transitions + commits. **Body edit only (frontmatter present).**
- `plugins/loom/skills/loom-eval-plan/SKILL.md` lines 29-31 — "The role writes
  `.docs/evaluations/<name>-eval.md` …, sets status …, and commits author-neutral" → same
  correction. **Body edit only (frontmatter present).**
- `plugins/loom/skills/loom-run/SKILL.md` — the step-e "verify the author-neutral commit and the
  new status" wording (line 98) presumes the evaluator committed; align it to recorder/root
  recording. **Body edit only (frontmatter present).** (Keep this minimal — the orchestrator does
  verify a commit exists; the correction is that the *evaluator* is not the committer.)

### Step 4 — Parallelism drift: local-main is not the landing authority (audit Theme-B finding 3)

**Reality to conform to** (authority: ADR 0020 §1 "A configured remote target ref is
authoritative … Local `main` is a disposable mirror/cache and is never part of the landing
transaction, dispatch authority, claim transaction, or recovery source"; ADR 0020 §Consequences
"Partially supersedes ADR 0014" on the shared-local-`main`/no-push model; spec 03 §"Dispatch
rules": "Dispatch never derives landing, claims, or current authority from local `main`").
`plugins/loom/skills/loom-playbook/references/parallelism.md` still asserts the pre-ADR-0020
model. Correct the specific false claims in prose:

- §"Agent-input freshness" (lines 120-129): "loom commits to local `main` and does not push, so
  `origin/main` lags … The authoritative 'what has landed / what is claimed' read is always
  current local `main` under the lock." → State ADR 0020: landing publishes to the **configured
  remote target**, which is the sole landing authority; local `main` is a **disposable
  mirror/cache**, never the landing/dispatch/claim authority; the authoritative "what has landed"
  read is a fresh read of the configured remote plus the publication receipt. (Worktrees may still
  branch off local `main` as a working base — that mechanic is unchanged.)
- The Land subsection (lines 195-235) and §"What stays serial" (line ~342's "loom commits
  directly to local main") describe merge-onto-local-`main` with no push as the landing act. Add a
  concise **superseded-by-ADR-0020 note** at the Land subsection: the landing authority is remote
  publication + fresh remote verification + receipt (ADR 0020, partially superseding ADR 0014);
  `Landed` is established only by that verified remote result and receipt. **Do NOT rewrite the
  merge/mode mechanics** — ADR 0020 §Consequences defers the mode state machine to a later spec
  03/04 amendment; correct the authority claim and point to ADR 0020, and NOTE the deferred
  mechanical reconciliation rather than inventing procedure.
- Preserve the multi-session lock/claim coordination model (ADR 0014/0015/0016 via `loom-coord`) —
  it is orthogonal to landing authority and is **not** superseded by ADR 0020.

**Cross-scan sibling carrying the identical drift** (Step 5; fold the same correction in):
- `plugins/loom/skills/loom-playbook/references/orchestration.md` line 340 — "Re-read
  Active/claim state from current local `main` (authoritative under the lock…)" carries the same
  local-main-authoritative claim → reconcile the same way: coordination/claim state is read under
  the lock, but landing/current-authority is never derived from local `main` (spec 03; ADR 0020).

### Step 5 — VERIFY-DON'T-ASSUME (developer performs before finalizing)

The planner already ran this cross-scan; the developer re-confirms against the live tree at
implementation time (the audit describes the drift; verify each still exists before editing, and
do not "fix" anything already correct):

```
# Lifecycle drift (should show the six occurrences named in Step 2):
rg -n 'Landed.*(on )?PASS|PASS.*\(?Landed|set .*Landed' plugins/loom --glob '*.md'
# Evaluator self-commit drift:
rg -n 'Write the verdict to|writes .*eval\.md|sets status|and commits author-neutral' \
  plugins/loom/roles/*evaluator.md plugins/loom/skills/loom-eval-*/SKILL.md
# Parallelism / local-main authority drift:
rg -n "commits to local .?main|does not push|authoritative.*local .?main|local .?main.*authoritative" \
  plugins/loom --glob '*.md'
```
If any location is already correct or its text differs from the audit's description, adjust the
Step and record it in `## Notes` — do not fix a non-problem, do not miss a real one. If the
cross-scan surfaces an occurrence **beyond** those enumerated in Steps 2-4, apply the same
correction, add the file to the allowlist, and NOTE it.

**Planner cross-scan result (2026-07-25, all three drifts CONFIRMED PRESENT, none pre-fixed):**
the additional same-drift occurrences already folded into Steps 2-4 are `developer.md:13` +
`commit-convention.md:78` (lifecycle), `loom-eval-code/SKILL.md:27-31` +
`loom-eval-plan/SKILL.md:29-31` + `loom-run/SKILL.md:98` (self-commit), and
`orchestration.md:340` (local-main). See Notes for the scope-expansion flag.

### Step 6 — Status finalize (record remediation-3; set NEXT ACTION)

In `.docs/status/progress.md` and `.docs/status/handoff.md`:
- Record **remediation-3 (playbook-conformance)**: ADR 0026 landed (Accepted) + the three
  Theme-B prose drifts corrected across the plugin prose bodies; first exercise of ADR 0026's
  broadened `docs-governance/v1` class.
- Set **NEXT ACTION** → after this slice lands, the tracked **code-bearing follow-ups**:
  (1) **test-301 flake stabilization** (the `scripts/check` bats flake unrelated to these md
  edits), (2) the **trivial reconciliation `slice-plans/README` Active-region residual** (the
  `docs-governance-reconciliation` entry still shown under `## Active plans` pointing to
  `archive/`); **then** plan **M1 slice 2 `coord-lock-ownership`** (per
  `.docs/repository-improvement-plan.md` § "M1 — Fix coordinator safety").

*(Index/archival note: this plan's `slice-plans/README` Active-plans entry is added at Plan
Review by the planner; on code-eval settlement the standard docs-governance §7 finalize moves it
Active→Archived and `git mv`s this plan into `archive/` — the orchestrator-owned index step, not
a developer prose edit.)*

## Verification

Named mechanical checks (all run at `head_sha`):

1. **Lifecycle corrected** — `rg -n 'Ready to Publish' plugins/loom/skills/loom-eval-code/SKILL.md
   plugins/loom/roles/code-evaluator.md plugins/loom/skills/loom-run/SKILL.md
   plugins/loom/skills/loom-playbook/references/status-machine.md` shows the corrected target;
   `rg -n 'Landed.*on PASS|PASS \(Landed\)' plugins/loom --glob '*.md'` returns **zero** stale
   "PASS ⇒ Landed" equivalences. `status-machine.md` now contains `Ready to Publish`, `Accepted`,
   and `Living` tokens (`rg -n 'Ready to Publish|Accepted|Living' status-machine.md`).
2. **Self-commit corrected** — `rg -n 'evaluator .*never mutates|writes .*to .*scratch|recorder .*commits|to its .*(scratch|output) workspace'`
   across `roles/*evaluator.md` + `skills/loom-eval-*/SKILL.md` shows the recorder/root-commits
   model; no remaining instruction telling the evaluator to write into `.docs/evaluations/` and
   commit.
3. **Parallelism corrected** — `rg -n 'does not push|authoritative.*local .?main'
   plugins/loom/skills/loom-playbook/references/parallelism.md
   plugins/loom/skills/loom-playbook/references/orchestration.md` no longer asserts local-`main`
   landing authority; an ADR 0020 remote-authority note is present.
4. **Frontmatter untouched (ADR 0026 §4.0 gate)** — `git diff <base>..<head>` shows **zero**
   changed lines inside any `---`-delimited frontmatter block of any `plugins/loom/**/*.md`. Only
   three target files carry frontmatter (`loom-eval-code/SKILL.md`, `loom-eval-plan/SKILL.md`,
   `loom-run/SKILL.md`); confirm every hunk in them is strictly below the closing `---`. A single
   frontmatter-line change **disqualifies the slice from the class** and the docs code-eval MUST
   FAIL.
5. **Ledger-blob identity** — `git hash-object` on the two pre-placed 0026 records equals
   `56d74dfc61c9a8fafcf2627fb61355f4b9f56078` (eval) and
   `967200c287ad0ad4f5166b4862ac449206e1e337` (acceptance), byte-identical.
6. **ADR 0026 body identity** — `diff <(git show b2614ce:.docs/ADR/0026-…md)
   .docs/ADR/0026-…md` shows a **single** differing line: `Status: Plan Review` → `Status:
   Accepted`. No other body change.
7. **No out-of-class paths** — `git diff --name-only <base>..<head>` contains **only** allowlist
   paths (see below); no `*.sh`/`bin/*`/hooks/`*.bats`/test/`*.json`/`scripts/**`/`.docs/spec/**`
   and no non-`0026` ADR.
8. **Gate green** — `scripts/check` at `head_sha` (incl. `validate-repository.mjs`). This is a
   pure prose-body docs slice, so the §3 finder package is not required (ADR 0026 §4). **If the
   only failure is the known test-301 bats flake** (unrelated to Markdown edits), record it as a
   pre-existing flake per progress/handoff and treat the gate as green for this slice; any other
   failure is a real gate failure.

Docs-governance §7 evidence (ADR 0026 §4): this slice-plan's **blind plan-eval verdict**; a
**distinct cold docs code-evaluator** verdict over the exact `base..head` diff confirming §4.0
(no behavior-bearing frontmatter change — MUST FAIL otherwise), §4.1 (no behavior/executable
change; pure prose), and §4.2 (`validate-repository.mjs` green); plus the `scripts/check` gate
rerun.

## Path allowlist (exact)

Prose bodies of the following `plugins/loom/**/*.md` files (**body text only — no frontmatter**):
- `plugins/loom/skills/loom-eval-code/SKILL.md` *(frontmatter present — body only)*
- `plugins/loom/skills/loom-eval-plan/SKILL.md` *(frontmatter present — body only)*
- `plugins/loom/skills/loom-run/SKILL.md` *(frontmatter present — body only)*
- `plugins/loom/roles/code-evaluator.md`
- `plugins/loom/roles/plan-evaluator.md`
- `plugins/loom/roles/developer.md`
- `plugins/loom/skills/loom-playbook/references/status-machine.md`
- `plugins/loom/skills/loom-playbook/references/parallelism.md`
- `plugins/loom/skills/loom-playbook/references/orchestration.md`
- `plugins/loom/skills/loom-playbook/references/commit-convention.md`

Plus:
- `.docs/ADR/0026-docs-governance-plugin-prompt-doc-scope.md` and `.docs/ADR/README.md`
- `.docs/evaluations/0026-docs-governance-plugin-prompt-doc-scope-eval.md` and
  `…-acceptance.md` (pre-placed, added byte-identical) and `.docs/evaluations/README.md`
- `.docs/slice-plans/playbook-conformance.md` (this plan) and `.docs/slice-plans/README.md`
- `.docs/status/progress.md` and `.docs/status/handoff.md`

**Categorically excluded:** any YAML frontmatter block; `*.sh`, `plugins/loom/bin/*`,
`plugins/loom/hooks/**`, `*.bats`, any test path/fixture; `*.json` schemas/manifests/catalogs;
`scripts/**`; `.docs/spec/**`; any ADR other than `0026-*`.

## Notes

- **Scope-expansion flag (for the evaluator/owner).** The task named a specific file set per
  drift. Step 5's mandated cross-scan surfaced the **identical** drift in four additional prose
  bodies: `roles/developer.md` and `references/commit-convention.md` (lifecycle),
  `skills/loom-eval-plan/SKILL.md` and `skills/loom-run/SKILL.md` (self-commit), and
  `references/orchestration.md` (local-main authority). Leaving these unfixed would ship an
  internally inconsistent remediation (the exact defect class this slice exists to remove), so
  they are folded into Steps 2-4 and added to the allowlist. This is a deliberate, disclosed
  expansion of the named set for coherence — flagged here for explicit review.
- **ADR 0026 provenance.** The ADR file is absent from `origin/main`/HEAD `06246d0`; it lives on
  the staging branch at commit `b2614ce` (blob `914090db`, Status: Plan Review). This slice both
  carries it into `main` and flips its Status to Accepted — its own landing rides the pre-existing
  `.docs/**` allowlist, so it does not depend on the broadening it enacts (ADR 0026 §5, non-circular).
- **Frontmatter is the disqualifier.** Restated for the developer: `git diff` must touch **no**
  line inside any `---`-delimited frontmatter block of any `plugins/loom/**/*.md` file (ADR 0026
  §4.0). This is the single most likely way to accidentally convert this docs slice into a
  code-bearing one and force a MUST-FAIL.
- **Bounded Step 4.** The Land-workflow mechanical redesign to ADR 0020's mode state machine is
  explicitly deferred (ADR 0020 §Consequences names a later spec 03/04 amendment). Step 4 corrects
  the false authority claims in prose and points to ADR 0020; it does not invent new landing
  procedure.
