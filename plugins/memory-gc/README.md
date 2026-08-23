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

Trigger it with `/memory-gc`, or by explicitly asking for project-memory maintenance —
"run memory gc", "triage the project memory", "is the project-memory index consistent?". Requests
that merely sound adjacent (cleaning up a repo, disk, or chat history) are not triggers.
And even an unintended activation is harmless by design: the pass stops at the proposal
table and mutates nothing without your per-row approval.

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

`<memory-dir>/gc-config.txt` (optional) moves the weekly gc off its default Monday:

```text
# memory-gc per-project config
weekday=Friday
```

With the file or the `weekday=` key absent, the cadence stays on Monday. A gc run writes
`next due` as the next occurrence of the configured day and names that day in the gc-log
index line. Both files are deliberately non-`.md` so they stay out of memory scans and
recall.

## Sandbox setup (optional)

If you run Claude Code with the Bash sandbox enabled, archive moves (`mkdir`/`mv` into the
memory directory) fail with "Read-only file system" and get rerun with the sandbox disabled
— a per-run escalation that you approve each time. That default works fine as-is.

If you want to stop those prompts, you can allowlist a project's memory directory for
sandboxed writes in your user-level `settings.json` (see the
[Claude Code settings docs](https://code.claude.com/docs/en/settings) for its location).
This is an edit **you make yourself** — the skill instructs Claude never to edit
`settings.json`:

```json
{ "sandbox": { "filesystem": { "allowWrite": ["~/.claude/projects/<encoded-project>/memory"] } } }
```

Listing the concrete paths you actually garbage-collect is the least-privilege choice. A
wildcard (`~/.claude/projects/*/memory`) also works but widens sandboxed write access to
the memory directories of **all** your projects — the same files Claude's Write/Edit tools
can already edit without the sandbox, but memory files have no git history, so weigh the
convenience before choosing it.

## Requirements

Bash plus standard Unix tools (awk / grep / sed / stat / date). Works with both the GNU
(Linux) and BSD (macOS) userlands; strict-POSIX-only environments are not targeted.
