# 0025 — Reconciliation Authority: Plugin-Root Supersession and No-Bypass §7 Target Landing

Status: Plan Review
Date: 2026-07-24

## Context

The 2026-07-24 alignment audit (recorded in `.docs/status/progress.md` §
"Remediation-1 audit errata" and in the archived `errata-and-settled-record`
slice's `## Notes`) surfaced two integrity matters that are **decisions**, not
record-keeping, and were explicitly deferred to a remediation-2 spec/ADR cycle plus
owner. This ADR is that cycle's **authority foundation**. It decides the rules only;
the dependent spec amendments and the concrete reconciliation edits land in a **later
reconciliation implementation step** (see Consequences → *Deferred to the
reconciliation implementation step*). No spec text is amended here.

The two deferred matters:

1. **ADR 0006 was rewritten in place after acceptance.** Commit `5e0b178` ("Build M1
   scaffold …") modified the already-accepted
   `.docs/ADR/0006-distribution-self-marketplace.md`, changing the plugin-root
   decision from "both manifests at the repo root, marketplace `source: "."`" to "the
   plugin lives in `plugins/loom/` with its own `plugins/loom/.claude-plugin/plugin.json`,
   listed at `source: "./plugins/loom"`." This violates ADR immutability (supersede,
   never rewrite — ADR README; ADR 0005). Verified: `git show 5e0b178 -- .docs/ADR/0006*`;
   pre-rewrite text at `git show 5e0b178^:.docs/ADR/0006-distribution-self-marketplace.md`.
   The **implemented reality** matches the rewritten (subdir) form — confirmed against the
   tree: `.claude-plugin/marketplace.json` lists `"source": "./plugins/loom"`; the plugin
   manifest is `plugins/loom/.claude-plugin/plugin.json`; there is no root `plugin.json`.
   So the repository is correct but its decision record is dishonest: 0006 now reads as if
   the subdir layout were its original decision, erasing the superseded root-layout decision.

2. **Direct pushes to `origin/main` occurred outside the slice/review/settlement path.**
   The audit recorded a code-bearing hotfix (`0ae81c1`, Linux CI `stat -f` fix) pushed
   directly to `main` with no slice, review, or settlement; a docs-only "direct-push per
   ADR 0020" landing of the errata slice (`87b72c9`) and of the earlier governance slice;
   and the July-21 planning-phase direct commits. The owner's standing rule for the
   self-hosting bootstrap is ADR [0023](0023-repository-self-hosting-bootstrap-transition.md)
   §7 (remote-direct intent/settle publication), but §7 authorizes only slices on ADR 0023
   §1's closed `allowed_slices` set, and that set contains only code-bearing improvement
   slices (plus, via ADR 0024, two named dogfood slices). There is no authorized path for
   governance, remediation, reconciliation, or planning-docs work to advance `main`, so
   such work has been landing by direct push — an unbounded bypass class the owner has
   decided to eliminate.

The owner has made both decisions (Decision A: a formal superseding ADR, not an
erratum; Decision B: everything through §7, no bypass class). This ADR records them
immutably and resolves the mechanism gap Decision B creates.

Out of scope: any change to ADR 0023's evidence, isolation, retirement, or sunset
machinery beyond the two narrow supersessions stated below; any release-contract
change; the actual reconciliation edits (named as deferred in Consequences).

## Decision

### A. Re-decide the plugin-root location and formally supersede ADR 0006

The **plugin-root location is `./plugins/loom`**, a source subdirectory of the
repository:

- the marketplace catalog is the repo-root `.claude-plugin/marketplace.json`, which
  lists loom at `"source": "./plugins/loom"`;
- the shippable plugin lives in `plugins/loom/` with its own manifest
  `plugins/loom/.claude-plugin/plugin.json`;
- there is no repo-root `plugin.json`; and
- loom's own `.docs/` is design memory, not a plugin component.

This is the implemented reality and it is now the authoritative decision of record.
**This ADR supersedes ADR 0006 on the plugin-root location.** ADR 0006's original
decision (both manifests at the repo root, marketplace `source: "."`, with
`plugins/loom` named only as an OQ-E fallback) is superseded, not extended: the root
layout is rejected because a marketplace `source: "."` root plugin is not documented,
and the proven `./plugins/loom` subdir form is used instead.

This ADR does **not** claim ADR 0006 was never rewritten. The rewrite (`5e0b178`)
happened; erratum (a) records it; this supersession makes the record honest going
forward.

**Restoration instruction for the reconciliation implementation step** (the edit
itself is out of scope here and lands in that later step): the implementing developer
SHALL restore `.docs/ADR/0006-distribution-self-marketplace.md`'s **body** to its exact
pre-rewrite text — the text at `5e0b178^` (the parent of the rewrite commit), i.e.
`git show 5e0b178^:.docs/ADR/0006-distribution-self-marketplace.md` — which decides
root `source: "."` with the `plugins/loom` fallback tracked as OQ-E. The restored file:

- keeps its original header, `Status: Accepted`, and `Date: 2026-06-08` (the original
  decision's identity is preserved — it is not re-dated or re-statused);
- carries one added forward-pointer note directly under the header, in the exact style
  ADR 0001 already uses for its ADR-0007 supersession — a single blockquote line such as
  `> Note: the repo-root plugin-root decision below is superseded by ADR 0025 (implemented
  reality is the `./plugins/loom` subdir).` This note points forward only; it does **not**
  alter the decision text, so immutability is preserved (the decision reads as originally
  written, plus a supersession pointer, exactly as 0001 does);
- makes no other change to 0006's Context/Decision/Consequences prose.

After restoration the record reads honestly: **0006 = the original repo-root decision,
now superseded; 0025 = the current `./plugins/loom` decision.** The README index entry
for 0006 is updated in the same step to note "plugin-root location superseded by 0025."

### B. Every commit advancing `origin/main` lands through ADR 0023 §7 — no bypass class

For the duration of the ADR 0023 bootstrap transition (until its §6 terminal sunset),
**every commit that advances the configured target ref `origin/refs/heads/main`** —
code-bearing, docs-only, governance, errata, planning/ADR/spec amendments, and
emergency hotfixes alike — SHALL land through the ADR 0023 §7 intent/settle publication
ceremony. **No direct-push bypass class exists.** In particular, the prior practice of
"docs-only direct-push per ADR 0020" is closed: docs-only work is not exempt.

This rule governs only the **configured target ref (`main`)**. Writes to the protected
transition ledger `refs/heads/loom/bootstrap-transition` are governed by ADR 0023 §6's
own append-only, create-only/fast-forward, no-force protocol; they advance a separate
branch, never `main`, and are therefore not a "direct-push to `main`" and not a bypass
of this rule.

#### B.1 Authorize a docs-governance slice class in the transition state

ADR 0023 §7 only lands slices that the freshly validated transition state lists in
`allowed_slices`, and ADR 0023 §6 permits removing but never adding to that set. To make
"everything through §7" workable for governance/remediation/reconciliation/planning-docs
work without an accepted ADR per document fix, this ADR authorizes **one** append-only
transition-state successor that adds a persistent **docs-governance slice class** to
`allowed_slices`, mirroring how ADR 0024 §3 added two named slices via a one-time
`authority_amendments` entry.

The mechanics, to be performed by the root only after the self-bootstrap gate in B.4:

- The successor is one ordinary fast-forward child of the **freshly read and verified
  current transition tip** (the root SHALL read the live protected ref, validate its
  complete ADR-0023/ADR-0024 history, and bind that exact tip as predecessor; this ADR
  deliberately does not hardcode a tip SHA, which would be stale). It increments the
  sequence by one, repeats every immutable ADR-0023 program/configuration field and the
  immutable `adr-0024-macos-dogfood/v1` amendment entry byte-for-byte, and adds exactly
  one new `authority_amendments` entry identified `adr-0025-no-bypass-target-landing/v1`.
- That entry binds: this accepted ADR's commit and blob IDs; the cold plan-eval verdict
  and package hashes; the owner-acceptance record hash; the predecessor state SHA; and
  the before/after `allowed_slices` sets. The **only** set change is the addition of the
  single class token `docs-governance/v1`. The root records `allowed_slices_before` (the
  freshly read live set) and `allowed_slices_after` (`before ∪ {docs-governance/v1}`) in
  the entry — exactly as ADR 0024 recorded its before/after at acceptance.
- `docs-governance/v1` is a **persistent class marker**, not a settling slice: it is not
  consumed by any slice settlement, is validated byte-for-byte immutable at every later
  sequence, and is removed only when ADR 0023 §6's terminal sunset successor empties
  `allowed_slices`. This narrowly supersedes ADR 0023 §6's add-never rule for that one
  successor only; thereafter the remove-only rule resumes and no other slice may be added.

#### B.2 How a docs-governance slice is eligible and runs §7

A concrete slice is **eligible under the class** — and thus §7-landable — when all hold:

1. `docs-governance/v1` is present in the freshly validated `allowed_slices`;
2. the slice has its **own approved slice-plan** that declares class membership
   (plan `Slice type: docs-governance` and a name prefixed `docs-governance/…` or an
   explicit class field) and passed a **blind plan evaluation** distinct from its planner;
3. the slice-plan's **exact path allowlist is confined to authority/documentation
   surfaces** — `.docs/**`, root `README.md`, root `CLAUDE.md`, root `AGENTS.md` — and
   the candidate introduces **no product/executable change** (nothing under
   `plugins/loom/**`, `scripts/**`, `bin/**`, or any hook/helper/test path). A candidate
   touching any excluded path is not a docs-governance slice and must use the normal
   code-bearing procedure; and
4. at settlement the slice records its result on the ledger like any §7 slice.

A docs-governance slice runs ADR 0023 §7's intent/settle ceremony with one substitution
that resolves the evidence-shape gap the class creates. Because there is no product code
to find defects in, the §3 three-finder correctness/tests/security auxiliary package is
**not required and not produced**. Its evidence is instead:

- the slice's **blind plan-eval verdict** (B.2 item 2); and
- a **distinct cold docs code-evaluator verdict** over the exact `base..head` candidate
  diff — a single fresh evaluator, distinct from the planner and root, adjudicating the
  documentation diff for conformance, accuracy, and cross-reference integrity, writing
  its own verdict to scratch, which the root records without merits changes; plus
- the standard §7 gate evidence and evaluator gate rerun: `scripts/check` run against the
  exact `head_sha` and rerun against a fresh copy (its link, whitespace, and
  plugin-validation checks are the mechanical gate for docs).

All ADR 0023 §2 exact-revision binding, §7 publication-intent → non-force target update →
fresh verification → bound receipt → settlement ordering, degraded-bootstrap provenance
labels, and §8 fail-closed recovery still apply unchanged. The cold docs code-evaluator
remains the sole PASS/FAIL authority; the root, planner, and owner cannot manufacture a
PASS. This substitution is explicitly narrow: it removes only the code-finder package for
a proven docs-only candidate and requires **no** sealed finder package for docs slices.

This narrowly extends ADR 0023 §1 and §7 to admit degraded planning evaluation and
repository-only §7 publication of docs-governance-class slices while the bootstrap remains
active — in the same spirit as ADR 0024 §3's extension for its documentation-only slice.

#### B.3 Retroactive classification of the prior direct pushes

The prior direct pushes are **pre-rule deviations already recorded** in the M0 and
remediation-1 errata (`.docs/status/progress.md`): the governance-slice and errata-slice
docs-only direct pushes (including `87b72c9`), the code-bearing hotfix `0ae81c1`, and the
July-21 planning-phase direct commits. This ADR **closes the rule going forward only**. It
does not rewrite, revert, or re-author those commits; history is immutable. They stand as
recorded deviations that predate this rule.

#### B.4 Self-bootstrap: this ADR's own honest landing path

Like ADR 0023 §1 ("cannot authorize its own acceptance retroactively") and ADR 0024 §2,
this ADR **cannot have been published under the rule it creates**. Its landing path is:

1. The planner commits **only** this ADR and its ADR-index entry at `Status: Plan Review`.
   This is a **local commit that does not advance `origin/main`** (it is not pushed), so it
   is not a §7 event and not a bypass — at Plan Review the everything-through-§7 rule is not
   yet in force.
2. A **fresh cold plan evaluator**, distinct from the planner and root, evaluates it under
   ADR 0023's bootstrap controls, labeled `bootstrap-ratification: degraded` (this ADR is a
   different ADR than 0023's closed list, so this narrowly extends ADR 0023 §1's
   plan-evaluation eligibility to cover exactly this ADR — the same one-time extension ADR
   0024 §2 took for itself).
3. **Explicit owner acceptance** under spec 03's owner-gate authority. Evaluator PASS is
   necessary but insufficient; the owner records the proposed commit/blob, verdict hash,
   decision, and UTC time. Absent either the cold plan-eval or owner acceptance, this ADR
   stays at Plan Review and neither decision takes effect.
4. Owner acceptance is effective **at first for one purpose only**: authorizing the single
   B.1 transition-state successor (the non-circular activation boundary ADR 0024 §2 used).
   The acceptance record hash is bound into that successor, so acceptance is **durably real
   on the ledger** even before the ADR document reaches `main`.
5. Once that successor is pushed and freshly re-verified, the everything-through-§7 regime
   and the `docs-governance/v1` class are active. The accepted ADR 0025 document (its
   `Status: Accepted` transition and the honest ADR-index/README updates) then reaches
   `origin/main` **as the payload of the first docs-governance §7 slice** — the remediation-2
   reconciliation slice planned in the later implementation step. **No direct bootstrap
   commit to `main` is required.**

**The one unavoidable bootstrap edge, stated honestly:** the Plan-Review authoring commit,
the eventual `Status: Accepted` authoring commit, and the B.1 ledger successor recording
acceptance necessarily exist **before** the everything-through-§7 regime is enforceable on
`main`. This is not a §7 bypass because **none of them advances the configured target ref
`main`**: the two authoring commits are local (unpushed) until a §7 slice carries them, and
the ledger successor is an ADR 0023 §6 transition-ref write on a separate branch. The single
irreducible edge is therefore the §6 ledger write itself — a real remote write that predates
the rule and is governed by ADR 0023 §6, not §7. This ADR does not paper over that edge; it
locates it precisely (the ledger, not `main`) and bounds it (one create-and-verify successor,
no force, no `main` advance), so no direct-push-to-`main` bootstrap commit is needed.

## Consequences

- The plugin-root decision record becomes honest: ADR 0006 stands as the original
  (superseded) repo-root decision with a forward pointer; ADR 0025 is the current
  `./plugins/loom` decision. **Supersedes ADR 0006** on the plugin-root location only; the
  self-marketplace model and `.docs/`-is-dev-memory points are unchanged and simply
  re-affirmed here.
- Every advance of `origin/main` during the bootstrap now has exactly one lawful path
  (ADR 0023 §7), and governance/planning/docs work has a real, auditable §7 lane via the
  `docs-governance/v1` class — each concrete slice still individually planned, blind-evaluated,
  path-confined, gated, and settled. The closed-list safety of ADR 0023 §6 is preserved: one
  persistent class token is the single add; no per-fix ADR is needed, and no product-code slice
  can ride the docs lane.
- **Narrowly supersedes ADR 0023 §6** (add-never rule) for exactly one successor that adds
  `docs-governance/v1`, and **narrowly extends ADR 0023 §1 and §7** to admit degraded planning
  evaluation and repository-only §7 publication of docs-governance-class slices, and to run
  their §7 without the §3 finder package (blind plan-eval + cold docs code-eval + gate instead).
  All other ADR 0023 machinery — exact-revision evidence, intent/settle ordering, fresh
  verification, receipts, retirement, fail-closed recovery, and terminal sunset — remains in
  force. ADR 0020's remote-publication authority remains the success boundary.
- Prior direct pushes remain recorded historical deviations; this ADR closes the rule going
  forward and rewrites nothing.
- **Deferred to the reconciliation implementation step** (this ADR decides the rules; those
  edits implement them, and are out of scope here): the ADR-0006 body restoration + forward
  note; correcting ADRs 0014–0017 `Status: Approved` → `Accepted`; authority-heading and
  bootstrap-slice-list harmonization in specs 03/04; the ADR path errata
  (`loom-coord.sh` → `bin/loom-coord`, `.git/loom-session` → `.git/loom/session`, the
  0016-misquotes-0015 fixes); and folding the §7/M2 duplication into the improvement plan's M2
  section. These land as the first `docs-governance/v1` §7 slice, which also carries this
  accepted ADR to `main`.
