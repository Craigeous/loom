# Apple-silicon Claude Code + Codex dogfood

Status: Implemented
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
   evidence hash before work. Each native mutation is one hash-chained immutable atomic
   journal below its owned control directory, with records `intent`, `supervisor-hello`,
   `supervisor-launch`, `supervisor-release`, `native-hello`, `native-launch`,
   `native-release`, `terminal`, and `applied`. A record is the state transition and the
   release capability; there is no second release file or mutable-state/file ordering
   window. `intent` binds argv hash, client, semantic pre/postconditions, allowed
   physical mutation roots, random run/substep token, handshake deadline, and complete
   pre-inventory hash.

   The harness spawns its marker-bound supervisor mode in a new process group. Before
   doing anything else, the supervisor atomically creates `supervisor-hello` with the
   token, PID, process-group ID, OS birth/start discriminator, and physical executable
   hash, then blocks. The parent verifies that identity and atomically creates
   `supervisor-launch` and `supervisor-release`. Only that single release record permits
   the supervisor to continue. It forks a native worker in the same group; the worker
   atomically creates `native-hello` with its own PID/birth identity and blocks. The
   supervisor verifies it and atomically writes `native-launch` and `native-release`.
   Only that native-release record permits the worker to `exec` the pinned client,
   preserving the already durable worker PID/birth identity across process replacement.
   The supervisor retains its own durable identity, waits for the worker, and writes the
   atomic `terminal` record with native exit and bounded output hashes. The token is
   present in every record, process argv/environment, and descendant scan. Native
   mutation is therefore impossible before both supervisor and mutating-worker
   identities are durable, while a separate durable supervisor remains able to record
   termination.

   After native exit, the harness
   inventories first, validates the semantic postcondition and allowed-root-only diff,
   then atomically records command status, output hash, post-inventory/evidence hashes,
   and `applied` before advancing. It never treats phase state alone as proof.

   Resume is permitted only for the same marker/schema/candidate/phase/substep and
   reconciles the longest valid journal prefix mechanically. Before either release,
   the corresponding blocked process times out and writes a terminal pre-release abort;
   resume may also append the missing release record exactly once after validating the
   recorded live identity. Because release is one atomic journal record, interruption
   before it leaves the process blocked and interruption after it is unambiguously
   released. If a pre-release supervisor/worker dies, resume requires a valid abort or
   the expired deadline, positive token/process-group death proof, no later journal
   record, and exact pre-inventory before appending `aborted-before-native` and starting
   a new tokenized attempt. It never reuses or overwrites an attempt.

   After `native-release`, resume never relaunches: it validates and waits for the
   durable worker or terminal record. Supervisor death cannot hide an orphan because
   the worker PID/birth and group are already journaled; worker/supervisor death without
   terminal is reconciled only after scanning exact identities, the process group, and
   the token across the process table. A stopped process plus satisfied postcondition
   and a diff wholly inside the
   declared roots records a `recovered-after-apply` result from the current inventory
   without rerunning; a dead released process with ambiguous effects, any
   other inventory, or any live/reused/unverifiable process identity atomically
   enters `quarantined` and exits 3. An interruption before intent leaves `idle`; after
   `applied` it advances normally. Signal tests require 130 for INT and 143 for TERM;
   the next invocation returns 0 only after one of the two valid reconciliations, while
   partial/ambiguous mutation returns 3 with the pre/current hashes, full journal,
   supervisor/worker/group/token process proof, and reason recorded.
   The state schema admits `recovery-required` and `quarantined` in addition to normal
   phase states, so no retry depends on an inventory a command may already have changed.

   Product/plugin cleanup uses only the pinned native uninstall and marketplace-remove
   commands. `--clean <absolute-run>` is the only recursive cleanup. It refuses a
   missing/wrong marker, symlink, path outside the temporary prefix, owner-home overlap,
   live or unverifiable token-bound supervisor/worker/descendant process or group,
   unexpired handshake, or
   incomplete inventory. A quarantined run is cleanable only
   after a fresh complete inventory proves every path is marker-owned and physically
   contained; before deletion, the harness atomically writes a canonical quarantine
   receipt with final inventory/evidence hashes to the documented untracked
   `.git/loom/dogfood/receipts/<run-id>.json`. Normal cleanup likewise requires a
   completed uninstall/residue check and receipt. Tests inject interruption before
   intent, after intent, during mutation, after native exit, after inventory, and after
   `applied` for every marketplace/install/remove operation and assert those exact
   state, exit, reconciliation, evidence, and cleanup outcomes. The injected points
   surround every journal record and include supervisor death, worker death before
   exec, supervisor death while the native worker continues, native orphaning, and
   descendants that remain in or escape the process group while retaining the token.
   Each test proves no early mutation, atomic release recovery, stable PID across worker
   exec, supervisor terminal recording, no duplicate live/unverifiable substep, and
   cleanup only after positive identity/group/token death proof.
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
- 2026-07-23 (pass 2, Steps 4-5): the plan under-specifies wire selection when hook
  root validation itself cannot determine a client (both `PLUGIN_ROOT` and
  `CLAUDE_PLUGIN_ROOT` validate — ambiguous — or neither does). Resolved
  non-blockingly: both cases fail closed via the Claude-style wire (exit 2 + single-
  line stderr, fixed reason `Loom hook input invalid for <event>.`), since that is
  the most universally-visible failure signal and matches the pre-existing (pre-dual-
  client) behavior this repo already shipped. Also: the PreCompact manual-block
  reason no longer embeds the live marker SHA (dropped, kept fully static) so the
  48-fixture set can byte-compare deterministically without pinning reproducible git
  commit hashes; and a missing/absent `trigger` or `session_id` on PreCompact now
  fails closed (previously missing `trigger` silently defaulted to `auto`), per spec
  08's literal "the only accepted values manual and auto" and this pass's session-
  scoped state requirement. jq is now an unconditional dependency for both hooks (no
  grep/sed fallback) since malformed/wrong-typed-input classification requires real
  JSON semantics a text fallback cannot provide; this is safe because jq 1.6+ is
  already a hard product-wide runtime floor (spec 10).
