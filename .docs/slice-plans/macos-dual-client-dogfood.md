# Apple-silicon Claude Code + Codex dogfood

Status: Plan Review
Target specs: [02-roles.md](../spec/02-roles.md),
[06-init-modes.md](../spec/06-init-modes.md),
[07-command-surface.md](../spec/07-command-surface.md),
[08-playbook.md](../spec/08-playbook.md), and
[10-packaging.md](../spec/10-packaging.md)
Authority: [ADR 0024](../ADR/0024-macos-first-dual-client-dogfood-bootstrap-amendment.md)
Improvement slice: `macos-dual-client-dogfood`

## Context

The documentation amendment is settled on remote `main` at `a3cb007`. On the
owner's Darwin `arm64` host, isolated baseline runs prove that Claude Code 2.1.216
and Codex CLI 0.144.6 can each add the local marketplace and install Loom 0.2.0.
The installed Codex copy exposes only `loom-playbook`; it does not yet implement the
eight `$loom-*` workflows, the five Codex role mappings, Codex-specific hook output,
or the installed-skill helper-root bootstrap required by the approved specs.

This code-bearing slice supplies only the minimum shared-core/thin-adapter behavior
and repeatable private evidence authorized by ADR 0024. It does not implement M1
coordinator safety, M2 remote landing, M4 production local review, M5 evaluation
isolation, `loom doctor`, a public marketplace release, a tag, Linux/macOS-Intel
execution, or public Codex support.

Official Codex 0.144.6 documentation confirms that plugin skills live at
`skills/<name>/SKILL.md`, plugin hooks may use a separate manifest path and receive
`PLUGIN_ROOT`, installing a plugin does not trust its hooks automatically, and local
marketplaces install a cached copy rather than executing the source tree directly.
The implementation and dogfood harness must test those installed-copy semantics.

## Exact path boundary

Only these product, test, evidence, and finalization paths may change.

### Metadata and installed-root contracts

- `.agents/plugins/marketplace.json`
- `plugins/loom/.codex-plugin/plugin.json`
- `plugins/loom/adapters/compatibility/v0.2.0.json`
- `plugins/loom/adapters/fixtures/v0.2.0/metadata/codex-manifest.json`
- `plugins/loom/adapters/fixtures/v0.2.0/metadata/codex-marketplace.json`
- `plugins/loom/adapters/fixtures/v0.2.0/metadata/compatibility.json`
- `plugins/loom/adapters/fixtures/v0.2.0/metadata/codex-root.json`
- `plugins/loom/adapters/roots/codex-skill-source-v1.json`
- `plugins/loom/schemas/loom-compatibility-matrix-v1.schema.json`
- `plugins/loom/schemas/loom-installed-root-binding-v1.schema.json`
- `scripts/schemas/codex-plugin-0.144.6.schema.json`
- `scripts/schemas/codex-marketplace-0.144.6.schema.json`

### Shared workflows and thin Claude command adapters

- `plugins/loom/skills/loom-run/SKILL.md`
- `plugins/loom/skills/loom-research/SKILL.md`
- `plugins/loom/skills/loom-plan/SKILL.md`
- `plugins/loom/skills/loom-eval-plan/SKILL.md`
- `plugins/loom/skills/loom-develop/SKILL.md`
- `plugins/loom/skills/loom-eval-code/SKILL.md`
- `plugins/loom/skills/loom-status/SKILL.md`
- `plugins/loom/skills/loom-init/SKILL.md`
- `plugins/loom/skills/loom-playbook/SKILL.md`
- `plugins/loom/commands/run.md`
- `plugins/loom/commands/research.md`
- `plugins/loom/commands/plan.md`
- `plugins/loom/commands/eval-plan.md`
- `plugins/loom/commands/develop.md`
- `plugins/loom/commands/eval-code.md`
- `plugins/loom/commands/status.md`
- `plugins/loom/commands/init.md`

### Shared role contracts and client adapters

- `plugins/loom/roles/researcher.md`
- `plugins/loom/roles/planner.md`
- `plugins/loom/roles/plan-evaluator.md`
- `plugins/loom/roles/developer.md`
- `plugins/loom/roles/code-evaluator.md`
- `plugins/loom/skills/loom-researcher/SKILL.md`
- `plugins/loom/skills/loom-planner/SKILL.md`
- `plugins/loom/skills/loom-plan-evaluator/SKILL.md`
- `plugins/loom/skills/loom-developer/SKILL.md`
- `plugins/loom/skills/loom-code-evaluator/SKILL.md`
- `plugins/loom/agents/researcher.md`
- `plugins/loom/agents/planner.md`
- `plugins/loom/agents/plan-evaluator.md`
- `plugins/loom/agents/developer.md`
- `plugins/loom/agents/code-evaluator.md`

