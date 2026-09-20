---
name: Post-merge hook configuration
description: Workspace-specific constraint for configuring the automatic setup that runs after task merges.
---

Configure post-merge hooks through the platform's post-merge configuration API or validated replacement flow; direct edits to `.replit` are rejected.

**Why:** The workspace validates `.replit` changes through the platform so post-merge configuration remains schema-safe.

**How to apply:** Use the post-merge setup skill's configuration callback to set the script path and timeout, then run the setup once to verify both the script and workflow reconciliation.