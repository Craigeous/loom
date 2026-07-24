# Review findings: coord-identifier-boundaries (bootstrap round 0)

```text
Evidence mode: loom-repository-bootstrap/v1
Conformance: degraded bootstrap; not loom-local-review/v1
Isolation: not established under ADR 0022
```

Aggregate state: `bootstrap-ran-with-findings`

Run: `coord-identifier-boundaries-82d689f-code-r0`
Base: `c89967311a928f2e0c4ba08526bd15112721ba54`
Head: `82d689f8958a80ddfb46ac1035072467ae518037`
Head tree: `209625a9545c15ccfe539a1abac3217ba9246a4f`
Sealed package: `/private/tmp/loom-coord-idb-code-r0.slMh5K`
Manifest SHA-256: `be237eeb58a37304d514c05607cbd828cd2d9a6f1369d79ba4300fc8244040cc`

Producer gate (recorded in manifest): `LOOM_DIFF_BASE=HEAD scripts/check` exit 0,
452 Bats (`loom-coord.bats` 82/82). Runs 1-2 failed only dogfood test 301
(`before:native-release` injection, outside this diff) under concurrent host load;
a base-commit control passed exit 0 in the identical sealed environment, and run3
passed 452/452 — adjudicated pre-existing load-sensitive, not slice-introduced.
All gate logs retained in the package.

Three cold, non-delegating auxiliary workers each validated every binding.
Required-worker completeness, echoed hashes, output parseability, source-inventory
match, and diff intersection mechanically verified for all three.

## Findings

- **T1** (tests — proposed MINOR)
  `plugins/loom/bin/loom-coord` (`cmd_session_bootstrap`, `cmd_session_end`) —
  the held-claims-line quarantine-skip path is untested: removing both
  `_valid_slice_name || continue` guards keeps the full suite 82/82 green.
- **T2** (tests — proposed MINOR)
  `plugins/loom/bin/loom-coord` (`cmd_cleanup` `--session`) — the user-supplied
  `validate_session_id` call site has no covering negative (`cleanup --session
  <bad>`); the primary validate path is covered.
- **T3** (tests — proposed MINOR)
  `plugins/loom/bin/loom-coord` (`cmd_release_claim`, `cmd_reclaim`) —
  `validate_slice_name` at these sites has no dedicated bad-slice-name negative
  (all invocations use valid names).
- **T4** (tests — proposed MINOR)
  `plugins/loom/bin/loom-coord.bats` / plan Implementation Record — the record
  says "17 new" NEG-ID cases; the suite actually adds 18 (64 + 18 = 82;
  NEG-ID3 omitted from the RED→GREEN map). Documentation miscount, not a code
  defect.

## Guards that held (no finding)

- **Correctness: no findings.** `_valid_identifier` leading-alnum + `/`-reject
  makes traversal structurally impossible; every identifier ingestion point
  (session-ids, decoded-blob sids in cleanup/reclaim, PIDs, slice names in the
  held-claims loops) is validated before it forms a path/ref/process argument;
  `_remove_session_dir` replaces all live `rm -rf` of computed dirs and its
  rmdir-quarantine can neither orphan nor over-delete. Bash 3.2/BSD+GNU-portable
  (case-glob + `${#}`, no `[[ =~ ]]`, no GNU-only flags). 82/82 reproduced green.
- **Security: guards held.** Every identifier→sink attack blocked — traversal,
  absolute paths, newline/tab/Unicode-slash, ref metacharacters, TSV corruption,
  PID injection (`1;touch`, `$(...)`, `-1`) — validation precedes path formation
  (no TOCTOU; pure string check). T3 quarantine does not wedge the coordinator.
  Recorded non-finding (E10): `_remove_session_dir` following a symlinked session
  dir requires pre-existing write to `$GITDIR/loom/` (same trust domain as
  `.git/hooks` — already RCE), strictly less capability than the attacker holds;
  out of threat model.
- **Tests: no masked negatives.** 8 surgical guard mutations flipped all 26 mapped
  assertions red; positive-capability cases (empty rejected, `/`/`:`/`..` slice
  names still claimable via SHA-hashed refs, empty-dir removed) stay green for the
  right reason. The T3 flip (swept → quarantined) is plan-authorized. 17 NEG-ID
  cases appended; the pre-existing suite is otherwise unchanged.
