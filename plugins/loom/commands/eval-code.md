---
description: One-off blind review of an implemented slice's code
argument-hint: [slice]
---

# /loom:eval-code

Load and follow the `loom-eval-code` skill at
`${CLAUDE_PLUGIN_ROOT}/skills/loom-eval-code/SKILL.md` exactly, treating its
root-relative references as relative to `${CLAUDE_PLUGIN_ROOT}`. Pass `$ARGUMENTS`
as the target. Launch the code-evaluator role via the Task tool as
`loom:code-evaluator`.
