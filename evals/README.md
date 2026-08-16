# Skill evals (development only)

Eval suites for the skills shipped in [`plugins/`](../plugins/). They live outside the plugin
directories on purpose: `/plugin install` copies a plugin's entire directory to the user's
local cache, and there is no exclusion mechanism, so anything under `plugins/<name>/` ships to
every installer. End users don't need these fixtures.

Each directory mirrors one skill:

- `memory-gc/` — self-contained. Stage the fixture with `fixture-setup.sh <tmp-dir>` first;
  the 90-day-review checks depend on mtimes the setup script re-ages.
- `promote-knowledge/` — the sharing-filter assertions are self-contained, but the dedup-path
  assertions need a staged target repo whose docs already cover the two "already documented"
  fixture facts (see `fixture_note` in its `evals.json`).
