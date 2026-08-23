# Changelog

All notable changes to the memory-gc plugin are documented in this file. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the plugin adheres to
[Semantic Versioning](https://semver.org/).

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
  user setup: instead of rerunning memory-dir writes with the sandbox disabled, the skill now
  asks for a one-time sandbox write-allowlist entry
  (`"sandbox": {"filesystem": {"allowWrite": ["~/.claude/projects/*/memory"]}}` in
  `~/.claude/settings.json`). Disabling the sandbox remains the documented fallback.
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
