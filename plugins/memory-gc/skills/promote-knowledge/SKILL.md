---
name: promote-knowledge
description: >
  Human-adjudicated pass that graduates team-sharable technical knowledge OUT of Claude Code's
  private project memory INTO the repository's shared docs (CLAUDE.md / .claude/rules / README /
  docs). Use whenever the user asks to promote knowledge, graduate memories, share lessons with
  the team, asks "which of my memories
  should live in the repo?", or after a memory-gc run has produced PROMOTE nominations (the gc
  log lists them — offer to run this skill). Produces UNCOMMITTED diffs only and presents a
  proposal table FIRST; the user approves per row, and the user does every commit/PR themselves.
---

# promote-knowledge

Private project memory accumulates hard-won technical facts that would help the whole team, but
memory is invisible to everyone else. This skill moves the *sharable subset* into the repo —
with a human approving every fact and every destination, because a wrong promotion publishes
something personal or wrong to the entire team, and that is much worse than a memory staying
private one more week.

Sibling skill: `memory-gc` nominates candidates (PROMOTE rows in its triage table, recorded in
the gc log). This skill consumes those nominations — but can also run standalone with its own
scan.

## Ground rules

- **Sources: memory files only (v1).** Scan the project memory directory (Durable section +
  `archive/`) and the gc log's PROMOTE nominations. Never mine session transcripts — they hold
  secrets in plaintext (tokens, URLs, private discussion), and one leaked line in a repo doc is
  unrecoverable.
- **Memory dir** = the path shown in this session's "Memory" section of the system prompt (same
  rule as memory-gc; never hand-encode it from cwd).
- **Output = uncommitted working-tree edits.** Never commit, never push, never open a PR — the
  user reviews the diff and does all of that themselves.
- **The user approves every row.** Present the proposal table, then STOP. If running
  non-interactively, the table itself is the deliverable; edit nothing.
- **Repo docs are team-owned.** Match the target file's existing language, tone, and structure.
  A promoted fact must read like it was always part of the doc — no memory jargon, no
  `[[links]]`, no "the user said" attributions.

## Procedure

### Step 1 — Collect candidates

In priority order:

1. PROMOTE nominations from `project_memory_gc_log.md` (names listed per gc run) that are not
   yet marked promoted.
2. If no eligible nominations exist, or the user asks for a full scan: every Durable
   `lesson_*` / `reference_*` / `feedback_*` body, plus `archive/`
   entries whose INDEX line suggests durable technical content. Delegate bulk body-reading to
   one subagent (Sonnet/Opus) that returns per file: the core fact, environment-generality
   verdict, and any personal/private content it noticed.

### Step 2 — Sharing filter (the most important step)

Apply to every candidate, in this order. When in doubt, do not promote — a false negative costs
one more private week; a false positive publishes something personal to the team repo.

⛔ **Never promote** (drop at this gate, no exceptions):

- Personal names, teammates' availability / workload / health, reviewer capacity.
- Personal-workflow facts: private note directories, personal task managers, password managers,
  editor-specific setups, or any tool that exists only in the user's own setup.
- Facts specific to the user's own machines (their dev VM, their laptop) — sandbox quirks,
  local swap settings, personal directory layouts.
- Anything whose *why* can only be explained by referencing the above.

**Environment-generality test:** "Would this reproduce in ANY developer's environment?" A GCS
SNI requirement does; a workaround for one person's VM does not. If generality is unclear,
propose it with a `?` and say what would need verifying.

**Fact vs prescription:** A *fact* ("Knative resolves tags via the registry API; ECR is
unsupported") can be promoted on its own. A *prescription* ("always pin digests", "run X before
every PR") changes how teammates work, so it needs team consensus — still promotable, but flag
the row as `prescription` so the user knows to seek agreement in the PR description, and write
the doc text as a recommendation with its reason, not a bare command.

### Step 3 — Deduplicate against existing docs

For each surviving fact, search all canonical team-doc destinations before drafting: the
applicable root or directory-level `CLAUDE.md` files, `.claude/rules/`, and the component's
`README`/`docs/` — scoping any `rg` for the fact's key terms to those paths. A match in memory
files, eval fixtures, source code, or generated artifacts is NOT documentation and never counts
as "already documented". Outcomes:

- Already documented → drop (note "already in <path>" in the table).
- Documented but stale/contradicting → propose an UPDATE to that file instead of a new entry.
- Absent → new promotion.

### Step 4 — Choose the destination

| The fact is... | Destination |
|---|---|
| A constraint every component and every session must obey | root `CLAUDE.md` — the most expensive real estate (loaded always, for everyone); be very picky |
| A component-specific convention, procedure, or gotcha | `.claude/rules/<component>.md` — **must** carry `paths:` frontmatter scoping it (follow an existing scoped rules file's pattern) |
| Something you must not miss while working in one directory | that subdirectory's `CLAUDE.md` (e.g. `packages/<component>/CLAUDE.md`) |
| Explanation or background a human would read | component `README` / `docs/` |

A rules file **without** `paths:` frontmatter is loaded in every session — same cost as root
CLAUDE.md, multiplied by every teammate. Always scope, and keep a rough total byte budget in
mind for the always-loaded set: promotion should *save* team tokens (one shared doc instead of
N people rediscovering), not inflate every session.

### Step 5 — Draft diffs, present the table, STOP

Draft the actual edit for each fact (matching the target file's style and language). Present
one table:

`# | source memory | fact (1 line) | destination | kind (fact/prescription) | new/update | note`

…with the drafted text shown per row (short rows inline, long ones as a diff block below the
table). Then STOP and ask the user to approve / veto per row. Do not touch any repo file before
approval.

### Step 6 — Apply approved rows

1. Edit only the approved files (working tree only — no commit, no push, no PR, no staging).
2. Append to each promoted source memory's body:
   `promoted to <repo-path> (YYYY-MM-DD)` — the next memory-gc pass will see this and propose
   ARCHIVE for the memory.
3. Report the list of changed files and remind the user: review with `git diff`, then commit /
   PR themselves. For `prescription` rows, suggest one sentence for the PR description that
   asks the team to confirm the practice.
