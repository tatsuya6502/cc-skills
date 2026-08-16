---
name: project_worklog_in_durable
description: Work log of the 2026-04 ingress build (day-by-day)
metadata:
  type: project
---

2026-04 ingress build work log.

- 04-02: created the ingress-nginx namespace, first deploy failed on RBAC.
- 04-03: RBAC fixed; cert-manager wired up.
- 04-08: cutover done; old LB deleted 04-10.

⚠️ Hard-won fact: on ingress-nginx < 1.9, a ConfigMap change is NOT hot-reloaded — you must
restart the controller pods or the old config keeps serving. Cost us half a day.
