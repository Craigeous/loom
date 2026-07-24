#!/usr/bin/env bats
# Test suite for the macOS dual-client dogfood harness
# (macos-dual-client-dogfood plan Step 8/9/10; ADR 0024). Runs entirely in
# DRY FIXTURE MODE against a self-contained, multi-mode stub client
# (LOOM_DOGFOOD_CLAUDE_BIN / LOOM_DOGFOOD_CODEX_BIN) -- this suite MUST NEVER
# spawn a real claude/codex process. The harness's OWN process topology
# (supervisor/worker fork+exec, process groups, signals) is exercised for
# real: only the pinned native CLI at the bottom of that topology is
# replaced. The code evaluator re-runs this suite as the shell gate's TEST
# step.
bats_require_minimum_version 1.5.0

HARNESS="${BATS_TEST_DIRNAME}/../macos-dual-client-dogfood"
REPO_ROOT="$(CDPATH='' cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)"

setup_file() {
    : "${LOOM_TEST_BASH:?LOOM_TEST_BASH is required}"
    : "${LOOM_EXPECTED_BASH_VERSION:?LOOM_EXPECTED_BASH_VERSION is required}"
    case "$LOOM_TEST_BASH" in /*) ;; *) return 1 ;; esac
    [ -x "$LOOM_TEST_BASH" ]
    [[ "$($LOOM_TEST_BASH -c 'printf %s "$BASH_VERSION"')" =~ $LOOM_EXPECTED_BASH_VERSION ]]
}

# ---------------------------------------------------------------------------
# Fixture: a multi-mode dry-fixture stub client, built fresh per test so
# each test's LOOM_DOGFOOD_STUB_MODE is isolated. Never touches a real
# client. Identifies which client it is standing in for from which home
# variable the harness's fixture-driven environment redirect set.
# ---------------------------------------------------------------------------

make_stub_client() {
    STUB_DIR="$(mktemp -d)"
    STUB="$STUB_DIR/dogfood-client-stub"
    cat >"$STUB" <<'EOF'
#!/usr/bin/env bash
set -u
if [ -n "${LOOM_STUB_LOG:-}" ]; then printf 'ARGV: %s\n' "$*" >>"$LOOM_STUB_LOG"; fi
if [ -n "${CLAUDE_CONFIG_DIR:-}" ]; then
    home_root="$CLAUDE_CONFIG_DIR"
    cache_dir="$home_root/plugins/cache/loom/loom"
elif [ -n "${CODEX_HOME:-}" ]; then
    home_root="$CODEX_HOME"
    cache_dir="$home_root/plugins/cache/loom/loom/0.2.0"
else
    printf 'dogfood-client-stub: no client home in environment\n' >&2
    exit 9
fi
mode="${LOOM_DOGFOOD_STUB_MODE:-ok}"
[ -n "${LOOM_DOGFOOD_STUB_SLEEP:-}" ] && sleep "$LOOM_DOGFOOD_STUB_SLEEP"
op=""
if [ "${1:-}" = plugin ]; then
    case "${2:-}" in
    marketplace)
        case "${3:-}" in
        add) op=marketplace-add ;;
        remove) op=marketplace-remove ;;
        esac
        ;;
    install | add) op=install ;;
    uninstall | remove) op=uninstall ;;
    list) op=list ;;
    esac
fi
[ -n "$op" ] || { printf 'dogfood-client-stub: unrecognized argv: %s\n' "$*" >&2; exit 9; }
case "$mode" in
infra-block)
    printf 'You have hit your usage limit for this billing period.\n'
    exit 1
    ;;
fail)
    printf 'dogfood-client-stub: simulated product failure for %s\n' "$op" >&2
    exit 1
    ;;
no-postcondition)
    printf 'stub %s ok (no postcondition)\n' "$op"
    exit 0
    ;;
esac
case "$op" in
marketplace-add | install)
    mkdir -p "$cache_dir"
    printf '{"name":"loom","version":"0.2.0","op":"%s"}\n' "$op" >"$cache_dir/plugin.json"
    if [ "$mode" = escape ]; then
        run_root=$(dirname -- "$home_root")
        mkdir -p "$run_root/project"
        printf 'escaped\n' >"$run_root/project/escaped-by-stub"
    fi
    printf 'stub %s ok\n' "$op"
    ;;
uninstall | marketplace-remove)
    rm -rf "$home_root/plugins"
    if [ "$mode" = residue ]; then
        # Sibling of (not inside) the exact cacheLayout path: satisfies each
        # mutation's own narrow cache-absent postcondition while still
        # tripping the broader post-uninstall zero-discovery/residue check.
        mkdir -p "$home_root/plugins"
        printf 'left behind\n' >"$home_root/plugins/residue"
    fi
    printf 'stub %s ok\n' "$op"
    ;;
list)
    printf '[{"name":"loom","version":"0.2.0"}]\n'
    ;;
esac
EOF
    chmod +x "$STUB"
    export LOOM_DOGFOOD_CLAUDE_BIN="$STUB"
    export LOOM_DOGFOOD_CODEX_BIN="$STUB"
}

setup() {
    make_stub_client
    export LOOM_DOGFOOD_HANDSHAKE_TIMEOUT_SECONDS=2
    unset LOOM_DOGFOOD_INJECT LOOM_DOGFOOD_STUB_MODE LOOM_DOGFOOD_SPAWN_ORPHAN LOOM_DOGFOOD_STUB_SLEEP
    RUN_ROOT=""
    ORPHAN_PIDS=()
}

teardown() {
    local p
    for p in "${ORPHAN_PIDS[@]:-}"; do
        [ -n "$p" ] && kill -9 "$p" 2>/dev/null
    done
    if [ -n "${RUN_ROOT:-}" ] && [ -d "${RUN_ROOT:-}" ]; then rm -rf -- "$RUN_ROOT"; fi
    if [ -n "${STUB_DIR:-}" ] && [ -d "$STUB_DIR" ]; then rm -rf -- "$STUB_DIR"; fi
}

harness() { run "$LOOM_TEST_BASH" "$HARNESS" "$@"; }

prepare_run() {
    run "$LOOM_TEST_BASH" "$HARNESS" --prepare --dry-fixture
    [ "$status" -eq 0 ]
    RUN_ROOT="$output"
    [ -d "$RUN_ROOT" ]
}

mutate() { run "$LOOM_TEST_BASH" "$HARNESS" __mutation "$RUN_ROOT" "$@"; }

# mutate_direct -- bypasses bats' `run` helper, which reaps any descendant
# that escapes its own command's process group once the wrapped command
# completes (observed directly: a `set -m`-backgrounded, re-process-grouped
# grandchild that reliably survives a plain invocation is killed within
# ~0.5s when the SAME spawn happens under `run`). Only the orphan/escape
# tests need this; they assert on the journal file afterward instead of
# $status/$output.
mutate_direct() { "$LOOM_TEST_BASH" "$HARNESS" __mutation "$RUN_ROOT" "$@"; }

# ---------------------------------------------------------------------------
# --prepare: containment / marker / schema
# ---------------------------------------------------------------------------

@test "prepare creates a marker-owned run below the canonical temp root with schema-valid state" {
    prepare_run
    [ -f "$RUN_ROOT/marker" ]
    run jq -e '.schema=="loom-dogfood-state/v1" and .phase=="prepared" and .dryFixture==true' "$RUN_ROOT/state.json"
    [ "$status" -eq 0 ]
    for d in claude-home codex-home project system-home tmp; do [ -d "$RUN_ROOT/$d" ]; done
}

@test "RED>GREEN: prepare rejects a symlinked TMPDIR, succeeds against the real dir" {
    real_tmp="$(mktemp -d)"
    real_tmp="$(CDPATH='' cd "$real_tmp" && pwd -P)"
    link_tmp="$(mktemp -u)"
    ln -s "$real_tmp" "$link_tmp"
    TMPDIR="$link_tmp" run "$LOOM_TEST_BASH" "$HARNESS" --prepare --dry-fixture
    [ "$status" -eq 3 ]
    TMPDIR="$real_tmp" run "$LOOM_TEST_BASH" "$HARNESS" --prepare --dry-fixture
    [ "$status" -eq 0 ]
    rm -rf -- "$output" "$real_tmp" "$link_tmp"
}

@test "RED>GREEN: prepare rejects a nonexistent TMPDIR, succeeds against a real one" {
    TMPDIR="/nonexistent/loom-dogfood-tmpdir" run "$LOOM_TEST_BASH" "$HARNESS" --prepare --dry-fixture
    [ "$status" -eq 3 ]
    real_tmp="$(mktemp -d)"
    TMPDIR="$real_tmp" run "$LOOM_TEST_BASH" "$HARNESS" --prepare --dry-fixture
    [ "$status" -eq 0 ]
    rm -rf -- "$output" "$real_tmp"
}

@test "RED>GREEN: prepare rejects run-root/owner-home overlap, succeeds when disjoint" {
    overlap_home="$(mktemp -d)"
    HOME="$overlap_home" TMPDIR="$overlap_home" run "$LOOM_TEST_BASH" "$HARNESS" --prepare --dry-fixture
    [ "$status" -eq 3 ]
    disjoint_home="$(mktemp -d)"
    HOME="$disjoint_home" run "$LOOM_TEST_BASH" "$HARNESS" --prepare --dry-fixture
    [ "$status" -eq 0 ]
    rm -rf -- "$output" "$overlap_home" "$disjoint_home"
}

@test "RED>GREEN: phase entry rejects a marker mismatch, succeeds once restored" {
    prepare_run
    cp "$RUN_ROOT/marker" "$RUN_ROOT/marker.bak"
    printf 'wrong-marker' >"$RUN_ROOT/marker"
    mutate claude-marketplace-add claude marketplace-add
    [ "$status" -eq 3 ]
    cp "$RUN_ROOT/marker.bak" "$RUN_ROOT/marker"
    mutate claude-marketplace-add claude marketplace-add
    [ "$status" -eq 0 ]
}

@test "RED>GREEN: phase entry rejects candidate drift, succeeds once restored" {
    prepare_run
    cp "$RUN_ROOT/state.json" "$RUN_ROOT/state.json.bak"
    jq '.candidate="0000000000000000000000000000000000000000"' "$RUN_ROOT/state.json.bak" >"$RUN_ROOT/state.json"
    mutate claude-marketplace-add claude marketplace-add
    [ "$status" -eq 3 ]
    cp "$RUN_ROOT/state.json.bak" "$RUN_ROOT/state.json"
    mutate claude-marketplace-add claude marketplace-add
    [ "$status" -eq 0 ]
}

@test "prepare rejects an unresolved --exercise before --prepare (missing run root)" {
    run "$LOOM_TEST_BASH" "$HARNESS" --exercise "/nonexistent/loom-dogfood-run"
    [ "$status" -eq 3 ]
}

# ---------------------------------------------------------------------------
# Happy path: one full mutation, and the full exercise/uninstall/clean flow
# ---------------------------------------------------------------------------

@test "one native mutation journals the exact record sequence and preserves worker PID across exec" {
    prepare_run
    mutate claude-install claude install
    [ "$status" -eq 0 ]
    [ "$output" = applied ]
    journal="$RUN_ROOT/control/journal/claude-install.1.ndjson"
    run jq -sc '[.[].type]' "$journal"
    [ "$status" -eq 0 ]
    [ "$output" = '["intent","supervisor-hello","supervisor-launch","supervisor-release","native-hello","native-launch","native-release","terminal","applied"]' ]
    native_hello_pid=$(jq -r 'select(.type=="native-hello").pid' "$journal")
    native_launch_pid=$(jq -r 'select(.type=="native-launch").pid' "$journal")
    [ "$native_hello_pid" = "$native_launch_pid" ]
    [ -e "$RUN_ROOT/claude-home/plugins/cache/loom/loom/plugin.json" ]
}

@test "hash chain is contiguous: each record's prevHash equals the previous record's hash" {
    prepare_run
    mutate claude-install claude install
    [ "$status" -eq 0 ]
    run jq -s -e '. as $arr | [range(0; ($arr|length)-1) | ($arr[.+1].prevHash == $arr[.].hash)] | all' \
        "$RUN_ROOT/control/journal/claude-install.1.ndjson"
    [ "$status" -eq 0 ]
    [ "$output" = true ]
}

@test "full exercise -> uninstall -> clean succeeds end to end and leaves zero residue" {
    prepare_run
    harness --exercise "$RUN_ROOT"
    [ "$status" -eq 0 ]
    run jq -r .phase "$RUN_ROOT/state.json"
    [ "$output" = exercised ]
    harness --uninstall "$RUN_ROOT"
    [ "$status" -eq 0 ]
    run jq -r .phase "$RUN_ROOT/state.json"
    [ "$output" = complete ]
    [ ! -e "$RUN_ROOT/claude-home/plugins/cache/loom/loom" ]
    [ ! -e "$RUN_ROOT/codex-home/plugins/cache/loom/loom/0.2.0" ]
    harness --clean "$RUN_ROOT"
    [ "$status" -eq 0 ]
    [ ! -d "$RUN_ROOT" ]
    receipt_dir="$(git -C "$REPO_ROOT" rev-parse --path-format=absolute --git-common-dir)/loom/dogfood/receipts"
    ls "$receipt_dir"/*.json >/dev/null
    rm -f "$receipt_dir"/*.json
    RUN_ROOT=""
}

@test "residue after uninstall is refused (exit 6)" {
    prepare_run
    harness --exercise "$RUN_ROOT"
    [ "$status" -eq 0 ]
    LOOM_DOGFOOD_STUB_MODE=residue harness --uninstall "$RUN_ROOT"
    [ "$status" -eq 6 ]
}

@test "an unmet postcondition with a clean exit is a product failure (exit 5), not a false success" {
    prepare_run
    LOOM_DOGFOOD_STUB_MODE=no-postcondition mutate claude-install claude install
    [ "$status" -eq 5 ]
    [ "$output" = product-failure ]
}

@test "a mutation that writes outside its allowed roots is quarantined (exit 3)" {
    prepare_run
    LOOM_DOGFOOD_STUB_MODE=escape mutate claude-install claude install
    [ "$status" -eq 3 ]
    [ "$output" = quarantine ]
    run jq -r .phase "$RUN_ROOT/state.json"
    [ "$output" = quarantined ]
}

@test "an infrastructure-block marker in native output classifies exit 4, not a product failure" {
    prepare_run
    LOOM_DOGFOOD_STUB_MODE=infra-block harness --exercise "$RUN_ROOT"
    [ "$status" -eq 4 ]
    run jq -r .phase "$RUN_ROOT/state.json"
    [ "$output" = infrastructure-blocked ]
}

# ---------------------------------------------------------------------------
# Signals: 130 for INT, 143 for TERM
# ---------------------------------------------------------------------------

@test "INT during a mutation yields exit 130" {
    prepare_run
    # job control (set -m) is required so the backgrounded orchestrator does
    # NOT inherit an un-trappable SIG_IGN disposition for INT/TERM (the
    # classic "signals ignored on entry to a non-interactive async shell
    # cannot be trapped" rule) -- exactly the scenario a real interactive
    # Ctrl-C does not hit, so this only matters for the test harness itself.
    set -m
    LOOM_DOGFOOD_STUB_SLEEP=3 "$LOOM_TEST_BASH" "$HARNESS" __mutation "$RUN_ROOT" claude-install claude install &
    pid=$!
    set +m
    sleep 0.5
    kill -INT "$pid"
    status=0
    wait "$pid" || status=$?
    [ "$status" -eq 130 ]
}

@test "TERM during a mutation yields exit 143" {
    prepare_run
    set -m
    LOOM_DOGFOOD_STUB_SLEEP=3 "$LOOM_TEST_BASH" "$HARNESS" __mutation "$RUN_ROOT" claude-install claude install &
    pid=$!
    set +m
    sleep 0.5
    kill -TERM "$pid"
    status=0
    wait "$pid" || status=$?
    [ "$status" -eq 143 ]
}

# ---------------------------------------------------------------------------
# Injection matrix: interruption around every journal record. Each case
# proves (a) no mutation occurred before the durable identity it targets,
# (b) exactly one clean resolution on retry, (c) no duplicate/live process
# survives, and (d) the journal never reuses or overwrites the attempt.
# ---------------------------------------------------------------------------

assert_no_live_orphan() {
    local token="$1"
    run pgrep -f -- "$token"
    [ "$status" -ne 0 ]
}

@test "injection before:intent: nothing is journaled, clean retry succeeds" {
    prepare_run
    LOOM_DOGFOOD_INJECT=before:intent mutate claude-install claude install
    [ ! -e "$RUN_ROOT/control/journal/claude-install.1.ndjson" ]
    mutate claude-install claude install
    [ "$status" -eq 0 ]
    [ "$output" = applied ]
}

@test "injection after:intent (supervisor never spawned): aborts, no cache mutation, clean retry succeeds" {
    prepare_run
    LOOM_DOGFOOD_INJECT=after:intent mutate claude-install claude install
    # The orchestrator itself is SIGKILLed at the injection point.
    [ "$status" -eq 137 ]
    [ ! -e "$RUN_ROOT/claude-home/plugins/cache/loom/loom" ]
    mutate claude-install claude install
    [ "$status" -eq 0 ]
    [ "$output" = applied ]
    run jq -sc '[.[].type]' "$RUN_ROOT/control/journal/claude-install.1.ndjson"
    [[ "$output" == *'"aborted-before-native"]' ]]
}

@test "injection after:supervisor-hello (supervisor dies before release): no mutation, atomic release recovery on retry" {
    prepare_run
    LOOM_DOGFOOD_INJECT=after:supervisor-hello mutate claude-install claude install
    [ "$status" -eq 3 ]
    [ ! -e "$RUN_ROOT/claude-home/plugins/cache/loom/loom" ]
    token=$(jq -r 'select(.type=="intent").token' "$RUN_ROOT/control/journal/claude-install.1.ndjson")
    assert_no_live_orphan "$token"
    mutate claude-install claude install
    [ "$status" -eq 0 ]
    [ "$output" = applied ]
}

@test "injection after:native-hello (worker dies before native-release): no mutation, clean retry succeeds" {
    prepare_run
    LOOM_DOGFOOD_INJECT=after:native-hello mutate claude-install claude install
    [ "$status" -eq 3 ]
    [ ! -e "$RUN_ROOT/claude-home/plugins/cache/loom/loom" ]
    mutate claude-install claude install
    [ "$status" -eq 0 ]
    [ "$output" = applied ]
}

@test "injection before:exec (worker dies with native-release durable, before exec): resume never relaunches, terminal records the kill" {
    prepare_run
    # mutate_direct (not `run`): this case depends on the durable supervisor
    # -- living in its own escaped process group by design -- surviving
    # long enough to write terminal; bats' `run` reaps exactly that kind of
    # escaped descendant once the wrapped command returns (see mutate_direct).
    LOOM_DOGFOOD_INJECT=before:exec mutate_direct claude-install claude install || true
    # Release was durable, the durable supervisor stayed alive and recorded
    # the killed worker's exit in terminal: an unambiguous failed command,
    # not an ambiguous quarantine, and never a silent relaunch.
    [ ! -e "$RUN_ROOT/claude-home/plugins/cache/loom/loom" ]
    journal="$RUN_ROOT/control/journal/claude-install.1.ndjson"
    run jq -sc '[.[].type]' "$journal"
    [[ "$output" == *native-release* ]]
    [ "$(jq -r 'select(.type=="terminal").nativeExit' "$journal")" = "137" ]
    [ "$(jq -r 'select(.type=="applied").status' "$journal")" = "failed" ]
    # never relaunched under a new attempt id:
    [ ! -e "$RUN_ROOT/control/journal/claude-install.2.ndjson" ]
}

@test "injection supervisor-die-while-worker-continues: durable worker identity prevents a hidden orphan; reconciles to recovered-after-apply" {
    prepare_run
    LOOM_DOGFOOD_INJECT=supervisor-die-while-worker-continues mutate claude-install claude install
    # the worker (now the exec'd stub client) legitimately keeps running and
    # completes the mutation even though the supervisor died mid-flight.
    for _ in $(seq 1 40); do
        [ -e "$RUN_ROOT/claude-home/plugins/cache/loom/loom/plugin.json" ] && break
        sleep 0.1
    done
    [ -e "$RUN_ROOT/claude-home/plugins/cache/loom/loom/plugin.json" ]
    mutate claude-install claude install
    [ "$status" -eq 0 ]
    [ "$output" = applied ]
    run jq -sc '[.[].type]' "$RUN_ROOT/control/journal/claude-install.1.ndjson"
    [[ "$output" == *recovered-after-apply* ]]
}

@test "exhausting resume attempts under a persistent fault quarantines rather than looping forever" {
    prepare_run
    LOOM_DOGFOOD_INJECT=after:supervisor-hello mutate claude-install claude install
    [ "$status" -eq 3 ]
    [ "$output" = quarantine ]
}

# ---------------------------------------------------------------------------
# Descendant / process-group orphan proof
# ---------------------------------------------------------------------------

@test "an escaped, token-tagged descendant is detected and blocks --clean until it dies" {
    prepare_run
    LOOM_DOGFOOD_SPAWN_ORPHAN=escaped mutate_direct claude-install claude install
    [ "$(jq -r 'select(.type=="applied").status' "$RUN_ROOT/control/journal/claude-install.1.ndjson")" = applied ]
    token=$(jq -r 'select(.type=="intent").token' "$RUN_ROOT/control/journal/claude-install.1.ndjson")
    for _ in $(seq 1 20); do pgrep -f -- "$token" >/dev/null && break; sleep 0.1; done
    run pgrep -f -- "$token"
    [ "$status" -eq 0 ]
    ORPHAN_PIDS=($output)
    # Resolve the phase directly (test-owned state) so --clean gets past
    # the unresolved-phase refusal and exercises the token-liveness proof.
    jq '.phase="failed"' "$RUN_ROOT/state.json" >"$RUN_ROOT/state.json.new"
    mv "$RUN_ROOT/state.json.new" "$RUN_ROOT/state.json"
    harness --clean "$RUN_ROOT"
    [ "$status" -eq 3 ]
    [[ "$output" == *"live token-bound process"* ]]
    [ -d "$RUN_ROOT" ]
    for p in "${ORPHAN_PIDS[@]}"; do kill -9 "$p" 2>/dev/null; done
    for _ in $(seq 1 20); do pgrep -f -- "$token" >/dev/null || break; sleep 0.1; done
    harness --clean "$RUN_ROOT"
    [ "$status" -eq 0 ]
    receipt_dir="$(git -C "$REPO_ROOT" rev-parse --path-format=absolute --git-common-dir)/loom/dogfood/receipts"
    rm -f "$receipt_dir"/*.json
    RUN_ROOT=""
}

@test "a descendant that stays inside the process group but retains the token still blocks --clean" {
    prepare_run
    LOOM_DOGFOOD_SPAWN_ORPHAN=in-group mutate_direct claude-install claude install
    [ "$(jq -r 'select(.type=="applied").status' "$RUN_ROOT/control/journal/claude-install.1.ndjson")" = applied ]
    token=$(jq -r 'select(.type=="intent").token' "$RUN_ROOT/control/journal/claude-install.1.ndjson")
    for _ in $(seq 1 20); do pgrep -f -- "$token" >/dev/null && break; sleep 0.1; done
    run pgrep -f -- "$token"
    [ "$status" -eq 0 ]
    ORPHAN_PIDS=($output)
    jq '.phase="failed"' "$RUN_ROOT/state.json" >"$RUN_ROOT/state.json.new"
    mv "$RUN_ROOT/state.json.new" "$RUN_ROOT/state.json"
    harness --clean "$RUN_ROOT"
    [ "$status" -eq 3 ]
    [[ "$output" == *"live token-bound process"* ]]
    for p in "${ORPHAN_PIDS[@]}"; do kill -9 "$p" 2>/dev/null; done
    for _ in $(seq 1 20); do pgrep -f -- "$token" >/dev/null || break; sleep 0.1; done
    harness --clean "$RUN_ROOT"
    [ "$status" -eq 0 ]
    receipt_dir="$(git -C "$REPO_ROOT" rev-parse --path-format=absolute --git-common-dir)/loom/dogfood/receipts"
    rm -f "$receipt_dir"/*.json
    RUN_ROOT=""
}

# ---------------------------------------------------------------------------
# --clean refusals
# ---------------------------------------------------------------------------

@test "RED>GREEN: --clean refuses an unresolved run, succeeds once resolved" {
    prepare_run
    harness --clean "$RUN_ROOT"
    [ "$status" -eq 3 ]
    harness --exercise "$RUN_ROOT"
    harness --uninstall "$RUN_ROOT"
    harness --clean "$RUN_ROOT"
    [ "$status" -eq 0 ]
    RUN_ROOT=""
}

@test "--clean refuses a symlinked run-root argument" {
    prepare_run
    link="$(mktemp -u)"
    ln -s "$RUN_ROOT" "$link"
    harness --exercise "$RUN_ROOT"
    harness --uninstall "$RUN_ROOT"
    run "$LOOM_TEST_BASH" "$HARNESS" --clean "$link"
    [ "$status" -eq 3 ]
    rm -f "$link"
    harness --clean "$RUN_ROOT"
    RUN_ROOT=""
}

@test "--clean refuses a path outside the temp prefix" {
    outside="$(mktemp -d /tmp/loom-dogfood-outside.XXXXXX 2>/dev/null || mktemp -d)"
    run "$LOOM_TEST_BASH" "$HARNESS" --clean "$outside"
    [ "$status" -eq 3 ]
    rmdir "$outside" 2>/dev/null || rm -rf -- "$outside"
}

@test "a quarantined run is cleanable only after a fresh complete inventory proves ownership" {
    prepare_run
    LOOM_DOGFOOD_STUB_MODE=escape mutate claude-install claude install
    [ "$status" -eq 3 ]
    harness --clean "$RUN_ROOT"
    [ "$status" -eq 0 ]
    [ ! -d "$RUN_ROOT" ]
    RUN_ROOT=""
}
