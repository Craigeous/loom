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
- `plugins/loom/adapters/fixtures/v0.2.0/dogfood/macos-arm64.json`
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
- `plugins/loom/bin/loom-launch-role`
- `plugins/loom/bin/loom-launch-role.bats`
- `plugins/loom/hooks/hooks.json`
- `plugins/loom/hooks/git-identity-guard.sh`
- `plugins/loom/hooks/git-identity-guard.bats`
- `plugins/loom/hooks/precompact-write-ahead-backstop.sh`
- `plugins/loom/hooks/precompact-write-ahead-backstop.bats`
- `plugins/loom/schemas/loom-hook-wire-fixture-v1.schema.json`
- `plugins/loom/schemas/loom-role-launch-v1.schema.json`
- `plugins/loom/schemas/loom-dogfood-state-v1.schema.json`
- `plugins/loom/schemas/loom-dogfood-evidence-v1.schema.json`

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
- `.docs/evaluations/macos-dual-client-dogfood-plan-eval.md`
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
client transcripts, guarded dogfood cleanup receipts below
`.git/loom/dogfood/receipts/`, and the publication receipt remain untracked.

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
5. Split hook policy from wire output at the executable boundary while retaining the
   one required physical manifest, `hooks/hooks.json`, for both clients. Its command
   resolves the hook executable from `${PLUGIN_ROOT:-${CLAUDE_PLUGIN_ROOT:-}}` only
   inside the hook process; an empty root fails closed. The executable selects Codex
   wire behavior only when `PLUGIN_ROOT` is a validated physical plugin root and
   otherwise selects Claude only when `CLAUDE_PLUGIN_ROOT` validates. Claude retains
   exit-2/stderr blocking; Codex uses exit 0 and the exact JSON envelopes in spec 08.
   Both accept current `trigger`; malformed, missing, wrong-typed, unknown, ambiguous-
   client, and mismatched-root inputs fail closed. Make PreCompact state per validated
   session, atomic, bounded, and injection-safe. Generate and byte-test all 48
   versioned fixture files. The Codex manifest binds exactly `./hooks/hooks.json`;
   there is no second client-specific hook manifest.
6. Add `loom-launch-role` as the sole client role launcher. It reads the exact role to
   profile to client mapping from the versioned compatibility matrix and never accepts
   a caller-supplied vendor selector. For every Claude launch it emits the exact native
   tier and omits the Agent capability. For every Codex launch it executes a fresh
   `codex exec --ephemeral --ignore-user-config --strict-config --disable multi_agent`
   child with exact `--model`, exact `-c model_reasoning_effort=<value>`, read-only
   sandbox, no web search, the canonical contract, and a closed bounded-output schema.
   It captures normalized effective launch configuration and client run metadata and
   rejects a missing, unavailable, renamed, inherited, or substituted model/effort,
   an enabled delegation feature, or a descendant-launch attempt. Deterministic tests
   inspect effective configuration for Economy, Standard, and Deep review, all five
   roles, both clients, cold IDs, one-level permissions, and each negative condition;
   dogfood still performs one real cold role launch per client.
7. Update Codex manifest/catalog, compatibility/root-binding metadata, pinned schemas,
   and release-owned fixtures only as required by the implemented surfaces. Validate
   exactly eight workflow skill names, five role mappings, the one shared hook manifest,
   and both root contracts while retaining version 0.2.0 and the full release matrix.
