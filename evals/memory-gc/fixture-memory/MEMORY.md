# Memory Index

## Active — in-progress work

- [Old bug fix](project_done_old_bug.md) — ✅ DONE 2026-06-20; cert renewal bug fixed and deployed.
- [Retry queue feature](project_done_but_pending_pr.md) — ✅ code done 2026-07-28; PR #421 review wait + prod apply remaining.
- [Ghost entry](project_ghost.md) — planted dead link.
- [License reminder](project_license_reminder.md) — ⏰ 2026-07-01 renew the scanner license.

## Backlog & ideas — not started / on hold

- [GitOps idea](project_idea_gitops.md) — not started; revisit after the August release.

## Durable — evaluations / lessons / feedback / reference

- [Upload chunk size A](reference_dup_a.md) — multipart upload chunk must be 8 MiB. 2026-05-02 first measured on staging; 2026-05-10 re-measured after SDK bump; 2026-06-01 confirmed again on prod-mirror; keep an eye on SDK release notes every month.
- [Upload chunk size B](reference_dup_b.md) — multipart upload chunk must be 16 MiB.
- [S3 retry backoff](reference_s3_retry.md) — exponential backoff base 400 ms; 2026-04-08 tuned after throttling; 2026-05-22 re-measured after SDK bump; ships with the client retry-helpers (bundle) since v3.
- [Broken CDN cache TTL entry — 2026-03-11 raised to 3600 s; 2026-04-02 lowered back to 600 s after the stale-asset incident; 2026-05-19 split per asset class; planted link-less overlong line.
- [k8s ingress build log](project_worklog_in_durable.md) — work log of the 2026-04 ingress build.
- [Registry mirror gotcha](reference_ancient_gotcha.md) — registry mirror needs explicit SNI or the TLS handshake fails.
- [Terse commit feedback](feedback_old_but_true.md) — The user prefers commit bodies under 5 lines.
- [Review shifts](project_team_norms_fact.md) — two review shifts; ping reviewers only during their shift (allowlisted team-process fact).
- [memory-gc log](project_memory_gc_log.md) — Weekly gc (Mondays, manual). last run: 2026-06-30; next due: 2026-07-06. If today > next due, remind the user to run /memory-gc.

## Archived

- Completed items live in [archive/](archive/INDEX.md) — not auto-loaded.
- [Misfiled entry](project_below_archived_note.md) — appended by another session, re-file me.
