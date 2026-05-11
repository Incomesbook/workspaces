# RESTORE_NOTES

## Restore role

This capsule helps restore the local J workspace architecture.

Minimum restore order:

1. Restore or recreate J:\Setup_VcCode_Workspace.
2. Clone Incomesbook/workspaces into:
   J:\Setup_VcCode_Workspace\S10_GitHub\workspaces
3. Restore S08_Shared_Global_AI_Chats from backup/archive layer.
4. Restore S06_Shared_Automation.
5. Restore S09_Shared_Private locally only.
6. Restore S20_Projects and J:\ПРОЕКТЫ project roots.
7. Open Igor_Master_Workspace.code-workspace.
8. Run tools\Test-MasterWorkspaceRestoreState.ps1.
9. Read MASTER_STRUCTURE_AND_MEMORY_LOCK.md.
10. Continue from NEXT_ACTIONS files.

## Not finished yet

- clean machine restore test
- full raw chat backup strategy
- export/import confirmation for ChatGPT, Claude, Copilot, Codex, Gemini, Cursor
- scheduled sync
