---
name: memory-gc
description: >
  Weekly, human-adjudicated garbage-collection pass over Claude Code's file-based project memory
  (MEMORY.md index + one-fact-per-file directory). Use whenever the user asks to run memory gc,
  clean up / tidy / triage project memory, check memory
  consistency ("is the memory consistent?", "is the index out of sync?"), asks why a memory was not
  recalled, or when the gc log's next-due date has passed (offer to run it). Also covers quick
  lint-only checks — run scripts/lint.sh without the full pass. Proposes all changes in a triage
  table FIRST and applies them only after the user approves in this conversation; never deletes
  files without explicit permission.
---

# memory-gc

Weekly gardening pass for the project memory. The design adapts batch-dedup / TTL-cleaner /
tier-promotion ideas from agent-memory systems to a file-based store with **human adjudication**
instead of LLM-automatic merge (files here have no git history — a wrong merge or delete is
unrecoverable, so a person approves every mutation).

## Ground rules

- **Memory dir** = the path shown in this session's "Memory" section of the system prompt. Never
  compute the encoded path from cwd yourself — worktrees share the main repo's memory dir and
  hand-encoding gets this wrong.
- **Move, never delete.** Archiving = `mv` into `archive/` + a line in `archive/INDEX.md`. Deleting
  a file requires the user's explicit permission for that specific file, every time.
- **Markers are hints, not verdicts.** Measured on the 2026-07-12 initial pass: of 33 index lines
  carrying DONE/✅/closed markers, fewer than half were actually archivable — most were
  "✅ done + remaining PR/prod-apply" or carried durable warnings. Always read the body before
  proposing anything. Grep can nominate candidates; it cannot adjudicate them.
- **Index lines stay lean**: English, one line per memory, ideally under ~500 characters. Running
  history belongs in the memory body; if an index line has grown into a changelog, first confirm
  the body contains the details (append them if not), then condense the line.
- **Durable is not a work-log shelf.** A `project_*` memory may sit in Durable only when it
  records a still-referenced fact about how the team or its processes work — e.g.
  `team_remote_flextime`, `deploy_approval_policy`, `memory_gc_log`. The exemption
  list is per-project data, so it lives in `<memory-dir>/durable-allowlist.txt` (one filename
  per line, `#` comments; deliberately not a `.md` so it stays out of the memory scans and
  recall) — lint.sh itself carries only the universal `project_memory_gc_log.md` default and
  must never hardcode project-specific names (it is one global script serving every project
  on the machine). Extend the allowlist only with the user's OK. Work-log-derived
  project memories go through Step 3 (lesson extraction) and are then ARCHIVED. Extraction is
  the *precondition* of the archive, not an alternative to it — once the lessons are out, the
  source body moves to `archive/`. Demoting a work log into Durable is not an escape hatch.
- **Sandbox note**: Bash writes to the memory dir (mkdir/mv/chmod) are outside the sandbox write
  allowlist — expect "Read-only file system" and rerun those commands with sandbox disabled.
  The Write/Edit tools are not affected.
- **Token economy**: when more than ~10 bodies need reading, delegate the reads to one subagent
  (Sonnet/Opus) that returns per-file: status, pending items (verbatim), durable knowledge,
  archive-safety verdict. Keep the final adjudication in the main session.

## Procedure

### Step 0 — Lint (mechanical checks, no judgment)

```bash
bash <this-skill's-directory>/scripts/lint.sh <memory-dir>
```

Silent output = clean. Findings are prefixed `MEMORY-LINT:`. Multi-file findings (long lines,
review-due, misplaced project_*) are aggregated into one line per check so the SessionStart hook
stays compact — during a gc pass, unpack those lists into per-file triage rows. The plugin ships
a SessionStart hook that runs this script automatically (no argument: it derives the memory dir
from cwd and stays silent when there is none), so during a gc run this mainly re-confirms state
before and after applying changes.

### Step 1 — Metrics

Report and compare against the previous run (recorded in `project_memory_gc_log.md`):
live file count, MEMORY.md lines and bytes, archive count, count of lines per section.

### Step 2 — Triage

Walk every index entry. For each candidate (marker hit, stale date, wrong section, or anything
lint flagged), read the body, then classify:

| Proposal | Meaning |
|---|---|
| ARCHIVE | Fully done / superseded / externally tracked; nothing pending owned by this memory |
| MOVE | Wrong section (e.g., done-ish work sitting in Active; durable fact stuck in Active) |
| MERGE | Duplicate or contradicting pair — propose the merged text. Theme bundling (below) is also proposed as MERGE rows |
| UPDATE | Body or index line is factually stale (verify external state first: `gh pr view` for PR memories, etc. — needs sandbox off) |
| PROMOTE | Team-sharable technical knowledge nominated for graduation into repo docs. gc only *nominates* — the promotion itself runs as a separate promote-knowledge pass with its own sharing filter, so err on the side of nominating |
| DELETE? | Self-obsoleting memory past its purpose (reminders after handoff). Requires explicit user OK |
| KEEP | Candidate examined, stays as is — record why so next gc skips the re-read |

TTL guidelines (from the maintenance plan):

