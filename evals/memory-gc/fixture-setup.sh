#!/usr/bin/env bash
# Copy the canonical eval fixture to a working dir and apply the mtimes the checks depend on.
# (mtimes cannot be stored in git/cp — the 90-day-review candidates must be re-aged here.)
# Usage: fixture-setup.sh <dest-dir> [gc-config entries...]
# Each extra argument becomes a line of <dest-dir>/gc-config.txt: a bare word is a weekday
# (weekday=<word>), anything containing "=" is written as-is (e.g. bundle_cap=450). Omit them
# for the default fixture (no config file).
set -eu
SRC="$(cd "$(dirname "$0")/fixture-memory" && pwd)"
DEST="${1:?usage: fixture-setup.sh <dest-dir> [gc-config entries...]}"
shift
mkdir -p "$DEST"
cp -r "$SRC"/. "$DEST"/
if [ "$#" -gt 0 ]; then
  printf '# memory-gc per-project config\n' > "$DEST/gc-config.txt"
  for entry in "$@"; do
    case "$entry" in
      *=*) printf '%s\n' "$entry" >> "$DEST/gc-config.txt" ;;
      *)   printf 'weekday=%s\n' "$entry" >> "$DEST/gc-config.txt" ;;
    esac
  done
else
  # A reused dest must come out identical to a fresh default stage — drop any stale config.
  rm -f "$DEST/gc-config.txt"
fi
# 90-day-review candidates: one team-sharable gotcha (expect PROMOTE nomination),
# one personal-preference feedback (expect "still true → reviewed:" refresh).
# Absolute mtime (2026-05-01), not "N days ago": the gc-triage prompt pins its run date
# (2026-09-07), so an executor reasoning from that date and lint.sh reasoning from the real
# clock must both see these files as >90 days old, no matter when the suite is run.
# touch -t takes the same [[CC]YY]MMDDhhmm on GNU and BSD.
touch -t 202605010000 "$DEST/reference_ancient_gotcha.md" "$DEST/feedback_old_but_true.md"
echo "fixture ready at $DEST"
