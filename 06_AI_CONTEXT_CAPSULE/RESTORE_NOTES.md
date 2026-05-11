# RESTORE_NOTES

## Restore principle

GitHub repo Incomesbook/workspaces restores the control layer.

It does not restore all raw chats or all huge files by itself.

To restore full environment:
1. Clone Incomesbook/workspaces.
2. Restore J:\Setup_VcCode_Workspace structure.
3. Restore protected chat roots from backup/archive layer.
4. Restore project roots.
5. Run tools\Test-MasterWorkspaceRestoreState.ps1.
6. Open 01_WORKSPACES\Igor_Master_Workspace.code-workspace.
7. Read MASTER_STRUCTURE_AND_MEMORY_LOCK.md.
8. Read this AI Context Capsule.
9. Continue from NEXT_ACTIONS.md.

## Not finished yet

- full raw chat backup strategy
- web/Desktop export/import
- scheduled sync
- clean machine restore test
