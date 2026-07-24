# Evaluation: macos-dual-client-dogfood (code)

Verdict: FAIL
Round: 0
Reviewed commit: `cf9eb1e5a8e57f0890bcda394d4ff1c80d5ac660`
Reviewed tree: `70f746f5911501a988688e111f57401446cba5b3`
Base: `a3cb007b5ddb3307867fc2f321a0368bfeac9336`
Sealed package: `/private/tmp/loom-macos-dogfood-code-r0.6yFkxa`
Manifest SHA-256: `52cfeb68a8a20086f72ad1ace51cd95b28daf121dfbf0f064dc4346e63c2dd80`
Verdict SHA-256: `35929e2088a352af0a0a148b5e1b8401a7dc8c7198a7eb58d17facdc8ff20d46`

```text
Evidence mode: loom-repository-bootstrap/v1
Conformance: degraded bootstrap; not loom-local-review/v1
Isolation: not established under ADR 0022
```

Independent gate rerun: GREEN — `LOOM_DIFF_BASE=HEAD scripts/check` exit 0,
426/426 Bats, all 9 stages, empty stderr matching the producer run; starting
inventory verified 326/326 against the sealed export before execution.

Scope conformance: 48 exact hook-wire fixtures; 54 changed paths all inside the
plan's allowed boundary, zero forbidden; single hook manifest, thin adapters, and
the exact workflow/role sets mechanically verified. The committed dogfood
evidence is canonical (`jq -S -c` + LF), schema-valid, and records the
credentialless Codex cold-launch 401 honestly as `infrastructure-blocked`
(exit 4) with no PASS claim — degraded but honest.

## Adjudications (all four advisory findings CONFIRMED)

- **T1 — CONFIRMED MAJOR (drives the FAIL).** 6 of the 12 harness-implemented
  injection points are untested, including the plan-named "after native exit"
  boundary (`before:terminal` / `after:terminal`) and the gate-2
  worker-hello-timeout writer-settle branch, which has zero coverage. Violates
  Step 8's "injected points surround every journal record" and Verification 6.
- **C1 — CONFIRMED MINOR.** Quarantined-run `--clean` validates the recomputed
  inventory as non-null JSON rather than per-path marker ownership and physical
  containment; deletion remains bounded by `_validate_run_root`.
- **T2 — CONFIRMED MINOR.** Interruption tests drive only `claude-install`;
  the reconcile path is operation-agnostic, mitigating the gap.
- **S1 — CONFIRMED MINOR.** Unsanitized `runId` reaches the quarantine receipt
  filename; same-uid reach only (0700 run root), defense-in-depth.

## Required changes

1. **(T1 — blocking)** Add Bats cases driving the untested injection points,
   each failing if its branch is stubbed: (a) worker death before `native-hello`
   proving the supervisor's worker-hello-timeout abort and the gate-2
   writer-settle path yield abort → clean retry with no early mutation;
   (b) `before:terminal` and `after:terminal` asserting `recovered-after-apply`
   from a fully-exited worker and applied-from-durable-terminal via resume;
   (c) `before:native-release` and `before:supervisor-hello`, each proving no
   early mutation and exactly one clean reconciliation.
2. (C1) Before `rm -rf` on a quarantined run, iterate the freshly recomputed
   inventory and fail closed on any entry not physically below the validated
   run root or any escaping symlink; confirm marker ownership; regression test.
3. (S1) Strictly validate the `runId` charset (or use the already-validated
   marker) before constructing the receipt filename; fail-closed exit-3
   regression test; optionally add a runId pattern to
   `loom-dogfood-state-v1.schema.json`.
4. (T2) Parameterize at least one representative injection case across
   marketplace-add, uninstall, marketplace-remove, and a `codex-*` opKey.

The slice returns to `In Progress`. A resolving PASS shares Round 0 per the
spec 03 FAIL-only counting rule; the re-review requires a fresh sealed package
at the new head (prior findings and verdicts do not carry forward).
