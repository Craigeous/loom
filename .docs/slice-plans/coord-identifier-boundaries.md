# coord-identifier-boundaries

Status: In Progress
Target specs: none (coordinator-safety code slice; no frozen-spec edits)
Authority: [repository improvement plan](../repository-improvement-plan.md) § "M1 —
Fix coordinator safety" → `### Slice: coord-identifier-boundaries`;
[ADR 0023](../ADR/0023-repository-self-hosting-bootstrap-transition.md) §1 (lists this
slice among the eligible code-bearing M1 bootstrap slices — **sealed-package review
applies at `Implemented`**: §3 three cold auxiliary finders + §4 independent
evaluator on the exact committed `base..head`).

## Context

`plugins/loom/bin/loom-coord` is loom's multi-session coordination CLI. It derives
filesystem state paths and git refs from **externally supplied identifiers**:

- The **session id** (`--session` / `$LOOM_SESSION_ID`) is interpolated directly into
  `$STATE_DIR/session-<id>/…` paths (`STATE_DIR="$GITDIR/loom"`), with no validation.
  A value like `x/../../victim` computes `$STATE_DIR/session-x/../../victim`, which
  resolves to `.git/victim` — an escape out of `.git/loom`. (A bare `../../victim`
  yields `.git/loom/victim`, still inside `loom`; the traversal only bites once the
  literal `session-` segment is itself consumed, hence the `x/` lead. Regression case 1
  uses the real-escape form.)
- **Slice names** (positional arg to `claim`/`renew`/`release-claim`/`reclaim`) are
  hashed for the ref (V5, safe) and base64'd into the claim blob (W2, safe), so a slice
  name **never** forms a filesystem path or a git ref path — arbitrary slice names
  (including `:` and `..`, per V5/V6) are a supported, tested capability. The **only**
  invariant a slice name can violate is the `session-<id>/held-claims` one-record-per-line
  format, into which the raw slice string is written and read back — so the sole slice
  bytes that need rejecting are the empty string and newline/tab/control bytes; `:` and
  `..` are safe and must stay claimable.
- A **PID** (positional arg to `renewer-start`) is passed to `process_starttime`,
  which uses it in `/proc/<pid>/stat` and `ps -p <pid>`.
- **Session ids decoded from claim blobs** (field 1) are used as *paths* in the
  destructive sweeps: `cmd_cleanup` does `rm -rf "$STATE_DIR/session-$sid"` and
  `worktree remove -f` keyed on `wt_sid_match "$sid"`; `cmd_reclaim` does the same
  worktree removal keyed on the decoded holder sid. A corrupt or adversarial blob can
  therefore drive an out-of-tree deletion.

The current destructive removals use `rm -rf` on *computed* session directories.

This slice adds centralized identifier validation and contained-target destructive
operations to `loom-coord`, per the M1 section. It is the first M1 coordinator-safety
slice. **Out of scope:** lock ownership (`coord-lock-ownership`), schema CAS
(`coord-schema-cas`), and any behavior change to the lock/claim CAS protocol itself —
this slice only bounds identifiers and contains destructive targets; it does not alter
the ADR 0014/0015/0016 lock or lease semantics.

## Exact path boundary

Only these files may change:

- `plugins/loom/bin/loom-coord` — the helper (add validators + contained destructive
  ops + call sites).
- `plugins/loom/bin/loom-coord.bats` — new negative cases + the T3 expectation change
  (see Step 8 and Notes).
- `.docs/slice-plans/coord-identifier-boundaries.md` — this plan's lifecycle.
- `.docs/slice-plans/README.md` — Active-plans index entry.

No other files. In particular: **no** frozen-spec edits, **no** ADR edits, **no**
`hooks.json` change (this helper is not a hook), **no** other `bin/` helper. Root
`CLAUDE.md` digest maintenance, if any, is the developer's **finalize pass** (spec 03
finalize step 2 / spec 08 boundary), not part of this implement diff.

## Steps

All edits are in `plugins/loom/bin/loom-coord` unless a step names the bats file.