### Helper-root and hook implementation

- `plugins/loom/bin/loom-resolve-helper`
- `plugins/loom/bin/loom-resolve-helper.bats`
- `plugins/loom/hooks/hooks.json`
- `plugins/loom/hooks/codex-hooks.json`
- `plugins/loom/hooks/git-identity-guard.sh`
- `plugins/loom/hooks/git-identity-guard.bats`
- `plugins/loom/hooks/precompact-write-ahead-backstop.sh`
- `plugins/loom/hooks/precompact-write-ahead-backstop.bats`
- `plugins/loom/schemas/loom-hook-wire-fixture-v1.schema.json`

The hook-wire fixture set is exactly the Cartesian product of clients `claude` and
`codex`, events `pre-tool-use` and `pre-compact`, cases `allow`, `block`, and
`malformed`, and suffixes `input.json`, `stdout`, `stderr`, and `exit`, rooted at
`plugins/loom/hooks/fixtures/hook-wire-v1/`. Its 48 literal paths are:

- `plugins/loom/hooks/fixtures/hook-wire-v1/claude/pre-tool-use/allow.input.json`
- `plugins/loom/hooks/fixtures/hook-wire-v1/claude/pre-tool-use/allow.stdout`
- `plugins/loom/hooks/fixtures/hook-wire-v1/claude/pre-tool-use/allow.stderr`
- `plugins/loom/hooks/fixtures/hook-wire-v1/claude/pre-tool-use/allow.exit`
- `plugins/loom/hooks/fixtures/hook-wire-v1/claude/pre-tool-use/block.input.json`
- `plugins/loom/hooks/fixtures/hook-wire-v1/claude/pre-tool-use/block.stdout`
- `plugins/loom/hooks/fixtures/hook-wire-v1/claude/pre-tool-use/block.stderr`
- `plugins/loom/hooks/fixtures/hook-wire-v1/claude/pre-tool-use/block.exit`
- `plugins/loom/hooks/fixtures/hook-wire-v1/claude/pre-tool-use/malformed.input.json`
- `plugins/loom/hooks/fixtures/hook-wire-v1/claude/pre-tool-use/malformed.stdout`
- `plugins/loom/hooks/fixtures/hook-wire-v1/claude/pre-tool-use/malformed.stderr`
- `plugins/loom/hooks/fixtures/hook-wire-v1/claude/pre-tool-use/malformed.exit`
- `plugins/loom/hooks/fixtures/hook-wire-v1/claude/pre-compact/allow.input.json`
- `plugins/loom/hooks/fixtures/hook-wire-v1/claude/pre-compact/allow.stdout`
- `plugins/loom/hooks/fixtures/hook-wire-v1/claude/pre-compact/allow.stderr`
- `plugins/loom/hooks/fixtures/hook-wire-v1/claude/pre-compact/allow.exit`
- `plugins/loom/hooks/fixtures/hook-wire-v1/claude/pre-compact/block.input.json`
- `plugins/loom/hooks/fixtures/hook-wire-v1/claude/pre-compact/block.stdout`
- `plugins/loom/hooks/fixtures/hook-wire-v1/claude/pre-compact/block.stderr`
- `plugins/loom/hooks/fixtures/hook-wire-v1/claude/pre-compact/block.exit`
- `plugins/loom/hooks/fixtures/hook-wire-v1/claude/pre-compact/malformed.input.json`
- `plugins/loom/hooks/fixtures/hook-wire-v1/claude/pre-compact/malformed.stdout`
- `plugins/loom/hooks/fixtures/hook-wire-v1/claude/pre-compact/malformed.stderr`
- `plugins/loom/hooks/fixtures/hook-wire-v1/claude/pre-compact/malformed.exit`
- `plugins/loom/hooks/fixtures/hook-wire-v1/codex/pre-tool-use/allow.input.json`
- `plugins/loom/hooks/fixtures/hook-wire-v1/codex/pre-tool-use/allow.stdout`
- `plugins/loom/hooks/fixtures/hook-wire-v1/codex/pre-tool-use/allow.stderr`
- `plugins/loom/hooks/fixtures/hook-wire-v1/codex/pre-tool-use/allow.exit`
- `plugins/loom/hooks/fixtures/hook-wire-v1/codex/pre-tool-use/block.input.json`
- `plugins/loom/hooks/fixtures/hook-wire-v1/codex/pre-tool-use/block.stdout`
- `plugins/loom/hooks/fixtures/hook-wire-v1/codex/pre-tool-use/block.stderr`
- `plugins/loom/hooks/fixtures/hook-wire-v1/codex/pre-tool-use/block.exit`
- `plugins/loom/hooks/fixtures/hook-wire-v1/codex/pre-tool-use/malformed.input.json`
- `plugins/loom/hooks/fixtures/hook-wire-v1/codex/pre-tool-use/malformed.stdout`
- `plugins/loom/hooks/fixtures/hook-wire-v1/codex/pre-tool-use/malformed.stderr`
- `plugins/loom/hooks/fixtures/hook-wire-v1/codex/pre-tool-use/malformed.exit`
- `plugins/loom/hooks/fixtures/hook-wire-v1/codex/pre-compact/allow.input.json`
- `plugins/loom/hooks/fixtures/hook-wire-v1/codex/pre-compact/allow.stdout`
- `plugins/loom/hooks/fixtures/hook-wire-v1/codex/pre-compact/allow.stderr`
- `plugins/loom/hooks/fixtures/hook-wire-v1/codex/pre-compact/allow.exit`
- `plugins/loom/hooks/fixtures/hook-wire-v1/codex/pre-compact/block.input.json`
- `plugins/loom/hooks/fixtures/hook-wire-v1/codex/pre-compact/block.stdout`
- `plugins/loom/hooks/fixtures/hook-wire-v1/codex/pre-compact/block.stderr`
- `plugins/loom/hooks/fixtures/hook-wire-v1/codex/pre-compact/block.exit`
- `plugins/loom/hooks/fixtures/hook-wire-v1/codex/pre-compact/malformed.input.json`
- `plugins/loom/hooks/fixtures/hook-wire-v1/codex/pre-compact/malformed.stdout`
- `plugins/loom/hooks/fixtures/hook-wire-v1/codex/pre-compact/malformed.stderr`
- `plugins/loom/hooks/fixtures/hook-wire-v1/codex/pre-compact/malformed.exit`

