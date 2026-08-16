---
name: reference_bc_default_feature
description: storage-connector's default cargo feature is gcs; S3 consumers must set default-features=false + features=["s3"]
metadata:
  type: reference
---

The storage-connector crate's default cargo feature is `["gcs"]`. Crates that need S3 must
depend on it with `default-features = false, features = ["s3"]` (the workspace root already
does this).