1. **Add the two centralized grammar predicates.** Define, alongside the existing
   helper functions (after `now()`, before the subcommand functions), a single
   pure-predicate:

   ```sh
   # _valid_identifier <value> — returns 0 iff <value> matches the safe grammar
   #   [A-Za-z0-9][A-Za-z0-9._-]{0,127}  AND contains no ".." substring.
   # Bash 3.2 / BSD safe: pure case-glob + ${#}.  The single [!A-Za-z0-9._-]
   # rejection covers "/", spaces, tabs, newlines, control bytes, and every
   # multibyte Unicode separator (their bytes fall outside the allowed set).
   _valid_identifier() {
       local v="$1"
       [ -n "$v" ] || return 1              # empty
       [ "${#v}" -le 128 ] || return 1      # overlong (1 + up to 127)
       case "$v" in [!A-Za-z0-9]*) return 1 ;; esac   # leading char must be alnum
       case "$v" in
       *[!A-Za-z0-9._-]*) return 1 ;;       # any byte outside the allowed set
       *..*) return 1 ;;                    # explicit ".." reject (literal M1 requirement)
       esac
       return 0
   }
   ```

   The leading-alnum rule alone rejects a bare `..`, a leading `.`/`-`, and an absolute
   path (leading `/`). Combined with the `/`-rejection, path traversal is structurally
   impossible; the explicit `*..*` reject satisfies the M1 wording literally.

   `_valid_identifier` is the grammar for identifiers that **form paths, refs, or
   process arguments** — session ids (user-supplied and decoded-from-blob) and, via
   `validate_pid`, PIDs. It is **not** applied to slice names (see the next predicate).

   Then define a **separate, narrow** predicate for slice names, which are never
   path/ref material (V5 hashes them; W2 base64-encodes them) and so only need to
   protect the one `held-claims` line format:

   ```sh
   # _valid_slice_name <value> — returns 0 iff <value> is a legal held-claims record:
   #   non-empty AND contains no newline, tab, or other control byte.
   #   Slice names are hash-consumed for the ref (V5) and base64'd into the blob (W2),
   #   so ":" and ".." are SAFE and must remain claimable (SC1, V5b, V5/V6 capability).
   #   The ONLY invariant to protect is the session-<id>/held-claims one-record-per-line
   #   format, which control bytes (esp. newline/tab) would corrupt.
   # Bash 3.2 / BSD safe: pure case-glob with the POSIX [[:cntrl:]] class.
   _valid_slice_name() {
       local v="$1"
       [ -n "$v" ] || return 1                    # empty
       case "$v" in *[[:cntrl:]]*) return 1 ;; esac  # newline, tab, any control byte
       return 0
   }
   ```

2. **Add exit-on-invalid wrappers for user-supplied identifiers.** Define next to
   `_valid_identifier`:

   ```sh
   validate_session_id() {
       if ! _valid_identifier "$1"; then
           printf 'loom-coord %s: invalid session id (expected [A-Za-z0-9][A-Za-z0-9._-]{0,127}, no "..")\n' "$SUBCOMMAND" >&2
           exit 1
       fi
   }
   validate_slice_name() {
       if ! _valid_slice_name "$1"; then
           printf 'loom-coord %s: invalid slice name (must be non-empty with no newline/tab/control bytes)\n' "$SUBCOMMAND" >&2
           exit 1
       fi
   }
   validate_pid() {
       case "$1" in '' | *[!0-9]*)
           printf 'loom-coord %s: invalid pid (expected digits)\n' "$SUBCOMMAND" >&2
           exit 1 ;;
       esac
       [ "${#1}" -le 20 ] || { printf 'loom-coord %s: pid too long\n' "$SUBCOMMAND" >&2; exit 1; }
   }
   ```

   Exit `1` (usage) matches the helper's existing convention for bad invocation
   (`assert_session`, missing-arg branches).

3. **Add a state-path containment guard + safe session-dir removal.** Define:

   ```sh
   # _assert_state_path <path> — 0 iff <path> is textually rooted at "$STATE_DIR/".
   # Secondary guard; the identifier grammar (no "/", no "..") is the primary
   # containment guarantee.
   _assert_state_path() {
       case "$1" in "$STATE_DIR"/*) return 0 ;; esac
       return 1
   }

   # _remove_session_dir <sid> — remove a session dir by deleting KNOWN files then
   # rmdir (replaces "rm -rf" of a computed path).  No-op (quarantine) on an invalid
   # sid or a target not rooted at STATE_DIR.  rmdir leaves the dir intact if
   # unexpected files remain — quarantining malformed state instead of force-deleting.
   _remove_session_dir() {
       local sid="$1" d
       _valid_identifier "$sid" || return 1
       d="$STATE_DIR/session-$sid"
       _assert_state_path "$d" || return 1
       rm -f "$d/checkpoint" "$d/held-claims" \
             "$d/session.pid" "$d/session.starttime" \
             "$d/renewer.pid" "$d/renewer.starttime" 2>/dev/null || true
       rm -f "$d"/*.tmp.* 2>/dev/null || true    # atomic-write temp files (known pattern)
       rmdir "$d" 2>/dev/null || true
       return 0
   }
   ```

