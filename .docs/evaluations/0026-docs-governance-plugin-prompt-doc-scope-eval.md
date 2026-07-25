# Evaluation: ADR 0026 — Broaden `docs-governance/v1` to Cover Plugin Prompt/Documentation Markdown

Verdict: PASS
Round: 0
Conformance: bootstrap-ratification: degraded
Reviewed against: ADR 0025 (esp. §B, §B.2 item 3), ADR 0023 §1/§6/§7, spec 03
(owner-gate authority), the live transition ledger
(`origin/loom/bootstrap-transition:state.json`), and the live plugin tree
(`plugins/loom/agents/*.md` frontmatter, `scripts/validate-repository.mjs`,
`scripts/schemas/agent-frontmatter-v1.schema.json`).

Advisory: this is a blind evaluator verdict. PASS is necessary but **not
dispositive** — owner acceptance under spec 03's owner-gate authority is the
disposition. Absent either this cold plan-eval PASS or explicit owner acceptance,
the ADR stays at Plan Review and the broadening does not take effect (ADR 0026 §5.3).

## Findings

### Narrowness (axis 1) — sound

- Verified against ADR 0025's live text: §B.2 **item 3** is exactly the path
  allowlist (`.docs/**`, root `README.md`/`CLAUDE.md`/`AGENTS.md`) plus its
  no-product-change guard ("nothing under `plugins/loom/**`, `scripts/**`,
  `bin/**`, or any hook/helper/test path"). ADR 0026 §1/§2 supersede **precisely
  that item** and nothing else.
- The §1 preservation list is accurate and complete against 0025: Decision A;
  §B no-bypass rule; the `docs-governance/v1` class and its persistent-token
  mechanics (§B.1); §B.2 items 1, 2, 4; the `bootstrap-landing` handover; the
  §B.4 self-bootstrap shape; §B.3 retroactive classification; and all ADR 0023
  §2/§7/§8 machinery. Each named item exists in 0025 as claimed. No overreach.
- §4's two strengthened evaluator confirmations are **within** the scope §1
  reserves ("the no-executable-change boundary that guards" the path), not an
  edit to §B.2 item 2's evidence shape. Not overreach.

### Boundary soundness (axis 2, the crux) — sound rule, enforcement-dependent

The classification **rule** is sound and closes the executable-equivalent hole
in principle. Confirmed mechanically that the risk is real: agent/command/skill
`.md` files under `plugins/loom/` carry behavior-bearing YAML frontmatter
(`model:`, `tools:`, `name:`, `description:`) that the Claude Code loader and
`validate-repository.mjs` consume **as data**. A `model: opus → haiku` or a
`tools:` edit is a runtime-behavior change delivered inside a `.md` file.

- ADR 0026 §3's general rule — a `.md` is out-of-class if it is "consumed as data
  by a script or validator, or is otherwise interpreted as behavior rather than
  read as prose" — **categorically excludes frontmatter changes**, since
  frontmatter is exactly data-consumed-by-the-validator. So no class of
  behavior-affecting change escapes the *classification*: a frontmatter
  model/tools/name change is, by rule, out-of-class and must fail the §4.1
  no-behavior-change confirmation.
- The **arbiter is correctly located**: §4.1 assigns the semantic
  no-behavior-change judgment to the cold docs code-evaluator over the exact
  `base..head` diff, with `validate-repository.mjs` (§4.2) as a *structural*
  backstop. Verified this division is honest: the validator's
  `agent-frontmatter-v1` schema accepts `model` as any of `{haiku,sonnet,opus}`
  and `tools` as any string/array, so a schema-valid `model:`/`tools:` edit
  **passes the validator while changing behavior**. The ADR does **not**
  over-claim the validator catches this — it explicitly (§Consequences) shifts
  the boundary-policing burden to the evaluator's confirmation and calls it "a
  deliberate trade." That is the correct, honest design.
- Residual risk is **enforcement/diligence, not a definitional hole**: a
  behavior-affecting `.md` slips through only if the evaluator fails to apply the
  stated rule to a frontmatter hunk. This is disclosed, not papered over.

- [MINOR] §2 admits `plugins/loom/**/*.md` (incl. agent/command/skill bodies)
  wholesale into the in-class allowlist, yet those files are **not** "pure
  documentation" — each carries behavior-bearing frontmatter. The reconciliation
  lives only in §3/§4's per-diff test, leaving the single most likely
  behavior-affecting edit (a schema-valid `model:`/`tools:`/`description:` tweak)
  dependent on evaluator inference. Recommend §2 (or §3) explicitly carve the
  frontmatter fields (`name`, `description`, `model`, `tools`, `color`,
  `argument-hint`) as categorically behavior-bearing / out-of-class, so the
  in-class surface is the **prose body only**. This converts the highest-risk case
  from a judgment call into a bright line. Precision only — the general
  "consumed as data" rule already governs it and §4.1 requires the confirmation;
  not a blocker.

### Ledger representation (axis 3) — sound and §6-conformant

- The successor records a **capability amendment with `allowed_slices`
  UNCHANGED** (`allowed_slices_after == allowed_slices_before`), the change living
  in the class *definition* the `authority_amendments` entry describes. This is a
  coherent §6 successor: because the set neither grows nor shrinks, ADR 0023 §6's
  add-never rule is **not even implicated** — this is strictly *more* conservative
  than ADR 0024/0025, which each carried a non-empty set delta and (for 0025)
  needed a narrow §6 supersession to add the token. Correctly distinguished in §5
  and Consequences.
- Recording a definitional change as an append-only `authority_amendments` entry
  with a null set delta conforms to §6's append-only/fast-forward/no-force
  protocol; §6 latches eligibility on the ledger and does not require an amendment
  to carry a membership delta. Sound.
- Live-ledger cross-check: `docs-governance/v1` is present in `allowed_slices`;
  the `adr-0025-no-bypass-target-landing/v1` amendment is recorded with its
  persistent-token note; the `docs-governance-reconciliation` slice
  (class `docs-governance/v1`) is present. Consistent with the ADR's premise.

- [MINOR] §Context/§5 state the token is present "at the time of writing at
  sequence 12." The live tip reads **sequence 11**, `phase:
  publication-intent`, with `docs-governance-reconciliation` still in
  `publication_intent` (not yet settled into `results`). The parenthetical is
  therefore off-by-one against the live ref. Immaterial to correctness — the ADR
  explicitly hardcodes **no** tip SHA and directs the root to read and bind the
  live protected ref — but the illustrative number should track reality or be
  dropped.

### Self-bootstrap (axis 4) — sound

- The landing path mirrors ADR 0025 §B.4 / ADR 0024 §2 exactly: planner commits
  at Plan Review; a fresh cold plan-eval labeled `bootstrap-ratification:
  degraded` (this one-time extension of ADR 0023 §1 eligibility to this ADR);
  explicit owner acceptance; acceptance effective at first only to authorize the
  single §6 successor; then the accepted document rides a docs-governance §7 slice
  to `main`. Consistent with the two prior precedents.
- Strength (non-circular): the accepted ADR 0026 document lands under
  `.docs/ADR/`, which is inside the **pre-existing** `.docs/**` allowlist — so its
  own landing does not depend on the broadening it enacts. No self-reference
  hazard.

### Scope discipline — clean

- ADR 0026 defers the remediation-3 playbook-conformance edits ("Out of scope
  (deferred, named only)"), authorizing the **path/capability** only, and amends
  **no spec text**. Consistent with 0025's own defer-the-edits posture.

## Required changes (for FAIL)

None — verdict is PASS. The two MINORs above are advisory precision improvements
the owner may direct be folded in before acceptance (ADRs being immutable once
accepted), as was done for ADR 0025's round-0 MINORs.

## Notes

The highest-value question — *can a behavior-affecting `.md` ride the lightweight
docs lane?* — resolves as: **not by rule, only by lax enforcement.** The
frontmatter of agent/command/skill `.md` files is genuine behavior surface and is
schema-valid under `validate-repository.mjs` even when its value changes, so the
validator is a structural backstop only; the real gate is the cold docs
code-eval's explicit no-behavior-change confirmation over the exact diff. ADR 0026
locates that arbiter correctly and discloses the trade honestly. The MINOR
frontmatter carve-out would harden a judgment call into a bright line but is not
required for soundness.

---

## Re-review — round 0 resolution (frontmatter carve-out folded)

Verdict: PASS
Round: 0
Conformance: bootstrap-ratification: degraded
Reviewed at: commit b2614ce (`git diff 798d7e8..b2614ce`), against the same
authority (ADR 0025 §B/§B.2, ADR 0023 §1/§6/§7, spec 03 owner-gate), the live
transition ledger, and the live plugin tree (`plugins/loom/commands/*.md`).

Advisory: blind evaluator verdict. PASS is necessary but **not dispositive** —
**owner acceptance under spec 03's owner-gate authority is the disposition**
(ADR 0026 §5.3). This re-review resolves the round-0 PASS-with-2-MINORs; no FAIL
intervened, so the round counter stays at 0.

### MINOR 1 (frontmatter carve-out) — genuinely and soundly resolved

Verified against the exact diff. Behavior-bearing YAML frontmatter is now carved
**categorically out of class**, closing the round-0 boundary hole:

- **§2** redefines the in-class surface as the **PROSE BODY only** of
  `plugins/loom/**/*.md`; the `---`-delimited header is declared out of class and
  cross-referenced to §3.
- **§3** adds the **Frontmatter carve-out (categorical rule)**: a bright-line, not
  a per-diff judgment call. It enumerates `model`, `tools`/`allowed-tools`, `name`,
  `description`, `color`, `argument-hint` **and** the general closure — "any field
  a loader or validator consumes as data, or that selects a model tier, a tool
  permission, an agent identity, or routing." A diff touching any such field is
  **code-bearing** and must use the normal code-bearing procedure.
- **§4** adds **confirmation 0** — a **mandatory categorical rejection** (the docs
  code-eval **MUST return FAIL** on any behavior-bearing frontmatter edit), and
  states explicitly that **schema-validity is not sufficient** evidence of no
  behavior change (validator is a structural backstop only; confirmations 0 and 1
  are the real gate).

The enumeration matches the owner's required set exactly, and the general closure
covers unlisted loader/validator-consumed or tier/permission/identity/routing
fields. MINOR 1 is closed.

### Round-0-sound content undisturbed

The diff (798d7e8..b2614ce) is confined to the §2/§3/§4 frontmatter-carve-out
additions plus a Notes—History line — nothing else changed. Re-verified intact:
narrow supersession of ADR 0025 §B.2 item 3's path allowlist only; broadened
body-prose scope; preserved executable/test/schema exclusions (§3); the
capability-not-token ledger successor with `allowed_slices` **UNCHANGED**
(`allowed_slices_after == allowed_slices_before`); and the self-bootstrap ceremony
(§5). Live-ledger cross-check now agrees with the ADR: tip reads
**`sequence: 12`, `phase: active`**, with `docs-governance-reconciliation` settled
into `results` and `docs-governance/v1` retained in `allowed_slices` — so MINOR 2's
"seq 12" reference is correct and the stale-read is confirmed a non-issue.

### Residual body-channel behavior surface (advisory, not a blocker)

The carve-out completely hardens the **frontmatter** channel into a bright line,
but a behavior-bearing change can still reach the **prose body**, where it is
governed only by §3's softer general rule ("otherwise interpreted as behavior
rather than read as prose") and §4 confirmation 1's semantic judgment — not by a
categorical carve-out. Confirmed mechanically that this surface is real, not
hypothetical: `plugins/loom/commands/*.md` bodies contain loader-interpreted
substitution tokens — `$ARGUMENTS` and `${CLAUDE_PLUGIN_ROOT}` path directives
(`eval-plan.md:10`, `eval-code.md:10`, `develop.md:10`, `run.md:11`,
`research.md:10`, `plan.md:10`) — that the command loader expands at invocation.
An in-body edit that alters/removes such a token, or that adds a Claude-Code
`!`-bash-exec line to a command/skill body, is behavior-bearing yet lives in the
prose body, outside the frontmatter carve-out. This is the same
enforcement-dependent residual the round-0 eval flagged for the general boundary;
it is disclosed (§3 general rule + §Consequences trade) and policed by §4.1, not a
definitional hole. It does **not** reopen MINOR 1. The owner may optionally direct
a parallel bright-line note for in-body loader-interpreted constructs
(argument/`$ARGUMENTS`/`${CLAUDE_PLUGIN_ROOT}` substitution, `!`-exec lines), but
soundness does not require it.

### Required changes

None — verdict is PASS. The residual above is advisory precision only.
