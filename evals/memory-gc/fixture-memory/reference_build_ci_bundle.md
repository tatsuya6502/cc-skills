---
name: reference_build_ci_bundle
description: Build & CI gotchas bundle — nextest retries, sccache region, macOS runner PATH, buildx cache mode, Gradle daemon heap
metadata:
  type: reference
---

Theme bundle (merged 2026-07-14 from five single-fact memories; back-links: [[reference_nextest_retry]],
[[reference_sccache_region]], [[reference_macos_runner_path]], [[reference_buildx_cache]], [[reference_gradle_heap]]).

- cargo nextest: pass `--retries 2` for the flaky integration group; measured 2026-06-02, flake rate 4 %.
- sccache: the S3 bucket must be in the same region as the runners or cache hits time out (2026-05-20).
- GitHub Actions macOS runners: `/opt/homebrew/bin` is not on PATH for `sh` steps; export it first.
- docker buildx: `--cache-to type=registry,mode=max` or layer cache misses on multi-stage builds.
- Gradle daemon on CI: set `org.gradle.jvmargs=-Xmx3g`; the 512 MiB default OOMs on the monorepo.