- project + DONE ≥14 days (or handed off to a GitHub Issue/PR): propose ARCHIVE.
- Epics: keep until the epic closes, then extract lessons → ARCHIVE.
- ⏰ reminders: past-due must be flagged to the user, never silently archived.
- Evaluations: keep in Durable with a re-eval date; archive when superseded.
- feedback / reference / lesson (and allowlisted Durable project facts): body mtime > 90 days
  triggers a **4-way review** — the point is that "durable" is a claim to re-verify, not a
  permanent exemption. lint.sh lists the candidates (`review due (mtime >90d)`). For each one:
  - **still true** → append `reviewed: YYYY-MM-DD — still true` as the body's last line (the
    write refreshes mtime, deferring it one cycle); no index change needed.
  - **PROMOTE** → nominate for promote-knowledge (see triage table).
  - **MERGE** → fold into a sibling or theme bundle.
  - **ARCHIVE** → no longer true or no longer worth its index line.
- Dated work-log memories: always ARCHIVE candidates.

### Step 3 — Lesson extraction (before archiving)

Scan each ARCHIVE candidate's body for ⚠️ / ⛔ / "Lesson" / hard-won config facts. Anything still
useful after the task dies gets its own file BEFORE the archive move:

- `lesson_<slug>.md` (metadata type: feedback) for failure-derived rules, using:

  ```markdown
  **Failure:** what went wrong, dated
  **Why:** root cause
  **How to apply:** the rule going forward (⛔ for hard prohibitions)
  Extracted YYYY-MM-DD (memory gc) from [[source-memory]] — details in archive/.
  ```

- `reference_<slug>.md` for procedures/config facts.

Project memories die; lessons survive.

### Step 4 — Present the proposal table and STOP

Show one table: `# | memory | section | proposal | reason (1 line)` — most impactful first,
KEEPs collapsed at the bottom. Then stop and ask the user to approve / veto per row (or
"all except N"). Do not touch any file before this. If running non-interactively (no user
available), output the table as the deliverable and apply nothing.

### Step 5 — Apply approved rows only

1. `mkdir -p <memory-dir>/archive` and `mv` approved files (sandbox off).
2. Append one line per file to `archive/INDEX.md`: `- [Title](file.md) — final state (archived YYYY-MM-DD)`.
3. Update MEMORY.md: remove archived lines, add extraction lines to Durable, apply approved
   MERGE/UPDATE/section moves. Keep untouched lines verbatim — churn hides real changes.
4. Re-run lint.sh; it must come back clean.
5. Report before/after metrics.

### Step 6 — Record the run

Update `project_memory_gc_log.md` (create from the template below if missing) AND its index line.
The index line must carry both dates — the SessionStart hook and other sessions read it there:

```
- [memory-gc log](project_memory_gc_log.md) — Weekly gc (Mondays, manual). last run: YYYY-MM-DD; next due: YYYY-MM-DD. If today > next due, remind the user to run /memory-gc.
```

next due = the Monday after the run date. In the body, append one line per run:
`YYYY-MM-DD: archived N, extracted M lessons, nominated P for promotion, index X lines / Y KB (was X'/Y'). Notes: ...`

List the approved PROMOTE nominations by name in the gc log body — they are the input queue for
the next promote-knowledge run, and that run may happen in a different session.

## Index layout (target state)

```markdown
# Memory Index
## Active — in-progress work                                 ≤22 entries
## Backlog & ideas — not started / on hold                   ≤10 entries
## Durable — evaluations / lessons / feedback / reference    ≤45 entries
## Archived
- Completed items live in [archive/](archive/INDEX.md) — not auto-loaded.
```

Every entry belongs to exactly one section; nothing below the Archived pointer. Only Active
lines may contain "next actions". New memories written by other sessions often get appended to
the bottom of the file — lint flags these; re-file them into the right section.

The per-section budgets are the primary size signal (lint enforces them); the whole-file
line/byte thresholds are auxiliary. The index is loaded into every session, so each line is a
recurring token cost — a line has to earn its keep.

### Theme bundling (Durable)

Recall reads **only MEMORY.md**. Verified experimentally 2026-08-16: a planted memory file with
a near-verbatim `description:` was never recalled while unindexed. (Harness-version-dependent —
if the recall mechanism changes, re-verify before relying on this.) Two consequences:

- A memory dropped from the index is effectively lost. Never split the index into hot/cold
  tiers — the "cold" tier would be invisible.
- Several single-fact Durable lines on one theme can be bundled into ONE themed file with ONE
  index line. This is safe **only if the index line keeps every trigger word** from the lines it
  replaces: the index line is the sole recall surface, so a dropped keyword is a lost recall
  path. Bundle lines therefore run long by design.

Mark bundle lines by putting `(bundle)` in the link title — lint exempts such lines from the
160-char length check. Propose each bundling as MERGE rows in the triage table (one row per
absorbed memory) and apply only after approval. Mechanics follow "move, never delete": write the
new bundle file (one theme, full bodies merged, `[[old-name]]` back-links kept), then `mv` the
absorbed originals into `archive/` with INDEX.md lines noting "merged into <bundle>". Sizing
guideline from a real 2026-08-16 pass: bundles of 3–5 same-theme lines each collapsed ≈19 index
lines into 5.
