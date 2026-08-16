#!/usr/bin/env bash
# memory-gc lint — mechanical consistency checks over a Claude Code project-memory directory.
# Usage: lint.sh [memory-dir]
#   No argument: derive the dir from $PWD (SessionStart-hook mode); exit silently if none exists.
# Output: findings prefixed "MEMORY-LINT:"; no output = clean. Always exits 0 (never blocks a session).
# Multi-file findings are aggregated into one line per check to keep hook output compact.

set -u
# ${#line} must count characters (not bytes) — Durable lines may contain Japanese.
# C.UTF-8 is glibc-only (older macOS lacks it; macOS offers en_US.UTF-8).
# Auto-pick the first UTF-8 locale available so character counts stay correct on
# both platforms; degrade to C (byte counts) if none exists.
utf8_loc() {
  for l in C.UTF-8 en_US.UTF-8; do
    if LC_ALL=$l locale charmap 2>/dev/null | grep -qi '^utf-8$'; then
      printf '%s\n' "$l"; return
    fi
  done
  printf 'C\n'
}
export LC_ALL=$(utf8_loc)

# .md link targets from stdin: "](slug.md)" -> "slug.md".
# POSIX grep/sed only — BSD grep (macOS) has no -P / \K support.
md_links() { grep -oE '\]\([^)]+\.md\)' | sed -e 's/^..//' -e 's/.$//'; }

# project_* memories allowed to live in Durable: still-referenced team/process facts.
# This script is global (one copy serves every project on the machine), so it carries NO
# per-project data: the built-in default covers only the gc log, which this skill creates in
# every project. Project-specific exemptions live in <memory-dir>/durable-allowlist.txt
# (one filename per line, '#' comments) — merged below after the memory dir is resolved.
# Extend an allowlist only with the user's OK (keep in sync with the SKILL.md ground rule).
DURABLE_PROJECT_ALLOWLIST="project_memory_gc_log.md"

MEMDIR="${1:-}"
if [ -z "$MEMDIR" ]; then
  # Hook mode: derive the encoded project dir from cwd. Worktree cwds encode to a
  # non-existent dir (memory lives under the main repo path) — stay silent there.
  ENC=$(printf '%s' "$PWD" | sed 's|[^A-Za-z0-9]|-|g')
  MEMDIR="$HOME/.claude/projects/${ENC}/memory"
  [ -d "$MEMDIR" ] || exit 0
fi

IDX="$MEMDIR/MEMORY.md"
if [ ! -f "$IDX" ]; then
  echo "MEMORY-LINT: MEMORY.md missing in $MEMDIR"
  exit 0
fi

cd "$MEMDIR" || exit 0
TODAY=$(date +%F)

# Merge the per-project Durable allowlist, if present. Non-.md on purpose: the file is lint
# config, not a memory — it must stay out of the *.md scans, the index, and recall.
if [ -f durable-allowlist.txt ]; then
  extra=$(awk '{sub(/\r$/,"")} /^[[:space:]]*#/ {next} NF {print $1}' durable-allowlist.txt | tr '\n' ' ')
  DURABLE_PROJECT_ALLOWLIST="$DURABLE_PROJECT_ALLOWLIST $extra"
fi

# 1. Orphan files: live memories not referenced anywhere in the index
for f in *.md; do
  [ "$f" = "MEMORY.md" ] && continue
  [ -e "$f" ] || continue
  grep -qF "($f)" MEMORY.md || echo "MEMORY-LINT: orphan (not indexed): $f"
done

# 2. Dead links: index references to files that do not exist
md_links < MEMORY.md | sort -u | while read -r f; do
  [ -f "$f" ] || echo "MEMORY-LINT: dead index link: $f"
done

# 3. Entries appended below the '## Archived' pointer (misfiled additions by other sessions)
awk '/^## Archived/{a=1;next} a && /^- \[/{print "MEMORY-LINT: entry below Archived section (re-file it): " substr($0,1,80)}' MEMORY.md

