# AI Chat Agents Weekly Sync Dry-Run Plan

Mode: DRY-RUN ONLY.

Goal:
Prepare a safe weekly GitHub workflow without deleting files and without pushing raw chat history prematurely.

Phase 1 - current:
- Inventory all known AI chat roots.
- Count files without printing chat content.
- Identify roots already under the common chat root.
- Identify roots requiring a read-only copy/sync plan.
- Commit only small control docs to GitHub.

Phase 2 - next:
- Build a read-only manifest of selected roots.
- Build destination mapping into the common chat root.
- Run secret/size risk checks.
- Do not copy yet.

Phase 3 - after explicit approval:
- Copy or mirror only approved roots.
- Never delete originals.
- Never overwrite without backup/versioning.
- Generate manifest.

Phase 4 - after separate explicit approval:
- Create weekly scheduled task.
- Commit only approved safe content or manifests first.
- Raw chat sync to GitHub requires separate approval because chats may contain private data or secrets.