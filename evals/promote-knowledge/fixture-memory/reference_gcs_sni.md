---
name: reference_gcs_sni
description: GCS behind an nginx proxy requires explicit SNI (proxy_ssl_server_name/proxy_ssl_name) or the TLS handshake fails
metadata:
  type: reference
---

When nginx proxies media requests to Google Cloud Storage, the Google front-end requires SNI:
without `proxy_ssl_server_name on;` and `proxy_ssl_name storage.googleapis.com;` the handshake
fails with a connection reset. Reproduces in any environment that fronts GCS with nginx —
nothing machine- or person-specific about it.
