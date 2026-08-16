---
name: project_done_old_bug
description: Cert renewal bug — fixed and deployed 2026-06-20; nothing pending
metadata:
  type: project
---

Cert renewal bug (staging pods served an expired cert). Root cause: renewal cron wrote the new
cert but pods cached the old one. Fixed 2026-06-15, deployed to prod 2026-06-20, verified same
day. Nothing pending.

⚠️ Lesson: after renewing certs you MUST run `regen-certs.sh` — pods keep serving the old cert
from the in-memory cache until it runs. This applies to every future cert rotation, not just
this bug.
