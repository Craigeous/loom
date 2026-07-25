# 0026 — Broaden `docs-governance/v1` to Cover Plugin Prompt/Documentation Markdown

Status: Accepted
Date: 2026-07-25

## Context

ADR [0025](0025-reconciliation-authority-plugin-root-no-bypass-landing.md) §B closed
every advance of `origin/main` behind the ADR 0023 §7 landing ceremony and created a
persistent `docs-governance/v1` slice class as the lawful §7 lane for
governance/remediation/reconciliation/planning-docs work. That class's eligibility
rule — ADR 0025 §B.2 item 3 — confines a docs-governance slice's path allowlist to
`.docs/**`, root `README.md`, root `CLAUDE.md`, and root `AGENTS.md`, and explicitly
declares that **any** change under `plugins/loom/**` (among others) is "not a
docs-governance slice and must use the normal code-bearing procedure."

An authority gap has surfaced. The planned playbook-conformance remediation edits
non-executable Markdown **prompt and documentation** files under `plugins/loom/` —
role/agent bodies (`plugins/loom/roles/*.md`, `plugins/loom/agents/*.md`), skill
bodies (`plugins/loom/skills/**/SKILL.md`), command bodies
(`plugins/loom/commands/*.md`), and references
(`plugins/loom/skills/loom-playbook/references/*.md`). These are pure instruction/doc
content, but they sit under `plugins/loom/**`, so ADR 0025 §B.2's allowlist **excludes
them** from the docs-governance class. Meanwhile no named code-bearing allowed-slice in
the transition state's closed `allowed_slices` set covers them either. The result is
that a purely documentary prompt fix has **no lawful §7 landing path**: it is neither
docs-governance-eligible (wrong directory) nor a member of any authorized code-bearing
slice.

This ADR resolves that gap by broadening the class's path capability to admit
non-executable prompt/documentation Markdown under `plugins/loom/`, while preserving —
byte-for-byte in intent — every other guarantee ADR 0025 established. It is a **narrow
supersession of ADR 0025 §B.2's path allowlist only**.

**Out of scope (deferred, named only):** the actual playbook-conformance edits
(remediation-3 content) are not authored or authorized in their specifics here. This
ADR authorizes the **path** — the class capability — under which those edits (and
future prompt-doc fixes) may be planned, evaluated, gated, and landed. It amends no
spec text.

## Decision

### 1. Narrow supersession of ADR 0025 §B.2's path allowlist — and nothing else

This ADR **supersedes ADR 0025 §B.2 item 3's path allowlist only**. Every other part
of ADR 0025 stands **unchanged and in force**, specifically:

- **Decision A** (plugin-root location `./plugins/loom`; supersession of ADR 0006);
- **Decision B's no-bypass rule** — every commit advancing `origin/main` lands through
  ADR 0023 §7, no direct-push bypass class (§B and §B.3);
- **the `docs-governance/v1` slice class itself** and all of its persistent-token
  mechanics — §B.1's one-time §6 successor pattern, the persistent (non-consumed) class
  marker, byte-for-byte immutability of the token at every later sequence, and removal
  governed only by a future superseding ADR or ADR 0023 §6's terminal sunset (§B.1
  third bullet, §B.2 item 4);
- **the eligibility conditions of §B.2 other than the path allowlist** — item 1
  (`docs-governance/v1` present in freshly validated `allowed_slices`), item 2 (own
  approved slice-plan declaring class membership + a blind plan evaluation distinct from
  its planner), and item 4 (settlement records a result entry + bound receipt without
  removing the class token);
- **the `bootstrap-landing` handover** transport rule (§B.2) and all ADR 0023 §2/§7/§8
  binding, ordering, verification, receipt, and fail-closed machinery;
- **the self-bootstrap ceremony shape** (§B.4) and the retroactive-deviation
  classification (§B.3).

The **only** clause this ADR re-decides is the exact set of paths a docs-governance
slice-plan's allowlist may touch, and the no-executable-change boundary that guards it.

### 2. The broadened path allowlist

A concrete docs-governance slice is path-eligible when its slice-plan's **exact path
allowlist is confined to authority/documentation surfaces**, now defined as the union
of:

