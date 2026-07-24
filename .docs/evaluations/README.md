# Evaluations

Blind verdicts authored by the **plan evaluator** and **code evaluator**. One file
per artifact reviewed, named to parallel the artifact:

```
slice-plans/native-result-thread.md  →  evaluations/native-result-thread-eval.md
spec/02-roles.md                     →  evaluations/02-roles-eval.md
```

Keeping verdicts here (rather than inline in the artifact) keeps work files clean
and verdicts scannable. The artifact's own `## Notes` section is for *clarification
requests* between roles; the eval file is the *verdict*.

Verdicts are **blind**: the evaluator never sees author identity or author
reasoning — only the artifact and the authority it's judged against. Format and the
PASS/FAIL + severity rules are in
[../spec/05-blind-evaluation.md](../spec/05-blind-evaluation.md).

## Current program evaluations

- [macOS dogfood program amendment](macos-dogfood-program-amendment-eval.md) —
  planner-owned frozen-spec/program set; degraded bootstrap provenance until its
  protected publication settles.
- [ADR 0024 ratification](0024-macos-first-dual-client-dogfood-bootstrap-amendment-eval.md)
  and [owner acceptance](0024-macos-first-dual-client-dogfood-bootstrap-amendment-acceptance.md)
  — immutable authority for the private Apple-silicon checkpoint.
- [ci-baseline](ci-baseline-eval.md) and
  [review findings](ci-baseline-review-findings.md) — landed M0 evidence.
- [macOS dual-client dogfood plan](macos-dual-client-dogfood-plan-eval.md) —
  plan evaluation history (Approved).
- [macOS dual-client dogfood review findings](macos-dual-client-dogfood-review-findings.md)
  — orchestrator-run `/code-review` + `/security-review` findings feeding the blind
  code-evaluator as advisory input.
- [macOS dual-client dogfood code evaluation](macos-dual-client-dogfood-eval.md) —
  FAIL round 0 (harness injection-coverage + cleanup hardening) → fix → resolving
  PASS round 0; `Ready to Publish` pending ADR-0023 settlement.

See also [`../status/progress.md`](../status/progress.md) § "M0 errata" — the
record-keeping reconciliation of four early-stretch process deviations found by the
2026-07-24 program-design and implementation-audit reviews (non-uniform commit
identity, a merge commit, a PR-vs-`remote-direct` publication-mode mismatch, and an
incomplete ci-baseline evidence set).

All other files in this directory remain durable historical verdicts and are not
rewritten when a later decision supersedes their subject.
