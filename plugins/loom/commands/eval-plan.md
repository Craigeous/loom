---
description: One-off blind review of a research note or planning artifact
argument-hint: [artifact path]
---

# /loom:eval-plan

Load and follow the `loom-eval-plan` skill at
`${CLAUDE_PLUGIN_ROOT}/skills/loom-eval-plan/SKILL.md` exactly, treating its
root-relative references as relative to `${CLAUDE_PLUGIN_ROOT}`. Pass `$ARGUMENTS`
as the target. Launch the plan-evaluator role via the Task tool as
`loom:plan-evaluator`.