- `.docs/**`;
- root `README.md`, root `CLAUDE.md`, root `AGENTS.md`; **and**
- **the non-executable Markdown prompt/documentation content — the PROSE BODY only —
  under `plugins/loom/`** — specifically the body text of `plugins/loom/**/*.md`,
  including skills' `SKILL.md`, role bodies (`plugins/loom/roles/*.md`), agent bodies
  (`plugins/loom/agents/*.md`), command bodies (`plugins/loom/commands/*.md`), and
  playbook references (`plugins/loom/skills/loom-playbook/references/*.md`), and
  analogous documentation Markdown.

A `plugins/loom/**/*.md` file is in-class **only for edits to its prose body.** Its
YAML frontmatter block (the `---`-delimited header) is **categorically out of class**:
see §3's frontmatter carve-out. A docs-governance slice's allowlist admits the body
prose of these files, **not** their frontmatter.

This replaces ADR 0025 §B.2 item 3's narrower allowlist. All other §B.2 eligibility
conditions are unchanged (§1 above).

### 3. Hard exclusions preserved — no executables, no behavior

The broadening admits **documentation only**. It does **not** admit any executable or
behavior-bearing file. The following remain out of class, exactly as before; a
candidate touching any of them is **not** a docs-governance slice and must use the
normal code-bearing procedure:

- shell scripts and helpers — `*.sh`, `plugins/loom/bin/*`, hooks
  (`plugins/loom/hooks/**`);
- tests and fixtures — `*.bats`, any test path, and any fixture consumed as data;
- structured data and manifests — `*.json` schemas, manifests, catalogs
  (`marketplace.json`, `plugin.json`, `hooks.json`, `check-toolchain.json`), and any
  `*.json` validated as plugin metadata;
- `scripts/**` in its entirety; and
- **any file whose change alters runtime or gate behavior**, regardless of extension.

**Frontmatter carve-out (categorical rule).** A `plugins/loom/**/*.md` file is in-class
for a docs-governance slice **only for edits to its prose body.** Its YAML frontmatter
block — the `---`-delimited header — is **categorically out of class.** This covers any
**behavior-bearing** frontmatter field, including but not limited to `model`,
`tools`/`allowed-tools`, `name`, `description`, `color`, and `argument-hint` — and, more
generally, **any field a loader or validator consumes as data, or that selects a model
tier, a tool permission, an agent identity, or routing.** A docs-governance slice **MUST
NOT modify any behavior-bearing frontmatter field.** A candidate whose diff changes any
such field is **code-bearing**, is **not** a docs-governance slice, and must use the
normal code-bearing procedure — regardless that the file's extension is `.md`. This is a
bright-line rule, not a per-diff judgment call: frontmatter is data-consumed-by-the-loader
and therefore behavior, not prose.

**Boundary precision.** A `.md` file under `plugins/loom/` is in-class **only if it is
pure prompt/instruction/documentation content** — an agent, role, skill, command, or
reference body read as natural-language instruction to a role or human — **and only its
prose body is touched** (per the frontmatter carve-out above). A `.md` file is **out of
class** if it encodes executable fixtures, is consumed as data by a script or validator,
or is otherwise interpreted as behavior rather than read as prose. Directory location
under `plugins/loom/` does not by itself make a file in-class or out-of-class: the test
is whether the content is behavior (out) or documentation (in). The `.md`/`.json`/`.sh`
extension is a strong signal but not the arbiter; the arbiter is the frontmatter
carve-out above together with the no-behavior-change confirmation in §4.

### 4. Evidence shape — unchanged from ADR 0025 §B.2, with one strengthened check

The evidence a docs-governance slice produces to run §7 is **unchanged** from ADR 0025
§B.2: because there is no product code to find defects in, the §3 three-finder
correctness/tests/security package is **not required and not produced**. Its evidence
remains:

- the slice's **blind plan-eval verdict** (§B.2 item 2, unchanged); and
- a **distinct cold docs code-evaluator verdict** over the exact `base..head` candidate
  diff — a single fresh evaluator distinct from the planner and root; plus
- the standard §7 gate evidence and evaluator gate rerun: `scripts/check` run against
  the exact `head_sha` and rerun against a fresh copy.

