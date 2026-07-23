---
description: Run the loom dev loop — detect state, take scope/gates, drive the roles
argument-hint: "[scope]   e.g. /loom:run slice  ·  /loom:run plan"
model: sonnet
---

# /loom:run — orchestrator

Load and follow the `loom-run` skill at
`${CLAUDE_PLUGIN_ROOT}/skills/loom-run/SKILL.md` exactly, treating its
root-relative references as relative to `${CLAUDE_PLUGIN_ROOT}`. Pass `$ARGUMENTS`
as the requested scope (if empty, the skill asks). Launch role agents via the Task
tool as `loom:<role>` per spec 07's role-launch mapping.