### Repository checks, private evidence, and documentation

- `scripts/validate-repository.mjs`
- `scripts/tests/repository-validation.bats`
- `scripts/macos-dual-client-dogfood`
- `scripts/tests/macos-dual-client-dogfood.bats`
- `.docs/evaluations/macos-dual-client-dogfood-evidence.json`
- `.docs/evaluations/macos-dual-client-dogfood-review-findings.md`
- `.docs/evaluations/macos-dual-client-dogfood-eval.md`
- `.docs/evaluations/README.md`
- `.docs/slice-plans/macos-dual-client-dogfood.md`
- `.docs/slice-plans/archive/macos-dual-client-dogfood.md`
- `.docs/slice-plans/README.md`
- `.docs/status/roadmap.md`
- `.docs/status/progress.md`
- `.docs/status/handoff.md`
- `README.md`
- `CLAUDE.md`
- `AGENTS.md`

All specs, ADRs, M1+ product work, CI/release files, existing coordination behavior,
and any path not listed above are forbidden. Generated caches, disposable homes, raw
client transcripts, and the publication receipt remain untracked.

## Steps

1. Record the exact Darwin/arm64, Bash/Git/jq, Claude 2.1.216, and Codex 0.144.6
   baseline. Keep all client and project homes disposable and inventory-tracked.
2. Move each workflow body into the matching `loom-*` Agent Skill. Reduce every
   Claude `commands/*.md` file to frontmatter plus a thin route to the shared skill.
   The shared skills use client-neutral lifecycle policy and explicit installed-root
   bootstrap; only adapters contain invocation syntax and launch mechanics.
3. Move each lifecycle role body into one canonical `roles/*.md` contract. Reduce
   Claude `agents/*.md` to native frontmatter plus a pointer to that contract. Add
   five thin Codex role skills that load the same contracts, state the exact profile,
   require a fresh one-level child, forbid delegation, and preserve the bounded return.
   Workflow skills launch only through the client's root orchestrator.
4. Add `loom-resolve-helper`, supporting only the two versioned root bindings and an
   allowlisted helper. Claude validates the physical injected plugin root. Codex
   validates an absolute selected `skills/<skill>/SKILL.md`, exact suffix and
   frontmatter identity, `../..` physical ascent, manifest name/version, direct-child
   helper containment, regular executable type, and symlink escape rejection before
   executing by absolute path. Never use bare `PATH`, `CODEX_HOME`, or a Claude-only
   variable for Codex workflow correctness.
