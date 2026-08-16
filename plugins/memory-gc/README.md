# memory-gc plugin

Weekly, human-adjudicated maintenance for Claude Code's file-based project memory
(the `MEMORY.md` index + one-fact-per-file directory under
`~/.claude/projects/<encoded-path>/memory/`).

Everything here follows one principle: **memory files have no git history, so no mutation
happens without a human approving it.** Both skills stop at a proposal table and apply only
the rows you approve.

## What's included

### `memory-gc` skill

A weekly "gardening" pass over the project memory:

1. **Lint** — mechanical consistency checks (`scripts/lint.sh`): dead/orphan index links,
   per-section entry budgets, overlong Durable lines, work-log memories parked in Durable,
   90-day review-due bodies, overdue gc runs and ⏰ reminders.
2. **Triage** — every index entry is classified (ARCHIVE / MOVE / MERGE / UPDATE / PROMOTE /
   DELETE? / KEEP) with the body read before any proposal.
3. **Lesson extraction** — durable knowledge is distilled out of a memory *before* it is
   archived. Project memories die; lessons survive.
4. **Move, never delete** — archiving is `mv` into `archive/` plus an index line; deletion
   always requires explicit per-file permission.

Trigger it with `/memory-gc`, or by asking for a memory cleanup / consistency check.

### `promote-knowledge` skill

Graduates *team-sharable* technical knowledge out of private memory into the repository's
shared docs (`CLAUDE.md` / `.claude/rules/` / `README` / `docs/`). A strict sharing filter
drops anything personal, machine-specific, or attribution-bound; output is uncommitted
working-tree edits only — you review the diff and commit yourself.

### SessionStart hook

Runs `lint.sh` at session start. With no argument the script derives the memory directory
from the current working directory — resolving a git worktree to its main repository path,
since all worktrees share the main repo's memory — and exits silently when none exists, so
the hook is a no-op in projects without memory. Findings appear as `MEMORY-LINT:` lines. The script always
exits 0 and never blocks a session.

## Install

```text
/plugin marketplace add tatsuya6502/cc-skills
/plugin install memory-gc@cc-skills
```

## Per-project configuration

`<memory-dir>/durable-allowlist.txt` (optional, one filename per line, `#` comments) lists
`project_*` memories allowed to stay in the Durable section — still-referenced facts about how
your team or its processes work. `lint.sh` itself only knows the universal
`project_memory_gc_log.md` default.

## Requirements

Bash plus standard Unix tools (awk / grep / sed / stat / date). Works with both the GNU
(Linux) and BSD (macOS) userlands; strict-POSIX-only environments are not targeted.
