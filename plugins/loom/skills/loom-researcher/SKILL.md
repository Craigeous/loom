---
name: loom-researcher
description: Codex cold-subagent binding for loom's researcher role — gathers and distills cited context for planning. Launched only by the root orchestrator through loom-run; never self-invoked.
---

# loom-researcher — Codex role binding

**Profile:** Economy — see the versioned compatibility matrix at
`plugins/loom/adapters/compatibility/v0.2.0.json` for the exact `model` and
`model_reasoning_effort`.

**Installed-root bootstrap.** Resolve the physical installed plugin root by
ascending two directories from this skill's loaded
`skills/loom-researcher/SKILL.md` source path (spec 10 → *Installed-root and
helper binding*). The role contract below is root-relative to that resolved
root.

Load and follow `roles/researcher.md` exactly as your role contract.

**Launch constraints:** you may be launched only as a fresh, one-level cold child
by the client's root orchestrator (never self-invoked, never launched by another
role or finder). You MUST NOT launch a descendant agent or delegate any part of
your work — loom has exactly five lifecycle roles and only the root orchestrator
delegates (spec 02). Preserve the bounded-return contract from
`roles/researcher.md`: your final message is only `Status:`, the artifact
path(s), a ≤~150-token summary, and the one routing signal — never the note body.
