# loom

**loom** weaves a development loop out of five specialist roles —
*researcher, planner, plan evaluator, developer, code evaluator* — and drives
them through a file-based, spec-driven process so that work survives context
resets and is reviewed through independent cold-agent evaluation with controlled
inputs.

loom currently provides its proven behavioral workflow through a Claude Code
**plugin**. The same distribution now also carries privately dogfood-proven Codex
CLI packaging, hooks, roles, and helpers on Apple silicon; public Codex support is
not yet released. Inside a repository, loom detects
how aligned that repo is with loom's conventions and either bootstraps,
migrates, or resumes work. A thin orchestrator spawns each role as a **cold
agent** on the model best suited to its job, hands off work through files in
`.docs/`, and stops at the scope boundary or human checkpoint you declared.

## Why

- **Context drift** — long sessions lose the thread. loom keeps durable memory in
  `.docs/` so any cold agent can resume from files alone.
- **Controlled evaluation** — independent cold-agent evaluation with controlled
  inputs separates producing and evaluating invocations and prohibits self-approval.
- **Token-smart automation** — each role runs on the cheapest model that can do
  its job well; only judgment-heavy roles use the strongest model.

## Status

**Private Apple-silicon dual-client dogfood checkpoint reached.** The reproducible
gate and static Claude Code/Codex packaging contracts are on remote `main`. On an
isolated Darwin `arm64` host, the `macos-dual-client-dogfood` slice privately proved
the shared workflows/roles, hook wire, `loom-resolve-helper` installed-root
resolution, and the full native install/reinstall/uninstall/marketplace-remove
lifecycle for both Claude Code 2.1.218+ and Codex CLI 0.144.6, plus a real cold
Claude role launch. Codex's cold role launch itself hit a live `401` from an
isolated, credential-less `CODEX_HOME` by design — recorded as
`infrastructure-blocked`, not a product defect. Accepted ADR 0024 inserted this
private checkpoint before M1 without changing the v0.2 Ubuntu/macOS-Intel release
obligations or its M0 through M7 release gate; **this is not a public release and
not public Codex support**. The authoritative design lives in
[`.docs/spec/`](.docs/spec/README.md) — start with
[`00-overview.md`](.docs/spec/00-overview.md); decisions are in
[`.docs/ADR/`](.docs/ADR/README.md).

## Repository layout

```
loom/                          # this repo = the loom project + its marketplace
├── .claude-plugin/marketplace.json   # lists the loom plugin (source ./plugins/loom)
├── .agents/plugins/marketplace.json  # Codex static catalog scaffold
├── plugins/loom/              # the shippable plugin
│   ├── .claude-plugin/plugin.json
│   ├── .codex-plugin/plugin.json
│   ├── adapters/compatibility/v0.2.0.json
│   ├── adapters/roots/        # Claude/Codex installed-root contracts
│   ├── commands/              # /loom:run + one-off /loom:research, :plan, :eval-plan, :develop, :eval-code, :status, :init
│   ├── agents/                # thin Claude adapters over roles/*.md contracts
│   ├── roles/                 # canonical researcher/planner/plan-evaluator/developer/code-evaluator contracts
│   ├── bin/                   # loom-coord, loom-resolve-helper, loom-launch-role
│   ├── hooks/                 # git-identity-guard.sh, precompact-write-ahead-backstop.sh; one shared hooks.json
│   └── skills/loom-playbook/  # templates, rubrics, conventions, gates
├── scripts/check              # pinned, reproducible local gate
├── scripts/macos-dual-client-dogfood  # private Apple-silicon dogfood harness
└── .docs/                     # loom's OWN design memory (dogfooding) — not shipped
```

## Install

Claude Code's currently proven local plugin path is:

```sh
/plugin marketplace add craigeous/loom     # or: /plugin marketplace add ./loom (local)
/plugin install loom@loom
claude plugin validate plugins/loom --strict # optional: check Claude metadata
```

Codex CLI installation, `$loom-*` discovery, hooks, roles, helpers, and uninstall are
now proven behind private Apple-silicon dogfood evidence (`macos-dual-client-dogfood`,
Codex CLI 0.144.6) but remain undocumented as public supported behavior pending a
public release decision. The intended mapping is specified in
[`07-command-surface.md`](.docs/spec/07-command-surface.md), not established by the
static manifest alone.

Then, inside any repo, run the orchestrated loop or a single role pass. Plugin
commands are namespaced as `/loom:<name>`:

| Command | What it does |
|---|---|
| `/loom:run [scope]` | the orchestrator — detect state, take scope/gates, drive the roles |
| `/loom:research <topic>` | one-off researcher pass |
| `/loom:plan` | one-off planner pass |
| `/loom:eval-plan [artifact]` | one-off independent cold-agent evaluation with controlled inputs |
| `/loom:develop [slice]` | one-off developer pass |
| `/loom:eval-code [slice]` | one-off independent cold-agent evaluation with controlled inputs |
| `/loom:status` | print `.docs/` state |
| `/loom:init` | initialize/align this repo to loom |

loom operates on the current repo's `.docs/`.

loom **dogfoods its own structure**: this repository is managed by the very
process loom implements.

## Development check

Run the complete gate from any working directory with:

```sh
/absolute/path/to/loom/scripts/check
```

The check pins shfmt 3.13.1, ShellCheck 0.11.0, Bats 1.13.0, Node 22.17.0,
Claude Code 2.1.216, Ajv 8.17.1, YAML 2.8.0, markdown-it 14.1.0, and
github-slugger 2.0.0. Bootstrap prerequisites are `curl` and `tar`; production
requires Bash 3.2+, Git 2.34+, and jq 1.6+. The exact supported client floors are
Claude Code 2.1.216 and Codex CLI 0.144.6.

The v0.2 host baseline is Ubuntu 22.04/24.04 x86-64 and macOS 14+ on Apple
silicon or Intel where the selected client is supported. Native Windows,
PowerShell, Git Bash/MSYS2, Cygwin, and WSL are unsupported. CI covers both Ubuntu
LTS releases, macOS Apple silicon, macOS Intel, Bash 3.2.57, and Bash 5.x.

The checked Codex manifest/catalog, compatibility matrix, and installed-root
bindings are static scaffolding only. Private Apple-silicon dogfood evidence in
[`.docs/evaluations/macos-dual-client-dogfood-evidence.json`](.docs/evaluations/macos-dual-client-dogfood-evidence.json)
additionally proves real Codex installation, hook activation, workflow invocation,
helper resolution, and uninstall — a role launch remains `infrastructure-blocked`
in the isolated, credential-less dogfood environment. This is private evidence, not
a public-release claim.
