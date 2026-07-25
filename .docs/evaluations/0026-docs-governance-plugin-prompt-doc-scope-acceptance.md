# Owner acceptance: ADR 0026 — Broaden docs-governance/v1 to plugin prompt/doc markdown

Status: Accepted
Accepted-at: 2026-07-25
Accepted-by: owner (repository owner, spec 03 owner-acceptance authority)

## What is accepted

ADR `0026-docs-governance-plugin-prompt-doc-scope.md`, revised commit
`b2614ce731218cd2fb559d30deb687ffb4aa8e3b`
(blob `914090db014cb9462d16da9992c73e98fbc1d4c9`).

## Basis

- Cold blind plan-evaluation (`bootstrap-ratification: degraded`): PASS round 0
  with 2 MINOR, then a resolving PASS after the frontmatter carve-out (MINOR 1)
  was folded in; MINOR 2 was a stale-read non-issue (ledger verified seq 12) —
  recorded in `.docs/evaluations/0026-docs-governance-plugin-prompt-doc-scope-eval.md`
  (blob `56d74dfc61c9a8fafcf2627fb61355f4b9f56078`,
  SHA-256 `1b0e55bbb9f9d55a6886e71a7be3f19793eab84c30357b18d3996c47dda56e88`).
- The evaluation is advisory; this owner acceptance is dispositive per spec 03
  and ADR 0026's self-bootstrap clause.

## Decision accepted

ADR 0026 narrowly supersedes ADR 0025 §B.2's path allowlist ONLY. A
`docs-governance/v1` slice may now edit the **prose body** of non-executable
Markdown under `plugins/loom/**/*.md` (skills/roles/agents/commands/references),
in addition to `.docs/**` and root docs. Behavior-bearing YAML **frontmatter**
(`model`, `tools`/`allowed-tools`, `name`, `description`, `color`,
`argument-hint`, and any loader/validator-consumed or tier/permission/identity/
routing-selecting field) is categorically **out of class**; touching it makes a
slice code-bearing, and the docs code-eval MUST FAIL on any such change
(schema-validity is explicitly insufficient evidence). All executable/test/
schema/manifest exclusions and everything else in ADR 0025 stand unchanged.

The owner accepts the advisory residual (command-body loader-interpreted tokens
`$ARGUMENTS`/`${CLAUDE_PLUGIN_ROOT}`/`!`-exec are governed by the docs code-eval's
no-behavior-change confirmation rather than a categorical rule).

## Activation and landing

Per ADR 0026's self-bootstrap: this acceptance activates one §6 ledger successor
(`adr-0026-plugin-prompt-doc-scope/v1`) on `refs/loom/bootstrap-transition` — a
**capability** amendment that changes the `docs-governance/v1` class definition
with `allowed_slices` UNCHANGED (the token already persists at seq 12). It never
advances `main`. This acceptance record, the eval verdict, ADR 0026's
`Status: Accepted` flip, and the reliant playbook-conformance edits reach `main`
via a `docs-governance/v1` §7 slice under the broadened class.