# 4. Archived files missing from archive/INDEX.md
if [ -d archive ]; then
  for f in archive/*.md; do
    b=$(basename "$f")
    [ "$b" = "INDEX.md" ] && continue
    grep -qF "($b)" archive/INDEX.md 2>/dev/null || echo "MEMORY-LINT: archived file not in archive/INDEX.md: $b"
  done
fi

# 5. Per-section entry budgets (primary size signal): Active ≤22 / Backlog ≤10 / Durable ≤45
awk '
  /^## Active/   {s="Active";  next}
  /^## Backlog/  {s="Backlog"; next}
  /^## Durable/  {s="Durable"; next}
  /^## Archived/ {s="";        next}
  s != "" && /^- \[/ {c[s]++}
  END {
    if (c["Active"]  > 22) print "MEMORY-LINT: Active section has "  c["Active"]  " entries (>22 budget) — finish or archive work items"
    if (c["Backlog"] > 10) print "MEMORY-LINT: Backlog section has " c["Backlog"] " entries (>10 budget) — prune stale ideas"
    if (c["Durable"] > 45) print "MEMORY-LINT: Durable section has " c["Durable"] " entries (>45 budget) — bundle / promote / archive"
  }' MEMORY.md

# 6. Whole-file size (auxiliary — the per-section budgets above are the primary signal)
lines=$(wc -l < MEMORY.md); bytes=$(wc -c < MEMORY.md)
[ "$lines" -gt 120 ] && echo "MEMORY-LINT: MEMORY.md is $lines lines (>120, auxiliary) — consider running /memory-gc"
[ "$bytes" -gt 20000 ] && echo "MEMORY-LINT: MEMORY.md is $bytes bytes (>20000, auxiliary) — consider running /memory-gc"

# Collect Durable-section entry lines / file links once for checks 7-9
DURABLE_LINES=$(awk '/^## Durable/{d=1;next} /^## /{d=0} d && /^- \[/' MEMORY.md)
DURABLE_FILES=$(printf '%s\n' "$DURABLE_LINES" | md_links | sort -u)

# 7. Durable index lines over 160 chars — running-history leaking into the index.
#    Lines whose link title contains "(bundle)" are exempt: bundle lines must keep every
#    trigger word of the memories they replaced, so they run long by design.
long=""
while IFS= read -r line; do
  [ -n "$line" ] || continue
  case "$line" in *"(bundle)"*) continue ;; esac
  if [ "${#line}" -gt 160 ]; then
    slug=$(printf '%s' "$line" | md_links | head -1)
    long="$long ${slug:-<no-link>}"
  fi
done <<EOF
$DURABLE_LINES
EOF
[ -n "$long" ] && echo "MEMORY-LINT: Durable line(s) >160 chars (move history into the body):$long"

# 8. Work-log project_* resident in Durable (outside the allowlist) — extract lessons, then archive
misplaced=""
for f in $DURABLE_FILES; do
  case "$f" in
    project_*)
      case " $DURABLE_PROJECT_ALLOWLIST " in
        *" $f "*) ;;
        *) misplaced="$misplaced $f" ;;
      esac
      ;;
  esac
done
[ -n "$misplaced" ] && echo "MEMORY-LINT: work-log project_* in Durable (extract lessons → archive):$misplaced"

# 9. Durable bodies untouched for >90 days — due for the 4-way review
#    (still true → append 'reviewed: YYYY-MM-DD' / PROMOTE / MERGE / ARCHIVE)
cutoff=$(( $(date +%s) - 90*86400 ))
due="" ; n=0
for f in $DURABLE_FILES; do
  [ -f "$f" ] || continue   # dead links already reported by check 2
  # GNU stat first, BSD stat (macOS) fallback
  m=$(stat -c %Y "$f" 2>/dev/null || stat -f %m "$f" 2>/dev/null || echo 0)
  if [ "$m" -gt 0 ] && [ "$m" -lt "$cutoff" ]; then
    due="$due $f" ; n=$((n+1))
  fi
done
[ -n "$due" ] && echo "MEMORY-LINT: Durable review due (mtime >90d, $n file(s); 4-way review at next gc):$due"

# 10. Weekly gc overdue (reads 'next due: YYYY-MM-DD' from the gc log's index line)
gcdue=$(grep -oE 'next due: [0-9]{4}-[0-9]{2}-[0-9]{2}' MEMORY.md | head -1 | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
if [ -n "${gcdue:-}" ] && [ "$TODAY" \> "$gcdue" ]; then
  echo "MEMORY-LINT: weekly memory-gc overdue (next due was $gcdue) — remind the user to run /memory-gc"
fi

# 11. Past-due ⏰ reminders sitting in the index
grep '⏰' MEMORY.md | while read -r line; do
  d=$(printf '%s' "$line" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)
  if [ -n "$d" ] && [ "$TODAY" \> "$d" ]; then
    echo "MEMORY-LINT: past-due ⏰ reminder: $(printf '%s' "$line" | cut -c1-100)"
  fi
done

exit 0
