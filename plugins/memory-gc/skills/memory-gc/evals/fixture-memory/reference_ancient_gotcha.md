---
name: reference_ancient_gotcha
description: Registry mirror behind TLS needs explicit SNI (proxy_ssl_server_name on) or the handshake fails
metadata:
  type: reference
---

When proxying a container-registry mirror through nginx, the upstream front-end requires SNI:
set `proxy_ssl_server_name on;` (and `proxy_ssl_name`) or the TLS handshake fails with a
generic reset. Reproduces in any environment that fronts the mirror with nginx — not specific
to one machine or one person's setup.
