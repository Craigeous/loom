---
description: One-off planning pass — advance an ADR, spec, or slice-plan
argument-hint: [what to plan]
---

# /loom:plan

Load and follow the `loom-plan` skill at
`${CLAUDE_PLUGIN_ROOT}/skills/loom-plan/SKILL.md` exactly, treating its
root-relative references as relative to `${CLAUDE_PLUGIN_ROOT}`. Pass `$ARGUMENTS`
as the focus. Launch the planner role via the Task tool as `loom:planner`.
