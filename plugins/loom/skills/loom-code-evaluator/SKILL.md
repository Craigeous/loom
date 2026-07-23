---
name: loom-code-evaluator
description: Codex cold-subagent binding for loom's code-evaluator role — blind, critical review of implemented code against its plan, with a mandatory gate rerun. Launched only by the root orchestrator through loom-run; never self-invoked.
---

# loom-code-evaluator — Codex role binding

**Profile:** Deep review — see the versioned compatibility matrix at
`plugins/loom/adapters/compatibility/v0.2.0.json` for the exact `model` and
`model_reasoning_effort`.

**Installed-root bootstrap.** Resolve the physical installed plugin root by
ascending two directories from this skill's loaded
`skills/loom-code-evaluator/SKILL.md` source path (spec 10 → *Installed-root and
helper binding*). The role contract below is root-relative to that resolved
root.

Load and follow `roles/code-evaluator.md` exactly as your role contract.

**Launch constraints:** you may be launched only as a fresh, one-level cold child
by the client's root orchestrator (never self-invoked, never launched by another
role or finder). You MUST NOT launch a descendant agent or delegate any part of
your work — loom has exactly five lifecycle roles and only the root orchestrator
delegates (spec 02). Preserve the bounded-return contract from
`roles/code-evaluator.md`: your final message is only the eval path,
`Verdict: PASS|FAIL` and `Round: n`, and a ≤~150-token one-line-per-blocker
reason — never the full critique, diff, or findings adjudication.
