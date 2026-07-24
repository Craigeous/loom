---
name: loom-research
description: One-off research pass — gather cited context into .docs/research/.
---

# loom-research

Run a single **researcher** pass, then stop (no chaining).

**Installed-root bootstrap.** Resolve your installed plugin root through your
client's adapter contract (spec 10 → *Installed-root and helper binding*) before
reading `skills/loom-playbook/references/orchestration.md` for the core rules;
references below are root-relative to that resolved root.

Topic: the workflow argument (if empty, infer the open need from
`.docs/status/handoff.md`).

1. Launch the **researcher** role (Economy profile). Run
   `bin/loom-launch-role <your-client> researcher` — the sole client role
   launcher (spec 10 → *Versioned compatibility and capability mapping*) — to
   derive/validate the exact tier from the tracked compatibility matrix and
   enforce a fresh, one-level, non-delegating cold child (Codex: this performs
   the cold launch itself; Claude: launch natively per `roles/researcher.md` /
   `agents/researcher.md` using its printed configuration). Give it the topic
   and where to look.
2. The role writes a **cited** note to `.docs/research/<date>-<slug>.md`
   (`Status: Research Review`) and commits author-neutral.
3. Verify the commit landed and is author-neutral; report the note path and that
   it's ready for `loom-eval-plan`.
