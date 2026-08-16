---
name: reference_dup_b
description: Multipart upload chunk size must be 16 MiB (measured 2026-07 on SDK 2.5)
metadata:
  type: reference
---

Multipart upload chunk size must be 16 MiB. Measured 2026-07-20 after the SDK 2.5 upgrade — the
2.5 client doubles the internal buffer, so the old 8 MiB guidance no longer holds.
