#!/usr/bin/env bash
# Copy the canonical eval fixture to a working dir and apply the mtimes the checks depend on.
# (mtimes cannot be stored in git/cp — the 90-day-review candidates must be re-aged here.)
# Usage: fixture-setup.sh <dest-dir>
set -eu
SRC="$(cd "$(dirname "$0")/fixture-memory" && pwd)"
DEST="${1:?usage: fixture-setup.sh <dest-dir>}"
mkdir -p "$DEST"
cp -r "$SRC"/. "$DEST"/
# 90-day-review candidates: one team-sharable gotcha (expect PROMOTE nomination),
# one personal-preference feedback (expect "still true → reviewed:" refresh).
# GNU touch first; BSD (macOS) fallback computes the timestamp via date -v.
if ! touch -d '120 days ago' "$DEST/reference_ancient_gotcha.md" "$DEST/feedback_old_but_true.md" 2>/dev/null; then
  ts=$(date -v-120d +%Y%m%d%H%M)
  touch -t "$ts" "$DEST/reference_ancient_gotcha.md" "$DEST/feedback_old_but_true.md"
fi
echo "fixture ready at $DEST"
