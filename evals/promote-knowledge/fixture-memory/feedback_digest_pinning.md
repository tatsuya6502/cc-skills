---
name: feedback_digest_pinning
description: Always pin container image digests (sha256) in k8s manifests instead of tags
metadata:
  type: feedback
---

Always pin container images by digest (`@sha256:...`) in Kubernetes manifests instead of
mutable tags. **Why:** tag-based deploys silently pick up new images; also some registries
don't support Knative's tag resolution. **How to apply:** when writing or reviewing manifests,
require a digest reference.