4. **Validate the session id at every user-supplied entry point.**
   - In `assert_session`, after the existing empty check, add
     `validate_session_id "$SESSION_ID"`. This centralizes validation for every
     subcommand that calls `assert_session`.
   - In `cmd_session_start`, after `SESSION_ID` is resolved (whether user-supplied or
     minted) and **before** computing `sess_dir`/`mkdir`, add
     `validate_session_id "$SESSION_ID"` and `_assert_state_path "$sess_dir" || exit 1`.
     (`cmd_session_start` does not call `assert_session`.)
   - In `cmd_cleanup`, when `$SESSION_ID` is non-empty (before deriving
     `cleanup_sid`), add `validate_session_id "$SESSION_ID"`.

5. **Validate slice names at every user-supplied entry point.** In `cmd_claim`,
   `cmd_renew`, `cmd_release_claim`, and `cmd_reclaim`, immediately after each
   subcommand's existing "slice name required" empty check on `$slice`, add
   `validate_slice_name "$slice"`. This calls the **narrow** `_valid_slice_name`
   predicate (Step 1): it rejects only empty/newline/tab/control slice names and
   deliberately **keeps** `:`/`..`/`/`-bearing names claimable (they are hash-consumed
   for the ref, never path material), preserving the V5/V6 capability and keeping SC1
   and V5b green.

6. **Validate the PID.** In `cmd_renewer_start`, after the existing empty check on
   `$spid`, add `validate_pid "$spid"` (before `process_starttime "$spid"`).