8. Add a fail-closed macOS dogfood harness with `--prepare`, `--exercise`, `--uninstall`,
   and `--clean` phases plus a unit-testable dry fixture mode. The versioned macOS-arm64
   fixture pins floor versions, native argv, environment redirects, allowed roots, and
   expected cache layout. `--prepare` creates a unique `mktemp -d` run below the
   canonical system temporary directory, rejects symlinks/owner-home overlap, writes a
   random owner marker plus schema-valid `state.json`, and creates separate Claude,
   Codex, project, system-home, and temporary roots. Every phase validates the marker,
   physical containment, exact candidate, current status, pre-inventory, and previous
   evidence hash before work. Each native mutation is a numbered substep with states
   `idle`, `intended`, `launched`, `released`, and `applied`. Before launch, one atomic
   write-ahead record binds
   the argv hash, client, semantic pre/postconditions, allowed physical mutation roots,
   random run/substep token, handshake deadline, and complete pre-inventory hash.

   The harness then spawns its own marker-bound mutation-wrapper mode, passing only the
   owned control directory and token. The wrapper's first action is an exclusive atomic
   `hello` containing that token, PID, OS process birth/start discriminator, and wrapper
   executable hash; it then waits and cannot exec the native client. The parent verifies
   `hello` against the physical wrapper, process table, token, and still-current intent,
   atomically persists `launched` with the non-reusable identity, atomically persists
   `released`, and only then creates a token-bound release record. The wrapper re-reads
   and validates `released`, its exact identity, and the release record before exec.
   It writes an atomic terminal result with native exit and bounded output hashes. Thus
   no native mutation can begin before its discoverable identity is durable.

   After native exit, the harness
   inventories first, validates the semantic postcondition and allowed-root-only diff,
   then atomically records command status, output hash, post-inventory/evidence hashes,
   and `applied` before advancing. It never treats phase state alone as proof.

   Resume is permitted only for the same marker/schema/candidate/phase/substep and
   reconciles mechanically. An `intended` substep never immediately reruns: until its
   recorded handshake deadline, resume scans the owned hello/control record and exact
   wrapper-path plus token process identity and exits 3 while either may still appear.
   A wrapper without durable release times out, atomically records
   `aborted-before-release`, and exits without mutation. Only after the deadline, a
   valid terminal abort, positive proof that no token-bound wrapper/client identity is
   live, absence of release, and an exact pre-inventory match may resume reset to
   `intended` and spawn once. `launched` resumes by validating the blocked identity and
   committing/reissuing `released`; `released` never relaunches and waits for the exact
   process or terminal result. A stopped process plus satisfied postcondition and a
   diff wholly inside the
   declared roots records a `recovered-after-apply` result from the current inventory
   without rerunning; a dead released process without a valid terminal result, any
   other inventory, or any live/reused/unverifiable process identity atomically
   enters `quarantined` and exits 3. An interruption before intent leaves `idle`; after
   `applied` it advances normally. Signal tests require 130 for INT and 143 for TERM;
   the next invocation returns 0 only after one of the two valid reconciliations, while
   partial/ambiguous mutation returns 3 with the pre/current hashes, handshake records,
   process proof, and reason recorded.
   The state schema admits `recovery-required` and `quarantined` in addition to normal
   phase states, so no retry depends on an inventory a command may already have changed.

   Product/plugin cleanup uses only the pinned native uninstall and marketplace-remove
   commands. `--clean <absolute-run>` is the only recursive cleanup. It refuses a
   missing/wrong marker, symlink, path outside the temporary prefix, owner-home overlap,
   live or unverifiable token-bound wrapper/client process, unexpired handshake, or
   incomplete inventory. A quarantined run is cleanable only
   after a fresh complete inventory proves every path is marker-owned and physically
   contained; before deletion, the harness atomically writes a canonical quarantine
   receipt with final inventory/evidence hashes to the documented untracked
   `.git/loom/dogfood/receipts/<run-id>.json`. Normal cleanup likewise requires a
   completed uninstall/residue check and receipt. Tests inject interruption before
   intent, after intent, during mutation, after native exit, after inventory, and after
   `applied` for every marketplace/install/remove operation and assert those exact
   state, exit, reconciliation, evidence, and cleanup outcomes. The injected points
   include before spawn, after spawn before `hello`, after `hello` before durable
   identity, after `launched` before `released`, after `released` before release-record
   creation, and after release before native exec; each test proves the wrapper cannot
   mutate early, resume never duplicates a live/unverifiable substep, and cleanup waits
   for positive process-death proof.
9. Exercise each client from that harness with `HOME`, `CLAUDE_CONFIG_DIR`,
   `CODEX_HOME`, and `TMPDIR` redirected to owned roots as applicable. Run the exact
   floor-version marketplace add, install, second install/reinstall, list/discovery,
   one explicit read-only workflow inside and outside the project, one real cold role,
   hook/trust observation, and installed-root helper probes, followed by uninstall,
   marketplace removal, and zero-discovery/residue checks. Canonical inventories use
   sorted physical relative paths, types, modes, sizes, and file SHA-256 values. Tests
   cover escape, missing/wrong ownership, owner-home access, partial/interrupted state,
   retry, stale candidate, unexpected residue, failed native cleanup, and forbidden
   recursive cleanup without ever touching the owner's real configuration.

   The fixture expands only placeholders and pins these native state-changing
   sequences at the recorded floors. Claude runs `claude plugin marketplace add
   $REPO_ROOT --scope user`, `claude plugin install loom@loom --scope user`,
   `claude plugin list --json`, `claude plugin uninstall loom@loom --scope user -y`,
   the same install/list pair as the reinstall, then final uninstall and `claude plugin
   marketplace remove loom`. Codex runs `codex plugin marketplace add $REPO_ROOT
   --json`, `codex plugin add loom@loom --json`, `codex plugin list`, `codex plugin
   remove loom@loom --json`, the same add/list pair as the reinstall, then final remove
   and `codex plugin marketplace remove loom --json`. Each removal is followed by
   native discovery and physical inventory checks before the next phase; an unexpected
   prompt, selector, cache root, marketplace name, or floor-version drift fails closed.