Because a docs-governance slice may now touch files **inside the plugin directory**,
the cold docs code-evaluator is additionally **required to confirm explicitly**, in its
verdict, that:

0. the candidate diff **touches no behavior-bearing frontmatter field** of any
   `plugins/loom/**/*.md` file (per §3's categorical frontmatter carve-out). This is a
   **mandatory categorical rejection, not a judgment call**: if the diff modifies any
   `---`-delimited frontmatter field — `model`, `tools`/`allowed-tools`, `name`,
   `description`, `color`, `argument-hint`, or any other field a loader/validator
   consumes as data or that selects a model tier, tool permission, agent identity, or
   routing — the evaluator **MUST return FAIL**, because such a change is code-bearing and
   outside the docs-governance class by rule;
1. the candidate diff contains **no behavior or executable change** — every changed
   file is pure prompt/instruction/documentation content per the §3 boundary, and no
   change alters runtime or gate behavior (this is the mechanism that polices the §3
   boundary); and
2. the plugin-metadata validator **`scripts/validate-repository.mjs` still passes** on
   the candidate — since plugin-directory edits can affect thin-adapter/frontmatter
   validation (e.g. an agent or skill frontmatter field), the evaluator confirms the
   validator (run by `scripts/check`) is green at `head_sha`.

**Frontmatter remaining schema-valid is explicitly NOT sufficient evidence of no
behavior change.** `scripts/validate-repository.mjs` accepts a changed `model` (any of
its allowed tiers) or a changed `tools` value as still-schema-valid, so confirmation 2 is
only a **structural backstop** — it does not and cannot certify that frontmatter behavior
is unchanged. Confirmation 0 (the categorical frontmatter rejection) and confirmation 1
(the semantic no-behavior-change judgment over the exact `base..head` diff) are the real
gate; a green validator alone never satisfies them.

If any confirmation fails, the candidate is not a docs-governance slice and the
evaluator returns FAIL. The cold docs code-evaluator remains the sole PASS/FAIL
authority; the root, planner, and owner cannot manufacture a PASS.

### 5. Self-bootstrap — identical pattern to ADR 0025, recording a capability change

This ADR **cannot have been published under a rule it broadens**. Its landing path is
the same shape ADR 0025 §B.4 and ADR 0024 §2 used:

1. The planner commits this ADR and its ADR-index entry at `Status: Plan Review`.
2. A **fresh cold plan evaluator**, distinct from the planner and root, evaluates it
   under ADR 0023's bootstrap controls, labeled `bootstrap-ratification: degraded`
   (this narrowly extends ADR 0023 §1's plan-evaluation eligibility to cover exactly
   this ADR, the same one-time extension ADRs 0024 and 0025 took for themselves).
3. **Explicit owner acceptance** under spec 03's owner-gate authority. Evaluator PASS is
   necessary but insufficient; absent either the cold plan-eval or owner acceptance,
   this ADR stays at Plan Review and the broadening does not take effect.
4. Owner acceptance is effective at first for one purpose only: authorizing the single
   §6 ledger successor described below.
5. Once that successor is pushed and freshly re-verified, the broadened allowlist is
   active. The accepted ADR 0026 document (its `Status: Accepted` transition and the
   honest ADR-index/README updates) then reaches `origin/main` **as the payload of a
   docs-governance §7 slice under the now-broadened class** — no direct bootstrap commit
   to `main` is required.

**The ledger successor records a capability change, not a new token.** This is the one
material difference from ADR 0025's successor, and it must be represented precisely:

- The class token `docs-governance/v1` is **already present** in the transition state's
  `allowed_slices` (added by ADR 0025's §B.1 successor, recorded on the ledger — at the
  time of writing at sequence 12). It is **NOT re-added.** This amendment records a
  **capability change to the existing class definition**, not a new class token.
- The successor is one ordinary fast-forward child of the **freshly read and verified
  current transition tip** (the root reads the live protected ref, validates its
  complete ADR-0023/0024/0025 history, and binds that exact tip as predecessor; this ADR
  deliberately hardcodes no tip SHA, which would be stale). It increments the sequence
  by one, repeats every immutable prior program/configuration field and every prior
  `authority_amendments` entry byte-for-byte, and adds exactly one new
  `authority_amendments` entry identified `adr-0026-plugin-prompt-doc-scope/v1`.
- That entry binds: this accepted ADR's commit and blob IDs; the cold plan-eval verdict
  and package hashes; the owner-acceptance record hash; and the predecessor state SHA.
  It records the amendment as a **class-definition change**: the
  `docs-governance/v1` path capability broadens from ADR 0025 §B.2's allowlist to §2 of
  this ADR. Crucially, `allowed_slices_before` and `allowed_slices_after` are recorded
  as **UNCHANGED** (`allowed_slices_after == allowed_slices_before`) — no token is added
  or removed. The change lives entirely in the class **definition** the entry describes,
  not in the membership set. This distinguishes it from ADR 0024's and ADR 0025's
  successors, which each recorded a non-empty set delta.

All ADR 0023 §6 append-only, create-only/fast-forward, no-force protocol applies to
this successor unchanged; it advances the separate transition branch, never `main`, and
is therefore not a direct-push-to-`main` bypass of ADR 0025 §B.

## Consequences

- **Future playbook and prompt-documentation fixes become lightweight docs-governance
  slices.** Non-executable Markdown under `plugins/loom/` (role/agent/skill/command
  bodies, references) now has a lawful, auditable §7 lane — each concrete slice still
  individually planned, blind-evaluated, path-confined, gated, and settled — instead of
  requiring an accepted code-bearing slice per prompt fix. The immediate beneficiary is
  the deferred remediation-3 playbook-conformance work.
- **The boundary-policing burden shifts to the docs code-eval's no-behavior-change
  confirmation (§4).** Because the class now reaches inside the plugin directory, the
  guarantee that "docs-governance never ships behavior" is no longer enforced by a
  directory boundary alone; it is enforced by the cold docs code-evaluator's explicit
  confirmation that the diff is pure documentation and that
  `scripts/validate-repository.mjs` still passes. This is a deliberate trade: a slightly
  heavier evaluator obligation in exchange for a broad, correct capability.
- **Narrowly supersedes ADR 0025 §B.2 item 3's path allowlist only.** Every other clause
  of ADR 0025 — Decision A, the no-bypass rule, the `docs-governance/v1` class and its
  persistent-token mechanics, the §6-successor pattern, the handover rule, self-bootstrap,
  and retroactive classification — stands unchanged and in force. All ADR 0023 machinery
  (exact-revision evidence, intent/settle ordering, fresh verification, receipts,
  retirement, fail-closed recovery, terminal sunset) and ADR 0020's remote-publication
  authority remain the success boundary.
- **No new class token; the closed-list safety of ADR 0023 §6 is preserved.** The ledger
  successor records a capability amendment with `allowed_slices` unchanged, so the set
  never grows and no product-code slice can ride the docs lane.
- **Deferred, named only:** the remediation-3 playbook-conformance edits themselves. This
  ADR authorizes the path; those edits are planned, evaluated, and landed as
  docs-governance §7 slices under the broadened class in a later step, which also carries
  this accepted ADR to `main`.

## Notes — History

- **2026-07-25, round-0 revision (pre-acceptance, Status still Plan Review).** Blind
  ratification round 0 returned PASS with two MINORs
  (`.docs/evaluations/0026-docs-governance-plugin-prompt-doc-scope-eval.md`); the owner
  directed folding the boundary-tightening MINOR in before acceptance (ADRs immutable once
  accepted). Folded: MINOR 1 — behavior-bearing frontmatter is now carved **categorically
  out of class** (§2 in-class = prose body only; §3 frontmatter carve-out as a bright-line
  rule; §4 confirmation 0 requires the docs code-eval to FAIL on any behavior-bearing
  frontmatter edit, and states that schema-valid frontmatter is not sufficient evidence of
  no behavior change). All other round-0-sound content is unchanged (narrow supersession of
  0025 §B.2 path allowlist only; broadened body-prose scope; preserved executable/test/schema
  exclusions; capability-not-token ledger successor with `allowed_slices` UNCHANGED;
  self-bootstrap). MINOR 2 (the "sequence 12 off-by-one") was a **stale read** and is a
  non-issue: the live ledger is verified at sequence 12 (settlement landed — recon settled,
  phase active, token persists); the §Context/§5 seq-12 reference is correct and unchanged.
