---
name: reference_release_ops_bundle
description: Release and deploy operations bundle — tagging, changelog, canary, rollback, artifact signing, feature flags, SBOM, status page
metadata:
  type: reference
---

Theme bundle (merged 2026-08-03 from eight single-fact memories).

- Release tags are `vMAJOR.MINOR.PATCH` on the merge commit, never on a branch head; CI
  (`release.yml`) refuses an unsigned tag.
- CHANGELOG.md is generated from PR titles — a PR without a `type(scope):` title lands in
  "Uncategorized".
- Canary rollout: 5 % for 30 minutes, then 50 %, then 100 %; the canary analysis reads the
  `error_rate_5m` and `p99_latency_ms` SLO queries.
- Rollback is `deploy rollback --to <previous-tag>` — re-running the old pipeline is slower and
  re-signs the artifact under a new key id.
- Artifacts are signed with cosign (keyless, OIDC); the verification step needs the
  `--certificate-identity-regexp` flag or it rejects every build.
- Feature flags live in `flags.yaml`; a flag deleted from the file is treated as OFF, not as
  removed, until the next full deploy.
- SBOM (`sbom.spdx.json`) is attached to every release; the scanner gate fails on CRITICAL only.
- The status page is updated by hand after a rollback — nothing posts there automatically.

This bundle's index line is a keyword hook for eight memories and exceeds the default 300-char
cap — planted as the second over-cap bundle line for the lint and triage evals.
