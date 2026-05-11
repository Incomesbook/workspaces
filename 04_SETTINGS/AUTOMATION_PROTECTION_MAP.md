# Automation Protection Map

## Protected automation

Do not stop, delete, rewrite, or replace without separate explicit approval:

- ProjectChatAutomation.ps1
- Watch-JWorkspaceProjectBootstrap.ps1
- S06_Shared_Automation
- S02_AI_Chats.code-workspace
- Codex / Claude / VS Code project automation cycle
- MCP filesystem server for J:\_AI_CHATS_ОБЩИЕ

## Known protected paths

J:\Setup_VcCode_Workspace\S06_Shared_Automation\S06_02_Shared_Project_Chat_Automation\ProjectChatAutomation.ps1

J:\Setup_VcCode_Workspace\S06_Shared_Automation\S06_01_Shared_Project_Bootstrap\Watch-JWorkspaceProjectBootstrap.ps1

J:\Setup_VcCode_Workspace\S02_Shared_VSCode\S02_03_Shared_Project_Workspaces\S02_AI_Chats.code-workspace

J:\_AI_CHATS_ОБЩИЕ

## Rules

1. First audit.
2. No delete.
3. No overwrite.
4. No stopping automation unless requested.
5. No blind repo merge.
6. No pushing secrets or huge runtime files.
7. All project moves must preserve chat links and restore path.
