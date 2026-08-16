---
name: lesson_vm_swap
description: 16 GiB swap on my GCP dev VM stops cargo test OOM kills; keep CARGO_BUILD_JOBS=2
metadata:
  type: feedback
---

**Failure:** cargo test runs were OOM-killed on my e2-highmem dev VM (2026-05).
**Why:** 16 GiB RAM is not enough for parallel rustc + test binaries on this particular VM.
**How to apply:** the VM now has a 16 GiB swapfile (created manually) and CARGO_BUILD_JOBS=2 in
my shell profile. Re-create the swapfile after VM rebuilds.