7. **Validate session ids decoded from claim blobs before path use, and quarantine
   malformed persisted state.**
   - In `cmd_cleanup`'s sweep loop: after decoding `sid` from the claim blob and after
     the existing empty-sid / non-numeric-ts guards, add
     `if ! _valid_identifier "$sid"; then skipped=$((skipped + 1)); continue; fi`.
     This quarantines a malformed decoded sid: the row is preserved (ref not
     delete-CAS'd, worktree/session dir not touched) and counted as `skipped`, so no
     out-of-tree deletion can be driven by a corrupt blob. Replace the surviving
     `rm -rf "$STATE_DIR/session-$sid"` with `_remove_session_dir "$sid"`. (The
     `wt_sid_match "$sid"` worktree removal is now only reached for a validated sid.)
   - In `cmd_reclaim`: after decoding `cur_sid`, guard the worktree removal — only run
     the `wt_sid_match "$cur_sid"` + `worktree remove -f` block when
     `_valid_identifier "$cur_sid"` succeeds (the claim-ref CAS steal itself is keyed
     on the git-computed ref hash, not the sid, so it is unaffected; only the
     filesystem removal is gated).
   - In `cmd_session_bootstrap` and `cmd_session_end`, when iterating slice names read
     from `held-claims`, skip any line failing **`_valid_slice_name`** (the *narrow*
     slice predicate — quarantine only a byte-corrupt registry line, never a
     legitimately-held `:`/`..` name): inside each `while IFS= read -r slice; do … done`
     loop, after the `[ -z "$slice" ] && continue` guard, add
     `_valid_slice_name "$slice" || continue`. **Using `_valid_slice_name` (not
     `_valid_identifier`) here is load-bearing:** a claim legitimately held under the
     pre-slice rules whose name contains `:` or `..` (SC1/V5b) stays claimed and gets
     re-issued/released normally; only newline/tab/control-corrupted lines are skipped.

8. **Replace the recursive session-dir deletions.** In `cmd_session_end`, replace both
   `rm -rf "$sess_dir"` occurrences with `_remove_session_dir "$SESSION_ID"`
   (`SESSION_ID` is already validated via `assert_session` at the top of the
   subcommand). Confirm (`grep -n 'rm -rf'` on the file) that the only remaining
   `rm -rf` in the helper is none for computed session dirs — every session-dir removal
   now goes through `_remove_session_dir`.

9. **Tests (`plugins/loom/bin/loom-coord.bats`).** Add the negative/adversarial cases
   in Verification below, each proven red→green. **Update the `T3` case** (line ~1087,
   `sid='foo\nbar'`): its decoded sid contains a backslash, which is now malformed
   persisted state. Its expectation changes from *sweep + orphan-worktree-removed* to
   *quarantined*: assert `cleanup` exits 0, reports `skipped` (not `swept 1`), the
   claim ref is **preserved**, and the orphan worktree is **preserved**. Keep it as a
   load-bearing negative proving decoded-blob quarantine (rename its description to
   reflect the new behavior; see Notes).

## Verification

**Gate (fail-closed, must be green before `Implemented`):** the shell gate over the
edited helper and suite —

```sh
shfmt -i 4 -d plugins/loom/bin/loom-coord
shellcheck plugins/loom/bin/loom-coord
LOOM_DIFF_BASE=HEAD scripts/check      # runs shfmt + shellcheck + the full bats suite + repo validation
```

`scripts/check` must exit 0. The full existing `loom-coord.bats` suite (64 cases at
base) must pass unchanged **except** the intentionally-updated `T3` case (Step 9); all
other cases are the regression proof that identifier validation does not reject the
legitimate session ids and slice names the suite uses. Verified mechanically against the
two distinct grammars:

- **Session ids** all match `_valid_identifier` (e.g. `foo`, `foo-bar`, `run1`,
  `ses-authv2-owner`, minted uuids, `ses-SC1`, `ses-V5b`).
- **Slice names** are checked only by the narrow `_valid_slice_name` (non-empty, no
  control bytes). The suite's special-char slice tests therefore **all stay green**,
  including the two that the previous over-restrictive grammar would have broken:
  `SC1` (`claim "slice:foo"`, bats line 1293) and `V5b` (`claim "a..b"`, bats line
  1735) both contain only printable bytes, so both still claim/renew/release
  successfully — as do `foo.lock` (V5a), `Auth`/`auth` (V6). No existing slice literal
  contains a control byte, so `_valid_slice_name` rejects none of them.

The "suite passes unchanged except T3" claim is therefore mechanically true under the
two-grammar design: T3 is the single authorized change (Step 9 / Notes), and no other
case flips.

**New negative cases — each MUST be shown failing on the pre-fix helper (red) and
passing after (green).** Red is demonstrated by running the new test against the helper
before the corresponding fix is applied (or by temporarily reverting the guard); a
green test that never exercised the vulnerable path is not acceptable. Map to the M1
regression list:

1. **Session-id traversal** — `session-start --session 'x/../../victim'` exits 1 and
   creates **no** directory outside `$STATE_DIR` (assert the sentinel target does not
   exist afterward).
2. **Absolute session id** — `--session '/tmp/loom-abs-victim'` exits 1; no out-of-tree
   dir created.
3. **Empty / overlong** — `--session ''` exits 1 (regression: `assert_session`); a
   129-char `--session` exits 1.
4. **Tab and newline** — a session id containing a literal tab, and one containing a
   real newline (built with `printf`), each exit 1.
5. **Unicode separator** — a session id containing U+2044/U+2215 (fraction/division
   slash, multibyte) exits 1.
6. **Malformed decoded session id → no out-of-tree deletion (the core case).** Plant a
   stale claim (via `plant_claim_ref`) whose blob field-1 sid is a traversal string
   (e.g. `../../../../tmp/loom-cleanup-victim`) with a target sentinel dir present;
   run `cleanup` with `LOOM_LEASE_TTL=0`. Assert: exit 0, the row is `skipped` (not
   swept), the **sentinel is untouched**, and the claim ref is preserved. Add the
   symmetric `reclaim` case: a stale claim held by a traversal sid must not drive a
   worktree removal outside the tree.
7. **Slice-name rejection (narrow)** — under a held lock, `claim` (and `renew`) with a
   slice name containing a **newline** (built with `printf`), a **tab**, or another
   control byte each exit 1; empty slice exits 1 (regression). **Positive counterpart
   (capability preserved):** in the same or an adjacent case, assert that `claim` with a
   slice name containing `/`, `:`, or `..` (e.g. `a/b`, `slice:foo`, `a..b`) **succeeds**
   (exit 0) — these are hash-consumed, not path/ref material, and must remain claimable.
   This pair proves the validator protects the `held-claims` line format *without*
   removing the V5/V6 freeform-slice-name capability.
8. **PID rejection** — `renewer-start` with a non-numeric pid (e.g. `1;rm`) exits 1.
9. **Known-file removal / quarantine** — a normal `session-end` removes the known files
   and the (now-empty) session dir (regression: existing session-end cases stay green);
   a `session-end` whose session dir contains an **unexpected** file leaves that file
   **and** the dir in place (rmdir refuses a non-empty dir), proving quarantine over
   `rm -rf`.
10. **T3 (updated)** — decoded sid `foo\nbar` is quarantined by `cleanup` (skipped, ref
    + worktree preserved), per Step 9.

**Portability:** all new code is Bash 3.2 / BSD-safe (pure `case`-glob + `${#}`; no
`[[ =~ ]]`, no GNU-only flags). The suite already runs under Bash 3.2 (macOS floor) and
Bash 5.x (Ubuntu) via `LOOM_TEST_BASH`/`LOOM_EXPECTED_BASH_VERSION`; the new cases must
pass under both lanes.

## Notes

- **Intentional behavior change — `T3`.** Before this slice, `cmd_cleanup` used a
  decoded claim-blob sid (including a byte-injected one like `foo\nbar`) to drive
  `worktree remove -f`. M1 requires decoded-blob sids to be validated before path use
  and malformed persisted state to be quarantined, so this slice deliberately flips the
  malformed-sid path from *act* to *quarantine*. The `T3` case is updated (not deleted)
  to assert the new quarantine outcome and remains the load-bearing proof for the
  decoded-blob path. This is called out here so the blind evaluator sees the changed
  assertion is plan-authorized, not silent test-weakening.
- **Quarantine, not reap, for invalid decoded sids.** Step 7 preserves (skips) a claim
  row whose decoded sid is invalid rather than delete-CAS'ing its ref, on the
  fail-closed principle (ADR 0023 §8; loom-coord's own fail-closed contract) that a
  coordination helper never performs a destructive action it cannot prove is safe. A
  corrupt claim row can only arise from adversarial/hand-edited state once user-supplied
  ids are validated at write time (Steps 4–5); leaving it for an operator is safer than
  acting on it.
- **Two grammars, by design.** Session ids (and decoded-from-blob sids and PIDs) form
  filesystem paths / process args, so they take the strict `_valid_identifier` grammar
  (no `/`, no `..`). Slice names are hash-consumed for the git ref (V5) and base64'd into
  the claim blob (W2) — they are **never** path or ref material — so they take the narrow
  `_valid_slice_name` predicate that guards only the `held-claims` one-record-per-line
  format (reject empty/newline/tab/control). Restricting slice names to the session
  grammar would remove the tested V5/V6 freeform-slice capability (SC1 `slice:foo`, V5b
  `a..b`) with no safety benefit and would strand any pre-existing `:`-named claim at the
  Step 7 held-claims guard; this plan deliberately does not do that.
- **`Checkpoint arguments` M1 bullet — dispositioned out of scope.** The M1 section lists
  "Checkpoint arguments where applicable." Verified not applicable: `cmd_checkpoint_write`
  writes `$EXTRA_ARGS` (or stdin) as file **content** to `$sess_dir/checkpoint`, where
  `sess_dir` is derived from the already-validated `SESSION_ID`. The argument never forms
  a path, ref, or process identifier — it is free-form payload — so "where applicable"
  resolves to *no validation needed*. Recorded here so the M1 bullet is visibly
  discharged, not silently dropped.
- **Round-0 revision (plan-eval FAIL → this pass).** The blind plan-eval flagged that the
  original draft applied the strict `_valid_identifier` grammar to slice names, which
  would break SC1 and V5b and contradict the V5/V6 freeform-slice design. This revision
  drops the slice-name grammar restriction: it introduces the narrow `_valid_slice_name`
  predicate (Step 1), routes slice-name validation (Steps 2/5) and the held-claims-line
  guard (Step 7) through it, restores the mechanically-true "suite passes unchanged except
  T3" claim (Verification), corrects the Context traversal example to `x/../../victim`,
  and dispositions the checkpoint-arguments bullet above. The T3 quarantine flip and all
  session-id / decoded-sid / PID / `_remove_session_dir` scope are unchanged (the
  evaluator confirmed them sound).
- **Sealed-package review.** Per ADR 0023 §1 this is a code-bearing bootstrap slice, so
  at `Implemented` the orchestrator runs the §3 three cold auxiliary finders and the §4
  independent evaluator against the exact committed `base..head`; the evaluator owns the
  PASS/FAIL. This plan does not itself constitute that review.
