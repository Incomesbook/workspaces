# Current Stop Point

## Current status

Main control repo:
https://github.com/Incomesbook/workspaces

Latest confirmed pushed commit:
c208afb Add master workspace sync policy and dry-run tool

## GitHub repos visible now

- Incomesbook/workspaces = main control repo
- Incomesbook/Workspace = legacy duplicate placeholder, do not delete now
- Incomesbook/canada-tax-optimizer = separate living project
- Incomesbook/livecontrol-cleansource = empty private repo created, pause for now
- Incomesbook/signals = reserved/empty for now
- microsoft/vscode = external repo shown in GitHub dashboard, not ours

## What is now in place

- Projects Master Index
- Chats Master Index
- Automation Protection Map
- Master Restore Plan
- Sync Policy
- Master Workspace Sync Dry-Run Tool
- Igor Master Workspace
- LiveControl CleanSource registered in master workspace, but LiveControl work is paused

## Important decision

Stop LiveControl-only work.

The main objective is:
- one J-based workspace
- one main GitHub control repo
- protected chat layer
- protected Codex / Claude / VS Code automation
- project-by-project safe consolidation
- no blind deletes
- no blind full-drive Git push

## Protected chat roots

- J:\_AI_CHATS_ОБЩИЕ
- J:\Setup_VcCode_Workspace\S08_Shared_Global_AI_Chats
- J:\ClaudeData
- J:\ClaudeHub

## Protected automation

- ProjectChatAutomation.ps1
- Watch-JWorkspaceProjectBootstrap.ps1
- S06_Shared_Automation
- S02_AI_Chats.code-workspace
- MCP filesystem server for J:\_AI_CHATS_ОБЩИЕ

## Next phase

Create restore verification and controlled sync workflow.

No scheduled task yet.
No automatic delete.
No raw chat GitHub push.
