---
name: reference_s3_retry
description: S3 retry backoff tuning (ships with the client retry-helpers bundle)
metadata:
  type: reference
---

Exponential backoff, base 400 ms. Tuned 2026-04-08 after throttling; re-measured 2026-05-22
after the SDK bump. Ships with the client retry-helpers (bundle) since v3.
