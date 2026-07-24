# Evaluation: coord-identifier-boundaries (slice-plan)

Verdict: FAIL
Round: 0
Reviewed against: repository-improvement-plan.md § "M1 — Fix coordinator safety"
→ `### Slice: coord-identifier-boundaries` (scope + acceptance criteria); ADR 0023
§1/§3/§4 (code-bearing bootstrap sealed-package review); the real
`plugins/loom/bin/loom-coord` and `plugins/loom/bin/loom-coord.bats` at HEAD e8f635b.

## Findings

- [BLOCKER] **Slice-name validator over-restricts and breaks two existing,
  undeclared regression tests — falsifying the plan's own "suite passes unchanged"
  claim.** Steps 2/5 apply `_valid_identifier` (grammar
  `[A-Za-z0-9][A-Za-z0-9._-]{0,127}`, no `..`) to slice names via
  `validate_slice_name` in `cmd_claim`/`cmd_renew`/`cmd_release_claim`/`cmd_reclaim`.
  That grammar rejects `:` and `..`. But the current suite has two load-bearing
  tests that assert those exact names claim/renew/release **successfully**:
  - `SC1` (bats line 1293): `claim "slice:foo"` expects exit 0 + `claimed slice:foo`;
    renew and release round-trip. New validator ⇒ exit 1. Test breaks.
  - `V5b` (bats line 1735): `claim "a..b"` expects exit 0 + `claimed a..b`. New
    validator ⇒ exit 1 (`*..*` reject). Test breaks.
  Verified mechanically: both names fail the grammar; the other special-char slice
  tests (`foo.lock`, `Auth`, `auth`) pass. The plan's Verification section asserts
  "the full existing suite (64 cases) must pass unchanged **except** the
  intentionally-updated T3 case" and offers that as the regression proof — that
  claim is false. An independent developer following the plan hits a red gate with
  no instruction on whether to rewrite SC1/V5b or loosen the grammar. That
  unresolved decision is a hard blocker on executability.

- [BLOCKER] **The slice-name restriction contradicts the deliberate V5/V6 design and
  is not required by the M1 contract.** `slice_to_refname` hashes the slice bytes to
  the ref (V5) and `_make_claim_blob_for` base64-encodes it into the blob (W2), so a
  slice name is never used to form a filesystem path or a git ref path — the plan's
  own Context §"Slice names" acknowledges the ref is "safe" and the blob is "safe."
  The **only** real invariant a slice name can violate is the `held-claims`
  one-record-per-line format, which requires rejecting newline/tab/control bytes —
  **not** `:` or `..`. The M1 regression list names `..`/absolute/traversal for
  *session IDs* (which do form paths); it does not require slice names to match the
  session grammar. Restricting slice names to the session grammar therefore removes a
  supported, tested capability (arbitrary slice names) with no safety benefit and no
  stated authority. It also creates an upgrade hazard: a claim legitimately held
  under the old rules whose name contains `:` would, after this slice, be silently
  skipped by the Step 7 `_valid_identifier || continue` guard in `cmd_session_end`
  and `cmd_session_bootstrap` — stranding/never-releasing a real claim ref. The plan
  must either (a) narrow slice-name validation to the held-claims invariant
  (reject only newline/tab/control/empty; keep hashing for ref safety), or (b) if it
  truly intends to restrict slice names, declare SC1 and V5b as intentional changes
  (as it did for T3) and justify the capability removal against V5/V6. It does
  neither.

- [MINOR] **Threat-model imprecision in Context.** Bullet 1 states
  `--session '../../victim'` "escapes `.git/loom`". It does not:
  `$STATE_DIR/session-../../victim` resolves to `.git/loom/victim` (the literal
  segment `session-..` then one `..` returns to `loom`). The genuine escape is
  `x/../../victim` → `.git/victim`, which is what regression case 1 actually uses.
  The validator rejects both (leading non-alnum / `/`), so the guard is correct; only
  the prose example is wrong. Fix the example to match the real escape.

