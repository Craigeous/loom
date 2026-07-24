# Review findings: macos-dual-client-dogfood (bootstrap round 0)

```text
Evidence mode: loom-repository-bootstrap/v1
Conformance: degraded bootstrap; not loom-local-review/v1
Isolation: not established under ADR 0022
```

Aggregate state: `bootstrap-ran-with-findings`

Run: `macos-dual-client-dogfood-cf9eb1e-code-r0`
Base: `a3cb007b5ddb3307867fc2f321a0368bfeac9336`
Head: `cf9eb1e5a8e57f0890bcda394d4ff1c80d5ac660`
Head tree: `70f746f5911501a988688e111f57401446cba5b3`
Sealed package: `/private/tmp/loom-macos-dogfood-code-r0.6yFkxa`
Manifest SHA-256: `52cfeb68a8a20086f72ad1ace51cd95b28daf121dfbf0f064dc4346e63c2dd80`
Producer gate (recorded in manifest): `LOOM_DIFF_BASE=HEAD scripts/check` exit 0,
426 Bats tests, run against the sealed head export in a synthetic single-commit git
context (no original identity or history).

Three cold, non-delegating auxiliary workers (correctness, tests, security) each
received the same hash-bound package, validated every binding, and returned
structured findings to distinct output locations. Required-worker completeness,
echoed hashes, output parseability, source-inventory match, and diff intersection
were mechanically verified for all three. Proposed severities are advisory; the
blind code evaluator owns adjudication and the verdict.

## Findings

- **C1** (correctness — proposed MINOR, confidence low)
  `scripts/macos-dual-client-dogfood:1650-1667` — the quarantined-run `--clean`
  gate asserts the recomputed inventory is non-null JSON but does not literally
  re-assert Step 8's "every path is marker-owned and physically contained" before
  deletion; deletion remains bounded by `_validate_run_root` and a
  non-symlink-traversing `rm -rf`, so this is a fidelity gap, not a demonstrated
  escape.

- **T1** (tests — proposed MAJOR, confidence high)
  `scripts/tests/macos-dual-client-dogfood.bats` — the injection matrix does not
  "surround every journal record": 6 of the 12 harness-implemented `_inject`
  points are untested, including the plan-named "after native exit"
  (`before:terminal`/`after:terminal`, the no-terminal process-scan
  reconciliation) and `before:native-release`'s `aborted-before-native` branch.
  Those recovery paths ship with zero coverage.

- **T2** (tests — proposed MINOR, confidence high)
  `scripts/tests/macos-dual-client-dogfood.bats` — every injection/signal/orphan
  case drives only `claude-install`; plan Step 8 requires interruption coverage
  "for every marketplace/install/remove operation" and both clients (mitigated by
  the operation-agnostic `_do_mutation` implementation).

- **S1** (security — proposed LOW, confidence high)
  `scripts/macos-dual-client-dogfood:1664` — `--clean` builds the quarantine
  receipt filename from the unvalidated `state.json` `.runId`; a `../`-bearing
  runId escapes the receipt directory via `_atomic_write` (reproduced
  mechanically). Gated by `state.json` living under the 0700 run root —
  defense-in-depth, not a live single-user exploit. Every other clean-path field
  is strictly validated; runId is the lone hole.

## Resolving re-review (head `a000cef`)

Run: `macos-dual-client-dogfood-a000cef-code-r0-resolve`
Head: `a000cefc9bc893db5e6bd54b865342081e9fdb27`
Head tree: `efc193904b237a5f62759425fc435b7edcd9cb44`
Sealed package: `/private/tmp/loom-macos-dogfood-code-r0b.RdTGq8`
Manifest SHA-256: `da61c862902ed4eb5baeb768d5cc36b27bf0afe026af8d114c7a14e626897b84`
Producer gate (recorded in manifest): `LOOM_DIFF_BASE=HEAD scripts/check` exit 0,
434 Bats tests, sealed head export, synthetic git context.

Aggregate state: `bootstrap-ran-with-findings`

Three fresh cold workers re-reviewed the fixed head (findings do not carry
forward across a head change). Mechanical validation passed for all three
(completeness, echoed hashes, parseability, diff intersection; the tests worker
reported its finding under a `location` field rather than `file` — recorded).

- **Correctness: no findings.** Fix layer traced clean: double-guarded
  containment walk; runId gate accepts minted tokens, rejects traversal forms;
  once-only late-release rescue remains recoverable within the same attempt;
  writer-settle defers to the supervisor's recorded abort. No fix-introduced
  regression found in the release topology.
- **Tests: 1 finding.** `tests-after-native-release-uncovered` (proposed MINOR,
  `scripts/macos-dual-client-dogfood:837`): injection census at this head is 12
  implemented / 11 covered; only `after:native-release` lacks a direct case.
  Mitigated: it is immediately adjacent to the covered
  `supervisor-die-while-worker-continues` point with no code between and
  identical program state. All 8 resolving cases verified non-vacuous (each
  turned red with its branch broken); the T2 parameterization genuinely
  exercises 4 distinct operations including a codex opKey. Prior T1/T2/C1/S1
  are resolved. The previously reported INT/130 flake reproduced 0 times.
- **Security: no findings.** Both new guards held under mechanical attack
  (charset/NUL/traversal on `_validate_run_id`; symlink-swap/TOCTOU/newline
  paths on `_verify_inventory_containment`; `rm -rf --` confirmed
  non-symlink-following; marker re-validated pre-delete).

## Guards that held (no finding, first round)

The `--clean` recursive-delete containment set failed closed under mechanical
bypass attempts (ancestor/top-level symlink, dot-dot, outside-tmp, owner-home
overlap, trailing slash, `TMPDIR=/`). Masked-negative spot-checks flipped three
safety guards in scratch copies and all three claiming tests correctly turned
red. All 48 hook-wire fixtures are byte-compared with `cmp -s`. The
supervisor/worker release topology, both helpers' containment/validation guards,
fail-closed hook root selection, and evidence canonicalization/redaction were
reproduced sound. All five Bats suites re-ran green from the sealed source
(33 dogfood, 51 launch-role, 46 identity-guard, 32 precompact, 38 resolve-helper).