- 2026-07-23 (pass 3, Steps 6-7): `loom-launch-role` derives every role/model/effort
  value at runtime from `adapters/compatibility/v0.2.0.json` (resolved relative to its
  own physical location, never `CLAUDE_PLUGIN_ROOT`/`PLUGIN_ROOT`/`CODEX_HOME`/`PATH`)
  rather than a duplicated hardcoded table, so there is no separate copy that could
  drift from the tracked matrix. Claude launches never spawn a process: they
  cross-check the installed `agents/<role>.md` native tier and Agent-capability
  omission against the matrix and print normalized configuration (schema
  `loom-role-launch/v1`). Codex launches exec a fresh `codex exec --ephemeral
  --ignore-user-config --strict-config --disable multi_agent` child behind a
  stubbable `LOOM_LAUNCH_ROLE_CODEX_BIN` boundary so unit tests never spawn a live
  client (confirmed the hard way: an unstubbed manual smoke test during development
  did invoke the real installed `codex` CLI, which failed closed on a usage limit
  before doing any work — no real launch occurred, but it is why the bats suite
  stubs every codex-reaching path without exception). Exact `--sandbox`/web-search
  flag spelling (`--sandbox read-only`, `-c tools.web_search=false`) is this pass's
  best engineering judgment, not verified Codex 0.144.6 syntax; the one real cold
  launch per client in the later dogfood pass is authoritative and may require
  reconciliation. Guards fail closed (exit 2) on a descendant-launch attempt
  (`LOOM_LAUNCH_ROLE_ACTIVE` already set — set by the launcher itself in the codex
  child's environment), an inherited vendor model/effort env var (`CODEX_MODEL`,
  `MODEL_REASONING_EFFORT`, `OPENAI_MODEL`, `ANTHROPIC_MODEL`, `CLAUDE_MODEL`, and
  the tool's own `LOOM_LAUNCH_ROLE_{MODEL,EFFORT,SELECTOR}`), or an enabled
  delegation feature (`LOOM_LAUNCH_ROLE_ALLOW_DELEGATION`). For Step 7, the release
  metadata/schemas/fixtures already matched spec 10 exactly (from the ci-baseline
  slice and passes 1-2 of this slice) and needed no data changes; the remaining gap
  was mechanical proof, so `scripts/validate-repository.mjs` gained a thin-adapter
  check (every `commands/*.md`/`agents/*.md` file must stay <=20 lines and route to
  an existing shared `skills/loom-<name>/SKILL.md`/`roles/<role>.md` body) and a
  one-shared-hook-manifest check. Wiring `loom-launch-role` into `loom-run`/the role
  skills themselves is out of this pass's path boundary (roles/skills are frozen for
  passes 1-3) and is deferred to the harness pass.
