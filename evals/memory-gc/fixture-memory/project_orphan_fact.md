---
name: project_orphan_fact
description: Orphaned fact — exists on disk but is not referenced from MEMORY.md
metadata:
  type: project
---

This memory was written by another session that forgot to add an index line. The gc pass should
detect it as an orphan and propose re-indexing (or archiving) it.
