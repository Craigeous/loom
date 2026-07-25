# Evaluation: ADR 0025 — Reconciliation Authority (Plugin-Root Supersession + No-Bypass §7 Landing)

Verdict: PASS
Round: 0
Reviewed against: ADR 0006 (superseded) + its rewrite commit `5e0b178`, ADR 0023
§1/§6/§7, ADR 0024 §2/§3 (precedent), ADR 0020, spec 03 (owner-gate + `Accepted`
token), ADR 0001 (forward-note style), and the repository tree.

**Assessment label: `bootstrap-ratification: degraded`.** This ADR is not on ADR
0023 §1's closed eligibility list; per the ADR's own B.4 step 2 (mirroring ADR 0024
§2), it narrowly extends §1's plan-evaluation eligibility to cover exactly this ADR,
and this cold plan-evaluation is prepared and labeled degraded accordingly. This is a
distinct cold plan-evaluator assessment, blind to authorship.

**This PASS is advisory only.** Per B.4 step 3 and spec 03's owner-gate authority,
evaluator PASS is necessary but insufficient: final acceptance is a separate,
explicit owner gate (record of commit/blob, verdict hash, decision, UTC time). Absent
that owner acceptance, neither Decision A nor Decision B takes effect.

## Findings

- [MINOR] B.4 step 1 asserts the Plan-Review authoring commit "is not pushed" and
  "does not advance `origin/main`." In reality the Plan-Review document already
  resides on `origin/main` (blob present at the reviewed tip). This does not break
  the self-bootstrap logic — at Plan Review Decision B is "not yet in force," so a
  docs-only Plan-Review push is a B.3-class *pre-rule deviation*, not a bypass of a
  live rule — but the idealized "not pushed" phrasing understates that a Plan-Review
  draft may already sit on `main` under the pre-Decision-B regime. A one-line
  acknowledgment (draft-on-main is a recorded pre-rule deviation; only the
  `Status: Accepted` transition must ride the §7 docs-governance slice) would make
  the narrative fully honest. Verdict is unaffected: the *Accepted* landing path
  (B.4 step 5) remains consistent and requires no direct `main` push.
- [MINOR] Landing *mechanism* for docs-governance slices is implicit. B.2 binds them
  to "ADR 0023 §7's intent/settle ceremony," but §7's numbered *bootstrap
  remote-direct* procedure is gated on `bootstrap-landing` being `available` and is
  retired after `remote-first-integration-candidate` settles ("every later
  publication uses the production landing helper"). The intent→publish→settle
  *ordering* survives that retirement, so the binding is workable, but the ADR should
  state that docs-governance slices use whichever landing mechanism is current
  (bootstrap remote-direct while `bootstrap-landing` is available, else the production
  helper) rather than leaving it to inference.
- [MINOR] Persistent-class-token settlement is a genuinely new mechanic. B.1 says
  `docs-governance/v1` "is not consumed by any slice settlement," while ADR 0023 §7
  step 8 removes "the slice from `allowed_slices`" at settlement. The ADR should make
  explicit that a concrete docs-governance slice settles by *adding an immutable slice
  result* (per §6) **without** removing the persistent class token — i.e. §7 step 8's
  removal is the one step modified for this class. The intent is inferable and
  internally consistent, but a single reconciling sentence would remove ambiguity for
  the implementing planner.

## Notes — adversarial pass against the five charge items

**1. Decision A (supersede, not rewrite) — sound.** Verified mechanically:
`git show 5e0b178` confirms the "Build M1 scaffold" commit rewrote the
already-accepted 0006 in place, changing root `source: "."` → `./plugins/loom`
subdir. The repo tree confirms the *implemented reality* is the subdir form
(`marketplace.json` → `"source": "./plugins/loom"`; manifest at
`plugins/loom/.claude-plugin/plugin.json`; no root `plugin.json`). 0025 correctly
(a) re-decides `./plugins/loom` as authoritative, (b) declares "Supersedes ADR 0006
on the plugin-root location only" in both Decision and Consequences (no silent
supersession), and (c) specifies 0006-body restoration as a *deferred implementation
instruction* without itself editing 0006. Supersession chain is honest: 0006 keeps
`Status: Accepted` + `Date: 2026-06-08`, gains one forward-pointer blockquote in the
exact style ADR 0001 already uses for its ADR-0007 note (verified present); 0025
carries the live decision. The restoration target (`5e0b178^` body: root `source:
"."`, `plugins/loom` as OQ-E fallback) matches the pre-rewrite text in the diff.

