# AI_MEMORY

## Important memory

Igor wants all AI agents to understand that J:\Setup_VcCode_Workspace is the central local operating environment.

The main repo Incomesbook/workspaces is only the control/index/restore layer.

The full environment also depends on:
- local project roots
- local AI chat archives
- VS Code configuration
- Claude/Codex/Copilot/Gemini/Cursor history
- automation scripts
- private access folders
- restore manifests

## Main principle

Preserve continuity:
future AI must be able to read the structure, understand the project state, find chat history/indexes, and continue from the last point.

## Strict rules

- Read MASTER_STRUCTURE_AND_MEMORY_LOCK.md first.
- Read this capsule before changing J structure.
- Never delete or move folders blindly.
- Never push credentials/private files.
- Never push raw huge AI chats to normal Git.