- 2026-07-23/24 (pass 4, Step 8 + deferred wiring): the harness's supervisor/worker
  handshake is implemented with real OS process groups (`set -m` around exactly the
  backgrounding statement that must start a new group; no `set -m` around the
  worker fork, so it inherits the supervisor's group), an append-only hash-chained
  NDJSON journal per attempt (`control/journal/<substep>.<attempt>.ndjson`, one
  atomic whole-file rewrite per record or record-pair), and `ps -o lstart=`/`pgid=`
  for the macOS birth/group discriminators the plan requires (no `/proc`, no
  `stat -c`). Two structural bash pitfalls were found the hard way and are now
  guarded everywhere: (1) `exit` inside a `$(...)` command substitution only exits
  that subshell, silently swallowing fail-closed exits at every phase-entry call
  site until each was changed to check the subshell's own status explicitly; (2)
  wrapping the mutation driver itself in `$(...)` runs the whole supervisor spawn
  inside a throwaway subshell, which both defers the process's own INT/TERM trap
  until that subshell exits and (observed directly, repeatably) lets the subshell's
  teardown reap an already-escaped-process-group descendant before it can be
  observed -- the driver now communicates its result through a global variable
  instead of stdout. A third, environment-specific finding: Bats' `run` helper
  itself reaps a descendant that has escaped into its own process group once the
  wrapped command returns, so the three Bats cases that depend on a durable,
  independently-grouped supervisor/orphan outliving the wrapped call use a
  `mutate_direct` (non-`run`) helper and assert against the journal file instead of
  `$status`/`$output`; this is a Bats/test-harness property, not a fix to the
  product script (a real terminal's Ctrl-C, unlike `kill -INT <pid>` on a single
  process, reaches the whole foreground group, so the INT/TERM signal tests still
  use plain `run`-free backgrounding with `kill -INT "$pid"` and pass because the
  trap fires in-process regardless). The post-uninstall residue check was widened
  from the exact `cacheLayout` path to each client's whole `plugins/` tree so it is
  reachable as an outcome distinct from a mutation's own narrower cache-absent
  postcondition (the fixture's `marketplace-add`/`marketplace-remove` postcondition
  was correspondingly narrowed to "none", since those commands never touch the
  plugin cache in any real client). Scope actually landed: `--prepare`,
  `--exercise` (marketplace-add/install/reinstall/list per client plus a
  `loom-launch-role` role-launch probe and a real hook-wire-fixture probe against
  the actual repo hook), `--uninstall` (uninstall/marketplace-remove/residue check),
  `--clean`, full resume/quarantine/cleanup reconciliation, and the two schemas +
  fixture. Not yet done (deferred to the next pass): a live run against the real
  installed Claude/Codex binaries (Verification 7/8), the three cold advisory
  finders + code-evaluator routing (Step 11), and archival (Step 12) -- Status stays
  `In Progress`.
- 2026-07-24 (pass 5, Steps 9-10, live run): five real-run attempts against Claude
  2.1.218 (exceeds the 2.1.216 floor) and Codex 0.144.6, each isolated via
  HOME/CLAUDE_CONFIG_DIR/CODEX_HOME/TMPDIR redirection, surfaced five real product
  bugs the dry-fixture suite could not reach at real scale; each was fixed minimally,
  covered by a RED>GREEN Bats case (one deliberately relies on the real dogfood
  re-run itself as the scale proof -- documented at its commit -- since faithfully
  reproducing thousands of real hashed files in-suite was judged not worth the
  gate-time cost), and the run was re-driven fresh from a clean `--prepare` each
  time (never resumed a half-mutated attempt): (1) `_probe_role_launch`'s Codex
  branch exec'd the real `codex` binary without the fixture's env redirect,
  silently reaching the owner's real `CODEX_HOME` (confirmed via file-timestamp
  diff, not just code reading) -- fixed to inherit the same env-arg redirection
  every native mutation already uses; (2) the fixture's `cacheLayout.claude` pinned
  an unversioned path but real Claude nests its cache by version exactly like
  Codex (`.../loom/loom/0.2.0/...`) -- corrected the fixture and the dry-fixture
  stub/assertions that had baked in the stale path; (3) `_start_attempt` computed
  the handshake deadline BEFORE `_compute_inventory`'s full-tree SHA-256 walk,
  so a real installed tree could make that walk outlast the deadline itself,
  producing an immediate spurious self-timeout -- moved the deadline computation
  to immediately before the intent write; (4) `_diff_inventory_roots` passed whole
  inventories through `jq --argjson`, which overflowed the OS argv limit
  ("Argument list too long") once a real installed tree (with each client's
  marketplace `.git` clone) pushed the inventory past roughly 6-7k entries --
  switched to `--slurpfile` over the already-written inventory files; (5) real
  Claude 2.1.218 `plugin uninstall` was confirmed to ORPHAN the cache (drops the
  registry entry, stamps `.orphaned_at`, leaves every file in place) while real
  Codex 0.144.6 `plugin remove` deletes its version directory outright but can
  leave now-empty ancestor directories behind -- the uninstall postcondition and
  the post-uninstall zero-discovery/residue check are now client-aware: Claude
  reads `installed_plugins.json` (the client's own discoverability truth) instead
  of raw cache-path presence, and Codex's residue check only matches files/symlinks,
  not bare empty directories. The fifth, final live run completed the full native
  lifecycle cleanly for both clients (all 10 marketplace-add/install/reinstall/
  uninstall/marketplace-remove mutations, both clients' list/discovery inside and
  outside the project, hook-trust observation, and installed-root helper-root
  probes against the real installed cache all exit 0) and the Claude cold role
  launch succeeded (bounded, cold, delegation denied). The Codex cold role launch
  itself got a live `401 Unauthorized` from `api.openai.com`: the isolated
  `CODEX_HOME` has no `auth.json` by design (never seeded from the owner's real
  credentials, which the harness must never touch), so it cannot authenticate --
  an infrastructure limitation, not a product defect, recorded honestly as
  `infrastructure-blocked` (exit 4) in `.docs/evaluations/macos-dual-client-dogfood-
  evidence.json` per the honesty rules, alongside the fully-succeeded Claude leg and
  every non-auth-requiring Codex surface. `Status: Implemented` reflects that the
  code + evidence-writing work for this pass is complete for evaluator adjudication;
  it does NOT itself claim a dual-client PASS -- the plan treats the
  infrastructure-blocked Codex role-launch leg as still blocking that claim until a
  future pass can complete it (e.g. against a host with a real, non-owner-identity
  Codex credential available to the isolated home) or the code evaluator/owner
  otherwise adjudicates the evidence as sufficient. Steps 11 (three cold advisory
  finders + code-evaluator routing) and 12 (archival) remain for later roles.
- 2026-07-24 (pass 6, round-0 code-eval FAIL remediation): all four required
  changes resolved. **T1 (blocking):** added the 6 previously-untested injection
  Bats cases -- `before:native-hello` (proves both the supervisor's own
  `worker-hello-timeout` abort AND the orchestrator's gate-2 writer-settle wait,
  asserting exactly one abort record with the supervisor's reason, never the
  orchestrator's own racing fallback), `before:supervisor-hello` (gate-1's
  fallback timeout-abort path, no writer to settle on since hello itself never
  existed), `before:native-release` (the dying supervisor leaves the blocked-but-
  still-alive worker to be rescued by the orchestrator's own once-only late
  release grant -- discovered empirically that this resolves within the SAME
  attempt, not a fresh retry, and can legitimately race between an instant
  "applied" and a "quarantine" pending one more reconciling call, mirroring the
  pre-existing `supervisor-die-while-worker-continues` case), `before:terminal`
  (reconciles to `recovered-after-apply` since the worker had already fully
  exited before the supervisor died) and `after:terminal` (applies directly from
  the already-durable terminal record, no `recovered-after-apply` marker). Each
  case was proven load-bearing by breaking its specific branch (disabling the
  resume-grant condition, the found-terminal short-circuit, the reconcile-post-
  apply gate, or mutating an abort-reason string), observing the exact assertion
  RED, then restoring and reconfirming GREEN. **T2:** added a parameterized case
  driving the same `after:supervisor-hello` injection across marketplace-add,
  uninstall, marketplace-remove, and a `codex install` opKey in one test (RED
  demonstrated by corrupting `_postcondition_label`'s claude-uninstall branch --
  a break the pre-existing claude-install-only test could not have caught).
  **C1:** `--clean` now calls `_verify_inventory_containment` on a quarantined
  run's freshly recomputed inventory before `rm -rf`: it fails closed if any of
  the five owned roots is itself a symlink (the actual escape shape, since
  `_inventory_root`'s `find` never descends through a directory symlink) and
  re-canonicalizes every entry's parent as defense in depth; marker ownership is
  now also re-confirmed via `_validate_marker` immediately before the delete, not
  just once at function entry. **S1:** added `_validate_run_id` (strict
  `^[A-Za-z0-9_-]+$` charset gate) called on the `state.json`-sourced `runId`
  before it builds the receipt filename, fail-closed exit 3 on a tampered
  non-charset value (e.g. a `../` escape); added the matching `pattern` to
  `loom-dogfood-state-v1.schema.json`'s `runId` property. Both C1 and S1 got
  their own RED>GREEN regression Bats cases using the same break-observe-restore
  method. Gate: `LOOM_DIFF_BASE=HEAD scripts/check` exit 0, 434/434 Bats (426
  baseline + 8 new cases), format/lint/test all green, matching the round-0
  independent gate rerun's method exactly. One pre-existing, unmodified signal
  test (`INT during a mutation yields exit 130`) flaked once under heavy
  concurrent-suite load and passed on every isolated rerun; it is untouched by
  this pass and outside the four required changes' scope.
