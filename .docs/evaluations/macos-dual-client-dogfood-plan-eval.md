# Evaluation: Apple-silicon Claude Code + Codex dogfood plan

Verdict: FAIL
Round: 0
Reviewed candidate: `9b35f929be2efc4f0b644a6185f32c2b3cfeff78`
Reviewed tree: `563a82d12b0dbd4b1980f9deefddba274187339f`
Sealed package: `/private/tmp/loom-macos-dual-client-plan-9b35f92-r0`
Manifest SHA-256: `d4fd7375b37a1d9aa0f6a803f082068716f1a6cc0497179597bbf625c8b7fc18`
Input inventory SHA-256: `41e293aabd48a636610fd54679fcfb443a90e2867b188c089e717606e6bec128`
Verdict SHA-256: `52a61a4eede40cce047fdff9fb61c2cef6860e1d1961b2c9829dcb4aec423ca4`

## Findings

- [BLOCKER] The proposed `hooks/codex-hooks.json` conflicts with the approved exact
  Codex binding `./hooks/hooks.json`. The plan must retain one physical manifest and
  define fail-closed client wire dispatch without weakening Claude behavior.
- [BLOCKER] The proposed role skills state profiles but do not define a launcher that
  reads the versioned mapping, sets and verifies both exact Codex model keys for every
  cold launch, enforces one-level non-delegation, or tests all profiles and failures.
- [MAJOR] The destructive dogfood harness lacks a versioned state/evidence schema,
  exact native floor commands and environment redirects, ownership and containment
  controls, canonical inventories/redaction, resumable phase rules, stable failure
  states, and negative cleanup tests.

## Required changes

Revise the plan to close all three findings, seal the exact revised package, and route
it back to a fresh cold plan evaluator. A resolving PASS remains round 0; the process
does not run an arbitrary number of review rounds.

---

## Reevaluation of revision `6d6c6e4`

Verdict: FAIL
Round: 0
Reviewed commit: `6d6c6e44b2bd1ac41971e423586c940f35865a6e`
Reviewed tree: `879d3057120ef1c68874af92083201dcb03dcbc4`
Manifest SHA-256: `aa05725180ecae93be6d8b0221140c0cc62b02808bd0f66bb3ad226892f5fc59`
Input inventory SHA-256: `ec4f6bc8c9cbea8dfc4c769ea829ca2ae99399c1198c1ad96dda2c1c53ac85db`
Verdict SHA-256: `8ceca7fe1923c7a91bd32e93fdfb3180ee3a4e06a894a46c791fd51390011a58`

The shared-hook and Codex-launch BLOCKERs are resolved. One MAJOR remains: a native
mutation may finish before its atomic phase record, making both the stated inventory
precondition and cleanup reject the interrupted run. Define write-ahead mutation
substeps, deterministic before/after/partial reconciliation, and a safe validated
recovery or quarantine cleanup transition with exact states, exits, and evidence.

---

## Reevaluation of revision `96cbc2c`

Verdict: FAIL
Round: 0
Reviewed commit: `96cbc2ce5045ed64fcfefb464c2d38c59e27bd94`
Reviewed tree: `c84a0643bd0564e0a427155fa43d623712d44652`
Manifest SHA-256: `fc010cf393f77d17e3ced29538d4d34224616282d6245962d59f0396c756e972`
Input inventory SHA-256: `fecac3bbd516b2e69900037cce02adec5466f744df3692dffe9c8404ee0aca76`
Verdict SHA-256: `ac4cdadbb5b4ba2acfd023e9e6a95840d12ce0fdf5d07f9f28e5e1bbafe6a82c`

The remaining recovery design still has one MAJOR launch-to-identity durability
window: a spawned native child may be live before its PID/birth identity is recorded,
so resume can duplicate it and cleanup cannot positively exclude it. Require a token-
bound wrapper that cannot mutate until durable `launched` identity and `released`
state exist, with exact reconciliation and interruption tests around every handshake
boundary.

---

## Reevaluation of revision `077aebd`

Verdict: FAIL
Round: 0
Reviewed commit: `077aebd5802bb209cd64814bbd2cff5872c21219`
Reviewed tree: `5ac1f0004c7895d052375edd917fa88b3749e019`
Manifest SHA-256: `47c7a0b721c6ee22376effad8826c1778580f39ca63d113c1babfd04b150600e`
Input inventory SHA-256: `83d9ef0e3682b7cf9ae48b8e3479715200b40a01199cafa7f9044adf51e0d47a`
Verdict SHA-256: `68464e134c03dc11e8815b5910af62b8ba6e1bb89f271cb0f5910363e27057e7`

One MAJOR remains in release-to-native topology. Process replacement prevents the
same wrapper from recording terminal output, while forking an unrecorded native PID
can orphan a mutator. The separate `released` state and release record also leave a
recovery gap. Specify a durable supervisor plus a gated worker whose recorded PID is
preserved across exec, one atomic release record per gate, process-group/token orphan
proof, and exact recovery for pre-release aborts, supervisor death, and native orphans.
