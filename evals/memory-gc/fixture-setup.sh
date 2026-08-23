#!/usr/bin/env bash
# Copy the canonical eval fixture to a working dir and apply the mtimes the checks depend on.
# (mtimes cannot be stored in git/cp — the 90-day-review candidates must be re-aged here.)
# Usage: fixture-setup.sh <dest-dir> [gc-weekday]
# The optional second argument writes <dest-dir>/gc-config.txt with weekday=<gc-weekday>,
# staging the configured-weekday eval path; omit it for the default-Monday fixture.
set -eu
SRC="$(cd "$(dirname "$0")/fixture-memory" && pwd)"
DEST="${1:?usage: fixture-setup.sh <dest-dir> [gc-weekday]}"
WEEKDAY="${2:-}"
mkdir -p "$DEST"
cp -r "$SRC"/. "$DEST"/
if [ -n "$WEEKDAY" ]; then
  printf '# memory-gc per-project config\nweekday=%s\n' "$WEEKDAY" > "$DEST/gc-config.txt"
else
  # A reused dest must come out identical to a fresh default stage — drop any stale config.
  rm -f "$DEST/gc-config.txt"
fi
# 90-day-review candidates: one team-sharable gotcha (expect PROMOTE nomination),
# one personal-preference feedback (expect "still true → reviewed:" refresh).
# GNU touch first; BSD (macOS) fallback computes the timestamp via date -v.
if ! touch -d '120 days ago' "$DEST/reference_ancient_gotcha.md" "$DEST/feedback_old_but_true.md" 2>/dev/null; then
  ts=$(date -v-120d +%Y%m%d%H%M)
  touch -t "$ts" "$DEST/reference_ancient_gotcha.md" "$DEST/feedback_old_but_true.md"
fi
echo "fixture ready at $DEST"
