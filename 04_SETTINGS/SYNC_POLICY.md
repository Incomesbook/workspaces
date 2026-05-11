# Sync Policy

## Main rule

This repository is the control layer, not a dump of the whole J drive.

Main repo:
J:\Setup_VcCode_Workspace\S10_GitHub\workspaces
https://github.com/Incomesbook/workspaces

## What can be synced to GitHub workspaces repo

Allowed:
- markdown indexes
- workspace files
- restore plans
- automation maps
- small scripts
- project manifests
- chat manifests
- configuration notes

Not allowed:
- raw AI chat jsonl
- sqlite databases
- videos
- installers
- archives
- .venv
- node_modules
- old .git folders
- secrets
- API keys
- token files
- password files

## Protected chat roots

- J:\_AI_CHATS_ОБЩИЕ
- J:\Setup_VcCode_Workspace\S08_Shared_Global_AI_Chats
- J:\ClaudeData
- J:\ClaudeHub

Chats must not disappear.
Chats must be indexed first.
Raw chats should be backed up by a separate archive/backup layer, not blindly pushed to GitHub.

## Protected automation

- ProjectChatAutomation.ps1
- Watch-JWorkspaceProjectBootstrap.ps1
- S06_Shared_Automation
- S02_AI_Chats.code-workspace
- MCP filesystem server for J:\_AI_CHATS_ОБЩИЕ

## Sync rhythm

Recommended:
- weekly or biweekly control repo sync
- first always run dry-run
- then commit/push only small safe control files
- never auto-push huge files
- never auto-delete anything

## Next stage

Create dry-run reports first.
Only after dry-run is stable, create the real controlled sync script.
