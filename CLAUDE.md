# cc-skills

Claude Code plugin marketplace. Everything in this repo is published publicly on GitHub —
write all content (skills, docs, fixtures, commit messages) as publicly sharable: English
only, no private repository references, no internal project/crate names, no personal names
or machine-specific facts.

## Layout

```text
.claude-plugin/marketplace.json   # marketplace manifest — lists every plugin
plugins/<plugin>/                 # one directory per plugin (= the installed payload)
  .claude-plugin/plugin.json      # plugin manifest (name, version, license, ...)
  skills/<skill>/SKILL.md         # skills shipped by the plugin
  hooks/hooks.json                # hooks shipped by the plugin (optional)
  README.md
evals/<skill>/                    # eval suites + fixtures for the skills (dev only)
```

## Developing skills

- **Use the `skill-creator` skill** to create new skills, modify existing ones, and run
  evals — don't hand-roll SKILL.md structure or eval harnesses.
- Eval suites live in top-level `evals/<skill>/`, **never** inside `plugins/` —
  `/plugin install` copies a plugin's entire directory to every user's cache and has no
  exclusion mechanism, so anything under `plugins/` ships to installers.
- Shell scripts shipped in plugins must run on both Linux (glibc/GNU) and macOS (BSD
  userland): POSIX grep/sed only (no `grep -P`), GNU-first with BSD fallbacks for
  `stat`/`date`/`touch`, and locale-safe character counting (see
  `plugins/memory-gc/skills/memory-gc/scripts/lint.sh` for the established patterns).

## Before committing

- Run `claude plugin validate .` — it must pass.
- Grep your changes for private references (personal names, employer repo paths, internal
  tool names) before they enter history; scrubbing after a push is too late.
- Bump the plugin's `version` in both `plugin.json` and `marketplace.json` when releasing
  user-visible changes — installed copies only update when the version changes.

## Pull requests

CodeRabbit reviews every PR with its default configuration (no `.coderabbit.yaml`; the
conditions under which automatic review runs are at
https://docs.coderabbit.ai/configuration/auto-review). Included reviews per hour follow the
OSS tier and depend on the repo's star count — currently one — so batch fixes into fewer
pushes; comment `@coderabbitai rate limit` on a PR to check the remaining allowance without
consuming a review. Details: https://docs.coderabbit.ai/management/plans#rate-limits.
After a fix is pushed it re-reviews on its own and resolves the thread itself once satisfied;
that re-review may arrive as a PR comment rather than a review. If a review never posts,
re-trigger it. Replying "Please remember: ..." on a thread stores a durable learning; two are on
file: author attribution in manifests/LICENSE/README is intentional, and
`evals/*/fixture-memory/` is synthetic data that may look personal by design.