5. Split hook policy from wire output at the executable boundary. Claude retains
   exit-2/stderr blocking. Codex uses `codex-hooks.json`, `${PLUGIN_ROOT}`, exit 0,
   and the exact JSON envelopes in spec 08. Both accept current `trigger`; malformed,
   missing, wrong-typed, or unknown inputs fail closed. Make PreCompact state
   per validated session, atomic, bounded, and injection-safe. Generate and byte-test
   all 48 versioned fixture files.
6. Update Codex manifest/catalog, compatibility/root-binding metadata, pinned schemas,
   and release-owned fixtures only as required by the implemented surfaces. Validate
   exactly eight workflow skill names, five role mappings, two hook manifests, and
   both root contracts while retaining version 0.2.0 and the full release matrix.
7. Add a fail-closed macOS dogfood harness with `--prepare`, `--exercise`, and
   `--uninstall` phases plus a unit-testable dry fixture mode. It creates fresh Claude,
   Codex, and project homes; inventories before/after paths; installs and reinstalls
   the exact committed plugin through each native marketplace flow; discovers all
   mappings; explicitly invokes a read-only workflow inside and outside the project;
   launches one real cold non-delegating role per client; runs hook fixtures and
   installed-root helper probes; records honest Codex hook trust/activation; and
   removes plugin/marketplace state without touching owner configuration.
8. Write the sanitized evidence JSON with exact candidate SHA/tree, commands, exits,
   versions, physical installed roots, fixture/output hashes, bounded role returns,
   delegation probes, trust result, and filesystem inventories. A client usage limit,
   missing trust path, or unavailable required model is `infrastructure-blocked`, not
   PASS and not a merits round.
9. Run three cold advisory finders (correctness, tests, security) on one sealed exact
   package, assemble their results, then route the aggregate plus full gate/evidence to
   a distinct cold code evaluator. Only its PASS authorizes finalization.
10. On PASS, archive the plan; synchronize README, CLAUDE, AGENTS, evaluation index,
    and living status to say private Apple-silicon dogfood-ready without claiming a
    public release or reducing Linux/Intel obligations. Publish only through the
    protected ADR-0023 intent/receipt/settlement sequence.

## Verification

1. `scripts/check` passes at the exact candidate under system Bash 3.2 and current
   Bash 5.x with `LOOM_DIFF_BASE=a3cb007`; plugin-creator's `validate_plugin.py`
   passes the plugin root; Claude strict validation passes.
2. Metadata validation parses the installed copy and proves the exact workflow set
   `run,research,plan,eval-plan,develop,eval-code,status,init`, exact role set
   `researcher,planner,plan-evaluator,developer,code-evaluator`, thin Claude adapters,
   canonical shared bodies, and no duplicate names or copied workflow/role bodies.
3. `loom-resolve-helper.bats` covers both success paths plus relative/missing source,
   wrong suffix/name/version, absent/non-executable helper, manifest/skill/helper
   symlink, physical escape, wrong direct child, forbidden environment-only guess,
   and invocation from unrelated working directories.
4. Hook Bats enumerate the exact fixture Cartesian product and byte-compare status,
   stdout, and stderr. Negative tests cover invalid JSON/types/trigger/reason/session,
   concurrent sessions, interrupted writes, log injection/cap, and both client wire
   envelopes.
5. From fresh isolated homes, run native marketplace add, plugin install, second
   install/reinstall, list/discovery, one explicit read-only workflow inside/outside,
   one real cold role launch, hook/trust observation, helper-root probe, uninstall,
   marketplace removal, and post-inventory for each client. Recompute evidence hashes
   from the exact installed cached roots; source-tree success is insufficient.
6. The evidence must show Darwin `arm64`, exact client floors, identical intended
   project root inside/outside, no writes beyond isolated roots/documented caches,
   bounded role returns, child delegation denied, exact helper containment, and zero
   remaining Loom discovery after uninstall. Any missing required proof blocks PASS.
7. Immediately before intent, freshly verify protected transition ancestry/rules/tip,
   active phase, this slice allowed, no unsettled conflicting intent, required
   components available, prior settled results contained in fresh remote `main`, exact
   base, immutable ADR-0024 authority, candidate/evidence hashes, and held claim.

## Notes

- 2026-07-23: Isolated baseline installs succeeded for both clients. Codex installed
  to `<CODEX_HOME>/plugins/cache/loom/loom/0.2.0` but exposed only `loom-playbook`.
- 2026-07-23: The OpenAI manual helper could not run because the host Homebrew Node
  binary referenced a missing `libllhttp.9.3.dylib`; official Docs MCP supplied the
  current plugin/skills/hooks contracts instead. This host tooling fault is outside
  the product and does not affect the planned client-floor tests.
