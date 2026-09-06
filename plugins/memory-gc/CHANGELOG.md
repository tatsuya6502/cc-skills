# Changelog

All notable changes to the memory-gc plugin are documented in this file. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the plugin adheres to
[Semantic Versioning](https://semver.org/).

## [1.0.2] - 2026-09-06

### Fixed

- Removed the sandbox `allowWrite` guidance from SKILL.md and the README: it never worked.
  `~/.claude/projects/` is a built-in *protected path* of the Bash sandbox, and per the
  official sandboxing docs no `allowWrite` entry lifts that protection — only
  `filesystem.disabled` does, which drops filesystem isolation for every path and is not
  recommended. The skill now simply reruns a refused `mkdir`/`mv` with the sandbox disabled
  and says so in its report; under strict sandbox mode it reports the failed moves and stops
  ([#9](https://github.com/tatsuya6502/cc-skills/issues/9)). Doing the archive moves with the
  Write/Edit tools instead was considered and rejected: removing the original still needs a
  Bash `rm` on the same protected path, so it would not avoid the unsandboxed step.

## [1.0.1] - 2026-08-23

### Changed

- Hardened the sandbox-setup guidance after a SkillSpector AS1 finding: the
  `settings.json` allowlist entry is now explicitly a manual change the user makes outside
  the session (the skill instructs Claude never to edit `settings.json`), the concrete
  per-project path replaced the wildcard as the least-privilege default recommendation
  (the wildcard stays documented as a multi-project convenience with its trade-off), and
  the per-run sandbox-disabled rerun is presented first as the no-setup path.

## [1.0.0] - 2026-08-23

### Added

- Optional per-project `<memory-dir>/gc-config.txt` makes the weekly gc weekday configurable
  (`weekday=Friday`). With the file or the `weekday=` key absent, behavior is unchanged
  (Monday), and the gc-log index line names the configured day
  ([#5](https://github.com/tatsuya6502/cc-skills/issues/5)).
- Eval case covering the configured-weekday path (`gc-weekday-config`), staged via a new
  optional weekday argument to `fixture-setup.sh`.
- This changelog.

### Changed

- Sandbox guidance rewritten — the reason for the major bump, since it changes recommended
  user setup: instead of always rerunning memory-dir writes with the sandbox disabled, the
  docs now describe a one-time, user-made sandbox write-allowlist entry for the memory
  directory in the user-level `settings.json`. The per-run sandbox-disabled rerun remains
  the documented fallback. (Wording further hardened in 1.0.1.)
- Narrowed natural-language trigger wording to explicit project-memory phrasing, for both
  memory-gc (README) and promote-knowledge (skill description) — addresses the two
  SkillSpector SQP-1 (broad-trigger) findings.
- README now notes that even an unintended activation is harmless by design: every pass stops
  at the proposal table and mutates nothing without per-row human approval.

## [0.1.1] - 2026-08-22

### Fixed

- Lint check 7's `(bundle)` exemption from the 160-char Durable line-length check now applies
  only when `(bundle)` appears in the link title, not anywhere in the line; the empty-slug
  guard no longer lets link-less long lines bypass the check
  ([#4](https://github.com/tatsuya6502/cc-skills/pull/4)).
- Durable-allowlisted files are exempt from the line-length check (their template-mandated
  index lines legitimately exceed it).

### Changed

- SKILL.md clarifies the index-line length rules and sets expectations for the first run on an
  established memory set.

## [0.1.0] - 2026-08-16

### Added

- Initial release: the `memory-gc` skill (weekly, human-adjudicated triage of the file-based
  project memory), the `promote-knowledge` skill (graduating team-sharable knowledge from
  private memory into repo docs), and a SessionStart hook running `lint.sh`'s mechanical
  consistency checks.