- [MINOR] **`Checkpoint arguments` bullet left silently undisposed.** The M1 section
  lists "Checkpoint arguments where applicable" among identifiers to validate. The
  plan never mentions them. `cmd_checkpoint_write` writes `EXTRA_ARGS` as file
  *content* to a path derived from the (validated) `SESSION_ID`, so the argument is
  free-form content, not a path-forming identifier — "where applicable" ⇒ not
  applicable. That reasoning is correct but should be stated explicitly so the M1
  bullet is visibly discharged rather than dropped.

## Required changes (for FAIL)

1. Resolve the slice-name grammar conflict. Preferred: scope `validate_slice_name`
   to the actual `held-claims` invariant — reject empty, newline, tab, and control
   bytes (and keep the existing hash-ref + base64-blob handling for everything else)
   — so `slice:foo` (SC1) and `a..b` (V5b) remain claimable and both tests stay
   green. If instead the intent is to fully restrict slice names, explicitly declare
   SC1 and V5b as authorized test changes with the same rigor as the T3 note, and
   justify removing the V5/V6 freeform-slice-name capability.
2. Re-verify the "suite passes unchanged except T3" claim mechanically after the
   grammar decision (it is currently false), and reconcile the Step 7
   held-claims-line `_valid_identifier` guard so it cannot strand pre-existing
   legitimately-held claims whose names are legal under the pre-slice rules.
3. Correct the Context bullet-1 traversal example (`../../victim` →
   `x/../../victim`) so the stated escape is accurate.
4. Explicitly dispose of the "Checkpoint arguments" M1 bullet (state it is free-form
   content, not a path identifier, hence out of validation scope).

## Notes

Positives confirmed for the author's next pass (these parts are sound and need no
change beyond the above):

- **Session-id validation is complete and clean.** Every user-supplied `SESSION_ID`
  path use flows through `assert_session` (validated) or the two non-`assert_session`
  sites the plan explicitly patches (`cmd_session_start`, `cmd_cleanup`). No existing
  session-id test uses a now-invalid character, so session-id validation breaks no
  test. The grammar structurally forecloses `/` and `..` traversal.
- **Decoded-blob-sid gating is complete.** Both destructive decoded-sid consumers —
  `cmd_cleanup` (`rm -rf session-$sid` + `wt_sid_match`) and `cmd_reclaim`
  (`wt_sid_match cur_sid`) — are gated. Verified the R3 (`run[1]`) test still passes:
  reclaim's CAS steal is keyed on the ref hash, not the sid, so gating the worktree
  removal leaves R3's live `run1` worktree correctly untouched and the reclaim still
  reports success.
- **The T3 flip is genuinely M1-required and safely specified.** `foo\nbar` contains
  a backslash, outside the grammar, so it is malformed persisted state; M1 mandates
  validating decoded sids and preserve/quarantine of malformed state. The quarantine
  semantics are well-defined (exit 0, row preserved/`skipped`, ref + worktree
  preserved, observable) and are a hygiene reduction, not a safety weakening — it is
  the fail-closed choice. Keeping the case as a load-bearing negative (not deleting
  it) and calling it out in Notes is the right handling.
- **`_remove_session_dir` known-file set is complete** against every file
  `loom-coord` writes into a session dir (checkpoint, held-claims, session/renewer
  pid+starttime, plus the `*.tmp.*` atomic-write and `held-claims.tmp.$$` patterns);
  `rmdir`-refuses-non-empty gives the intended quarantine, matched by test case 9.
- All three `rm -rf` of computed session dirs (bats-verified: lines 1022, 1029, 1132)
  are routed through `_remove_session_dir` by Steps 7–8; the grep self-check is a good
  mechanical closure.
- PID validation (Step 6) and the path boundary (four files, no spec/ADR/hooks edits)
  are correct for a no-spec code slice. Red→green discipline and the Bash 3.2/BSD
  portability constraint are stated.

The plan is close: the design, containment, and session-id/decoded-sid coverage are
solid. The single structural defect is treating slice names as path identifiers when
the tree already renders them path-safe by hashing — that over-restriction is what
breaks the suite and conflicts with V5/V6.