**2. Decision B + self-bootstrap — the circle is genuinely broken; no smuggled
direct-push.** The chicken-and-egg (no-bypass §7 requires a slice on a closed list;
docs work isn't on it) is broken exactly as ADR 0024 broke its own: (i) B.1 adds one
persistent `docs-governance/v1` token via a single append-only `authority_amendments`
successor, an explicitly-declared narrow supersession of §6's add-never rule
(mirroring 0024 §3, which added two named slices the same way); (ii) B.4 step 4 makes
owner acceptance effective "at first for one purpose only" — authorizing that one
successor — the identical non-circular activation boundary ADR 0024 §2 used (verified
against 0024 §2/§3); (iii) the ledger write lands on
`refs/heads/loom/bootstrap-transition` (ref naming verified consistent with 0023 §6),
a separate branch governed by §6's create-only/fast-forward/no-force protocol, and
**never advances `main`**; (iv) the accepted-document then reaches `main` only as the
payload of the first docs-governance §7 slice. The "irreducible edge" claim is TRUE
and SUFFICIENT: the two authoring commits are carried by a §7 slice (never a direct
`main` push) and the single real remote write is the §6 ledger successor, which by
construction does not advance `main`. No `main`-advancing bypass is smuggled. The
evidence substitution (blind plan-eval + cold docs code-eval + gate, no §3 finder
package) is a defensible narrowing for a proven docs-only candidate — it preserves the
cold-evaluator-is-sole-PASS-authority core of §4 and mirrors 0024's differential
treatment of its documentation-only slice. The docs gate reference (`scripts/check`)
resolves to a real executable in the tree.

**3. Immutability + retroactivity — correct.** B.3 classifies the prior direct pushes
(`0ae81c1`, `87b72c9`, July-21 planning commits) as pre-rule deviations *already
recorded* in the M0/remediation-1 errata; it rewrites/reverts/re-authors nothing and
"closes the rule going forward only." No already-settled slice is retroactively
invalidated; history is treated as immutable. Consistent with ADR immutability and
with §6's monotonic latch.

**4. Scope discipline — strong.** The ADR DECIDES rules and correctly DEFERS every
implementing edit — 0006 body restoration + forward note, ADRs 0014–0017
`Approved`→`Accepted`, spec 03/04 heading/slice-list harmonization, the path errata,
and the §7/M2 fold — to "the reconciliation implementation step," to land as the first
`docs-governance/v1` §7 slice. "No spec text is amended here" holds. I confirmed the
deferred factual claim: ADRs 0014–0017 are indeed currently `Status: Approved` (should
be `Accepted`), so the deferral targets a real defect rather than inventing one. The
ADR resists doing the edits — this is a virtue, not a gap.

**5. Contradictions / undefined terms / unimplementable instructions —** none rising
above MINOR. The "cold docs code-evaluator" is defined in B.2; the ledger ref, the
before/after `allowed_slices` recording, and the activation ordering are all concrete
and mirror an accepted precedent. The three MINORs above are clarity refinements, not
defects that block the decision.

**Self-bootstrap soundness judgment:** The self-bootstrap circle is genuinely broken
and non-circular — owner-acceptance activates only the one §6 ledger successor, which
never advances `main`, so the accepted ADR reaches `main` solely as a §7
docs-governance-slice payload with no direct-push bypass.

<!--
Round 0: fresh artifact, no prior FAIL in this eval file. PASS with zero
BLOCKER/MAJOR; three MINORs do not block. Advisory only — owner acceptance is the
separate, dispositive gate (B.4 step 3 / spec 03). Not committed by the evaluator;
the root records per the ADR's own landing path. Artifact status line left unchanged
(Plan Review) — the owner gate, not this evaluator, moves it to Accepted.
-->

---

# Re-evaluation (round-0 revision): PASS

Verdict: PASS
Round: 0
Reviewed at commit `1fc8cd0` against the same authorities (ADR 0006 + rewrite
`5e0b178`, ADR 0023 §1/§6/§7, ADR 0024 §2/§3, ADR 0020, spec 03, ADR 0001) and the
repository tree. Assessment label unchanged: `bootstrap-ratification: degraded`.
**This PASS remains advisory only** — owner acceptance under spec 03's owner gate
(and B.4 step 3) is the dispositive gate; absent it, neither Decision A nor B takes
effect.

The owner directed the three round-0 MINORs be folded in before acceptance (ADRs are
immutable once accepted). The revision (`git diff b1ba112 1fc8cd0`) is tightly scoped:
its only hunks touch the three MINOR regions plus an appended `## Notes — History`.
Decision A, B.3, B.4 steps 2–5, and the deferred-edits Consequences bullet are
byte-unchanged — the round-0-sound core is undisturbed.

## Per-MINOR resolution

- **MINOR 1 — B.4 step 1 "not pushed" understatement — RESOLVED.** The prior
  "local commit that does not advance `origin/main` (it is not pushed)" is replaced by
  an accurate statement: the Plan-Review draft "has **already reached `origin/main`**
  … a B.3-class recorded pre-rule deviation (a docs-only Plan-Review push), not a
  bypass of a live rule," and "This ADR does not claim the draft was never on `main`."
  Verified mechanically: `git cat-file -e origin/main:…0025….md` → PRESENT; the blob
  is on `origin/main` (tip `1fc8cd0`). The bootstrap-edge paragraph is rewritten to
  match. Non-circularity preserved: only the `Status: Accepted` disposition + live
  decision ride the §7 docs-governance slice (B.4 step 5); the draft-on-main is not a
  live-rule bypass because Decision B is not in force at Plan Review. No new problem.
- **MINOR 2 — post-`bootstrap-landing`-retirement landing — RESOLVED.** New B.2
  paragraph binds docs-governance slices to §7's intent→publish→settle *ordering*, not
  a transport: bootstrap remote-direct while `bootstrap-landing` is `available`, then
  the production remote landing helper under ADR 0020's authority after retirement at
  `remote-first-integration-candidate` settlement. Matches ADR 0023 §7's own handover
  boundary ("every later publication uses the production landing helper") and §6's
  `remote-first-integration-candidate`-retires-`bootstrap-landing` rule. Coherent; the
  handover reintroduces no direct-push bypass (ordering, exact-revision binding, fresh
  verification, and bound receipt identical either side; only transport changes).
- **MINOR 3 — class token vs §7 step 8 — RESOLVED.** B.1 third bullet + B.2 item 4 now
  state `docs-governance/v1` authorizes a recurring **class**, so a concrete slice
  settles by recording its immutable **result entry + bound receipt** (per §6)
  **without** removing the token — explicitly named as "the one point where a
  docs-governance slice's settlement differs from ADR 0023 §7 step 8." Token removal is
  governed only by a future superseding ADR or §6's terminal sunset, never by a single
  slice's settlement. No contradiction with 0023 §6/§7: §6 permits "remove, never add"
  (a permission, not a mandate) and "add one immutable slice result"; persisting the
  token is a declared, narrow deviation from §7 step 8's removal, validated
  byte-for-byte immutable at later sequences per §6's cumulative-state rule.

## Core re-confirmation

- Decision A (supersede-not-rewrite + `5e0b178^` body-restoration instruction, forward
  note in ADR 0001's style, README index update) — intact, byte-unchanged.
- Decision B no-bypass, the single B.1 §6 append-only successor, finder-free docs §7
  evidence (blind plan-eval + cold docs code-eval + gate) — intact.
- B.3 retroactive pre-rule-deviation classification — intact; rewrites nothing.
- Deferred implementation edits (0006 body, 0014–0017 `Approved`→`Accepted`, spec
  03/04 harmonization, path errata, §7/M2 fold) — intact.
- **Self-bootstrap still genuinely broken/non-circular:** owner acceptance is effective
  "at first for one purpose only" — authorizing the one B.1 ledger successor, a §6
  transition-ref write on a separate branch that never advances `main`; the accepted
  document reaches `main` solely as the payload of the first §7 docs-governance slice.
  Untouched by the revision. No smuggled `main`-advancing direct push.

Zero BLOCKER/MAJOR. The three round-0 MINORs are folded in faithfully; none reopened
and no new finding surfaced. Verdict: **PASS (advisory)**, Round 0.

<!--
Round stays 0: round 0 was a PASS-with-MINORs, never a FAIL, so the counter does not
advance (increment only on FAIL). Not committed by the evaluator — the root records
per the ADR's own landing path; artifact status line left unchanged (Plan Review), the
owner gate moves it to Accepted.
-->
