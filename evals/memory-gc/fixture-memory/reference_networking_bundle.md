---
name: reference_networking_bundle
description: Networking lessons bundle — corporate proxy redirects, VPN MTU, split-horizon DNS, IPv6 on runners, wireguard keepalive
metadata:
  type: reference
---

Theme bundle (merged 2026-06-09 from five single-fact memories).

- Corporate proxy strips the Proxy-Authorization header on redirects, so pin the mirror URL
  instead of following redirects. First seen 2026-02-14; re-confirmed 2026-04-03 after the
  proxy upgrade.
- VPN MTU must be 1400 or large multipart uploads stall at 97 %.
- Split-horizon DNS returns the internal IP for *.corp only when the resolver is 10.0.0.53;
  TTL lowered to 60 s on 2026-05-19.
- IPv6 is disabled on the build runners since the 2026-03 outage.
- wireguard: keepalive 25 s, or NAT drops the tunnel after idle.

The index line for this bundle has grown into a compressed copy of this body (dates, values,
history) — planted as the over-cap bundle line for the lint and triage evals.