10. Write evidence conforming to `loom-dogfood-evidence/v1` as UTF-8 canonical compact
   JSON (`jq -S -c` plus one LF) and hash those exact bytes. It binds candidate SHA/tree,
   harness/fixture/schema hashes, commands and exits, versions, redacted physical roots,
   fixture/output hashes, bounded role returns, delegation probes, trust result, and
   pre/post inventories. Replace the run and repository prefixes with `$RUN_ROOT` and
   `$REPO_ROOT`, retain no raw transcripts or credentials, reject secret-shaped fields,
   and bound every captured string. States are `prepared`, `installed`, `exercised`,
   `uninstalled`, `complete`, `recovery-required`, `quarantined`,
   `infrastructure-blocked`, or `failed`; stable exits are 0 success, 2 usage, 3 unsafe
   target/state or quarantined partial mutation, 4 infrastructure block, 5 product
   failure, 6 residue, 130 interrupted by INT, and 143 interrupted by TERM. A usage
   limit, missing trust path, or unavailable required model is
   `infrastructure-blocked`, not PASS and not a merits round.
11. Run three cold advisory finders (correctness, tests, security) on one sealed exact
   package, assemble their results, then route the aggregate plus full gate/evidence to
   a distinct cold code evaluator. Only its PASS authorizes finalization.
12. On PASS, archive the plan; synchronize README, CLAUDE, AGENTS, evaluation index,
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
   concurrent sessions, interrupted writes, log injection/cap, ambiguous/mismatched
   client roots, empty roots, and both client wire envelopes. Static validation proves
   the Codex manifest references only exact `./hooks/hooks.json`.
5. `loom-launch-role.bats` exercises all five roles and three profiles for both clients,
   compares normalized effective launch configuration to the versioned matrix, and
   rejects missing/unavailable/substituted model or effort, inheritance, non-cold IDs,
   enabled delegation, descendant launch, unbounded output, and role/profile drift.
6. Harness dry-fixture tests prove marker/schema/physical-root ownership, canonical
   inventories and hashes, owner-home isolation, atomic phase transitions, safe retry,
   redaction and secret rejection, stable exits/states, residue detection, native-only
   uninstall, and fail-closed cleanup for escape, symlink, partial, stale, or wrong-
   ownership inputs.
7. From fresh isolated homes, run the fixture-pinned native marketplace add, plugin
   install, second
   install/reinstall, list/discovery, one explicit read-only workflow inside/outside,
   one real cold role launch, hook/trust observation, helper-root probe, uninstall,
   marketplace removal, and post-inventory for each client. Recompute evidence hashes
   from the exact installed cached roots; source-tree success is insufficient.
8. The evidence must show Darwin `arm64`, exact client floors, identical intended
   project root inside/outside, no writes beyond isolated roots/documented caches,
   bounded role returns, child delegation denied, exact helper containment, and zero
   remaining Loom discovery after uninstall. Any missing required proof blocks PASS.
9. Immediately before intent, freshly verify protected transition ancestry/rules/tip,
   active phase, this slice allowed, no unsettled conflicting intent, required
   components available, prior settled results contained in fresh remote `main`, exact
   base, immutable ADR-0024 authority, candidate/evidence hashes, and held claim.

## Notes

- 2026-07-23: Cold plan evaluation round 0 failed on the shared hook path, enforceable
  Codex launch configuration, and destructive-harness evidence controls. This revision
  resolved the hook and launch findings. Reevaluation retained one harness-recovery
  MAJOR; the current revision adds write-ahead substeps, deterministic reconciliation,
  quarantine, a token-bound pre-exec process-identity handshake, and narrowly validated
  cleanup and returns the same merits round.
- 2026-07-23: Isolated baseline installs succeeded for both clients. Codex installed
  to `<CODEX_HOME>/plugins/cache/loom/loom/0.2.0` but exposed only `loom-playbook`.
- 2026-07-23: The OpenAI manual helper could not run because the host Homebrew Node
  binary referenced a missing `libllhttp.9.3.dylib`; official Docs MCP supplied the
  current plugin/skills/hooks contracts instead. This host tooling fault is outside
  the product and does not affect the planned client-floor tests.
